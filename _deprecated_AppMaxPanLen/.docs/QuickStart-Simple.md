# QuickStart: Simple Project

**Goal:** Build a working MVP in 1-3 days with minimal complexity.

**Best for:** Personal projects, MVPs, learning, proof-of-concepts, local development

**Reference project:** [habit-tracker](../examples/REFERENCE_PROJECTS.md#1-habit-tracker)

---

## What You'll Build

A single-service web application with:
- FastAPI backend (Python)
- React frontend (JavaScript/TypeScript)
- SQLite database
- Basic testing
- Local development setup

**Time estimate:** 8-24 hours

---

## Prerequisites

**Required:**
- Python 3.11+ with uv package manager
- Node.js 20+ with npm
- Code editor (VS Code recommended)
- Git

**Installation:**
```bash
# Install uv (Python package manager)
pip install uv

# Verify installations
python --version  # Should be 3.11+
node --version    # Should be 20+
uv --version
```

---

## Step 1: Project Structure (15 minutes)

### Create Directory Structure

```bash
mkdir my-project
cd my-project

# Backend
mkdir -p backend/app/routers
mkdir -p backend/tests/unit
mkdir -p backend/tests/integration

# Frontend
mkdir -p frontend/src/components
mkdir -p frontend/src/features
mkdir -p frontend/src/lib

# Database
mkdir -p database
```

### Copy Templates

```bash
# Backend config
cp <template-path>/config/pyproject.toml.template backend/pyproject.toml

# Frontend config
cp <template-path>/config/package.json.template frontend/package.json
cp <template-path>/config/vite.config.ts.template frontend/vite.config.ts

# Database init
cp <template-path>/database/sqlite_init.sql database/init.sql
```

### Replace Placeholders

Edit copied files and replace:
- `{{ PROJECT_NAME }}` → `my-project`
- `{{ SERVICE_NAME }}` → `backend` / `frontend`
- `{{ VERSION }}` → `0.1.0`
- `{{ DESCRIPTION }}` → Your project description
- `{{ AUTHOR_NAME }}` → Your name
- `{{ PYTHON_VERSION }}` → `3.11` (or your version)
- `{{ PORT }}` → `8000` (backend)
- `{{ DEV_PORT }}` → `5173` (frontend)

---

## Step 2: Backend Setup (30 minutes)

### Initialize Backend

```bash
cd backend

# Create pyproject.toml (already copied above)
# Add dependencies for simple project
uv add fastapi uvicorn sqlalchemy pydantic pydantic-settings

# Add dev dependencies
uv add --dev pytest pytest-asyncio httpx
```

### Create Main App

**backend/app/main.py:**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .routers import items

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="My Project")

# CORS for local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(items.router, prefix="/api", tags=["items"])

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

### Create Database Module

**backend/app/database.py:**
```python
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./database/app.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)

# Execute PRAGMAs for SQLite
with engine.connect() as conn:
    conn.execute(text("PRAGMA foreign_keys=ON"))
    conn.execute(text("PRAGMA journal_mode=WAL"))
    conn.commit()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    db.execute(text("PRAGMA foreign_keys=ON"))
    try:
        yield db
    finally:
        db.close()
```

### Create Models

**backend/app/models.py:**
```python
from sqlalchemy import Column, Integer, String, DateTime, func
from .database import Base

class Item(Base):
    __tablename__ = "items"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(String, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
```

### Create Schemas

**backend/app/schemas.py:**
```python
from pydantic import BaseModel, Field
from datetime import datetime

class ItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: str | None = None

class ItemUpdate(BaseModel):
    name: str | None = None
    description: str | None = None

class ItemResponse(BaseModel):
    id: int
    name: str
    description: str | None
    created_at: datetime
    updated_at: datetime | None
    
    class Config:
        from_attributes = True
```

### Create Router

**backend/app/routers/items.py:**
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas
from ..database import get_db

router = APIRouter()

@router.get("/items", response_model=List[schemas.ItemResponse])
def list_items(db: Session = Depends(get_db)):
    return db.query(models.Item).all()

