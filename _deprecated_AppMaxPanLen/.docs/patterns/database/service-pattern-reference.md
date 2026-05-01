# Database Service Pattern

**Pattern Type:** Architecture - Data Access Layer  
**Complexity:** Medium  
**Best For:** Multi-endpoint applications requiring centralized database operations, dependency injection, consistent error handling

---

## Overview

The Database Service pattern provides a **centralized class** for all database operations in a service. Instead of scattering SQL queries across endpoint files, all CRUD operations live in a single `DatabaseService` class.

### Without vs With Service Pattern

**Without (queries in endpoints):**
```python
# routes/users.py
@router.post("/users")
async def create_user(user: UserCreate):
    conn = await get_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO users (email, role) VALUES (%s, %s) RETURNING id", 
                (user.email, user.role))
    result = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return {"id": result[0]}

# routes/credentials.py
async def get_user_credentials(user_id: str):
    conn = await get_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM credentials WHERE created_by = %s", (user_id,))
    # ... duplicate connection logic
```

**With Service Pattern:**
```python
# services/database.py
class DatabaseService:
    def create_user(self, email: str, role: str) -> dict:
        with self.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute("""
                    INSERT INTO auth.users (email, role)
                    VALUES (%s, %s) RETURNING *
                """, (email, role))
                return cur.fetchone()

# routes/users.py
@router.post("/users")
async def create_user(user: UserCreate, db: DatabaseService = Depends(get_db_service)):
    return db.create_user(user.email, user.role)
```

**Benefits:**
- **Single responsibility**: Database logic separate from HTTP logic
- **Reusability**: Same method called from multiple endpoints
- **Testability**: Mock DatabaseService in tests
- **Consistency**: Connection handling, error handling in one place
- **Maintainability**: Schema changes touch one file

**Use this pattern when:**
- Multiple endpoints access same tables
- Need consistent error handling
- Want to mock database in tests
- Using dependency injection (FastAPI `Depends`)

**Don't use when:**
- Single-endpoint prototype (premature abstraction)
- Using ORM with built-in service layer (SQLAlchemy sessions)

---

## Basic Service Structure

### Minimal DatabaseService

```python
# app/services/database.py
import os
import psycopg
from psycopg.rows import dict_row
from contextlib import contextmanager
from typing import Optional


class DatabaseService:
    """Centralized database operations."""
    
    def __init__(self, dsn: Optional[str] = None):
        self.dsn = dsn or os.environ['DATABASE_URL']
    
    @contextmanager
    def get_connection(self):
        """Context manager for database connections."""
        conn = psycopg.connect(self.dsn, row_factory=dict_row)
        try:
            yield conn
        finally:
            conn.close()
    
    def get_user_by_id(self, user_id: str) -> Optional[dict]:
        """Get user by ID."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, email, role, created_at
                    FROM auth.users
                    WHERE id = %s
                """, (user_id,))
                return cur.fetchone()
    
    def create_user(self, email: str, role: str = "user") -> dict:
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
```

**Key components:**
- `__init__`: Connection string from environment
- `get_connection`: Context manager for connection lifecycle
- CRUD methods: `get_*`, `create_*`, `update_*`, `delete_*`
- Singleton: Single instance reused across app

---

## FastAPI Integration

### Dependency Injection

```python
# app/services/database.py
from fastapi import Depends

# Singleton instance
_db_service = None

def get_db_service() -> DatabaseService:
    """FastAPI dependency for DatabaseService."""
    global _db_service
    if _db_service is None:
        _db_service = DatabaseService()
    return _db_service


# app/routes/users.py
from fastapi import APIRouter, Depends, HTTPException
from app.services.database import DatabaseService, get_db_service
from app.schemas import UserCreate, UserResponse

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    db: DatabaseService = Depends(get_db_service)
):
    """Get user by ID."""
    user = db.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.post("", response_model=UserResponse, status_code=201)
async def create_user(
    user: UserCreate,
    db: DatabaseService = Depends(get_db_service)
):
    """Create new user."""
    return db.create_user(user.email, user.role)
```

**Benefits:**
- Automatic injection via `Depends(get_db_service)`
- Easy to mock in tests (override dependency)
- Single instance created on first request

---

## Complete Service Implementation

### Full DatabaseService Class

