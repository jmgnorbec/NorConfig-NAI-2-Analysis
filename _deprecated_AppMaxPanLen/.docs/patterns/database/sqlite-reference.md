# SQLite Setup Pattern

**Pattern Type:** Database Configuration  
**Complexity:** Simple  
**Best For:** Single-user apps, local tools, development/testing, embedded applications

---

## Overview

SQLite is a lightweight, embedded SQL database engine stored in a single file. It requires no separate server process and is perfect for applications that need a local database without operational overhead.

### When to Use SQLite

**✅ Use SQLite when:**
- Building desktop/mobile applications
- Single-user or low-concurrency scenarios
- Local development and testing
- Prototyping before scaling to PostgreSQL
- Application cache or local data store
- No network database setup required
- Database size under 1TB
- Read-heavy workloads

**❌ Don't use SQLite when:**
- High write concurrency needed (>100 concurrent writers)
- Network filesystem required (NFS, SMB)
- Multiple servers need access to same database
- Very large datasets (>multiple TB)
- High-traffic production web applications (consider PostgreSQL)

---

## Essential PRAGMA Settings

SQLite requires specific PRAGMA statements on **every connection** to enable critical features and optimize performance.

### Required PRAGMAs

| PRAGMA | Value | Purpose | Impact |
|--------|-------|---------|--------|
| `journal_mode` | `WAL` | Write-Ahead Logging | Readers don't block writers, better concurrency |
| `foreign_keys` | `ON` | Enable FK enforcement | **OFF by default!** Must enable per connection |
| `synchronous` | `NORMAL` | Disk sync frequency | Safe with WAL, faster than FULL |
| `cache_size` | `-64000` | Page cache (KB) | 64MB cache, improves read performance |
| `temp_store` | `MEMORY` | Temp table storage | Store temp tables in RAM for speed |

### Why These Matter

**`journal_mode=WAL` (Write-Ahead Logging):**
- Default is DELETE mode (readers block writers, writers block readers)
- WAL mode: readers never block writers, writers never block readers
- Creates `-wal` and `-shm` files alongside database file
- **Critical for any multi-threaded application**

**`foreign_keys=ON`:**
- **SQLite disables foreign key enforcement by default!**
- Must enable on every connection
- Without this: CASCADE deletes don't work, orphaned records possible

**`synchronous=NORMAL`:**
- Default is FULL (very slow, fsync after every commit)
- NORMAL is safe with WAL mode
- Balances data safety with performance

---

## SQLAlchemy Setup Pattern

### Basic Configuration

**`app/database.py`** - SQLAlchemy engine with PRAGMA listeners