@router.post("/items", response_model=schemas.ItemResponse, status_code=201)
def create_item(item: schemas.ItemCreate, db: Session = Depends(get_db)):
    db_item = models.Item(**item.model_dump())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

@router.get("/items/{item_id}", response_model=schemas.ItemResponse)
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@router.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(item)
    db.commit()
```

### Run Backend

```bash
cd backend
uv run uvicorn app.main:app --reload --port 8000
```

Visit: http://localhost:8000/docs (Swagger UI)

📎 **Pattern reference:** [single-service-overview.md](patterns/architecture/single-service-overview.md)

---

## Step 3: Frontend Setup (30 minutes)

### Initialize Frontend

```bash
cd frontend

# Install dependencies
npm install react react-dom react-router-dom
npm install @tanstack/react-query
npm install -D @vitejs/plugin-react

# For styling (choose one)
npm install -D tailwindcss postcss autoprefixer  # Tailwind CSS
# OR
npm install @mui/material @emotion/react @emotion/styled  # Material UI
```

### Create Main App

**frontend/src/main.jsx:**
```jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import App from './App'
import './index.css'

const queryClient = new QueryClient()

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </React.StrictMode>,
)
```

**frontend/src/App.jsx:**
```jsx
import { ItemList } from './features/items/ItemList'

function App() {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold mb-4">My Project</h1>
      <ItemList />
    </div>
  )
}

export default App
```

### Create API Client

**frontend/src/lib/api.js:**
```javascript
const API_BASE = 'http://localhost:8000'

export async function fetchItems() {
  const response = await fetch(`${API_BASE}/api/items`)
  if (!response.ok) throw new Error('Failed to fetch items')
  return response.json()
}

export async function createItem(itemData) {
  const response = await fetch(`${API_BASE}/api/items`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(itemData),
  })
  if (!response.ok) throw new Error('Failed to create item')
  return response.json()
}

export async function deleteItem(itemId) {
  const response = await fetch(`${API_BASE}/api/items/${itemId}`, {
    method: 'DELETE',
  })
  if (!response.ok) throw new Error('Failed to delete item')
}
```

### Create Feature Component

**frontend/src/features/items/ItemList.jsx:**
```jsx
import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchItems, createItem, deleteItem } from '../../lib/api'

