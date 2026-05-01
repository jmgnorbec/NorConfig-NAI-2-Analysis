# PostgreSQL Patterns with psycopg

**Pattern Type:** Database Configuration  
**Complexity:** Medium  
**Best For:** Production applications, multi-user systems, high concurrency, microservices

---

## Overview

PostgreSQL is a powerful, production-grade relational database with advanced features like schemas, full-text search, JSON support, and excellent concurrency. This pattern uses **psycopg 3** (psycopg, not psycopg2) for Python connectivity.

### When to Use PostgreSQL

**✅ Use PostgreSQL when:**
- Production web applications
- High write concurrency (hundreds of concurrent connections)
- Multi-service architectures (shared database across services)
- Complex queries with JOINs, CTEs, window functions
- Need for schemas (namespace isolation)
- ACID transactions with strong consistency
- Advanced features (JSON, full-text search, GIS)
- Database size >100GB

**❌ Consider SQLite when:**
- Single-user desktop applications
- Local development/prototyping only
- No network database required
- Simple CRUD operations only

---

## psycopg 3 Connection Pattern

### Why psycopg 3 (not psycopg2)?

| Feature | psycopg 3 | psycopg2 |
|---------|-----------|----------|
| Async support | Native `asyncpg`-like API | Limited |
| Row access | `row['column']` (dict-like) | `row[0]` (tuple-like) |
| Type safety | Automatic type conversion | Manual casting often needed |
| Performance | Faster, modern codebase | Legacy, slower |
| Maintenance | Actively developed | Maintenance mode |

**Import:** `import psycopg` (not `import psycopg2`)

---

## Connection Configuration

### Environment Variables

```bash
# .env file
DATABASE_URL=postgresql://app_root:password@postgres:5432/app_db

# Docker environment (service-to-service)
DATABASE_URL=postgresql://app_root:password@postgres:5432/app_db

# Local development
DATABASE_URL=postgresql://localhost:5432/app_db
```

**URL format:**
```
postgresql://[user]:[password]@[host]:[port]/[database]
```

---

## Database Service Pattern

### Centralized Service Class

**`app/services/database.py`** - Centralized database operations