```python
# auth/app/services/database.py
import os
import psycopg
from psycopg.rows import dict_row
from psycopg import sql
from psycopg.errors import UniqueViolation, ForeignKeyViolation, CheckViolation
from contextlib import contextmanager
from typing import Optional, List, Dict, Any
import structlog

logger = structlog.get_logger()


class DatabaseError(Exception):
    """Base exception for database operations."""
    pass


class RecordNotFoundError(DatabaseError):
    """Record not found in database."""
    pass


class DuplicateRecordError(DatabaseError):
    """Duplicate record (unique constraint violation)."""
    pass


class AuthDatabaseService:
    """Centralized database operations for Auth service.
    
    All database queries for the auth service go through this class.
    Provides:
    - Connection management
    - Transaction support
    - Consistent error handling
    - Logging
    """
    
    def __init__(self, dsn: Optional[str] = None):
        self.dsn = dsn or os.environ.get('DATABASE_URL')
        if not self.dsn:
            raise ValueError("DATABASE_URL not configured")
    
    # =========================================================================
    # Connection Management
    # =========================================================================
    
    @contextmanager
    def get_connection(self):
        """Context manager for database connections.
        
        Usage:
            with db.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT ...")
        """
        conn = None
        try:
            conn = psycopg.connect(self.dsn, row_factory=dict_row)
            logger.debug("Database connection opened")
            yield conn
        except Exception as e:
            logger.error("Database connection error", error=str(e))
            raise DatabaseError(f"Connection failed: {e}")
        finally:
            if conn:
                conn.close()
                logger.debug("Database connection closed")
    
    @contextmanager
    def transaction(self):
        """Context manager for transactions with auto-commit/rollback.
        
        Usage:
            with db.transaction() as cur:
                cur.execute("INSERT ...")
                cur.execute("UPDATE ...")
            # Commits automatically if no exception
        """
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                try:
                    yield cur
                    conn.commit()
                    logger.debug("Transaction committed")
                except Exception as e:
                    conn.rollback()
                    logger.error("Transaction rolled back", error=str(e))
                    raise
    
    def check_health(self) -> dict:
        """Health check: verify database connectivity."""
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1 AS healthy")
                    result = cur.fetchone()
                    return {"status": "healthy", "result": result}
        except Exception as e:
            logger.error("Database health check failed", error=str(e))
            return {"status": "unhealthy", "error": str(e)}
    
    # =========================================================================
    # User Operations
    # =========================================================================
    
    def get_user_by_id(self, user_id: str) -> Optional[dict]:
        """Get user by ID."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, email, phone, role, is_active, verified_at, 
                           last_login_at, created_at, updated_at
                    FROM auth.users
                    WHERE id = %s
                """, (user_id,))
                return cur.fetchone()
    
    def get_user_by_email(self, email: str) -> Optional[dict]:
        """Get user by email (case-insensitive)."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, email, phone, role, is_active, verified_at,
                           last_login_at, created_at, updated_at
                    FROM auth.users
                    WHERE LOWER(email) = LOWER(%s)
                """, (email,))
                return cur.fetchone()
    
    def create_user(self, email: str, role: str = "user", 
                    created_by: Optional[str] = None) -> dict:
        """Create new user.
        
        Args:
            email: User email (will be lowercased)
            role: User role (user, admin, super-user)
            created_by: User ID who created this user (optional)
        
        Returns:
            Created user record
        
        Raises:
            DuplicateRecordError: Email already exists
        """
        try:
            with self.transaction() as cur:
                cur.execute("""
                    INSERT INTO auth.users (email, role, created_by)
                    VALUES (LOWER(%s), %s, %s)
                    RETURNING id, email, role, is_active, created_at, updated_at
                """, (email, role, created_by))
                user = cur.fetchone()
                logger.info("User created", user_id=user['id'], email=user['email'])
                return user
        except UniqueViolation as e:
            logger.warning("Duplicate user email", email=email)
            raise DuplicateRecordError(f"User with email {email} already exists") from e
    
    def update_user(self, user_id: str, **updates) -> dict:
        """Update user fields.
        
        Args:
            user_id: User ID to update
            **updates: Fields to update (email, role, is_active, etc.)
        
        Returns:
            Updated user record
        
        Raises:
            RecordNotFoundError: User not found
        """
        if not updates:
            raise ValueError("No fields to update")
        
        # Build dynamic SET clause
        set_clause = sql.SQL(", ").join([
            sql.SQL("{} = {}").format(sql.Identifier(k), sql.Placeholder())
            for k in updates.keys()
        ])
        
        query = sql.SQL("""
            UPDATE auth.users
            SET {set_clause}, updated_at = now()
            WHERE id = %s
            RETURNING id, email, role, is_active, updated_at
        """).format(set_clause=set_clause)
        
        try:
            with self.transaction() as cur:
                cur.execute(query, (*updates.values(), user_id))
                user = cur.fetchone()
                if not user:
                    raise RecordNotFoundError(f"User {user_id} not found")
                logger.info("User updated", user_id=user_id, fields=list(updates.keys()))
                return user
        except CheckViolation as e:
            logger.error("User update constraint violation", user_id=user_id, error=str(e))
            raise DatabaseError(f"Invalid value: {e}") from e
    
    def delete_user(self, user_id: str) -> bool:
        """Delete user (soft delete: set is_active=false).
        
        Args:
            user_id: User ID to delete
        
        Returns:
            True if deleted, False if not found
        """
        with self.transaction() as cur:
            cur.execute("""
                UPDATE auth.users
                SET is_active = false, updated_at = now()
                WHERE id = %s
            """, (user_id,))
            deleted = cur.rowcount > 0
            if deleted:
                logger.info("User deleted (soft)", user_id=user_id)
            return deleted
    
    def list_users(self, limit: int = 100, offset: int = 0,
                   role: Optional[str] = None,
                   is_active: bool = True) -> List[dict]:
        """List users with pagination and filtering.
        
        Args:
            limit: Max results (default 100)
            offset: Offset for pagination
            role: Filter by role (optional)
            is_active: Filter by active status (default True)
        
        Returns:
            List of user records
        """
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                query = """
                    SELECT id, email, phone, role, is_active, 
                           verified_at, last_login_at, created_at
                    FROM auth.users
                    WHERE is_active = %s
                """
                params = [is_active]
                
                if role:
                    query += " AND role = %s"
                    params.append(role)
                
                query += " ORDER BY created_at DESC LIMIT %s OFFSET %s"
                params.extend([limit, offset])
                
                cur.execute(query, params)
                return cur.fetchall()
    
    # =========================================================================
    # Credential Operations
    # =========================================================================
    
    def get_credential_by_id(self, credential_id: str) -> Optional[dict]:
        """Get credential by ID."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, created_by, name, display_name, provider,
                           client_id, tenant_id, status, is_active,
                           created_at, updated_at
                    FROM auth.credentials
                    WHERE id = %s
                """, (credential_id,))
                return cur.fetchone()
    
    def create_credential(self, created_by: str, name: str, provider: str,
                          **fields) -> dict:
        """Create OAuth credential.
        
        Args:
            created_by: User ID who owns this credential
            name: Credential name (unique per user)
            provider: OAuth provider (ms365, googlews, github)
            **fields: client_id, encrypted_client_secret, tenant_id, etc.
        
        Returns:
            Created credential record
        
        Raises:
            DuplicateRecordError: Credential name already exists for user
        """
        try:
            with self.transaction() as cur:
                cur.execute("""
                    INSERT INTO auth.credentials 
                    (created_by, name, provider, client_id, encrypted_client_secret,
                     tenant_id, scopes, redirect_uri, authorization_url, token_url)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id, name, provider, status, created_at
                """, (
                    created_by, name, provider,
                    fields.get('client_id'),
                    fields.get('encrypted_client_secret'),
                    fields.get('tenant_id'),
                    fields.get('scopes', []),
                    fields.get('redirect_uri'),
                    fields.get('authorization_url'),
                    fields.get('token_url')
                ))
                credential = cur.fetchone()
                logger.info("Credential created", 
                           credential_id=credential['id'], 
                           provider=provider)
                return credential
        except UniqueViolation as e:
            logger.warning("Duplicate credential name", name=name, user=created_by)
            raise DuplicateRecordError(
                f"Credential '{name}' already exists for this user"
            ) from e
    
    def update_credential(self, credential_id: str, **updates) -> dict:
        """Update credential fields."""
        if not updates:
            raise ValueError("No fields to update")
        
        set_clause = sql.SQL(", ").join([
            sql.SQL("{} = {}").format(sql.Identifier(k), sql.Placeholder())
            for k in updates.keys()
        ])
        
        query = sql.SQL("""
            UPDATE auth.credentials
            SET {set_clause}, updated_at = now()
            WHERE id = %s
            RETURNING id, name, provider, status, updated_at
        """).format(set_clause=set_clause)
        
        try:
            with self.transaction() as cur:
                cur.execute(query, (*updates.values(), credential_id))
                credential = cur.fetchone()
                if not credential:
                    raise RecordNotFoundError(f"Credential {credential_id} not found")
                logger.info("Credential updated", credential_id=credential_id)
                return credential
        except CheckViolation as e:
            raise DatabaseError(f"Invalid value: {e}") from e
    
    def delete_credential(self, credential_id: str) -> bool:
        """Delete credential (hard delete with CASCADE)."""
        with self.transaction() as cur:
            cur.execute("""
                DELETE FROM auth.credentials WHERE id = %s
            """, (credential_id,))
            deleted = cur.rowcount > 0
            if deleted:
                logger.info("Credential deleted", credential_id=credential_id)
            return deleted
    
    def list_credentials(self, user_id: str, 
                         provider: Optional[str] = None,
                         status: Optional[str] = None) -> List[dict]:
        """List credentials for a user."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                query = """
                    SELECT id, name, display_name, provider, status,
                           tenant_id, is_active, created_at
                    FROM auth.credentials
                    WHERE created_by = %s AND is_active = true
                """
                params = [user_id]
                
                if provider:
                    query += " AND provider = %s"
                    params.append(provider)
                
                if status:
                    query += " AND status = %s"
                    params.append(status)
                
                query += " ORDER BY created_at DESC"
                
                cur.execute(query, params)
                return cur.fetchall()


# Singleton instance
_db_service = None

def get_auth_db_service() -> AuthDatabaseService:
    """Get or create singleton DatabaseService."""
    global _db_service
    if _db_service is None:
        _db_service = AuthDatabaseService()
    return _db_service
```