export function ItemList() {
  const queryClient = useQueryClient()
  const [newItemName, setNewItemName] = useState('')

  const { data: items = [], isLoading } = useQuery({
    queryKey: ['items'],
    queryFn: fetchItems,
  })

  const createMutation = useMutation({
    mutationFn: createItem,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['items'] })
      setNewItemName('')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteItem,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['items'] })
    },
  })

  if (isLoading) return <div>Loading...</div>

  return (
    <div>
      <form onSubmit={(e) => {
        e.preventDefault()
        if (newItemName.trim()) {
          createMutation.mutate({ name: newItemName, description: null })
        }
      }} className="mb-4">
        <input
          type="text"
          value={newItemName}
          onChange={(e) => setNewItemName(e.target.value)}
          placeholder="Item name"
          className="border p-2 mr-2"
        />
        <button type="submit" className="bg-blue-500 text-white px-4 py-2">
          Add Item
        </button>
      </form>

      <div className="grid gap-2">
        {items.map((item) => (
          <div key={item.id} className="border p-4 flex justify-between">
            <div>
              <h3 className="font-bold">{item.name}</h3>
              {item.description && <p>{item.description}</p>}
            </div>
            <button
              onClick={() => deleteMutation.mutate(item.id)}
              className="text-red-500"
            >
              Delete
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}
```

### Run Frontend

```bash
cd frontend
npm run dev
```

Visit: http://localhost:5173

📎 **Pattern reference:** [tanstack-query-overview.md](patterns/frontend/tanstack-query-overview.md)

---

## Step 4: Testing (30 minutes)

### Backend Tests

**backend/tests/conftest.py:**
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.database import Base, get_db

SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test.db"

@pytest.fixture
def test_db():
    engine = create_engine(SQLALCHEMY_TEST_DATABASE_URL, connect_args={"check_same_thread": False})
    TestingSessionLocal = sessionmaker(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()
    
    app.dependency_overrides[get_db] = override_get_db
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client(test_db):
    return TestClient(app)
```

**backend/tests/integration/test_api_items.py:**
```python
def test_create_item(client):
    response = client.post("/api/items", json={"name": "Test Item"})
    assert response.status_code == 201
    assert response.json()["name"] == "Test Item"

def test_list_items(client):
    # Create item
    client.post("/api/items", json={"name": "Item 1"})
    
    # List items
    response = client.get("/api/items")
    assert response.status_code == 200
    assert len(response.json()) == 1

def test_delete_item(client):
    # Create item
    response = client.post("/api/items", json={"name": "To Delete"})
    item_id = response.json()["id"]
    
    # Delete item
    response = client.delete(f"/api/items/{item_id}")
    assert response.status_code == 204
    
    # Verify deleted
    response = client.get(f"/api/items/{item_id}")
    assert response.status_code == 404
```

### Run Tests

```bash
cd backend
uv run pytest tests/ -v
```

📎 **Pattern reference:** [pytest-overview.md](patterns/testing/pytest-overview.md)

---

## Step 5: Development Workflow

### Daily Development

**Terminal 1 (Backend):**
```bash
cd backend
uv run uvicorn app.main:app --reload --port 8000
```

**Terminal 2 (Frontend):**
```bash
cd frontend
npm run dev
```

**Terminal 3 (Tests):**
```bash
cd backend
uv run pytest tests/ -v --cov=app
```

### Git Setup

```bash
# Initialize git
git init

# Copy .gitignore
cp <template-path>/.gitignore .

# Initial commit
git add .
git commit -m "feat: initial project setup"
```

---

## Step 6: Expanding Features

### Adding Authentication

See: [Simple auth pattern example](#) (TODO: link to pattern)

### Adding More Models

1. Create model in `backend/app/models.py`
2. Create schemas in `backend/app/schemas.py`
3. Create router in `backend/app/routers/`
4. Include router in `backend/app/main.py`
5. Add tests

### Adding UI Components

1. Create component in `frontend/src/components/`
2. Create feature module in `frontend/src/features/`
3. Add API functions in `frontend/src/lib/api.js`
4. Use TanStack Query for data fetching

---

## Common Pitfalls

### ❌ Forgot SQLite PRAGMAs

**Problem:** Foreign keys not enforced, database corrupts easily

**Solution:** Always execute PRAGMAs in `get_db()`:
```python
db.execute(text("PRAGMA foreign_keys=ON"))
db.execute(text("PRAGMA journal_mode=WAL"))
```

### ❌ CORS Errors

**Problem:** Frontend can't call backend API

**Solution:** Add CORS middleware in `backend/app/main.py`:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### ❌ Using useEffect for Data Fetching

**Problem:** Race conditions, no caching, complex error handling

**Solution:** Always use TanStack Query:
```jsx
const { data, isLoading } = useQuery({
  queryKey: ['items'],
  queryFn: fetchItems,
})
```

---

## Next Steps

### When to Level Up

Your project is ready for production patterns when:
- You have real users (not just you)
- You need deployment to a server
- SQLite shows concurrency issues
- You need CI/CD automation

**Next guide:** [QuickStart-Production.md](QuickStart-Production.md)

### Growth Path

See [ArchitectureGrowthPath.md](ArchitectureGrowthPath.md) for evolution strategy from simple → production.

---

## Checklist

- [ ] Project structure created
- [ ] Backend running on localhost:8000
- [ ] Frontend running on localhost:5173
- [ ] Can create, list, and delete items
- [ ] Tests passing
- [ ] Git repository initialized
- [ ] Ready to add features

---

**Estimated Total Time:** 2-4 hours (experienced developer)

**Reference Project:** [habit-tracker](../examples/REFERENCE_PROJECTS.md#1-habit-tracker)

**Pattern Library:** [.docs/patterns/](patterns/)

**Template Version:** 1.0.0
