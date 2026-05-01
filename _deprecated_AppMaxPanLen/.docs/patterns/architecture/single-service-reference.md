# Single-Service Architecture

**Pattern Type:** Simple  
**Best For:** MVPs, prototypes, single-user apps, simple CRUD applications  
**Source:** Production MVP (simple CRUD application)  
**Complexity:** ⭐☆☆☆☆

---

## Overview

Single-service architecture combines backend API and frontend in one cohesive application, typically with a lightweight database. Perfect for getting started quickly and iterating rapidly.

**Key Characteristics:**
- One backend service (e.g., FastAPI, Express)
- One frontend application (e.g., React, Vue)
- Embedded or single database (SQLite, PostgreSQL)
- No service boundaries to manage
- Simple deployment (single container or VM)

---

## When to Use

### ✅ Ideal For:
- **MVPs and prototypes** (< 3 months development)
- **Solo developer projects**
- **Single-user applications** (habit trackers, personal tools)
- **Simple CRUD apps** with straightforward business logic
- **Learning projects** where you want to focus on features, not architecture
- **Internal tools** with limited user base (< 100 users)

### ❌ Avoid When:
- Need to scale horizontally (multiple instances)
- Multiple teams working independently
- Require different tech stacks for different features
- High availability requirements (99.9%+ uptime)
- Need to isolate failure domains

---

## Architecture Diagram

```
┌─────────────────────────────────────────────┐
│                  Browser                    │
└────────────────┬────────────────────────────┘
                 │ HTTP/HTTPS
                 ↓
┌─────────────────────────────────────────────┐
│           Single Application                │
│  ┌──────────────────────────────────────┐  │
│  │         Frontend (React)             │  │
│  │  - Components, hooks, state          │  │
│  │  - TanStack Query for data fetching  │  │
│  └──────────────┬───────────────────────┘  │
│                 │ API calls                  │
│                 ↓                           │
│  ┌──────────────────────────────────────┐  │
│  │       Backend API (FastAPI)          │  │
│  │  - REST endpoints                    │  │
│  │  - Business logic                    │  │
│  │  - Request validation (Pydantic)     │  │
│  └──────────────┬───────────────────────┘  │
│                 │ SQL queries                │
│                 ↓                           │
│  ┌──────────────────────────────────────┐  │
│  │       Database (SQLite)              │  │
│  │  - Tables, indexes                   │  │
│  │  - Single file on disk               │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

---

## Example Structure

```
project/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI entry point, app instance
│   │   ├── database.py          # DB connection, session management
│   │   ├── models.py            # SQLAlchemy ORM models
│   │   ├── schemas.py           # Pydantic request/response models
│   │   ├── logging_config.py    # Structured logging setup
│   │   └── routers/             # API endpoint modules
│   │       ├── habits.py        # /api/habits routes
│   │       └── completions.py   # /api/completions routes
│   ├── pyproject.toml           # Python dependencies (uv/pip)
│   └── tests/
│       ├── conftest.py          # Shared pytest fixtures
│       ├── test_api_habits.py   # API integration tests
│       └── test_streak.py       # Unit tests
├── frontend/
│   ├── src/
│   │   ├── App.jsx              # Root component
│   │   ├── main.jsx             # React entry point
│   │   ├── lib/
│   │   │   └── api.js           # API client functions
│   │   ├── components/          # Reusable UI components
│   │   │   └── ui/              # Base components (Button, Card)
│   │   └── features/            # Feature-based modules
│   │       ├── habits/          # Habit management feature
│   │       │   ├── components/  # Habit-specific components
│   │       │   └── hooks/       # TanStack Query hooks
│   │       └── calendar/        # Calendar feature
│   ├── package.json
│   ├── vite.config.js           # Vite bundler config
│   └── tailwind.config.js       # Tailwind CSS config
└── README.md
```

---

## Key Implementation Patterns

### 1. Database Connection

**SQLite with PRAGMAs:**
```python
# backend/app/database.py
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker

# SQLite with WAL mode for better concurrency
DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},  # Allow multi-threading
    echo=False,  # Set True for SQL debugging
)

# Enable foreign keys and WAL mode
@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_conn, connection_record):
    cursor = dbapi_conn.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.execute("PRAGMA journal_mode=WAL")
    cursor.execute("PRAGMA synchronous=NORMAL")
    cursor.close()

SessionLocal = sessionmaker(bind=engine)