---

## Error Handling Pattern

### Custom Exceptions

```python
# app/services/database.py
class DatabaseError(Exception):
    """Base exception for database operations."""
    pass


class RecordNotFoundError(DatabaseError):
    """Record not found in database."""
    def __init__(self, record_type: str, record_id: str):
        self.record_type = record_type
        self.record_id = record_id
        super().__init__(f"{record_type} {record_id} not found")


class DuplicateRecordError(DatabaseError):
    """Duplicate record (unique constraint violation)."""
    def __init__(self, message: str, constraint: Optional[str] = None):
        self.constraint = constraint
        super().__init__(message)


class ConstraintViolationError(DatabaseError):
    """Check constraint or foreign key violation."""
    def __init__(self, message: str, constraint: Optional[str] = None):
        self.constraint = constraint
        super().__init__(message)
```

### Exception Mapping

```python
from psycopg.errors import UniqueViolation, ForeignKeyViolation, CheckViolation

def create_user(self, email: str) -> dict:
    """Create user with exception mapping."""
    try:
        with self.transaction() as cur:
            cur.execute("""
                INSERT INTO auth.users (email) VALUES (%s) RETURNING *
            """, (email,))
            return cur.fetchone()
    except UniqueViolation as e:
        # Map psycopg exception to domain exception
        raise DuplicateRecordError(
            f"User with email {email} already exists",
            constraint=e.diag.constraint_name
        ) from e
    except ForeignKeyViolation as e:
        raise ConstraintViolationError(
            f"Foreign key violation: {e.diag.constraint_name}",
            constraint=e.diag.constraint_name
        ) from e
    except CheckViolation as e:
        raise ConstraintViolationError(
            f"Invalid value: {e.diag.message_primary}",
            constraint=e.diag.constraint_name
        ) from e
```

