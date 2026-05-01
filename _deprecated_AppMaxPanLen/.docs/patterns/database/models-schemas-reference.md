# Models vs Schemas Pattern

**Pattern Type:** Architecture - Layer Separation  
**Complexity:** Low  
**Best For:** FastAPI + ORM applications requiring clear separation between database and API layers

---

## Overview

The Models vs Schemas pattern separates **database concerns** (SQLAlchemy models) from **API concerns** (Pydantic schemas). This creates clean layer boundaries and prevents database implementation details from leaking into API contracts.

### The Two Layers

| Layer | Purpose | Technology | Location |
|-------|---------|------------|----------|
| **Models** | Database representation | SQLAlchemy | `app/models.py` |
| **Schemas** | API validation & serialization | Pydantic | `app/schemas.py` |

**Models** define how data is **stored**:
- Table structure, columns, types
- Relationships, foreign keys
- Constraints, indexes
- Database-specific features

**Schemas** define how data is **transmitted**:
- Request validation (what clients send)
- Response serialization (what API returns)
- Field-level validation rules
- API documentation (OpenAPI spec)

---

## Why Separate?

### Without Separation (Anti-Pattern)

```python
# app/models.py - Using ORM models in API responses
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, nullable=False)
    password_hash = Column(String, nullable=False)  # 😱 Exposed!
    credentials = relationship("Credential", back_populates="user")


# app/routes.py - Returning ORM model directly
@router.get("/users/{user_id}")
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    return user  # ❌ Exposes password_hash, eager-loads credentials!
```

**Problems:**
- Exposes sensitive fields (`password_hash`)
- Leaks database structure (relationships, internal IDs)
- Can't customize response format
- N+1 query issues with relationships
- API changes require database migrations

---

### With Separation (Correct)

```python
# app/models.py - Database layer
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    password_hash: Mapped[str] = mapped_column(String, nullable=False)
    is_active: Mapped[bool] = mapped_column(default=True)


# app/schemas.py - API layer
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class UserResponse(BaseModel):
    """User data returned by API."""
    id: int
    email: EmailStr
    is_active: bool
    
    model_config = {"from_attributes": True}  # Enable ORM mode


class UserCreate(BaseModel):
    """Data required to create user."""
    email: EmailStr
    password: str = Field(min_length=8)


# app/routes.py - Using schemas
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(404, "User not found")
    return user  # ✅ Pydantic serializes using UserResponse
```

**Benefits:**
- Sensitive fields (`password_hash`) never exposed
- API contract independent of database schema
- Custom validation per operation (Create, Update)
- Clear documentation (OpenAPI spec from Pydantic)
- Refactor database without breaking API

---

## Pattern Structure

### File Organization

```
app/
├── models.py          # SQLAlchemy models (database layer)
├── schemas.py         # Pydantic schemas (API layer)
├── database.py        # Database connection
└── routes/
    ├── users.py       # User endpoints (uses schemas)
    └── habits.py      # Habit endpoints (uses schemas)
```

---

## SQLAlchemy Models (Database Layer)

### Model Definition

```python
# app/models.py
from sqlalchemy import String, Text, CheckConstraint, UniqueConstraint, ForeignKey
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from datetime import datetime
from typing import List


class Base(DeclarativeBase):
    """Base class for all models."""
    pass


class Habit(Base):
    """Habit database model.
    
    Represents a habit that can be tracked daily.
    """
    __tablename__ = "habits"
    
    # Primary key
    id: Mapped[int] = mapped_column(primary_key=True)
    
    # Core fields
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    frequency: Mapped[str] = mapped_column(
        String(20), 
        nullable=False,
        default="daily"
    )
    target_days_per_week: Mapped[int | None] = mapped_column()
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow, 
        onupdate=datetime.utcnow
    )
    
    # Relationships
    completions: Mapped[List["Completion"]] = relationship(
        back_populates="habit",
        cascade="all, delete-orphan",  # Delete completions when habit deleted
        lazy="selectin"  # Eager load to avoid N+1 queries
    )
    
    # Constraints
    __table_args__ = (
        CheckConstraint(
            "frequency IN ('daily', 'weekly', 'custom')",
            name="valid_frequency"
        ),
        CheckConstraint(
            "target_days_per_week IS NULL OR (target_days_per_week >= 1 AND target_days_per_week <= 7)",
            name="valid_target_days"
        ),
    )


class Completion(Base):
    """Completion database model.
    
    Represents a single completion of a habit on a specific date.
    """
    __tablename__ = "completions"
    
    # Primary key
    id: Mapped[int] = mapped_column(primary_key=True)
    
    # Foreign key
    habit_id: Mapped[int] = mapped_column(
        ForeignKey("habits.id", ondelete="CASCADE"),
        nullable=False
    )
    
    # Completion data
    completed_at: Mapped[str] = mapped_column(String(10), nullable=False)  # YYYY-MM-DD
    notes: Mapped[str | None] = mapped_column(Text)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    
    # Relationships
    habit: Mapped["Habit"] = relationship(back_populates="completions")
    
    # Constraints
    __table_args__ = (
        UniqueConstraint("habit_id", "completed_at", name="unique_completion_per_day"),
    )
```

