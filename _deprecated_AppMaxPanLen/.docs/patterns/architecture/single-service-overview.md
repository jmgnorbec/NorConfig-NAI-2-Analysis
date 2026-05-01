# Single-Service Architecture - Overview

**Pattern Type:** Simple  
**Complexity:** Beginner  
**Read Time:** ~3 minutes  
**Best For:** MVPs, prototypes, solo developers, simple CRUD apps

---

## When to Use Single-Service

### ✅ Use Single-Service For

- **MVPs and prototypes** - Ship fast, iterate quickly
- **Solo developer projects** - No coordination overhead
- **Simple CRUD applications** - Straightforward business logic
- **Learning projects** - Focus on features, not architecture
- **Internal tools** - Limited user base (< 100 users)
- **Personal apps** - Habit trackers, note-taking, personal dashboards

### ❌ Graduate to Multi-Service When

- **Multiple teams working** - Merge conflicts, coordination issues
- **Need independent deployment** - Deploy auth without restarting API
- **Different scaling needs** - API needs more resources than frontend
- **Security boundaries required** - Isolate auth from business logic
- **Technology diversity needed** - Mix Python, Node.js, Go

### vs. Other Architectures

| Architecture | Complexity | Team Size | Deployment | Best For |
|--------------|------------|-----------|------------|----------|
| **Single-Service** | ⭐ | 1-2 | Simple | MVP, prototype |
| **Multi-Service** | ⭐⭐⭐⭐ | 3+ | Complex | Scaling teams |
| **Hexagonal** | ⭐⭐⭐ | 2+ | Medium | Multi-provider |

**Key insight:** Start simple. Add complexity only when real problems emerge, not hypothetical future needs.

---

## Essential Configuration

### Tech Stack (Typical)

**Backend options:**
- Python: FastAPI + SQLAlchemy + SQLite/PostgreSQL
- Node.js: Express + Prisma + PostgreSQL
- Go: Gin + GORM + PostgreSQL

**Frontend options:**
- React + Vite + TanStack Query + Tailwind CSS
- Vue + Vite + Pinia + Tailwind CSS
- Svelte + SvelteKit + Tailwind CSS

**Database options:**
- SQLite (development, small apps)
- PostgreSQL (production, growth ready)

### Project Structure

```
project/
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI entry point
│   │   ├── database.py      # DB connection
│   │   ├── models.py        # SQLAlchemy models
│   │   ├── schemas.py       # Pydantic schemas
│   │   └── routers/         # API endpoints
│   └── tests/
└── frontend/
    ├── src/
    │   ├── App.jsx
    │   ├── lib/api.js       # API client
    │   ├── components/
    │   └── features/
    └── package.json
```

---

## Minimal Working Examples

### 1. FastAPI Backend (Python)

**backend/app/main.py:**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine
from app.models import Base
from app.routers import habits, completions

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Habit Tracker API")

# CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes
app.include_router(habits.router, prefix="/api", tags=["habits"])
app.include_router(completions.router, prefix="/api", tags=["completions"])

@app.get("/api/health")
def health():
    return {"status": "ok"}
```

**backend/app/database.py:**
```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}  # SQLite only
)

SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

**backend/app/routers/habits.py:**
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Habit
from app.schemas import HabitCreate, HabitResponse

router = APIRouter()

@router.get("/habits", response_model=list[HabitResponse])
def list_habits(db: Session = Depends(get_db)):
    return db.query(Habit).all()

@router.post("/habits", response_model=HabitResponse, status_code=201)
def create_habit(habit: HabitCreate, db: Session = Depends(get_db)):
    db_habit = Habit(**habit.model_dump())
    db.add(db_habit)
    db.commit()
    db.refresh(db_habit)
    return db_habit

@router.delete("/habits/{habit_id}", status_code=204)
def delete_habit(habit_id: int, db: Session = Depends(get_db)):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    db.delete(habit)
    db.commit()
```

**Run:**
```bash
cd backend
uvicorn app.main:app --reload --port 8000
```

### 2. React Frontend

**frontend/src/lib/api.js:**
```javascript
const API_URL = 'http://localhost:8000/api';

export async function fetchHabits() {
  const response = await fetch(`${API_URL}/habits`);
  if (!response.ok) throw new Error('Failed to fetch habits');
  return response.json();
}

export async function createHabit(habit) {
  const response = await fetch(`${API_URL}/habits`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(habit),
  });
  if (!response.ok) throw new Error('Failed to create habit');
  return response.json();
}

export async function deleteHabit(id) {
  const response = await fetch(`${API_URL}/habits/${id}`, {
    method: 'DELETE',
  });
  if (!response.ok) throw new Error('Failed to delete habit');
}
```

**frontend/src/features/habits/hooks/useHabits.js:**
```javascript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchHabits, createHabit, deleteHabit } from '@/lib/api';

export function useHabits() {
  return useQuery({
    queryKey: ['habits'],
    queryFn: fetchHabits,
  });
}

export function useCreateHabit() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: createHabit,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}

export function useDeleteHabit() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: deleteHabit,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['habits'] });
    },
  });
}
```

**frontend/src/App.jsx:**
```javascript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useHabits, useCreateHabit, useDeleteHabit } from '@/features/habits/hooks/useHabits';

const queryClient = new QueryClient();

