# FastAPI Testing Patterns

**Pattern Type:** Integration Testing  
**Best For:** API endpoint testing with real database  
**Source:** Habit Tracker  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

FastAPI testing patterns using `TestClient` for integration tests. Covers API endpoint testing, database fixtures, dependency overrides, authentication testing, and async patterns.

**Key Characteristics:**
- Test full HTTP request/response cycle
- Use real database (in-memory SQLite for speed)
- Verify status codes, JSON responses, headers
- Test authentication and authorization
- Slower than unit tests (50-200ms per test)

---

## When to Use

### ✅ Use FastAPI Integration Tests For:
- **API endpoints** (POST, GET, PUT, DELETE)
- **Request validation** (Pydantic schemas)
- **Database operations** (CRUD through API)
- **Authentication flows** (login, JWT tokens)
- **Error handling** (4xx, 5xx responses)

### ❌ Don't Use Integration Tests For:
- **Pure business logic** (use unit tests)
- **External API calls** (mock or E2E)
- **Performance testing** (use load testing tools)
- **Browser behavior** (use Playwright E2E tests)

---

## TestClient Setup

### Basic Configuration

**`conftest.py`:**
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, StaticPool
from sqlalchemy.orm import sessionmaker

from app.database import Base, get_db
from app.main import app

