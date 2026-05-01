# Models vs Schemas - Overview

**Pattern Type:** Architecture - Layer Separation  
**Complexity:** Low  
**Read Time:** 2-3 minutes  
**Best For:** FastAPI + SQLAlchemy apps requiring clean separation between database and API layers

---

## When to Use Models vs Schemas

### ✅ Use Separate Models + Schemas for:
- **FastAPI + SQLAlchemy** - Standard pattern for REST APIs
- **Exposing APIs** - Prevent leaking database structure
- **Field validation** - Different validation for create/update/response
- **Security** - Hide sensitive fields (password_hash, internal IDs)
- **Flexibility** - Change API without database migration

### ❌ Don't Use Separate Models + Schemas for:
- **psycopg without ORM** - No models, only Pydantic schemas
- **Internal services** - Same codebase, no API surface
- **Quick prototypes** - Can return models directly for MVPs

### The Two Layers

| Layer | Purpose | Technology | Location |
|-------|---------|------------|----------|
| **Models** | Database storage | SQLAlchemy | `app/models.py` |
| **Schemas** | API validation | Pydantic | `app/schemas.py` |

**Models**: How data is **stored** (tables, columns, constraints)  
**Schemas**: How data is **transmitted** (request validation, response serialization)

---

## Why Separate?

### Without Separation (Anti-Pattern)

```python
# models.py
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String)
    password_hash = Column(String)  # 😱

# routes.py
@router.get("/users/{user_id}")
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).first()
    return user  # ❌ Exposes password_hash!
```

### With Separation (Correct)

```python
# models.py - Database layer
class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str]
    password_hash: Mapped[str]  # Internal only

# schemas.py - API layer
class UserResponse(BaseModel):
    id: int
    email: str
    # password_hash NOT included ✅
    
    model_config = {"from_attributes": True}

# routes.py
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).first()
    return user  # ✅ Pydantic filters to UserResponse fields
```

---

## Essential Pattern

### Models (Database Layer)

```python
# app/models.py
from sqlalchemy import String, Text, ForeignKey, CheckConstraint
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from datetime import datetime
from typing import List

class Base(DeclarativeBase):
    pass

class Habit(Base):
    """Habit database model."""
    __tablename__ = "habits"
    
    # Primary key
    id: Mapped[int] = mapped_column(primary_key=True)
    
    # Fields
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    frequency: Mapped[str] = mapped_column(String(20), default="daily")
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    completions: Mapped[List["Completion"]] = relationship(
        back_populates="habit",
        cascade="all, delete-orphan",
        lazy="selectin"
    )
    
    # Constraints
    __table_args__ = (
        CheckConstraint("frequency IN ('daily', 'weekly', 'custom')", name="valid_frequency"),
    )
```

### Schemas (API Layer)

```python
# app/schemas.py
from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional

class HabitBase(BaseModel):
    """Shared habit fields."""
    name: str = Field(min_length=1, max_length=255)
    description: Optional[str] = None
    frequency: str = Field(default="daily", pattern="^(daily|weekly|custom)$")

class HabitCreate(HabitBase):
    """Schema for POST /habits."""
    pass

class HabitUpdate(BaseModel):
    """Schema for PATCH /habits/{id}. All fields optional."""
    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    description: Optional[str] = None
    frequency: Optional[str] = None

class HabitResponse(HabitBase):
    """Schema for GET /habits. Includes database-generated fields."""
    id: int
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}  # Enable ORM conversion
```

---

## Schema Variants

### Base + Create/Update/Response Pattern

```python
# Base: Shared fields
class UserBase(BaseModel):
    email: EmailStr

# Create: Fields user provides
class UserCreate(UserBase):
    password: str = Field(min_length=8)

# Update: All optional (partial update)
class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(default=None, min_length=8)

# Response: Includes database-generated fields
class UserResponse(UserBase):
    id: int
    created_at: datetime
    
    model_config = {"from_attributes": True}
```

**Why 4 schemas?**
- **Base**: Avoid duplication of common fields
- **Create**: Validation for new records (password required)
- **Update**: All optional for PATCH (no password required)
- **Response**: What API returns (includes id, timestamps, excludes password)

