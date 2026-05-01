# SQLite Setup - Overview

**Pattern Type:** Database - Embedded  
**Complexity:** Low  
**Read Time:** 2-3 minutes  
**Best For:** MVPs, single-user apps, local development, embedded databases

---

## When to Use SQLite

### ✅ Use SQLite for:
- **MVPs and prototypes** - Get started fast without database server
- **Single-user applications** - Desktop apps, mobile apps, CLI tools
- **Small team projects** - < 5 concurrent users
- **Development/testing** - Lightweight local database
- **Read-heavy workloads** - Excellent read performance
- **Edge computing** - Embed database in application

### ❌ Don't Use SQLite for:
- **High concurrency** - Writes serialize, only one writer at a time
- **Multi-server deployments** - No network access (file-based)
- **Large teams** - PostgreSQL better for collaboration
- **High write throughput** - Writes lock entire database
- **Distributed systems** - No replication or clustering

### SQLite vs PostgreSQL Quick Decision

| Factor | SQLite | PostgreSQL |
|--------|--------|------------|
| Setup complexity | Zero config | Requires server |
| Concurrent writes | One at a time | Thousands |
| Deployment | Single file | Separate service |
| Team size | Solo - 5 | 5+ |
| Data size | < 1 TB | Unlimited |
| Network access | No | Yes |

**Rule of thumb**: Start with SQLite, migrate to PostgreSQL when you need concurrency or team collaboration.

---

## Essential Configuration

### Critical PRAGMAs (Must Set)

SQLite requires **per-connection** configuration. These are NOT persistent!

```python
# MUST set on every connection
PRAGMA journal_mode=WAL;        # Write-Ahead Logging (concurrency)
PRAGMA foreign_keys=ON;         # Foreign keys OFF by default!
PRAGMA synchronous=NORMAL;      # Balance safety vs speed
```

**Why each matters:**
- **journal_mode=WAL** - Allows concurrent reads during writes (default DELETE mode blocks)
- **foreign_keys=ON** - SQLite disables foreign key constraints by default (silent data corruption risk!)
- **synchronous=NORMAL** - Safe for WAL mode, much faster than FULL

### SQLAlchemy Engine Setup

```python
# app/database.py
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, DeclarativeBase

# Create engine
engine = create_engine(
    "sqlite:///./app.db",
    connect_args={"check_same_thread": False},  # Allow multi-threading
    echo=False  # Set True for SQL logging
)

# CRITICAL: Set PRAGMAs on every connection
@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_conn, connection_record):
    """Execute PRAGMAs on each connection."""
    cursor = dbapi_conn.cursor()
    cursor.execute("PRAGMA journal_mode=WAL")
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.execute("PRAGMA synchronous=NORMAL")
    cursor.close()

# Base class for models
class Base(DeclarativeBase):
    pass

# Session factory
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
```

---

## Minimal Working Example

Complete setup with models, session, and endpoint:

```python
# app/database.py
from sqlalchemy import create_engine, event, String
from sqlalchemy.orm import sessionmaker, DeclarativeBase, Mapped, mapped_column

engine = create_engine("sqlite:///./app.db", connect_args={"check_same_thread": False})

@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_conn, connection_record):
    cursor = dbapi_conn.cursor()
    cursor.execute("PRAGMA journal_mode=WAL")
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.execute("PRAGMA synchronous=NORMAL")
    cursor.close()

class Base(DeclarativeBase):
    pass

SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)

def get_db():
    """FastAPI dependency for database sessions."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# app/models.py
from sqlalchemy import String, CheckConstraint
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True)
    role: Mapped[str] = mapped_column(String(20), default="user")
    
    __table_args__ = (
        CheckConstraint("role IN ('user','admin')", name="valid_role"),
    )

# app/main.py
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from app.database import engine, Base, get_db
from app.models import User

app = FastAPI()

@app.on_event("startup")
def create_tables():
    """Create tables on startup."""
    Base.metadata.create_all(bind=engine)

@app.get("/users")
def list_users(db: Session = Depends(get_db)):
    return db.query(User).all()
```

**That's it!** No database server needed. File `app.db` created automatically.

---

## Basic Operations

### Create
```python
user = User(email="test@example.com", role="user")
db.add(user)
db.commit()
db.refresh(user)  # Load generated ID
```

### Read
```python
# Get by ID
user = db.query(User).filter(User.id == 1).first()

# Get all
users = db.query(User).all()

# Filter
admins = db.query(User).filter(User.role == "admin").all()
```

### Update
```python
user = db.query(User).filter(User.id == 1).first()
user.email = "new@example.com"
db.commit()
```

### Delete
```python
user = db.query(User).filter(User.id == 1).first()
db.delete(user)
db.commit()
```

### Relationships
```python
# In models
class Habit(Base):
    __tablename__ = "habits"
    id: Mapped[int] = mapped_column(primary_key=True)
    completions: Mapped[List["Completion"]] = relationship(
        cascade="all, delete-orphan",
        lazy="selectin"  # Eager load
    )

class Completion(Base):
    __tablename__ = "completions"
    id: Mapped[int] = mapped_column(primary_key=True)
    habit_id: Mapped[int] = mapped_column(ForeignKey("habits.id", ondelete="CASCADE"))
```

---

## Top 5 Gotchas

### 1. Foreign Keys Disabled by Default ⚠️
**Problem**: Foreign key constraints silently ignored

**Solution**: 
```python
@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_conn, connection_record):
    cursor = dbapi_conn.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")  # MUST set per connection!
    cursor.close()
```

### 2. Database Locked Errors
**Problem**: `sqlite3.OperationalError: database is locked`

**Solution**:
- Use WAL mode: `PRAGMA journal_mode=WAL`
- Keep transactions short
- Always close sessions: Use `get_db()` dependency pattern

### 3. Poor String Type Handling
**Problem**: TEXT columns don't enforce max length

**Solution**:
```python
# Use String(length) for validation
email: Mapped[str] = mapped_column(String(255))  # Enforces max length
```

### 4. No Network Access
**Problem**: Can't connect from remote machines

**Solution**: SQLite is file-based. For network access, use PostgreSQL or expose via API.

### 5. Concurrent Writes Lock
**Problem**: Only one write at a time

**Solution**: 
- WAL mode helps but doesn't solve
- Migrate to PostgreSQL for high write concurrency

---

## Quick Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `foreign key constraint failed` | Foreign keys not enabled | Set `PRAGMA foreign_keys=ON` per connection |
| `database is locked` | Long transaction or unclosed session | Use WAL mode, close sessions properly |
| `no such table` | Tables not created | Run `Base.metadata.create_all(bind=engine)` on startup |
| `UNIQUE constraint failed` | Duplicate value | Check unique constraints, handle exception |
| `CHECK constraint failed` | Invalid enum/range value | Fix data or adjust CHECK constraint |

---

## 📎 Complete Reference

For comprehensive implementation details:

**📎 Reference**: [sqlite-reference.md](sqlite-reference.md)  
**When to load**: Implementing advanced features, performance tuning, troubleshooting  
**Key content**:
- All PRAGMA settings explained (cache_size, temp_store, mmap_size)
- Complete model patterns (relationships, constraints, indexes)
- Date/time storage strategies
- Session management patterns
- Testing with in-memory databases
- Performance optimization
- Complete troubleshooting guide

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Extracted From:** Production MVP (SQLAlchemy 2.0 + SQLite)