# In-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite://"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,  # Reuse same connection
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db_session():
    """Create fresh database for each test."""
    Base.metadata.create_all(bind=engine)
    
    # Enable foreign keys in SQLite
    with engine.connect() as conn:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.commit()
    
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(db_session):
    """FastAPI test client with dependency overrides."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass  # Session cleanup handled by db_session fixture
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()
```

**Key Points:**
- ✅ `StaticPool` - Reuses connection for in-memory database
- ✅ `PRAGMA foreign_keys=ON` - Enforces referential integrity
- ✅ Function scope - Fresh database per test
- ✅ Dependency override - Inject test database

---

## Basic API Testing

### 1. Test GET Endpoint

```python
def test_list_habits_returns_empty_array(client):
    """GET /api/habits should return empty array initially."""
    response = client.get("/api/habits")
    
    assert response.status_code == 200
    assert response.json() == []

def test_list_habits_returns_created_habits(client):
    """GET /api/habits should return all habits."""
    # Arrange: Create habits
    client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    client.post("/api/habits", json={"name": "Reading", "color": "#3B82F6"})
    
    # Act: List habits
    response = client.get("/api/habits")
    
    # Assert
    assert response.status_code == 200
    habits = response.json()
    assert len(habits) == 2
    assert habits[0]["name"] == "Exercise"
    assert habits[1]["name"] == "Reading"
```

---

### 2. Test POST Endpoint

```python
def test_create_habit_returns_201(client):
    """POST /api/habits should create habit and return 201."""
    payload = {
        "name": "Exercise",
        "description": "Daily workout",
        "color": "#10B981"
    }
    
    response = client.post("/api/habits", json=payload)
    
    assert response.status_code == 201
    data = response.json()
    assert data["id"] is not None
    assert data["name"] == payload["name"]
    assert data["description"] == payload["description"]
    assert data["color"] == payload["color"]

def test_create_habit_persists_to_database(client, db_session):
    """Created habit should be retrievable from database."""
    payload = {"name": "Meditation", "color": "#EF4444"}
    
    response = client.post("/api/habits", json=payload)
    habit_id = response.json()["id"]
    
    # Verify in database
    from app.models import Habit
    habit = db_session.query(Habit).filter_by(id=habit_id).first()
    assert habit is not None
    assert habit.name == "Meditation"
```

---

### 3. Test PUT/PATCH Endpoint

```python
def test_update_habit(client):
    """PUT /api/habits/{id} should update habit."""
    # Create habit
    create_response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    habit_id = create_response.json()["id"]
    
    # Update habit
    update_payload = {"name": "Morning Exercise", "color": "#3B82F6"}
    response = client.put(f"/api/habits/{habit_id}", json=update_payload)
    
    assert response.status_code == 200
    updated = response.json()
    assert updated["name"] == "Morning Exercise"
    assert updated["color"] == "#3B82F6"
```

---

### 4. Test DELETE Endpoint

```python
def test_delete_habit_returns_204(client):
    """DELETE /api/habits/{id} should return 204."""
    # Create habit
    create_response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    habit_id = create_response.json()["id"]
    
    # Delete habit
    response = client.delete(f"/api/habits/{habit_id}")
    
    assert response.status_code == 204
    assert response.text == ""  # No content

def test_delete_habit_removes_from_database(client, db_session):
    """Deleted habit should not be retrievable."""
    # Create and delete
    create_response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    habit_id = create_response.json()["id"]
    client.delete(f"/api/habits/{habit_id}")
    
    # Verify deletion
    from app.models import Habit
    habit = db_session.query(Habit).filter_by(id=habit_id).first()
    assert habit is None
```

---

## Request Validation Testing

### 1. Test Required Fields

```python
def test_create_habit_requires_name(client):
    """POST /api/habits should fail without name."""
    payload = {"color": "#10B981"}  # Missing name
    
    response = client.post("/api/habits", json=payload)
    
    assert response.status_code == 422
    error = response.json()
    assert "name" in str(error)

def test_create_habit_requires_color(client):
    """POST /api/habits should fail without color."""
    payload = {"name": "Exercise"}  # Missing color
    
    response = client.post("/api/habits", json=payload)
    
    assert response.status_code == 422
```

---

### 2. Test Field Validation

```python
def test_create_habit_rejects_blank_name(client):
    """POST /api/habits should reject blank name."""
    payload = {"name": "   ", "color": "#10B981"}
    
    response = client.post("/api/habits", json=payload)
    
    assert response.status_code == 422

def test_create_habit_rejects_invalid_color(client):
    """POST /api/habits should reject invalid hex color."""
    payload = {"name": "Exercise", "color": "not-a-color"}
    
    response = client.post("/api/habits", json=payload)
    
    assert response.status_code == 422
    error = response.json()
    assert "color" in str(error)
```

---

### 3. Test Custom Validators

```python
def test_date_must_be_valid_iso_format(client):
    """POST /api/completions should reject invalid date."""
    payload = {"habit_id": 1, "completed_date": "2025-13-45"}  # Invalid date
    
    response = client.post("/api/completions", json=payload)
    
    assert response.status_code == 422
    error = response.json()
    assert "date" in str(error).lower()
```

---

## Error Handling

### 1. Test 404 Not Found

```python
def test_get_nonexistent_habit_returns_404(client):
    """GET /api/habits/999 should return 404 for missing habit."""
    response = client.get("/api/habits/999")
    
    assert response.status_code == 404
    error = response.json()
    assert "not found" in error["detail"].lower()

def test_update_nonexistent_habit_returns_404(client):
    """PUT /api/habits/999 should return 404."""
    response = client.put("/api/habits/999", json={"name": "Test"})
    
    assert response.status_code == 404
```

---

### 2. Test 409 Conflict

```python
def test_duplicate_completion_returns_409(client):
    """POST /api/completions should reject duplicate date."""
    # Create habit
    habit_response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    habit_id = habit_response.json()["id"]
    
    # Create completion
    payload = {"habit_id": habit_id, "completed_date": "2025-01-15"}
    client.post("/api/completions", json=payload)
    
    # Try duplicate
    response = client.post("/api/completions", json=payload)
    
    assert response.status_code == 409
    error = response.json()
    assert "already exists" in error["detail"].lower()
```

---

### 3. Test 500 Internal Server Error

```python
from unittest.mock import patch

def test_database_error_returns_500(client):
    """Database error should return 500."""
    with patch("app.routers.habits.db", side_effect=Exception("DB connection lost")):
        response = client.get("/api/habits")
    
    assert response.status_code == 500
```

---

## Database Fixture Patterns

### 1. Persistent Test Data

```python
@pytest.fixture
def sample_habit(client):
    """Create a sample habit for testing."""
    response = client.post("/api/habits", json={
        "name": "Exercise",
        "description": "Daily workout",
        "color": "#10B981"
    })
    return response.json()

def test_with_existing_habit(client, sample_habit):
    """Test using pre-created habit."""
    response = client.get(f"/api/habits/{sample_habit['id']}")
    assert response.status_code == 200
    assert response.json()["name"] == "Exercise"
```

---

### 2. Factory Fixtures

```python
@pytest.fixture
def habit_factory(client):
    """Factory to create multiple habits."""
    def _create_habit(name: str = "Test Habit", color: str = "#10B981"):
        response = client.post("/api/habits", json={"name": name, "color": color})
        return response.json()
    return _create_habit

def test_list_multiple_habits(client, habit_factory):
    """Test listing multiple habits."""
    habit_factory(name="Exercise")
    habit_factory(name="Reading")
    habit_factory(name="Meditation")
    
    response = client.get("/api/habits")
    assert len(response.json()) == 3
```

---

### 3. Database Seeding

```python
@pytest.fixture
def seeded_database(db_session):
    """Pre-populate database with test data."""
    from app.models import Habit, Completion
    from datetime import date
    
    habit = Habit(name="Exercise", color="#10B981")
    db_session.add(habit)
    db_session.commit()
    
    completion = Completion(habit_id=habit.id, completed_date=date.today())
    db_session.add(completion)
    db_session.commit()
    
    return {"habit": habit, "completion": completion}

def test_with_seeded_data(client, seeded_database):
    """Test with pre-populated database."""
    habit = seeded_database["habit"]
    response = client.get(f"/api/habits/{habit.id}")
    assert response.status_code == 200
```

---

## Authentication Testing

### 1. Test Login Endpoint

```python
def test_login_with_valid_credentials(client):
    """POST /auth/login should return JWT token."""
    payload = {"email": "user@example.com", "password": "secret123"}
    
    response = client.post("/auth/login", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_with_invalid_credentials(client):
    """POST /auth/login should return 401 for wrong password."""
    payload = {"email": "user@example.com", "password": "wrong"}
    
    response = client.post("/auth/login", json=payload)
    
    assert response.status_code == 401
    error = response.json()
    assert "invalid credentials" in error["detail"].lower()
```

---

### 2. Test Protected Endpoints

```python
def test_protected_route_requires_auth(client):
    """GET /api/profile should require authentication."""
    response = client.get("/api/profile")
    
    assert response.status_code == 401

def test_protected_route_with_valid_token(client):
    """GET /api/profile should work with valid JWT."""
    # Login to get token
    login_response = client.post("/auth/login", json={
        "email": "user@example.com",
        "password": "secret123"
    })
    token = login_response.json()["access_token"]
    
    # Call protected route
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/profile", headers=headers)
    
    assert response.status_code == 200
    assert response.json()["email"] == "user@example.com"
```

---

### 3. Auth Fixture

```python
@pytest.fixture
def authenticated_client(client):
    """TestClient with valid JWT token."""
    # Login
    login_response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    token = login_response.json()["access_token"]
    
    # Add token to headers
    client.headers.update({"Authorization": f"Bearer {token}"})
    return client

def test_with_auth(authenticated_client):
    """Test using authenticated client."""
    response = authenticated_client.get("/api/profile")
    assert response.status_code == 200
```

---

## Async Testing

### 1. Async Test Functions

```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_async_endpoint():
    """Test async endpoint with async client."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/api/habits")
        assert response.status_code == 200