---

## Conversion Between Layers

### ORM to Pydantic (Database → API)

```python
@router.get("/{habit_id}", response_model=HabitResponse)
async def get_habit(habit_id: int, db: Session = Depends(get_db)):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if not habit:
        raise HTTPException(404, "Habit not found")
    
    # Pydantic auto-converts ORM model to HabitResponse
    return habit  # ✅ Works because model_config = {"from_attributes": True}
```

### Pydantic to ORM (API → Database)

```python
@router.post("", response_model=HabitResponse, status_code=201)
async def create_habit(habit: HabitCreate, db: Session = Depends(get_db)):
    # Convert Pydantic schema to ORM model
    db_habit = Habit(
        name=habit.name,
        description=habit.description,
        frequency=habit.frequency
    )
    
    db.add(db_habit)
    db.commit()
    db.refresh(db_habit)  # Load generated id, timestamps
    
    return db_habit  # ✅ Converts to HabitResponse
```

**Alternative**: Use `.model_dump()`:
```python
habit_data = habit.model_dump()
db_habit = Habit(**habit_data)
```

---

## Validation Patterns

### Field Validation

```python
class HabitCreate(BaseModel):
    name: str
    target_days: Optional[int] = None
    
    @field_validator("name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("name cannot be empty")
        return v.strip()
    
    @field_validator("target_days")
    @classmethod
    def validate_range(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and (v < 1 or v > 7):
            raise ValueError("target_days must be 1-7")
        return v
```

### Cross-Field Validation

```python
from pydantic import model_validator

class HabitCreate(BaseModel):
    frequency: str
    target_days: Optional[int] = None
    
    @model_validator(mode="after")
    def validate_custom_frequency(self):
        if self.frequency == "custom" and self.target_days is None:
            raise ValueError("target_days required when frequency='custom'")
        return self
```

---

## Top 5 Gotchas

### 1. Forgetting `from_attributes = True`
**Problem**: `ValueError: Model has no attribute 'dict'`

**Solution**:
```python
class UserResponse(BaseModel):
    model_config = {"from_attributes": True}  # Required for ORM conversion!
```

### 2. Returning ORM Model Without response_model
**Problem**: Exposes all fields including sensitive data

**Solution**:
```python
@router.get("/users/{id}", response_model=UserResponse)  # ✅ Filters fields
```

### 3. Reusing Create Schema for Update
**Problem**: All fields required in PATCH request

**Solution**: Separate `UserUpdate` with all fields optional

### 4. N+1 Query with Relationships
**Problem**: Slow API when including relationships

**Solution**:
```python
# In model: use lazy="selectin" for eager loading
completions: Mapped[List["Completion"]] = relationship(lazy="selectin")
```

### 5. Validation Errors Not Descriptive
**Problem**: Generic "validation error" messages

**Solution**: Add custom error messages in Field()
```python
name: str = Field(min_length=1, description="Habit name (1-255 chars)")
```

---

## Quick Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `from_attributes` not working | Using old Pydantic v1 | Update to Pydantic v2, use `model_config` |
| Sensitive fields exposed | No response_model | Add `response_model=UserResponse` to route |
| All fields required in PATCH | Reusing Create schema | Create separate Update schema with Optional fields |
| Slow API with relationships | N+1 queries | Use `lazy="selectin"` in relationship() |
| Generic validation errors | No custom messages | Add descriptions to Field() |

---

## 📎 Complete Reference

For comprehensive implementation details:

**📎 Reference**: [models-schemas-reference.md](models-schemas-reference.md)  
**When to load**: Complex validation, nested relationships, computed fields  
**Key content**:
- Complete model patterns (relationships, constraints, indexes)
- All schema variants (Base, Create, Update, Response, WithRelations)
- Validation patterns (field-level, cross-field, computed fields)
- Exclude sensitive fields pattern
- Nested relationships pattern
- Testing patterns (with models and schemas)
- Best practices and troubleshooting

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Extracted From:** Production MVP (SQLAlchemy 2.0 + Pydantic v2)
