# FastAPI Testing - Overview

**Pattern Type:** Integration Testing  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Testing API endpoints with real database interactions

---

## When to Use FastAPI Testing

### ✅ Use FastAPI Integration Tests When

- **Testing API endpoints** (POST, GET, PUT, DELETE)
- **Request/response validation** (Pydantic schemas)
- **Database operations through API** (CRUD via HTTP)
- **Authentication flows** (login, JWT tokens, protected routes)
- **Error handling** (4xx, 5xx responses)

### ❌ Don't Use Integration Tests When

- **Testing pure business logic** (use unit tests)
- **External API calls** (mock them or use E2E)
- **Complex calculations** (unit test them)
- **Browser behavior** (use Playwright E2E)

### vs. Unit Tests

| Aspect | Unit Tests | Integration Tests |
|--------|------------|-------------------|
| **Speed** | 1-10 ms | 50-200 ms |
| **Database** | Mocked/none | Real (in-memory SQLite) |
| **HTTP** | No | Yes (TestClient) |
| **Coverage** | Single function | API → Business Logic → Database |
| **Failures** | Logic error | Interface mismatch, DB constraints |

**Key insight:** Integration tests verify that layers work together correctly (API + database + business logic).

---

## Essential Configuration

### Installation

```bash
# Install testing dependencies
pip install pytest
pip install httpx  # Required by TestClient

# Optional: async support
pip install pytest-asyncio
```

### Test Fixtures Setup

**`tests/conftest.py`:**
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, StaticPool
from sqlalchemy.orm import sessionmaker

from app.database import Base, get_db
from app.main import app