```

---

### 2. Async Fixtures

```python
@pytest.fixture
async def async_client():
    """Async test client fixture."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client

@pytest.mark.asyncio
async def test_with_async_fixture(async_client):
    """Test using async client fixture."""
    response = await async_client.get("/api/habits")
    assert response.status_code == 200
```

---

## Response Validation

### 1. JSON Schema Validation

```python
def test_habit_response_has_required_fields(client):
    """Habit response should have all required fields."""
    response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    
    assert response.status_code == 201
    habit = response.json()
    
    # Required fields
    assert "id" in habit
    assert "name" in habit
    assert "color" in habit
    assert "created_at" in habit
    assert "updated_at" in habit
    
    # Types
    assert isinstance(habit["id"], int)
    assert isinstance(habit["name"], str)
    assert isinstance(habit["created_at"], str)
```

---

### 2. Pydantic Schema Validation

```python
from app.schemas import HabitResponse

def test_response_matches_pydantic_schema(client):
    """Response should match Pydantic schema."""
    response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    
    # Parse response with Pydantic
    habit = HabitResponse(**response.json())
    
    assert habit.name == "Exercise"
    assert habit.color == "#10B981"
```

---

## Headers and Cookies

### 1. Test Custom Headers

```python
def test_custom_header_required(client):
    """API should require X-API-Key header."""
    response = client.get("/api/protected")
    assert response.status_code == 401
    
    headers = {"X-API-Key": "secret123"}
    response = client.get("/api/protected", headers=headers)
    assert response.status_code == 200
```

---

### 2. Test Cookies

```python
def test_sets_session_cookie(client):
    """Login should set session cookie."""
    response = client.post("/auth/login", json={
        "email": "user@example.com",
        "password": "secret123"
    })
    
    assert "session" in response.cookies

def test_cookie_authentication(client):
    """Subsequent requests should use session cookie."""
    # Login (sets cookie)
    client.post("/auth/login", json={"email": "user@example.com", "password": "secret123"})
    
    # Request with cookie (automatically included)
    response = client.get("/api/profile")
    assert response.status_code == 200
```

---

## Query Parameters

### 1. Test Filtering

```python
def test_filter_habits_by_color(client, habit_factory):
    """GET /api/habits?color=#10B981 should filter by color."""
    habit_factory(name="Exercise", color="#10B981")
    habit_factory(name="Reading", color="#3B82F6")
    
    response = client.get("/api/habits", params={"color": "#10B981"})
    
    habits = response.json()
    assert len(habits) == 1
    assert habits[0]["name"] == "Exercise"