**Key features:**
- **Mapped types**: Type hints for column types (`Mapped[int]`, `Mapped[str | None]`)
- **Relationships**: Define how tables relate (`back_populates`, `cascade`)
- **Constraints**: Database-level validation (`CheckConstraint`, `UniqueConstraint`)
- **Indexes**: Auto-created on foreign keys (recommended to add explicit indexes)

---

## Pydantic Schemas (API Layer)

### Schema Variants

```python
# app/schemas.py
from pydantic import BaseModel, Field, field_validator, EmailStr
from datetime import datetime, date
from typing import Optional, List


# ============================================================================
# Habit Schemas
# ============================================================================

class HabitBase(BaseModel):
    """Shared habit fields."""
    name: str = Field(min_length=1, max_length=255)
    description: Optional[str] = None
    frequency: str = Field(default="daily", pattern="^(daily|weekly|custom)$")
    target_days_per_week: Optional[int] = Field(default=None, ge=1, le=7)


class HabitCreate(HabitBase):
    """Schema for creating a habit.
    
    Used in POST /habits
    """
    pass  # Inherits all fields from HabitBase


class HabitUpdate(BaseModel):
    """Schema for updating a habit.
    
    Used in PATCH /habits/{habit_id}
    All fields optional (partial update).
    """
    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    description: Optional[str] = None
    frequency: Optional[str] = Field(default=None, pattern="^(daily|weekly|custom)$")
    target_days_per_week: Optional[int] = Field(default=None, ge=1, le=7)


class HabitResponse(HabitBase):
    """Schema for habit responses.
    
    Used in GET /habits, GET /habits/{habit_id}, POST /habits
    Returned by API - includes database-generated fields.
    """
    id: int
    created_at: datetime
    updated_at: datetime
    current_streak: Optional[int] = None  # Computed field
    
    model_config = {
        "from_attributes": True  # Enable conversion from ORM models
    }


class HabitWithCompletions(HabitResponse):
    """Habit with completion history.
    
    Used in GET /habits/{habit_id}?include_completions=true
    """
    completions: List["CompletionResponse"]


# ============================================================================
# Completion Schemas
# ============================================================================

class CompletionBase(BaseModel):
    """Shared completion fields."""
    completed_at: str = Field(pattern=r"^\d{4}-\d{2}-\d{2}$")  # YYYY-MM-DD
    notes: Optional[str] = None
    
    @field_validator("completed_at")
    @classmethod
    def validate_date_format(cls, v: str) -> str:
        """Validate date is valid ISO format."""
        try:
            datetime.strptime(v, "%Y-%m-%d")
            return v
        except ValueError:
            raise ValueError("completed_at must be YYYY-MM-DD format")


class CompletionCreate(CompletionBase):
    """Schema for creating a completion.
    
    Used in POST /habits/{habit_id}/completions
    """
    pass


class CompletionResponse(CompletionBase):
    """Schema for completion responses."""
    id: int
    habit_id: int
    created_at: datetime
    
    model_config = {"from_attributes": True}


class SkipCreate(BaseModel):
    """Schema for skipping a day.
    
    Used in POST /habits/{habit_id}/skip
    """
    skipped_at: str = Field(pattern=r"^\d{4}-\d{2}-\d{2}$")
    reason: Optional[str] = Field(default=None, max_length=500)
```

**Schema types:**
- **Base**: Shared fields (abstract base class)
- **Create**: Fields required for creation (POST)
- **Update**: Fields for updates (PATCH) - all optional
- **Response**: Fields returned by API (includes `id`, timestamps)
- **WithRelations**: Response with related objects (e.g., completions)

---