```python
"""Database connection and schema management."""
import os
from contextlib import contextmanager
from typing import Optional, List, Dict, Any, Generator
import psycopg
from psycopg.rows import dict_row


# Custom Exceptions
class DatabaseError(Exception):
    """Base exception for database operations."""
    pass


class RecordNotFoundError(DatabaseError):
    """Raised when a database record is not found."""
    pass


class DuplicateRecordError(DatabaseError):
    """Raised when attempting to create a duplicate record."""
    pass


def get_database_url() -> str:
    """Get database URL from environment."""
    dsn = os.environ.get("DATABASE_URL")
    if not dsn:
        raise ValueError("DATABASE_URL environment variable not set")
    return dsn


class DatabaseService:
    """Centralized database service for schema operations."""
    
    def __init__(self):
        """Initialize the database service."""
        self.dsn = get_database_url()
    
    def get_connection(self) -> psycopg.Connection:
        """
        Get a database connection with dict_row factory.
        
        Returns:
            psycopg.Connection: Database connection
            
        Usage:
            with db_service.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT * FROM users")
                    users = cur.fetchall()
                    # Access columns: users[0]['email']
        """
        return psycopg.connect(self.dsn, row_factory=dict_row)
    
    def check_health(self) -> dict:
        """
        Check database health.
        
        Returns:
            dict: Health status with database info
            
        Usage:
            health = db_service.check_health()
            # {'status': 'ok', 'database': 'app_db', 'user': 'app_root', 'version': 'PostgreSQL 16.1'}
        """
        try:
            with psycopg.connect(self.dsn, connect_timeout=3, row_factory=dict_row) as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT version(), current_database(), current_user")
                    row = cur.fetchone()
                    return {
                        "status": "ok",
                        "database": row['current_database'],
                        "user": row['current_user'],
                        "version": str(row['version'])
                    }
        except Exception as e:
            raise DatabaseError(f"Health check failed: {e}")
    
    @contextmanager
    def transaction(self) -> Generator[psycopg.Connection, None, None]:
        """
        Context manager for database transactions.
        
        Yields:
            psycopg.Connection: Database connection
            
        Usage:
            with db_service.transaction() as conn:
                # Multiple operations
                db_service.create_user(conn, ...)
                db_service.store_tokens(conn, ...)
                # Auto-commit on success, rollback on exception
        """
        conn = self.get_connection()
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()
    
    # CRUD Operations
    
    def get_user_by_email(self, email: str) -> dict:
        """
        Get user by email address.
        
        Args:
            email: User email address
            
        Returns:
            dict: User record (access columns by name: user['email'])
            
        Raises:
            RecordNotFoundError: If user not found
        """
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, email, role, is_active, created_at
                    FROM auth.users
                    WHERE email = %s
                """, (email.lower(),))
                user = cur.fetchone()
                if not user:
                    raise RecordNotFoundError(f"User not found: {email}")
                return user
    
    def create_user(self, email: str, role: str = "user") -> str:
        """
        Create a new user.
        
        Args:
            email: User email address
            role: User role (default: "user")
            
        Returns:
            str: User ID (UUID)
            
        Raises:
            DuplicateRecordError: If user already exists
        """
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                try:
                    cur.execute("""
                        INSERT INTO auth.users (email, role)
                        VALUES (%s, %s)
                        RETURNING id
                    """, (email.lower(), role))
                    result = cur.fetchone()
                    conn.commit()
                    return result['id']
                except psycopg.errors.UniqueViolation:
                    raise DuplicateRecordError(f"User already exists: {email}")
    
    def update_user(self, user_id: str, **kwargs) -> None:
        """
        Update user fields.
        
        Args:
            user_id: User ID (UUID)
            **kwargs: Fields to update (email, role, is_active)
            
        Raises:
            RecordNotFoundError: If user not found
        """
        valid_fields = {'email', 'role', 'is_active'}
        updates = {k: v for k, v in kwargs.items() if k in valid_fields}
        
        if not updates:
            return
        
        set_clause = ', '.join(f"{k} = %s" for k in updates.keys())
        values = list(updates.values())
        values.append(user_id)
        
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(f"""
                    UPDATE auth.users
                    SET {set_clause}
                    WHERE id = %s
                """, values)
                if cur.rowcount == 0:
                    raise RecordNotFoundError(f"User not found: {user_id}")
                conn.commit()
    
    def list_users(self, filters: Optional[Dict[str, Any]] = None) -> List[dict]:
        """
        List users with optional filters.
        
        Args:
            filters: Optional filters (role, is_active)
            
        Returns:
            List[dict]: List of user records
        """
        filters = filters or {}
        where_clauses = []
        values = []
        
        if 'role' in filters:
            where_clauses.append("role = %s")
            values.append(filters['role'])
        
        if 'is_active' in filters:
            where_clauses.append("is_active = %s")
            values.append(filters['is_active'])
        
        where_sql = f"WHERE {' AND '.join(where_clauses)}" if where_clauses else ""
        
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(f"""
                    SELECT id, email, role, is_active, created_at
                    FROM auth.users
                    {where_sql}
                    ORDER BY created_at DESC
                """, values)
                return cur.fetchall()


# Singleton instance
db_service = DatabaseService()
```

**Key concepts:**
- **dict_row factory**: Access columns by name (`row['email']`)
- **Context managers**: Auto-commit/rollback/close
- **Custom exceptions**: Type-safe error handling
- **Parameterized queries**: Prevent SQL injection (`%s` placeholders)
- **Singleton pattern**: Reuse service instance across app

---

## Row Access Pattern

### dict_row vs Tuple Access