```

---

### 2. Test Pagination

```python
def test_pagination(client, habit_factory):
    """GET /api/habits?skip=2&limit=2 should paginate."""
    for i in range(5):
        habit_factory(name=f"Habit {i}")
    
    response = client.get("/api/habits", params={"skip": 2, "limit": 2})
    
    habits = response.json()
    assert len(habits) == 2
    assert habits[0]["name"] == "Habit 2"
    assert habits[1]["name"] == "Habit 3"
```

---

### 3. Test Sorting

```python
def test_sort_by_name(client, habit_factory):
    """GET /api/habits?sort=name should sort alphabetically."""
    habit_factory(name="Zumba")
    habit_factory(name="Archery")
    habit_factory(name="Meditation")
    
    response = client.get("/api/habits", params={"sort": "name"})
    
    habits = response.json()
    assert habits[0]["name"] == "Archery"
    assert habits[1]["name"] == "Meditation"
    assert habits[2]["name"] == "Zumba"
```

---

## File Upload Testing

### 1. Test File Upload

```python
def test_upload_image(client):
    """POST /api/upload should accept image file."""
    file_content = b"fake image content"
    files = {"file": ("test.jpg", file_content, "image/jpeg")}
    
    response = client.post("/api/upload", files=files)
    
    assert response.status_code == 201
    data = response.json()
    assert "url" in data

def test_upload_validates_file_type(client):
    """POST /api/upload should reject non-image files."""
    file_content = b"not an image"
    files = {"file": ("test.txt", file_content, "text/plain")}
    
    response = client.post("/api/upload", files=files)
    
    assert response.status_code == 422
```

---

## Dependency Override Patterns

### 1. Override Database

```python
# Already covered in TestClient setup above
# See conftest.py example
```

---

### 2. Override Authentication

```python
from app.dependencies import get_current_user

@pytest.fixture
def mock_user():
    return {"id": 1, "email": "test@example.com"}

@pytest.fixture
def client_with_mock_auth(client, mock_user):
    """Client that bypasses authentication."""
    def override_get_current_user():
        return mock_user
    
    app.dependency_overrides[get_current_user] = override_get_current_user
    yield client
    app.dependency_overrides.clear()

def test_protected_route_with_mock_auth(client_with_mock_auth):
    """Test protected route without real login."""
    response = client_with_mock_auth.get("/api/profile")
    assert response.status_code == 200
```

---

### 3. Override External Services

```python
from app.dependencies import get_email_service

@pytest.fixture
def mock_email_service():
    """Mock email service for testing."""
    from unittest.mock import Mock
    service = Mock()
    service.send_email.return_value = True
    return service

@pytest.fixture
def client_with_mock_email(client, mock_email_service):
    """Client with mocked email service."""
    def override_email_service():
        return mock_email_service
    
    app.dependency_overrides[get_email_service] = override_email_service
    yield client
    app.dependency_overrides.clear()