## Conversion Between Layers

### ORM to Pydantic (Database → API)

```python
# app/routes/habits.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/habits", tags=["habits"])


@router.get("/{habit_id}", response_model=schemas.HabitResponse)
async def get_habit(habit_id: int, db: Session = Depends(get_db)):
    """Get habit by ID.
    
    Returns:
        HabitResponse with id, name, timestamps from database
    """
    habit = db.query(models.Habit).filter(models.Habit.id == habit_id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    
    # Pydantic automatically converts ORM model to HabitResponse
    # model_config = {"from_attributes": True} enables this
    return habit  # ✅ Serializes using HabitResponse schema
```

**Key:** `model_config = {"from_attributes": True}` (Pydantic v2) enables ORM conversion.

---

### Pydantic to ORM (API → Database)

```python
@router.post("", response_model=schemas.HabitResponse, status_code=201)
async def create_habit(habit: schemas.HabitCreate, db: Session = Depends(get_db)):
    """Create new habit.
    
    Args:
        habit: HabitCreate schema with validated data
    
    Returns:
        HabitResponse with created habit (includes id, timestamps)
    """
    # Convert Pydantic schema to ORM model
    db_habit = models.Habit(
        name=habit.name,
        description=habit.description,
        frequency=habit.frequency,
        target_days_per_week=habit.target_days_per_week
    )
    
    db.add(db_habit)
    db.commit()
    db.refresh(db_habit)  # Load generated id, timestamps
    
    return db_habit  # ✅ Serializes using HabitResponse schema
```

**Alternative:** Use `.model_dump()` to convert schema to dict:

```python
# Convert schema to dict
habit_data = habit.model_dump()

# Create ORM model from dict
db_habit = models.Habit(**habit_data)
```

---

## Validation Patterns

### Field-Level Validation

```python
from pydantic import field_validator

class HabitCreate(BaseModel):
    name: str
    frequency: str
    target_days_per_week: Optional[int] = None
    
    @field_validator("name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        """Validate name is not empty or whitespace."""
        if not v or not v.strip():
            raise ValueError("name cannot be empty")
        return v.strip()
    
    @field_validator("target_days_per_week")
    @classmethod
    def validate_target_days(cls, v: Optional[int]) -> Optional[int]:
        """Validate target_days_per_week is 1-7 if provided."""
        if v is not None and (v < 1 or v > 7):
            raise ValueError("target_days_per_week must be between 1 and 7")
        return v
```

---

### Cross-Field Validation

```python
from pydantic import model_validator

class HabitCreate(BaseModel):
    name: str
    frequency: str
    target_days_per_week: Optional[int] = None
    
    @model_validator(mode="after")
    def validate_frequency_target(self):
        """Validate target_days_per_week required for custom frequency."""
        if self.frequency == "custom" and self.target_days_per_week is None:
            raise ValueError(
                "target_days_per_week required when frequency is 'custom'"
            )
        if self.frequency != "custom" and self.target_days_per_week is not None:
            raise ValueError(
                "target_days_per_week only allowed when frequency is 'custom'"
            )
        return self
```

---

### Computed Fields

```python
from pydantic import computed_field

class HabitResponse(BaseModel):
    id: int
    name: str
    created_at: datetime
    
    # Computed field - not stored in database
    @computed_field
    @property
    def days_active(self) -> int:
        """Calculate days since habit created."""
        return (datetime.utcnow() - self.created_at).days
```

**Note:** Computed fields calculate values at serialization time, not stored in database.

---

## Common Patterns

### Pattern 1: Base + Variants

```python
# Base schema with shared fields
class UserBase(BaseModel):
    email: EmailStr
    is_active: bool = True


# Create: Only fields user provides
class UserCreate(UserBase):
    password: str = Field(min_length=8)


# Update: All fields optional (partial update)
class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = None
    password: Optional[str] = Field(default=None, min_length=8)


# Response: Includes database-generated fields
class UserResponse(UserBase):
    id: int
    created_at: datetime
    
    model_config = {"from_attributes": True}
```

---

### Pattern 2: Nested Relationships

```python
# Completion response (no nesting)
class CompletionResponse(BaseModel):
    id: int
    habit_id: int
    completed_at: str
    
    model_config = {"from_attributes": True}


# Habit with nested completions
class HabitWithCompletions(BaseModel):
    id: int
    name: str
    completions: List[CompletionResponse]  # Nested schema
    
    model_config = {"from_attributes": True}


# Endpoint
@router.get("/{habit_id}", response_model=HabitWithCompletions)
async def get_habit_with_completions(habit_id: int, db: Session = Depends(get_db)):
    habit = db.query(models.Habit).filter(models.Habit.id == habit_id).first()
    return habit  # Pydantic serializes habit + completions
```