function HabitList() {
  const { data: habits, isLoading } = useHabits();
  const createMutation = useCreateHabit();
  const deleteMutation = useDeleteHabit();

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      <h1>Habits</h1>
      <ul>
        {habits.map(habit => (
          <li key={habit.id}>
            {habit.name}
            <button onClick={() => deleteMutation.mutate(habit.id)}>
              Delete
            </button>
          </li>
        ))}
      </ul>
      <button onClick={() => createMutation.mutate({ name: 'Exercise' })}>
        Add Habit
      </button>
    </div>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <HabitList />
    </QueryClientProvider>
  );
}
```

**Run:**
```bash
cd frontend
npm run dev
```

### 3. Docker Deployment

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=sqlite:///./app.db
    volumes:
      - ./backend/app:/app/app  # Hot reload

  frontend:
    build: ./frontend
    ports:
      - "5173:5173"
    environment:
      - VITE_API_URL=http://localhost:8000
    volumes:
      - ./frontend/src:/app/src  # Hot reload
```

**Run:**
```bash
docker compose up
```

---

## Common Operations

### Database Migrations

**Without migration tool (simple apps):**
```python
# In main.py
from app.models import Base
from app.database import engine

# Create all tables
Base.metadata.create_all(bind=engine)
```

**With Alembic (production apps):**
```bash
# Initialize
alembic init migrations

# Create migration
alembic revision --autogenerate -m "Add habits table"

# Apply migration
alembic upgrade head
```

### API Testing

```bash
# Health check
curl http://localhost:8000/api/health

# Create habit
curl -X POST http://localhost:8000/api/habits \
  -H "Content-Type: application/json" \
  -d '{"name": "Exercise", "description": "Daily workout"}'

# List habits
curl http://localhost:8000/api/habits
```

### Development Workflow

```bash
# Terminal 1: Backend
cd backend
uvicorn app.main:app --reload

# Terminal 2: Frontend
cd frontend
npm run dev

# Terminal 3: Tests
cd backend
pytest
```

---

## Top 5 Gotchas

### 1. CORS Not Configured (Frontend Can't Call API) ⚠️

```python
# ❌ Wrong: No CORS (blocked by browser)
app = FastAPI()

# ✅ Correct: Allow frontend origin
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Impact:** All API calls fail with CORS error in browser console.

### 2. SQLite check_same_thread Error

```python
# ❌ Wrong: SQLite threading error
engine = create_engine("sqlite:///./app.db")

# ✅ Correct: Disable check for FastAPI
engine = create_engine(
    "sqlite:///./app.db",
    connect_args={"check_same_thread": False}
)
```

**Impact:** "SQLite objects created in a thread can only be used in that same thread"

### 3. Database Session Not Closed (Connection Leaks)

```python
# ❌ Wrong: Session never closed
def get_items():
    db = SessionLocal()
    return db.query(Item).all()  # Leak!

# ✅ Correct: Use dependency injection
from fastapi import Depends

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/items")
def get_items(db: Session = Depends(get_db)):
    return db.query(Item).all()
```

**Impact:** Database connection exhaustion, app crashes.

### 4. Frontend Hardcodes localhost (Breaks in Production)

```javascript
// ❌ Wrong: Hardcoded URL
const API_URL = 'http://localhost:8000';

// ✅ Correct: Environment variable
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';
```

**In production (.env.production):**
```
VITE_API_URL=https://api.example.com
```

**Impact:** Frontend works locally, breaks in production.

### 5. No Input Validation (Security Risk)

```python
# ❌ Wrong: Raw dict, no validation
@app.post("/habits")
def create_habit(habit: dict):
    db_habit = Habit(**habit)  # SQL injection risk!

# ✅ Correct: Pydantic validation
from pydantic import BaseModel

class HabitCreate(BaseModel):
    name: str
    description: str | None = None

@app.post("/habits")
def create_habit(habit: HabitCreate):
    db_habit = Habit(**habit.model_dump())
```

**Impact:** Security vulnerabilities, invalid data in database.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| API calls blocked | CORS not configured | Add CORSMiddleware |
| SQLite thread error | check_same_thread | Add connect_args |
| Connection leak | Session not closed | Use Depends(get_db) |
| Prod frontend broken | Hardcoded localhost | Use environment variables |
| Invalid data in DB | No validation | Use Pydantic models |

---

## Evolution Path

**When to graduate from single-service:**

1. **Team grows to 3+** → Multi-Service
2. **Need multiple providers** → Hexagonal Architecture
3. **Security boundaries needed** → Multi-Service
4. **Different scaling needs** → Multi-Service
5. **Independent deployment required** → Multi-Service

**Don't prematurely optimize!** Solve real problems, not hypothetical ones.

---

## References

📎 **Reference**: [single-service-reference.md](single-service-reference.md)  
**When to load**: Complete implementation patterns, database setup, testing strategies, deployment to VPS (~315 lines)

📎 **Related patterns**:
- [multi-service-overview.md](multi-service-overview.md) - When to split into services
- [hexagonal-architecture-overview.md](hexagonal-architecture-overview.md) - Multi-provider support
- [docker-overview.md](../deployment/docker-overview.md) - Containerization
- [docker-compose-overview.md](../deployment/docker-compose-overview.md) - Orchestration

---

**Pattern Type:** Simple  
**Last Updated:** 2026-03-07  
**Complexity:** Beginner ⭐☆☆☆☆