def test_signup_sends_email(client_with_mock_email, mock_email_service):
    """Signup should send confirmation email."""
    client_with_mock_email.post("/auth/signup", json={
        "email": "new@example.com",
        "password": "secret123"
    })
    
    mock_email_service.send_email.assert_called_once()
```

---

## Test Organization

### Directory Structure

```
tests/
├── conftest.py                    # Shared fixtures (TestClient, database)
├── integration/
│   ├── conftest.py                # Integration-specific fixtures
│   ├── test_api_habits.py         # Habits endpoint tests
│   ├── test_api_completions.py    # Completions endpoint tests
│   └── test_auth.py               # Authentication tests
```

---

### Class-Based Organization

```python
class TestHabitsAPI:
    """Tests for /api/habits endpoints."""
    
    def test_create_habit(self, client):
        response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
        assert response.status_code == 201
    
    def test_list_habits(self, client):
        response = client.get("/api/habits")
        assert response.status_code == 200
    
    def test_get_habit(self, client, sample_habit):
        response = client.get(f"/api/habits/{sample_habit['id']}")
        assert response.status_code == 200


class TestHabitValidation:
    """Tests for habit validation rules."""
    
    def test_name_required(self, client):
        response = client.post("/api/habits", json={"color": "#10B981"})
        assert response.status_code == 422
    
    def test_color_required(self, client):
        response = client.post("/api/habits", json={"name": "Exercise"})
        assert response.status_code == 422
```

---

## Running Tests

```bash
# Run all integration tests
pytest tests/integration/

# Run specific file
pytest tests/integration/test_api_habits.py

# Run specific test
pytest tests/integration/test_api_habits.py::test_create_habit

# Verbose output
pytest tests/integration/ -v

# Show API responses
pytest tests/integration/ -s

# Run with coverage
pytest tests/integration/ --cov=app.routers
```

---

## Best Practices

### ✅ Do:
- **Use in-memory SQLite** for speed
- **Test full request/response cycle**
- **Verify database persistence**
- **Test both success and error cases**
- **Use dependency overrides** for external services
- **Keep tests independent** (no shared state)

### ❌ Don't:
- **Test implementation details** (test API contract)
- **Use production database**
- **Share state between tests** (use fresh fixtures)
- **Skip error case testing**
- **Ignore response status codes**

---

## Common Patterns

### Setup-Execute-Verify

```python
def test_update_habit_name(client):
    # Setup: Create habit
    create_response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    habit_id = create_response.json()["id"]
    
    # Execute: Update habit
    update_response = client.put(f"/api/habits/{habit_id}", json={"name": "Morning Exercise"})
    
    # Verify: Check response and database
    assert update_response.status_code == 200
    assert update_response.json()["name"] == "Morning Exercise"
```

---

### Test Multiple Related Operations

```python
def test_complete_workflow(client):
    """Test creating habit, adding completions, calculating streak."""
    # Create habit
    habit_response = client.post("/api/habits", json={"name": "Exercise", "color": "#10B981"})
    habit_id = habit_response.json()["id"]
    
    # Add completions
    client.post("/api/completions", json={"habit_id": habit_id, "completed_date": "2025-01-13"})
    client.post("/api/completions", json={"habit_id": habit_id, "completed_date": "2025-01-14"})
    client.post("/api/completions", json={"habit_id": habit_id, "completed_date": "2025-01-15"})
    
    # Get habit with streak
    response = client.get(f"/api/habits/{habit_id}")
    assert response.json()["current_streak"] == 3
```

---

## Source References

**Extracted from:**
- Habit Tracker: `backend/tests/conftest.py` (TestClient + database setup)
- Habit Tracker: `backend/tests/test_api_habits.py` (integration test examples)
- Habit Tracker: `backend/tests/test_api_completions.py` (POST/DELETE patterns)
- Habit Tracker: `.claude/reference/testing-and-logging.md` (FastAPI testing patterns)

**Related Patterns:**
- 📎 [Testing Pyramid](testing-pyramid.md) - Overall testing strategy
- 📎 [Pytest Patterns](pytest-patterns.md) - Unit testing basics
- 📎 [Unit Testing Patterns](unit-testing-patterns.md) - Pure function testing

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0
