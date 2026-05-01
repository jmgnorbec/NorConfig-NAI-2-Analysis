# Database Service Pattern - Overview

**Pattern Type:** Architecture - Data Access Layer  
**Complexity:** Medium  
**Read Time:** 2-3 minutes  
**Best For:** Multi-endpoint apps requiring centralized database operations, testability, dependency injection

---

## When to Use Database Service Pattern

### ✅ Use Database Service for:
- **Multiple endpoints** - Same query used across routes
- **Testing** - Easy to mock database in tests
- **Consistency** - Centralize error handling, logging
- **FastAPI apps** - Works perfectly with dependency injection
- **Team projects** - Clear separation of concerns
- **PostgreSQL** - Especially valuable with psycopg (no ORM)

### ❌ Don't Use Database Service for:
- **Single-route prototype** - Premature abstraction
- **SQLAlchemy with ORM** - Sessions already provide service layer
- **Ultra-simple CRUD** - Direct queries in endpoints OK for MVPs

### With vs Without Service Pattern

**Without (queries scattered):**
```python
# routes/users.py - connection logic repeated
@router.get("/users/{user_id}")
async def get_user(user_id: str):
    conn = psycopg.connect(dsn, row_factory=dict_row)
    cur = conn.cursor()
    cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    # ... duplicate connection handling in every endpoint
```

**With DatabaseService:**
```python
# services/database.py - connection logic centralized
class DatabaseService:
    def get_user_by_id(self, user_id: str):
        with self.get_connection() as conn:
            # ... connection handling in ONE place

# routes/users.py - thin endpoints
@router.get("/users/{user_id}")
async def get_user(user_id: str, db: DatabaseService = Depends(get_db_service)):
    return db.get_user_by_id(user_id)  # Clean!
```

---

## Essential Pattern

### Minimal DatabaseService

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
                    FROM auth.users WHERE id = %s
                """, (user_id,))
                return cur.fetchone()
    
    def create_user(self, email: str, role: str = "user"):
        """Create user."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO auth.users (email, role)
                    VALUES (%s, %s) RETURNING *
                """, (email, role))
                conn.commit()
                return cur.fetchone()

# Singleton instance
_db_service = None

def get_db_service() -> DatabaseService:
    """FastAPI dependency."""
    global _db_service
    if _db_service is None:
        _db_service = DatabaseService()
    return _db_service
```

---

## FastAPI Integration

### Dependency Injection

```python
# app/routes/users.py
from fastapi import APIRouter, Depends, HTTPException
from app.services.database import DatabaseService, get_db_service

router = APIRouter(prefix="/users")

@router.get("/{user_id}")
async def get_user(
    user_id: str,
    db: DatabaseService = Depends(get_db_service)  # Auto-injected!
):
    user = db.get_user_by_id(user_id)
    if not user:
        raise HTTPException(404, "User not found")
    return user

@router.post("")
async def create_user(
    email: str,
    role: str = "user",
    db: DatabaseService = Depends(get_db_service)
):
    return db.create_user(email, role)
```

**Benefits**:
- `db` automatically injected by FastAPI
- Single instance created (singleton pattern)
- Easy to override in tests

---

## Key Patterns

### Transaction Context Manager

```python
@contextmanager
def transaction(self):
    """Auto-commit/rollback transactions."""
    with self.get_connection() as conn:
        with conn.cursor() as cur:
            try:
                yield cur
                conn.commit()
            except Exception:
                conn.rollback()
                raise

# Usage
with db.transaction() as cur:
    cur.execute("INSERT INTO users ...")
    cur.execute("UPDATE credentials ...")
    # Commits automatically if no exception
```

### Custom Exceptions

```python
# services/database.py
class DatabaseError(Exception):
    """Base exception for database operations."""
    pass

class RecordNotFoundError(DatabaseError):
    """Record not found."""
    pass

class DuplicateRecordError(DatabaseError):
    """Duplicate record (unique constraint)."""
    pass

# In methods
from psycopg.errors import UniqueViolation

def create_user(self, email: str):
    try:
        with self.transaction() as cur:
            cur.execute("INSERT INTO users (email) VALUES (%s) RETURNING *", (email,))
            return cur.fetchone()
    except UniqueViolation:
        raise DuplicateRecordError(f"Email {email} already exists")
```

### Health Check

```python
def check_health(self) -> dict:
    """Verify database connectivity."""
    try:
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1 AS healthy")
                result = cur.fetchone()
                return {"status": "healthy", "result": result}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}

# In route
@app.get("/health")
async def health(db: DatabaseService = Depends(get_db_service)):
    return db.check_health()
```

---

## Testing Patterns

### Mocking DatabaseService

```python
# tests/test_users.py
from unittest.mock import Mock, patch

def test_get_user():
    """Test user retrieval with mocked database."""
    mock_db = Mock()
    mock_db.get_user_by_id.return_value = {
        "id": "123",
        "email": "test@example.com"
    }
    
    with patch('app.routes.users.get_db_service', return_value=mock_db):
        response = client.get("/users/123")
        assert response.status_code == 200
        assert response.json()["email"] == "test@example.com"
        mock_db.get_user_by_id.assert_called_once_with("123")
```

### Integration Tests

```python
# tests/integration/test_database.py
import pytest
from app.services.database import DatabaseService

@pytest.fixture
def db():
    """Test database instance."""
    dsn = "postgresql://test_user:test_pass@localhost/test_db"
    return DatabaseService(dsn)

def test_create_user(db):
    """Test user creation with real database."""
    user = db.create_user("test@example.com", "user")
    assert user["email"] == "test@example.com"
    assert "id" in user
```

---

## Top 5 Gotchas

### 1. Creating Multiple Instances
**Problem**: New DatabaseService per request wastes connections

**Solution**: Use singleton pattern with `get_db_service()`

### 2. Not Closing Connections
**Problem**: Connection pool exhaustion

**Solution**: Always use `with self.get_connection()` context manager

### 3. Mixing SQL in Routes
**Problem**: Defeats purpose of service layer

**Solution**: All SQL in DatabaseService, routes call methods only

### 4. Forgetting to Commit
**Problem**: INSERT/UPDATE not saved

**Solution**: Use `transaction()` context manager or explicit `conn.commit()`

### 5. Not Handling Exceptions
**Problem**: Generic database errors exposed to users

**Solution**: Map psycopg exceptions to custom exceptions, handle in FastAPI

---

## Quick Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| Multiple DatabaseService instances | Not using singleton | Use `get_db_service()` function |
| Connection pool exhausted | Connections not closed | Use context managers |
| Transactions not committing | Missing `conn.commit()` | Use `transaction()` context manager |
| Generic error messages | Not mapping exceptions | Catch psycopg errors, raise custom exceptions |
| Can't mock in tests | Direct instantiation | Use `Depends(get_db_service)` pattern |

---

## 📎 Complete Reference

For comprehensive implementation details:

**📎 Reference**: [service-pattern-reference.md](service-pattern-reference.md)  
**When to load**: Building complete CRUD operations, complex error handling, connection pooling  
**Key content**:
- Complete DatabaseService class with all operations (1,000+ lines)
- Connection pooling with psycopg_pool (min/max size, timeout)
- All CRUD patterns (users, credentials, sessions, OTP, OAuth)
- Custom exception hierarchy
- Transaction management patterns
- FastAPI error handlers for custom exceptions
- Testing patterns (mocking, integration tests)
- Complete troubleshooting guide

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Extracted From:** Enterprise application v0.2.11 (Auth & API services)
