# PostgreSQL Setup - Overview

**Pattern Type:** Database - Client/Server  
**Complexity:** Medium  
**Read Time:** 2-3 minutes  
**Best For:** Production apps, team collaboration, high concurrency, microservices

---

## When to Use PostgreSQL

### ✅ Use PostgreSQL for:
- **Production applications** - Battle-tested, reliable, ACID compliant
- **Team collaboration** - Multi-user concurrent access
- **High write throughput** - Thousands of concurrent writes
- **Microservices** - Schema isolation (`auth.users`, `api.webhooks`)
- **Complex queries** - Advanced SQL features (CTEs, window functions, JSONB)
- **Distributed systems** - Replication, clustering support

### ❌ Don't Use PostgreSQL for:
- **MVPs** - Overkill for prototypes (use SQLite first)
- **Single-user apps** - SQLite simpler for local/desktop apps
- **Embedded systems** - Requires separate server process
- **Quick scripts** - Setup overhead not worth it

### PostgreSQL vs SQLite Quick Decision

| Factor | PostgreSQL | SQLite |
|--------|------------|--------|
| Concurrent writes | Thousands | One at a time |
| Setup | Docker/server | Single file |
| Team size | 5+ | Solo - 5 |
| Network access | Yes | No |
| Schema isolation | Multiple schemas | Single database |
| Production ready | Yes | Limited concurrency |

**Migration path**: Start SQLite → Migrate to PostgreSQL when team grows or concurrency needed.

---

## Essential Configuration

### Connection Setup

```python
# Use psycopg 3 (not psycopg2!)
import psycopg
from psycopg.rows import dict_row

# Connection string
DATABASE_URL = "postgresql://user:password@localhost:5432/dbname"

# Connect with dict_row (column access by name)
conn = psycopg.connect(DATABASE_URL, row_factory=dict_row)

# Query
with conn.cursor() as cur:
    cur.execute("SELECT id, email FROM users WHERE id = %s", (user_id,))
    user = cur.fetchone()
    print(user['email'])  # Access by column name, not index!
```

**Critical**: Use `row_factory=dict_row` to access columns by name (`row['email']`) instead of index (`row[0]`).

### Why psycopg 3 (not psycopg2)?

| Feature | psycopg2 (Old) | psycopg 3 (New) |
|---------|----------------|----------------|
| Row access | Tuple by default | dict_row available |
| Type hints | No | Yes |
| Async support | Requires psycopg2-binary | Native async |
| Connection pooling | External library | Built-in (`psycopg_pool`) |
| Maintenance | Security fixes only | Active development |

**Don't use**: `psycopg2` or `psycopg2-binary` (legacy, tuple-only access)

### Schema Isolation (Multi-Service Pattern)

```sql
-- Create schemas for different services
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS api;

-- Grant privileges
GRANT USAGE ON SCHEMA auth TO app_root;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO app_root;

-- Query with schema qualification
SELECT * FROM auth.users WHERE id = %s;
SELECT * FROM api.webhook_subscriptions WHERE user_id = %s;
```

**Benefit**: Multiple services share one database, data isolated by schema.

---

## Minimal Working Example

Complete DatabaseService pattern:

```python
# app/services/database.py
import os
import psycopg
from psycopg.rows import dict_row
from contextlib import contextmanager

class DatabaseService:
    """Centralized database operations."""
    
    def __init__(self, dsn: str = None):
        self.dsn = dsn or os.environ['DATABASE_URL']
    
    @contextmanager
    def get_connection(self):
        """Context manager for connections."""
        conn = psycopg.connect(self.dsn, row_factory=dict_row)
        try:
            yield conn
        finally:
            conn.close()
    
    def get_user_by_id(self, user_id: str):
        """Get user by ID."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, email, role, created_at
                    FROM auth.users
                    WHERE id = %s
                """, (user_id,))
                return cur.fetchone()
    
    def create_user(self, email: str, role: str = "user"):
        """Create new user."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO auth.users (email, role)
                    VALUES (%s, %s)
                    RETURNING id, email, role, created_at
                """, (email, role))
                conn.commit()
                return cur.fetchone()

# Singleton instance
db_service = DatabaseService()

# app/routes/users.py
from fastapi import APIRouter, Depends
from app.services.database import db_service

router = APIRouter()

@router.get("/users/{user_id}")
async def get_user(user_id: str):
    user = db_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(404, "User not found")
    return user

@router.post("/users")
async def create_user(email: str, role: str = "user"):
    return db_service.create_user(email, role)
```