# In-memory SQLite for tests
SQLALCHEMY_DATABASE_URL = "sqlite://"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,  # Reuse connection
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db_session():
    """Fresh database for each test."""
    Base.metadata.create_all(bind=engine)
    
    # Enable foreign keys (SQLite default is OFF)
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
    """TestClient with dependency override."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()
```

**Key points:**
- `StaticPool`: Reuses same in-memory SQLite connection
- `scope="function"`: Fresh database per test (no state leakage)
- `PRAGMA foreign_keys=ON`: Enforces foreign key constraints
- `dependency_overrides`: Injects test database into FastAPI

---

## Minimal Working Examples

### 1. Basic GET Endpoint

```python
# tests/integration/test_api_habits.py
def test_list_habits_returns_empty_initially(client):
    """GET /api/habits returns empty array initially."""
    response = client.get("/api/habits")
    
    assert response.status_code == 200
    assert response.json() == []

def test_list_habits_returns_created_habits(client):
    """GET /api/habits returns all habits."""
    # Create habits
    client.post("/api/habits", json={"name": "Exercise"})
    client.post("/api/habits", json={"name": "Meditate"})
    
    # List habits
    response = client.get("/api/habits")
    
    assert response.status_code == 200
    habits = response.json()
    assert len(habits) == 2
    assert habits[0]["name"] == "Exercise"
```

### 2. POST Endpoint with Validation

```python
def test_create_habit_returns_201(client):
    """POST /api/habits creates habit and returns 201."""
    response = client.post(
        "/api/habits",
        json={"name": "Exercise", "description": "Daily workout"}
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Exercise"
    assert data["description"] == "Daily workout"
    assert "id" in data

def test_create_habit_validates_required_fields(client):
    """POST /api/habits requires name field."""
    response = client.post("/api/habits", json={})
    
    assert response.status_code == 422  # Validation error
    error = response.json()
    assert "name" in str(error)

def test_create_habit_saves_to_database(client):
    """POST /api/habits persists habit in database."""
    client.post("/api/habits", json={"name": "Exercise"})
    
    # Verify saved
    response = client.get("/api/habits")
    habits = response.json()
    assert len(habits) == 1
    assert habits[0]["name"] == "Exercise"
```

### 3. PUT Endpoint

```python
def test_update_habit(client):
    """PUT /api/habits/:id updates habit."""
    # Create habit
    create_response = client.post(
        "/api/habits",
        json={"name": "Exercise", "description": "Old description"}
    )
    habit_id = create_response.json()["id"]
    
    # Update habit
    update_response = client.put(
        f"/api/habits/{habit_id}",
        json={"name": "Workout", "description": "New description"}
    )
    
    assert update_response.status_code == 200
    data = update_response.json()
    assert data["name"] == "Workout"
    assert data["description"] == "New description"

def test_update_nonexistent_habit_returns_404(client):
    """PUT /api/habits/999 returns 404."""
    response = client.put("/api/habits/999", json={"name": "New"})
    
    assert response.status_code == 404
```

### 4. DELETE Endpoint

```python
def test_delete_habit_removes_from_database(client):
    """DELETE /api/habits/:id removes habit."""
    # Create habit
    create_response = client.post("/api/habits", json={"name": "Exercise"})
    habit_id = create_response.json()["id"]
    
    # Delete habit
    delete_response = client.delete(f"/api/habits/{habit_id}")
    
    assert delete_response.status_code == 204
    
    # Verify removed
    list_response = client.get("/api/habits")
    assert len(list_response.json()) == 0
```

### 5. Authentication Testing

```python
def test_protected_route_requires_auth(client):
    """Protected routes return 401 without auth."""
    response = client.get("/api/protected")
    assert response.status_code == 401

def test_protected_route_with_valid_token(client):
    """Protected routes work with valid JWT."""
    # Login
    login_response = client.post(
        "/auth/login",
        json={"email": "user@example.com", "password": "password123"}
    )
    token = login_response.json()["access_token"]
    
    # Access protected route
    response = client.get(
        "/api/protected",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    assert response.status_code == 200
```

---

## Common Operations

### Testing Different HTTP Methods

```python
# GET
client.get("/api/habits")

# POST
client.post("/api/habits", json={"name": "Exercise"})

# PUT
client.put("/api/habits/1", json={"name": "Updated"})

# PATCH
client.patch("/api/habits/1", json={"name": "Partially Updated"})

# DELETE
client.delete("/api/habits/1")
```

### Testing Headers

```python
# Send custom headers
response = client.get(
    "/api/habits",
    headers={"Authorization": "Bearer token123"}
)

# Verify response headers
assert response.headers["content-type"] == "application/json"
```

### Testing Query Parameters

```python
# Send query params
response = client.get("/api/habits", params={"status": "active"})

# Multiple params
response = client.get("/api/habits", params={"status": "active", "limit": 10})
```

### Testing File Uploads

```python
def test_upload_image(client):
    files = {"file": ("test.png", open("test.png", "rb"), "image/png")}
    response = client.post("/api/upload", files=files)
    assert response.status_code == 200
```

---

## Top 5 Gotchas

### 1. Forgetting `PRAGMA foreign_keys=ON` ⚠️

```python
# ❌ Wrong: Foreign key constraints not enforced
@pytest.fixture
def db_session():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    yield session
    # Foreign keys OFF by default in SQLite!

# ✅ Correct: Enable foreign keys
@pytest.fixture
def db_session():
    Base.metadata.create_all(bind=engine)
    with engine.connect() as conn:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.commit()
    session = TestingSessionLocal()
    yield session
```

**Impact:** Tests pass but production fails with foreign key violations.

### 2. Shared Database State Across Tests

```python
# ❌ Wrong: Tests share database
@pytest.fixture(scope="module")  # Module scope!
def db_session():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    yield session
    # Never drops tables

# ✅ Correct: Function scope with cleanup
@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    yield session
    session.close()
    Base.metadata.drop_all(bind=engine)
```

**Impact:** Tests fail/pass depending on order, impossible to debug.

### 3. Not Using `StaticPool` for In-Memory SQLite

```python
# ❌ Wrong: Each request creates new in-memory DB
engine = create_engine("sqlite://")

# ✅ Correct: StaticPool reuses same connection
engine = create_engine(
    "sqlite://",
    poolclass=StaticPool,
    connect_args={"check_same_thread": False}
)
```

**Impact:** Data created in test not visible in subsequent requests.

### 4. Forgetting to Clear Dependency Overrides

```python
# ❌ Wrong: Overrides persist to other tests
@pytest.fixture
def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    yield TestClient(app)
    # Never clears overrides!

# ✅ Correct: Clear after test
@pytest.fixture
def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
```

**Impact:** Tests interfere with each other, overrides leak between tests.

### 5. Testing Business Logic in Integration Tests

```python
# ❌ Wrong: Integration test for calculation
def test_streak_calculation_with_gaps(client):
    # 50 lines of API calls to test calculation logic

# ✅ Correct: Unit test for calculation, integration for API
# Unit test
def test_streak_calculation():
    result = calculate_streak([today, today - timedelta(days=2)])
    assert result == 1

# Integration test (just verify API works)
def test_get_streak_endpoint(client):
    response = client.get("/api/habits/1/streak")
    assert response.status_code == 200
    assert "current_streak" in response.json()
```

**Impact:** Slow tests, hard to debug, violates testing pyramid.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Data not persisting | No `StaticPool` | Add `poolclass=StaticPool` |
| Foreign key violations ignored | Foreign keys disabled | Add `PRAGMA foreign_keys=ON` |
| Tests fail in random order | Shared state | Use `scope="function"` + cleanup |
| Dependency override not working | Wrong fixture order | Put `db_session` before `client` |
| 422 validation errors | Wrong request format | Check Pydantic schema requirements |

---

## References

📎 **Reference**: [fastapi-testing-reference.md](fastapi-testing-reference.md)  
**When to load**: Advanced patterns (background tasks, WebSockets, streaming responses), async testing, authentication strategies, file uploads, testing middleware, mocking external APIs (~760 lines)

📎 **Related patterns**:
- [testing-pyramid.md](testing-pyramid-overview.md) - Testing strategy
- [pytest-patterns.md](pytest-overview.md) - Pytest fundamentals
- [unit-testing-patterns.md](unit-testing-overview.md) - Unit testing business logic

---

**Pattern Type:** Integration Testing  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
