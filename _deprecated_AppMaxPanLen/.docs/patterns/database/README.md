# Database Patterns

**Purpose:** Database setup, schema management, and migration patterns for SQLite and PostgreSQL.

---

## Pattern Structure

This library follows the **overview + reference pattern** for low-entropy documentation:

| File Type | Lines | Purpose | Read Time |
|-----------|-------|---------|-----------|
| **Overview** (`*-overview.md`) | 200-300 | Quick decisions, minimal examples | 2-3 min |
| **Reference** (`*-reference.md`) | 5,000+ | Complete implementation details | 20+ min |

**How to use:**
1. **Start with overview** - Decide if pattern fits your needs
2. **Load reference** - Get complete implementation details when building

---

## Available Patterns

### SQLite Setup
**When to use**: MVPs, single-user apps, local development, embedded databases  
**Complexity**: Low  
**Source**: Production MVP

- 📖 [**sqlite-overview.md**](sqlite-overview.md) - Start here (250 lines, 2-3 min)
- 📎 [sqlite-reference.md](sqlite-reference.md) - Complete guide (7,200 lines)

**Quick decision**: Use SQLite for solo/MVP projects (< 5 users), migrate to PostgreSQL when team grows.

---

### PostgreSQL Patterns
**When to use**: Production apps, team collaboration, high concurrency  
**Complexity**: Medium  
**Source**: Enterprise application

- 📖 [**postgresql-overview.md**](postgresql-overview.md) - Start here (250 lines, 2-3 min)
- 📎 [postgresql-reference.md](postgresql-reference.md) - Complete guide (6,800 lines)

**Quick decision**: Use PostgreSQL for production systems (5+ users), multi-service apps with schema isolation (auth.users, api.webhooks).

---

### Manual SQL Migrations
**When to use**: Production databases requiring explicit schema control, no ORM  
**Complexity**: Medium  
**Source**: Enterprise application

- 📖 [**migrations-overview.md**](migrations-overview.md) - Start here (250 lines, 2-3 min)
- 📎 [migrations-reference.md](migrations-reference.md) - Complete guide (5,400 lines)

**Quick decision**: Use manual migrations for production systems with audit requirements, complex DDL (vs Alembic for ORM-heavy projects).

---

### Database Service Pattern
**When to use**: Multi-endpoint apps, FastAPI, centralized DB operations  
**Complexity**: Medium  
**Source**: Enterprise application

- 📖 [**service-pattern-overview.md**](service-pattern-overview.md) - Start here (250 lines, 2-3 min)
- 📎 [service-pattern-reference.md](service-pattern-reference.md) - Complete guide (5,900 lines)

**Quick decision**: Use DatabaseService for FastAPI apps with psycopg (no ORM), centralizes queries and enables easy testing.

---

### Models vs Schemas (SQLAlchemy + Pydantic)
**When to use**: FastAPI + SQLAlchemy, API surface requiring validation  
**Complexity**: Low  
**Source**: Production MVP

- 📖 [**models-schemas-overview.md**](models-schemas-overview.md) - Start here (250 lines, 2-3 min)
- 📎 [models-schemas-reference.md](models-schemas-reference.md) - Complete guide (5,700 lines)

**Quick decision**: Separate SQLAlchemy models (database) from Pydantic schemas (API) to prevent leaking sensitive fields and enable independent evolution.

---

## Decision Matrix

| Your Situation | Recommended Patterns |
|----------------|---------------------|
| **Week 1 MVP** | SQLite overview + Models/Schemas overview (if using FastAPI) |
| **Month 1 Beta** | PostgreSQL overview + Migrations overview |
| **Month 3 Production** | All references for deep implementation |
| **Team onboarding** | PostgreSQL overview + Service Pattern overview |
| **Troubleshooting** | Specific reference file (comprehensive troubleshooting) |

---

## Loading Strategy for AI Agents

**Decision-making**: Load overview files  
**Implementation**: Load reference files via anchor pattern

Example anchor:
```markdown
📎 **Reference**: `.docs/patterns/database/postgresql-reference.md#connection-pooling`
**When to load**: Implementing connection pooling, debugging pool exhaustion
**Key content**: psycopg_pool setup, min/max size, timeout configuration
```

---

**Pattern Library Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Extracted From**: Production MVP (simple patterns), Enterprise application v0.2.11 (production patterns)
```bash
# SQLite
sqlite3 app.db < migrations/0001_initial_schema.sql

# PostgreSQL
psql -h localhost -U user -d dbname -f migrations/0001_initial_schema.sql

# Docker
docker exec -i postgres psql -U user -d dbname < migrations/0001_initial_schema.sql
```

📎 **Full pattern:** [manual-migrations.md](manual-migrations.md)

## Connection Patterns

### Dependency Injection (FastAPI)
```python
from fastapi import Depends

async def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/api/habits")
async def list_habits(db: Session = Depends(get_db)):
    return db.query(Habit).all()
```

### Service Layer (Recommended)
```python
class DatabaseService:
    def __init__(self, connection):
        self.conn = connection
    
    async def get_habit(self, habit_id: int):
        cursor = await self.conn.cursor()
        await cursor.execute(
            "SELECT * FROM habits WHERE id = %s",
            (habit_id,)
        )
        return await cursor.fetchone()
```

## Data Types

### Date/Time Storage

**SQLite:** TEXT in ISO-8601 format
```python
created_at = datetime.now(UTC).isoformat()  # "2026-03-06T10:30:00+00:00"
```

**PostgreSQL:** TIMESTAMPTZ
```sql
created_at TIMESTAMPTZ DEFAULT NOW()
```

### JSON Storage

**SQLite 3.38+:** JSON1 extension
```sql
CREATE TABLE settings (
    user_id INTEGER,
    preferences JSON
);
```

**PostgreSQL:** JSONB (indexed)
```sql
CREATE TABLE settings (
    user_id INTEGER,
    preferences JSONB
);

CREATE INDEX idx_prefs ON settings USING GIN (preferences);
```

## Best Practices

1. **Enable foreign keys** (SQLite requires PRAGMA)
2. **Use connection pooling** (production)
3. **Manual migrations** > auto-migration tools
4. **Idempotent migrations** (IF NOT EXISTS)
5. **Transaction boundaries** in service layer
6. **Row access** via dict_row or column names

---

**Pattern files will be created in Phase 3**

**Template Version:** 1.0.0  
**Last Updated:** March 6, 2026