### FastAPI Error Handlers

```python
# app/main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from app.services.database import (
    RecordNotFoundError, 
    DuplicateRecordError,
    ConstraintViolationError
)

app = FastAPI()


@app.exception_handler(RecordNotFoundError)
async def record_not_found_handler(request: Request, exc: RecordNotFoundError):
    return JSONResponse(
        status_code=404,
        content={"detail": str(exc), "record_type": exc.record_type}
    )


@app.exception_handler(DuplicateRecordError)
async def duplicate_record_handler(request: Request, exc: DuplicateRecordError):
    return JSONResponse(
        status_code=409,
        content={"detail": str(exc), "constraint": exc.constraint}
    )


@app.exception_handler(ConstraintViolationError)
async def constraint_violation_handler(request: Request, exc: ConstraintViolationError):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc), "constraint": exc.constraint}
    )
```

---

## Testing with DatabaseService

### Mocking DatabaseService

```python
# tests/test_users.py
from unittest.mock import Mock, patch
from fastapi.testclient import TestClient
from app.main import app
from app.services.database import RecordNotFoundError

client = TestClient(app)


def test_get_user_success():
    """Test successful user retrieval."""
    mock_db = Mock()
    mock_db.get_user_by_id.return_value = {
        "id": "123",
        "email": "test@example.com",
        "role": "user"
    }
    
    with patch('app.routes.users.get_db_service', return_value=mock_db):
        response = client.get("/users/123")
        assert response.status_code == 200
        assert response.json()["email"] == "test@example.com"
        mock_db.get_user_by_id.assert_called_once_with("123")


def test_get_user_not_found():
    """Test user not found."""
    mock_db = Mock()
    mock_db.get_user_by_id.return_value = None
    
    with patch('app.routes.users.get_db_service', return_value=mock_db):
        response = client.get("/users/999")
        assert response.status_code == 404
```