```python
# With dict_row (recommended)
conn = psycopg.connect(dsn, row_factory=dict_row)
cur = conn.cursor()
cur.execute("SELECT id, email, role FROM users WHERE id = %s", (user_id,))
user = cur.fetchone()

# Access by column name
print(user['email'])      # ✅ Clear, self-documenting
print(user['role'])       # ✅ Refactoring-safe

# Without dict_row (default tuple)
conn = psycopg.connect(dsn)
cur = conn.cursor()
cur.execute("SELECT id, email, role FROM users WHERE id = %s", (user_id,))
user = cur.fetchone()

# Access by index
print(user[1])            # ❌ What column is this?
print(user[2])            # ❌ Breaks if column order changes
```

**Always use `row_factory=dict_row`** for better code clarity and safety.

---

## Schema Isolation Pattern

PostgreSQL supports **schemas** (namespaces) for organizing tables. This is critical for multi-service architectures.

### Schema Structure

```
app_db (database)
├── auth (schema)
│   ├── users
│   ├── credentials
│   └── oauth_state
├── api (schema)
│   ├── webhook_subscriptions
│   ├── webhook_events
│   └── workflow_events
└── public (schema)
    └── (default schema, avoid for application tables)
```

### Create Schemas

```sql
-- Create schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS api;

-- Grant permissions
GRANT USAGE ON SCHEMA auth TO app_root;
GRANT CREATE ON SCHEMA auth TO app_root;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO app_root;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO app_root;

-- Default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL PRIVILEGES ON TABLES TO app_root;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL PRIVILEGES ON SEQUENCES TO app_root;
```

### Query with Schemas

```python
# Always use schema-qualified table names
cur.execute("SELECT * FROM auth.users WHERE email = %s", (email,))

# Don't rely on search_path
# BAD: SELECT * FROM users  (which schema?)
# GOOD: SELECT * FROM auth.users
```

---

## Connection Pooling

### When to Use Connection Pooling

**Use pooling when:**
- High traffic (>100 requests/sec)
- Microservices with many short-lived connections
- Want to limit max connections to database
- Need connection reuse for performance

**Skip pooling when:**
- Simple applications with low traffic
- Long-running connections (workers, background jobs)
- Development/testing environments

### psycopg Pool Pattern

```python
from psycopg_pool import ConnectionPool

# Create pool (application startup)
pool = ConnectionPool(
    conninfo=get_database_url(),
    min_size=5,      # Minimum connections
    max_size=20,     # Maximum connections
    max_waiting=10,  # Max clients waiting for connection
    timeout=5.0,     # Wait timeout (seconds)
    kwargs={"row_factory": dict_row}
)

# Use pool in service
class DatabaseService:
    def __init__(self, pool: ConnectionPool):
        self.pool = pool
    
    def get_connection(self):
        """Get connection from pool."""
        return self.pool.connection()
    
    def get_user(self, email: str) -> dict:
        with self.pool.connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM auth.users WHERE email = %s", (email,))
                return cur.fetchone()


# FastAPI integration
from fastapi import FastAPI

app = FastAPI()
pool = None

@app.on_event("startup")
def startup():
    global pool
    pool = ConnectionPool(conninfo=get_database_url(), kwargs={"row_factory": dict_row})

@app.on_event("shutdown")
def shutdown():
    pool.close()

# Use in routes
@app.get("/users/{email}")
def get_user(email: str):
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM auth.users WHERE email = %s", (email,))
            return cur.fetchone()
```

---

## Transaction Management

### Basic Transactions

```python
# Auto-commit per statement (default)
with psycopg.connect(dsn) as conn:
    with conn.cursor() as cur:
        cur.execute("INSERT INTO users (email) VALUES (%s)", ("user@example.com",))
        # Auto-commits when connection closes

# Explicit transaction
with psycopg.connect(dsn) as conn:
    with conn.cursor() as cur:
        cur.execute("INSERT INTO users (email) VALUES (%s)", ("user@example.com",))
        cur.execute("INSERT INTO profiles (user_id) VALUES (%s)", (user_id,))
        conn.commit()  # Both or neither

# Rollback on error
with psycopg.connect(dsn) as conn:
    try:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO users ...")
            cur.execute("INSERT INTO profiles ...")
            conn.commit()
    except Exception:
        conn.rollback()
        raise
```