def get_db():
    """Dependency for FastAPI routes."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### 2. API Endpoint Structure

**FastAPI with Pydantic:**
```python
# backend/app/routers/habits.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/api/habits", tags=["habits"])

@router.get("/", response_model=list[schemas.HabitResponse])
def list_habits(db: Session = Depends(get_db)):
    habits = db.query(models.Habit).all()
    return habits

@router.post("/", response_model=schemas.HabitResponse, status_code=201)
def create_habit(
    habit: schemas.HabitCreate,
    db: Session = Depends(get_db)
):
    db_habit = models.Habit(**habit.dict())
    db.add(db_habit)
    db.commit()
    db.refresh(db_habit)
    return db_habit
```

### 3. Frontend Data Fetching

**TanStack Query (no useEffect):**
```javascript
// frontend/src/features/habits/hooks/useHabits.js
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../../../lib/api';

export function useHabits() {
  return useQuery({
    queryKey: ['habits'],
    queryFn: () => api.get('/api/habits'),
  });
}

export function useCreateHabit() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (newHabit) => api.post('/api/habits', newHabit),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}
```

### 4. Feature-Based Frontend Organization

```
features/
├── habits/
│   ├── components/
│   │   ├── HabitList.jsx        # List display
│   │   ├── HabitForm.jsx        # Create/edit form
│   │   └── HabitCard.jsx        # Individual habit card
│   └── hooks/
│       └── useHabits.js         # TanStack Query hooks
└── calendar/
    ├── components/
    │   └── Calendar.jsx
    └── hooks/
        └── useCompletions.js
```

---

## Testing Strategy

### Backend Testing

**Fixture setup (conftest.py):**
```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient
from app.main import app
from app.database import Base, get_db

@pytest.fixture
def db_session():
    """In-memory SQLite for tests."""
    engine = create_engine("sqlite:///:memory:", echo=False)
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()

@pytest.fixture
def client(db_session):
    """TestClient with test database."""
    def override_get_db():
        yield db_session
    
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
```

**Integration testing:**
```python
def test_create_habit(client):
    response = client.post(
        "/api/habits",
        json={"name": "Exercise", "frequency": "daily"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Exercise"
    assert "id" in data
```

---

## Deployment

### Single Container (Docker)

```dockerfile
# Simple Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install backend dependencies
COPY backend/pyproject.toml .
RUN pip install .

# Copy backend code
COPY backend/app ./app

# Expose port
EXPOSE 8000

# Run server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Single VM/VPS

```bash
# Run backend
cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000

# Serve frontend (via Nginx or built into backend)
cd frontend && npm run build
# Copy dist/ to backend static files
```

---

## Scaling Considerations

### When to Evolve

Consider moving to multi-service when you experience:

1. **Team scaling** - Multiple developers stepping on each other
2. **Feature complexity** - Business logic tangled with API logic
3. **External integrations** - Need multiple provider adapters
4. **Authentication needs** - Require OAuth2/JWT with token management
5. **Horizontal scaling** - Need multiple API instances

### Evolution Path

Single-Service → **Multi-Service** → Hexagonal (if needed)

**First split:** Separate auth service
- Keeps user management independent
- Allows separate security audits
- Enables token-based session management

**Second split:** BFF pattern
- Adds security layer for frontend
- Centralizes JWT cookie handling
- Enables backend-for-frontend optimizations

📎 **Next steps:**
- [Multi-Service Architecture](multi-service.md) - When you need service boundaries
- [Hexagonal Architecture](hexagonal-architecture.md) - When you need provider flexibility

---

## Trade-offs

### Advantages ✅
- **Fast development** - No service boundaries to manage
- **Simple deployment** - One artifact, one process
- **Easy debugging** - All code in one place
- **Low operational overhead** - Single database, single service
- **Quick iterations** - Change frontend and backend together

### Disadvantages ❌
- **No isolation** - Backend failure = frontend failure
- **Scaling challenges** - Can't scale frontend/backend independently
- **Team coordination** - Hot path for merge conflicts
- **Technology lock-in** - Hard to change backend without frontend changes
- **Limited flexibility** - Can't add new tech stack easily

---

## Source References

**Extracted from:**
- Production MVP: `backend/app/` structure (complete implementation)
- Production MVP: `frontend/src/` structure (React + TanStack Query)
- Production MVP: `CLAUDE.md` (lines 1-100, architecture overview)
- Production MVP: `.claude/reference/fastapi-best-practices.md` (API patterns)
- Production MVP: `.claude/reference/sqlite-best-practices.md` (database setup)

**Related Patterns:**
- 📎 [Testing Pyramid](../testing/testing-pyramid.md) - Testing strategy
- 📎 [SQLite Setup](../database/sqlite-setup.md) - Database configuration
- 📎 [React Patterns](../frontend/react-patterns.md) - Frontend organization
- 📎 [TanStack Query](../frontend/tanstack-query.md) - Data fetching

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 6, 2026  
**Source Project:** Production MVP v1.0.0