---

## Basic Operations

### Parameterized Queries (SQL Injection Protection)

```python
# ✅ Safe: Parameterized query
cur.execute("SELECT * FROM users WHERE email = %s", (email,))

# ❌ UNSAFE: String formatting (SQL injection!)
cur.execute(f"SELECT * FROM users WHERE email = '{email}'")  # DON'T DO THIS!
```

### Error Handling

```python
from psycopg.errors import UniqueViolation, ForeignKeyViolation

try:
    cur.execute("INSERT INTO users (email) VALUES (%s)", (email,))
    conn.commit()
except UniqueViolation:
    print("Email already exists")
except ForeignKeyViolation:
    print("Referenced record doesn't exist")
```

### Transactions

```python
# Auto-commit context manager
@contextmanager
def transaction(self):
    with self.get_connection() as conn:
        with conn.cursor() as cur:
            try:
                yield cur
                conn.commit()
            except Exception:
                conn.rollback()
                raise

# Usage
with db_service.transaction() as cur:
    cur.execute("INSERT INTO users ...")
    cur.execute("INSERT INTO credentials ...")
    # Commits automatically if no exception
```

### JSON Support

```python
# Store JSON in jsonb column
cur.execute("""
    INSERT INTO credentials (metadata)
    VALUES (%s)
""", ({'scopes': ['read', 'write'], 'tenant_id': '123'},))  # Dict auto-converts

# Query JSON
cur.execute("""
    SELECT * FROM credentials
    WHERE metadata->>'tenant_id' = %s
""", ('123',))
```

---

## Top 5 Gotchas

### 1. Tuple Access Instead of Dict ⚠️
**Problem**: Accessing `row[0]` breaks when columns reordered

**Solution**:
```python
# Always use dict_row
conn = psycopg.connect(dsn, row_factory=dict_row)
user = cur.fetchone()
print(user['email'])  # ✅ Access by name, not index
```

### 2. Forgetting Schema Qualification
**Problem**: `SELECT * FROM users` fails with multiple schemas

**Solution**:
```python
# Always qualify table names with schema
cur.execute("SELECT * FROM auth.users WHERE id = %s", (user_id,))
```

### 3. SQL Injection via String Formatting
**Problem**: `f"WHERE id = {user_id}"` allows SQL injection

**Solution**:
```python
# Always use parameterized queries
cur.execute("WHERE id = %s", (user_id,))  # ✅ Safe
```

### 4. Not Closing Connections
**Problem**: Connection pool exhaustion

**Solution**:
```python
# Use context managers
with self.get_connection() as conn:
    # Connection auto-closes
```

### 5. Using psycopg2 Instead of psycopg 3
**Problem**: Legacy library, tuple-only access

**Solution**:
```bash
# Use psycopg 3
pip install psycopg[binary]  # Not psycopg2!
```

---

## Quick Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `relation "users" does not exist` | Missing schema qualification | Use `auth.users` not `users` |
| `column "email" does not exist` | Typo or wrong table | Verify column name, check schema |
| `UniqueViolation` | Duplicate email/name | Handle exception, show error to user |
| `connection pool exhausted` | Too many connections | Use connection pooling, close connections |
| `tuple index out of range` | Accessing `row[0]` | Use `dict_row`, access by name |

---

## 📎 Complete Reference

For comprehensive implementation details:

**📎 Reference**: [postgresql-reference.md](postgresql-reference.md)  
**When to load**: Connection pooling, advanced queries, schema design, performance tuning  
**Key content**:
- Complete DatabaseService class with all CRUD operations
- Connection pooling with psycopg_pool (min/max size, timeout)
- Transaction management patterns
- Error handling for all constraint types
- Array support (PostgreSQL native arrays)
- Testing with Docker (docker-compose.test.yml)
- Performance optimization
- Complete troubleshooting guide

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Extracted From:** Enterprise application v0.2.11 (Auth & API services)