### Transaction Context Manager

```python
@contextmanager
def transaction() -> Generator[psycopg.Connection, None, None]:
    """Transaction with auto-commit/rollback."""
    conn = psycopg.connect(get_database_url(), row_factory=dict_row)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# Usage
def create_user_with_profile(email: str) -> str:
    with transaction() as conn:
        with conn.cursor() as cur:
            # Insert user
            cur.execute("INSERT INTO users (email) VALUES (%s) RETURNING id", (email,))
            user_id = cur.fetchone()['id']
            
            # Insert profile (same transaction)
            cur.execute("INSERT INTO profiles (user_id) VALUES (%s)", (user_id,))
            
            # Auto-commits both on success
            return user_id
```

---

## Error Handling

### PostgreSQL-Specific Errors

```python
import psycopg
from psycopg import errors

try:
    cur.execute("INSERT INTO users (email) VALUES (%s)", (email,))
    conn.commit()
except errors.UniqueViolation:
    # Duplicate key (e.g., email already exists)
    raise DuplicateRecordError(f"User already exists: {email}")
except errors.ForeignKeyViolation:
    # Foreign key constraint failed
    raise DatabaseError("Referenced record does not exist")
except errors.CheckViolation:
    # Check constraint failed
    raise DatabaseError("Invalid data: check constraint violation")
except psycopg.OperationalError as e:
    # Connection issues, timeouts
    raise DatabaseError(f"Database connection error: {e}")
except Exception as e:
    # Catch-all for unexpected errors
    raise DatabaseError(f"Database error: {e}")
```

---

## Parameterized Queries (SQL Injection Prevention)

### Safe Query Patterns

```python
# ✅ Parameterized query (safe)
cur.execute(
    "SELECT * FROM users WHERE email = %s AND role = %s",
    (email, role)
)

# ✅ Named parameters (safe)
cur.execute(
    "SELECT * FROM users WHERE email = %(email)s AND role = %(role)s",
    {"email": email, "role": role}
)

# ✅ IN clause with list
ids = [1, 2, 3]
cur.execute(
    "SELECT * FROM users WHERE id = ANY(%s)",
    (ids,)
)

# ❌ String formatting (SQL INJECTION!)
# NEVER DO THIS:
cur.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

**Rule:** Always use `%s` placeholders, never string formatting.

---

## JSON Support

PostgreSQL has native JSON support with `jsonb` type.

```python
# Store JSON data
metadata = {"theme": "dark", "language": "en"}
cur.execute(
    "INSERT INTO settings (user_id, metadata) VALUES (%s, %s)",
    (user_id, metadata)  # psycopg automatically converts dict to jsonb
)

# Query JSON fields
cur.execute("""
    SELECT * FROM settings
    WHERE metadata->>'theme' = %s
""", ("dark",))

# Update JSON field
cur.execute("""
    UPDATE settings
    SET metadata = metadata || %s
    WHERE user_id = %s
""", ({"language": "fr"}, user_id))  # Merge JSON
```

---

## Array Support

PostgreSQL supports native arrays.

```python
# Store array
scopes = ["mail.read", "calendars.read", "contacts.read"]
cur.execute(
    "INSERT INTO credentials (name, scopes) VALUES (%s, %s)",
    (name, scopes)  # psycopg converts list to PostgreSQL array
)

# Query array contains
cur.execute("""
    SELECT * FROM credentials
    WHERE %s = ANY(scopes)
""", ("mail.read",))

# Query array overlap
cur.execute("""
    SELECT * FROM credentials
    WHERE scopes && %s
""", (["mail.read", "calendars.read"],))
```

---

## Testing with Docker

### Docker Compose for Tests

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  test-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_password
    ports:
      - "5433:5432"  # Non-standard port to avoid conflicts
    tmpfs:
      - /var/lib/postgresql/data  # In-memory for speed
```