```python
from collections.abc import Generator
from sqlalchemy import create_engine, event
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker
from app.config import get_settings

settings = get_settings()

# Create engine
engine = create_engine(
    settings.database_url,  # "sqlite:///./app.db"
    connect_args={"check_same_thread": False},  # Allow multi-threading
    echo=settings.debug,  # Log SQL queries in debug mode
)


@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    """
    Apply SQLite optimizations on every connection.
    
    Critical: SQLite PRAGMAs are per-connection, not per-database.
    This event listener runs when SQLAlchemy creates a new connection.
    """
    cursor = dbapi_connection.cursor()
    
    # Essential PRAGMAs
    cursor.execute("PRAGMA journal_mode=WAL")       # Write-Ahead Logging
    cursor.execute("PRAGMA foreign_keys=ON")        # Enable FK enforcement
    cursor.execute("PRAGMA synchronous=NORMAL")     # Safe with WAL
    cursor.execute("PRAGMA cache_size=-64000")      # 64MB page cache
    cursor.execute("PRAGMA temp_store=MEMORY")      # Temp tables in RAM
    
    # Optional: Additional performance tuning
    # cursor.execute("PRAGMA mmap_size=268435456")  # 256MB memory-mapped I/O
    # cursor.execute("PRAGMA busy_timeout=5000")    # Wait 5s for locks
    
    cursor.close()


class Base(DeclarativeBase):
    """SQLAlchemy declarative base class."""
    pass


# Session factory
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db() -> Generator[Session, None, None]:
    """
    FastAPI dependency for database sessions.
    
    Usage:
        @app.get("/habits")
        def list_habits(db: Session = Depends(get_db)):
            return db.query(Habit).all()
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

**Key concepts:**
- **`check_same_thread=False`**: Required for multi-threaded apps (FastAPI, Flask)
- **`echo=True`**: Print SQL queries (useful for debugging)
- **Event listener**: Runs on every new connection
- **SessionLocal**: Factory for creating sessions
- **get_db()**: FastAPI dependency, auto-closes session

---

### Configuration File

**`app/config.py`** - Environment-based configuration

```python
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings from environment variables."""
    
    database_url: str = "sqlite:///./app.db"  # Default: local file
    debug: bool = False
    
    class Config:
        env_file = ".env"


def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
```

**`.env` file:**
```bash
DATABASE_URL=sqlite:///./app.db
DEBUG=false
```

**Production alternatives:**
```bash
# Absolute path
DATABASE_URL=sqlite:////var/data/app.db

# In-memory (testing only, data lost on process end)
DATABASE_URL=sqlite:///:memory:
```

---

## Model Definition

### SQLAlchemy ORM Models

**`app/models.py`** - Database models with relationships

```python
from sqlalchemy import Column, Integer, String, Text, ForeignKey, CheckConstraint, UniqueConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Habit(Base):
    """Habit model - trackable daily habit."""
    
    __tablename__ = "habits"
    
    # Columns (modern SQLAlchemy 2.0 style with Mapped)
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str | None] = mapped_column(String(500))
    color: Mapped[str] = mapped_column(String(7), default="#10B981")  # Hex color
    created_at: Mapped[str] = mapped_column(String(19), nullable=False)  # ISO datetime
    archived_at: Mapped[str | None] = mapped_column(String(19))  # Soft delete timestamp
    
    # Relationships
    completions: Mapped[list["Completion"]] = relationship(
        back_populates="habit",
        cascade="all, delete-orphan",  # Delete completions when habit deleted
        lazy="selectin",  # Eager load with SELECT IN (avoid N+1)
    )
    
    # Constraints
    __table_args__ = (
        CheckConstraint("length(name) > 0", name="name_not_empty"),
    )


class Completion(Base):
    """Completion model - habit done or skipped on specific date."""
    
    __tablename__ = "completions"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    habit_id: Mapped[int] = mapped_column(
        ForeignKey("habits.id", ondelete="CASCADE"),  # CASCADE: delete completions when habit deleted
        nullable=False,
    )
    completed_date: Mapped[str] = mapped_column(String(10), nullable=False)  # YYYY-MM-DD
    status: Mapped[str] = mapped_column(String(10), default="completed")  # completed | skipped
    notes: Mapped[str | None] = mapped_column(String(500))
    created_at: Mapped[str] = mapped_column(String(19), nullable=False)
    
    # Relationships
    habit: Mapped["Habit"] = relationship(back_populates="completions")
    
    # Constraints and indexes
    __table_args__ = (
        UniqueConstraint("habit_id", "completed_date", name="uq_habit_date"),  # One completion per habit per day
        CheckConstraint("status IN ('completed', 'skipped')", name="valid_status"),
        Index("idx_completions_habit_date", "habit_id", "completed_date"),  # Composite index
    )
```

**Key concepts:**
- **Mapped[type]**: Modern SQLAlchemy 2.0 type hints
- **ForeignKey with CASCADE**: Delete child records automatically
- **Relationships**: ORM navigation between tables
- **lazy="selectin"**: Avoid N+1 queries (load all related objects with one extra query)
- **CheckConstraint**: Database-level validation
- **UniqueConstraint**: Prevent duplicate records
- **Index**: Speed up queries on habit_id + completed_date

---

## Date/Time Storage

### ISO 8601 Format (Recommended)

SQLite has no native DATE or DATETIME types. Store dates as TEXT in ISO 8601 format.

```python
from datetime import datetime, date

# Store dates as YYYY-MM-DD strings
habit = Habit(
    name="Exercise",
    created_at=datetime.now().isoformat(),  # "2025-01-15T12:30:00"
    # OR for date-only:
    # created_at=date.today().isoformat()  # "2025-01-15"
)

# Query by date range (lexicographic sorting works!)
from sqlalchemy import and_

completions = db.query(Completion).filter(
    and_(
        Completion.completed_date >= "2025-01-01",
        Completion.completed_date < "2025-02-01"
    )
).all()
```

**Why TEXT over INTEGER (Unix timestamp)?**
- Human-readable in database
- Lexicographically sortable
- Works with SQLite date functions
- Compatible with JSON serialization

**Date column types:**
```python
created_at: Mapped[str] = mapped_column(String(19))  # "2025-01-15 12:30:00"
completed_date: Mapped[str] = mapped_column(String(10))  # "2025-01-15"
```

---

## Session Management

### Context Manager Pattern (Recommended)

```python
from contextlib import contextmanager
from sqlalchemy.orm import Session

@contextmanager
def get_db_session():
    """Context manager for database sessions with auto-commit/rollback."""
    db = SessionLocal()
    try:
        yield db
        db.commit()  # Auto-commit on success
    except Exception:
        db.rollback()  # Auto-rollback on error
        raise
    finally:
        db.close()


# Usage
def create_habit(name: str) -> Habit:
    with get_db_session() as db:
        habit = Habit(name=name, created_at=datetime.now().isoformat())
        db.add(habit)
        # Auto-commit when exiting context
    return habit
```

### FastAPI Dependency Pattern

```python
from fastapi import Depends
from sqlalchemy.orm import Session

def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Usage in FastAPI routes
@app.post("/habits", response_model=HabitResponse)
def create_habit(
    data: HabitCreate,
    db: Session = Depends(get_db)
):
    habit = Habit(name=data.name, created_at=datetime.now().isoformat())
    db.add(habit)
    db.commit()
    db.refresh(habit)  # Refresh to get auto-generated ID
    return habit
```

**Key concepts:**
- **Depends(get_db)**: FastAPI injects database session
- **db.commit()**: Explicitly commit transaction
- **db.refresh(habit)**: Reload object from database (get auto-generated fields)
- **db.close()**: Always close session (handled by dependency)

---

## Database Initialization

### Create Tables on Startup

**`app/main.py`** - FastAPI app with database initialization

```python
from fastapi import FastAPI
from app.database import engine, Base
from app.models import Habit, Completion  # Import to register models

app = FastAPI()


@app.on_event("startup")
def on_startup():
    """Create database tables on application startup."""
    Base.metadata.create_all(bind=engine)
    print("✓ Database tables created")


@app.get("/")
def read_root():
    return {"status": "ok"}
```

**Alternative: CLI command**

```python
# cli.py
import typer
from app.database import engine, Base
from app.models import Habit, Completion

app = typer.Typer()


@app.command()
def init_db():
    """Initialize database schema."""
    Base.metadata.create_all(bind=engine)
    print("✓ Database tables created")


if __name__ == "__main__":
    app()
```

```bash
# Usage
python cli.py init-db
```

---

## Common Queries

### Basic CRUD Operations

```python
from sqlalchemy.orm import Session
from app.models import Habit, Completion

def get_habit(db: Session, habit_id: int) -> Habit | None:
    """Get habit by ID."""
    return db.query(Habit).filter(Habit.id == habit_id).first()


def list_habits(db: Session, include_archived: bool = False) -> list[Habit]:
    """List habits."""
    query = db.query(Habit)
    if not include_archived:
        query = query.filter(Habit.archived_at.is_(None))
    return query.all()


def create_habit(db: Session, name: str, color: str = "#10B981") -> Habit:
    """Create new habit."""
    habit = Habit(
        name=name,
        color=color,
        created_at=datetime.now().isoformat()
    )
    db.add(habit)
    db.commit()
    db.refresh(habit)
    return habit


def update_habit(db: Session, habit_id: int, **updates) -> Habit:
    """Update habit fields."""
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if not habit:
        raise ValueError(f"Habit not found: {habit_id}")
    
    for key, value in updates.items():
        setattr(habit, key, value)
    
    db.commit()
    db.refresh(habit)
    return habit


def delete_habit(db: Session, habit_id: int) -> None:
    """Delete habit (hard delete with CASCADE)."""
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if not habit:
        raise ValueError(f"Habit not found: {habit_id}")
    
    db.delete(habit)
    db.commit()
```

### Relationships and Joins

```python
from sqlalchemy.orm import selectinload

def get_habit_with_completions(db: Session, habit_id: int) -> Habit:
    """Get habit with all completions (eager loaded)."""
    return db.query(Habit).options(
        selectinload(Habit.completions)
    ).filter(Habit.id == habit_id).first()


def get_completions_for_month(db: Session, habit_id: int, year: int, month: int) -> list[Completion]:
    """Get completions for specific month."""
    start_date = f"{year:04d}-{month:02d}-01"
    end_date = f"{year:04d}-{month:02d}-31"  # Simplification, actual last day varies
    
    return db.query(Completion).filter(
        Completion.habit_id == habit_id,
        Completion.completed_date >= start_date,
        Completion.completed_date <= end_date
    ).order_by(Completion.completed_date).all()
```

---

## Testing with In-Memory Database

### Test Configuration

```python
# tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base

# In-memory database (separate for each test)
TEST_DATABASE_URL = "sqlite:///:memory:"


@pytest.fixture
def db_engine():
    """Create test database engine."""
    engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
    
    # Apply PRAGMAs
    @event.listens_for(engine, "connect")
    def set_pragma(conn, record):
        cursor = conn.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()
    
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)


@pytest.fixture
def db(db_engine):
    """Create test database session."""
    TestSession = sessionmaker(bind=db_engine)
    session = TestSession()
    yield session
    session.close()
```

### Test Example

```python
# tests/test_habits.py
def test_create_habit(db):
    """Test habit creation."""
    habit = Habit(name="Exercise", created_at=datetime.now().isoformat())
    db.add(habit)
    db.commit()
    
    assert habit.id is not None
    assert habit.name == "Exercise"


def test_cascade_delete(db):
    """Test CASCADE delete removes completions."""
    habit = Habit(name="Exercise", created_at=datetime.now().isoformat())
    db.add(habit)
    db.commit()
    
    completion = Completion(
        habit_id=habit.id,
        completed_date="2025-01-15",
        created_at=datetime.now().isoformat()
    )
    db.add(completion)
    db.commit()
    
    # Delete habit should cascade to completions
    db.delete(habit)
    db.commit()
    
    assert db.query(Completion).count() == 0
```

---

## Performance Optimization

### Indexing Strategy

```python
# Single column index
Index("idx_habits_created_at", "created_at")

# Composite index (order matters: filter first, then sort)
Index("idx_completions_habit_date", "habit_id", "completed_date")

# Partial index (only active habits)
Index("idx_active_habits", "name", sqlite_where=archived_at.is_(None))
```

### Batch Operations

```python
def bulk_insert_completions(db: Session, completions_data: list[dict]):
    """Bulk insert completions (faster than individual inserts)."""
    db.bulk_insert_mappings(Completion, completions_data)
    db.commit()


# Usage
completions = [
    {"habit_id": 1, "completed_date": "2025-01-15", "created_at": datetime.now().isoformat()},
    {"habit_id": 1, "completed_date": "2025-01-16", "created_at": datetime.now().isoformat()},
    # ... many more
]
bulk_insert_completions(db, completions)
```

---

## Best Practices

### ✅ Do

1. **Always enable foreign keys** - Via event listener on every connection
2. **Use WAL mode** - Better concurrency for multi-threaded apps
3. **Store dates as ISO 8601 TEXT** - Human-readable, sortable, compatible
4. **Use context managers** - Auto-commit/rollback/close
5. **Eager load relationships** - `selectinload()` to avoid N+1 queries
6. **Index foreign keys** - Critical for CASCADE operations
7. **Use CheckConstraints** - Database-level validation
8. **Test with in-memory DB** - Fast, isolated tests

### ❌ Don't

1. **Don't forget PRAGMAs** - Foreign keys OFF by default!
2. **Don't use SQLite on network filesystems** - Corruption risk (NFS, SMB)
3. **Don't skip indexes on foreign keys** - Slow JOINs and CASCADE
4. **Don't store dates as integers** - Use ISO 8601 TEXT instead
5. **Don't nest transactions** - SQLite doesn't support savepoints in nested transactions
6. **Don't use SQLite for high write concurrency** - One writer at a time
7. **Don't forget check_same_thread=False** - Required for multi-threaded apps
8. **Don't skip db.commit()** - Changes not persisted without explicit commit

---

## Troubleshooting

### Issue: Foreign key constraint violations not caught

**Symptom:** Deleting parent record doesn't cascade, orphaned child records

**Solution:**
```python
# Verify foreign keys enabled
@event.listens_for(engine, "connect")
def set_pragma(conn, record):
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    result = cursor.execute("PRAGMA foreign_keys").fetchone()
    assert result[0] == 1, "Foreign keys not enabled!"
    cursor.close()
```

### Issue: Database locked errors

**Symptom:** `sqlite3.OperationalError: database is locked`

**Solution:**
```python
# Increase busy timeout
cursor.execute("PRAGMA busy_timeout=5000")  # Wait 5s for locks

# Or use WAL mode (reduces lock contention)
cursor.execute("PRAGMA journal_mode=WAL")
```

### Issue: Poor performance

**Symptom:** Slow queries, high latency

**Solution:**
```python
# Increase cache size
cursor.execute("PRAGMA cache_size=-64000")  # 64MB

# Enable memory-mapped I/O
cursor.execute("PRAGMA mmap_size=268435456")  # 256MB

# Analyze query plans
from sqlalchemy import text
result = db.execute(text("EXPLAIN QUERY PLAN SELECT * FROM habits"))
print(result.fetchall())
```

---

## References

### Source Code
- **Production MVP**: `d:\_learn\Production MVP\backend\app\database.py`
  - Complete SQLAlchemy setup with PRAGMA event listeners
  - Session management patterns

### Related Patterns
- 📎 [Models vs Schemas](./models-vs-schemas.md) - Separation of ORM and API layers
- 📎 [PostgreSQL Patterns](./postgresql-patterns.md) - Scaling beyond SQLite
- 📎 [Database Service Pattern](./service-pattern.md) - Centralized DB operations

### External Resources
- [SQLite Documentation](https://sqlite.org/docs.html)
- [SQLite PRAGMA Statements](https://sqlite.org/pragma.html)
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [SQLite When to Use](https://sqlite.org/whentouse.html)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Production MVP backend v1.0.0