---

### Pattern 3: Exclude Sensitive Fields

```python
# Model includes sensitive data
class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str]
    password_hash: Mapped[str]  # Sensitive!
    api_key: Mapped[str]  # Sensitive!


# Response excludes sensitive fields
class UserResponse(BaseModel):
    id: int
    email: str
    # password_hash NOT included ✅
    # api_key NOT included ✅
    
    model_config = {"from_attributes": True}


# Pydantic only serializes fields defined in schema
@router.get("/me", response_model=UserResponse)
async def get_current_user(user: User = Depends(get_current_user)):
    return user  # password_hash, api_key automatically excluded
```

---

## Best Practices

### ✅ Do

1. **Separate files** - `models.py` for database, `schemas.py` for API
2. **Use schema variants** - `Create`, `Update`, `Response` for different operations
3. **Enable ORM mode** - `model_config = {"from_attributes": True}` for conversion
4. **Validate at API layer** - Pydantic validation in schemas
5. **Constrain at DB layer** - Database constraints in models
6. **Exclude sensitive fields** - Don't include in response schemas
7. **Use type hints** - Annotate all fields with types
8. **Document schemas** - Docstrings become OpenAPI descriptions

### ❌ Don't

1. **Don't return ORM models** - Always use response schemas
2. **Don't validate in models** - Validation belongs in schemas
3. **Don't expose relationships** - Unless intentionally included in response
4. **Don't reuse Create in Update** - Update should have all optional fields
5. **Don't mix concerns** - Keep database logic in models, API logic in schemas
6. **Don't forget `from_attributes`** - Required for ORM conversion
7. **Don't duplicate constraints** - Database constraints, Pydantic validation
8. **Don't skip type hints** - Critical for Pydantic validation

---

## Troubleshooting

### Issue: `from_attributes` not working

**Symptom:** `ValueError: Model has no attribute 'dict'`

**Solution:**
```python
# Pydantic v2 (new)
class UserResponse(BaseModel):
    model_config = {"from_attributes": True}  # ✅ Correct

# Pydantic v1 (old - deprecated)
class UserResponse(BaseModel):
    class Config:
        orm_mode = True  # ❌ Old syntax
```

---

### Issue: Nested relationships cause N+1 queries

**Symptom:** Slow API responses when including relationships

**Solution:**
```python
# In model: Use eager loading
class Habit(Base):
    completions: Mapped[List["Completion"]] = relationship(
        lazy="selectin"  # ✅ Eager load with single query
    )

# Or in query: Use joinedload
from sqlalchemy.orm import joinedload

habit = db.query(models.Habit).options(
    joinedload(models.Habit.completions)
).filter(models.Habit.id == habit_id).first()
```

---

### Issue: Validation error not descriptive

**Symptom:** Generic error messages from Pydantic

**Solution:**
```python
# Add custom error messages
class HabitCreate(BaseModel):
    name: str = Field(
        min_length=1,
        max_length=255,
        description="Habit name (1-255 characters)"
    )
    
    @field_validator("name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Habit name cannot be empty or whitespace")
        return v.strip()
```

---

## References

### Source Code
- **Production MVP Models**: `d:\_learn\Production MVP\backend\app\models.py`
  - SQLAlchemy 2.0 with Mapped types
  - Habit and Completion models
  - Relationships, constraints, indexes
  
- **Production MVP Schemas**: `d:\_learn\Production MVP\backend\app\schemas.py`
  - Pydantic v2 schemas
  - Create, Update, Response variants
  - Field validation examples

### Related Patterns
- 📎 [SQLite Setup](./sqlite-setup.md) - SQLAlchemy model setup
- 📎 [PostgreSQL Patterns](./postgresql-patterns.md) - psycopg without ORM
- 📎 [Database Service Pattern](./service-pattern.md) - Service layer (no ORM)

### External Resources
- [Pydantic v2 Documentation](https://docs.pydantic.dev/latest/)
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [FastAPI Response Models](https://fastapi.tiangolo.com/tutorial/response-model/)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Production MVP (SQLAlchemy 2.0 + Pydantic v2)