```bash
# Start test database
docker-compose -f docker-compose.test.yml up -d

# Run tests
DATABASE_URL=postgresql://test_user:test_password@localhost:5433/test_db pytest

# Stop test database
docker-compose -f docker-compose.test.yml down
```

### pytest Fixtures

```python
# tests/conftest.py
import pytest
import psycopg
from psycopg.rows import dict_row

TEST_DATABASE_URL = "postgresql://test_user:test_password@localhost:5433/test_db"


@pytest.fixture(scope="session")
def db_connection():
    """Session-scoped database connection."""
    conn = psycopg.connect(TEST_DATABASE_URL, row_factory=dict_row)
    
    # Run migrations
    with conn.cursor() as cur:
        cur.execute(open("migrations/0001_bootstrap.sql").read())
        conn.commit()
    
    yield conn
    conn.close()


@pytest.fixture
def db(db_connection):
    """Function-scoped transaction (rollback after test)."""
    with db_connection.transaction() as txn:
        yield db_connection
        txn.rollback()  # Clean up after each test
```

---

## Best Practices

### ✅ Do

1. **Use dict_row** - Access columns by name, not index
2. **Use schemas** - Namespace isolation for multi-service apps
3. **Parameterize queries** - Prevent SQL injection
4. **Use context managers** - Auto-commit/rollback/close
5. **Handle specific errors** - Catch `UniqueViolation`, `ForeignKeyViolation`
6. **Use connection pooling** - For high-traffic applications
7. **Schema-qualify table names** - `auth.users`, not `users`
8. **Test with Docker** - Isolated, reproducible test database

### ❌ Don't

1. **Don't use string formatting** - SQL injection risk
2. **Don't hardcode DSN** - Use environment variables
3. **Don't forget to commit** - Changes not persisted without commit
4. **Don't use tuple access** - `row[0]` fragile, use `row['column']`
5. **Don't skip connection pooling** - For production apps
6. **Don't rely on search_path** - Always use schema-qualified names
7. **Don't forget error handling** - Catch database-specific errors
8. **Don't leave connections open** - Always close or use context managers

---

## Troubleshooting

### Issue: `row[0]` vs `row['column']`

**Symptom:** AttributeError or IndexError when accessing rows

**Solution:**
```python
# Ensure row_factory=dict_row
conn = psycopg.connect(dsn, row_factory=dict_row)

# Then access by column name
user = cur.fetchone()
print(user['email'])  # Works!
```

### Issue: SQL injection warnings

**Symptom:** Security scanner flags SQL queries

**Solution:**
```python
# ❌ BAD: String formatting
cur.execute(f"SELECT * FROM users WHERE email = '{email}'")

# ✅ GOOD: Parameterized
cur.execute("SELECT * FROM users WHERE email = %s", (email,))
```

### Issue: Connection pool exhausted

**Symptom:** `PoolTimeout` errors

**Solution:**
```python
# Increase pool size
pool = ConnectionPool(
    conninfo=dsn,
    min_size=10,
    max_size=50,     # Increase if needed
    timeout=10.0     # Increase wait time
)

# Or check for connection leaks (unclosed connections)
```

---

## References

### Source Code
- **Enterprise Auth Service**: `<enterprise-app>/auth/app/services/database.py`
  - Complete DatabaseService class with CRUD operations
  - dict_row usage, error handling, transaction management
  
- **Enterprise API Service**: `<enterprise-app>/api/app/services/database.py`
  - Schema isolation patterns
  - Webhook subscription operations

### Related Patterns
- 📎 [SQLite Setup](./sqlite-setup.md) - Lightweight alternative for simple apps
- 📎 [Manual Migrations](./manual-migrations.md) - Schema evolution
- 📎 [Database Service Pattern](./service-pattern.md) - Centralized DB operations

### External Resources
- [psycopg 3 Documentation](https://www.psycopg.org/psycopg3/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Schemas](https://www.postgresql.org/docs/current/ddl-schemas.html)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Enterprise application v0.2.11 (Auth & API services)