### Integration Tests with Real Database

```python
# tests/integration/test_database_service.py
import pytest
from app.services.database import AuthDatabaseService, DuplicateRecordError

@pytest.fixture
def db_service():
    """Fixture with test database."""
    dsn = "postgresql://test_user:test_pass@localhost/test_db"
    return AuthDatabaseService(dsn)


def test_create_user(db_service):
    """Test user creation."""
    user = db_service.create_user("test@example.com", "user")
    assert user["email"] == "test@example.com"
    assert user["role"] == "user"
    assert "id" in user


def test_create_duplicate_user(db_service):
    """Test duplicate email raises exception."""
    db_service.create_user("duplicate@example.com", "user")
    
    with pytest.raises(DuplicateRecordError):
        db_service.create_user("duplicate@example.com", "user")
```

---

## Best Practices

### ✅ Do

1. **One service per schema** - `AuthDatabaseService`, `APIDatabaseService`
2. **Use context managers** - `with self.get_connection()` for auto-cleanup
3. **Custom exceptions** - Map psycopg errors to domain errors
4. **Singleton pattern** - Single instance via `get_db_service()`
5. **Structured logging** - Log all CRUD operations
6. **Type hints** - Annotate return types (`-> Optional[dict]`)
7. **Dependency injection** - FastAPI `Depends(get_db_service)`
8. **Transaction support** - Provide `transaction()` context manager

### ❌ Don't

1. **Don't scatter queries** - Keep all SQL in DatabaseService
2. **Don't expose connections** - Return data, not connections
3. **Don't ignore errors** - Always catch and map exceptions
4. **Don't hardcode DSN** - Use environment variables
5. **Don't create multiple instances** - Use singleton pattern
6. **Don't mix HTTP logic** - Keep endpoints thin (validation only)
7. **Don't forget logging** - Log all database operations
8. **Don't skip tests** - Test DatabaseService in isolation

---

## Troubleshooting

### Issue: Connection pool exhaustion

**Symptom:** `psycopg.OperationalError: connection pool exhausted`

**Solution:**
```python
# Use connection pooling
from psycopg_pool import ConnectionPool

class DatabaseService:
    def __init__(self, dsn: str):
        self.pool = ConnectionPool(dsn, min_size=5, max_size=20)
    
    @contextmanager
    def get_connection(self):
        conn = self.pool.getconn()
        try:
            yield conn
        finally:
            self.pool.putconn(conn)
```

See [PostgreSQL Patterns](./postgresql-patterns.md#connection-pooling) for details.

---

### Issue: Duplicate dependency injection

**Symptom:** Multiple DatabaseService instances created

**Solution:**
```python
# Use global singleton
_db_service = None

def get_db_service():
    global _db_service
    if _db_service is None:
        _db_service = DatabaseService()
    return _db_service

# NOT this (creates new instance per request):
def get_db_service():
    return DatabaseService()  # ❌ Creates multiple instances
```

---

### Issue: Transactions not committing

**Symptom:** Data not saved after `cur.execute()`

**Solution:**
```python
# Always commit after INSERT/UPDATE/DELETE
with self.get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("INSERT INTO ...")
        conn.commit()  # ✅ Don't forget!

# Or use transaction context manager
with self.transaction() as cur:
    cur.execute("INSERT INTO ...")
    # Commits automatically
```

---

## References

### Source Code
- **Enterprise Auth Service**: `<enterprise-app>/auth/app/services/database.py`
  - Complete AuthDatabaseService (1,065 lines)
  - User, credential, OTP, OAuth operations
  - Custom exceptions, transaction management
  
- **Enterprise API Service**: `<enterprise-app>/api/app/services/database.py`
  - APIDatabaseService pattern
  - Subscription, webhook event operations

### Related Patterns
- 📎 [PostgreSQL Patterns](./postgresql-patterns.md) - Connection management, queries
- 📎 [Manual Migrations](./manual-migrations.md) - Schema versioning
- 📎 [Models vs Schemas](./models-vs-schemas.md) - Data layer separation

### External Resources
- [psycopg 3 Documentation](https://www.psycopg.org/psycopg3/docs/)
- [FastAPI Dependency Injection](https://fastapi.tiangolo.com/tutorial/dependencies/)
- [Repository Pattern (Martin Fowler)](https://martinfowler.com/eaaCatalog/repository.html)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Enterprise application v0.2.11 (Auth & API services)
