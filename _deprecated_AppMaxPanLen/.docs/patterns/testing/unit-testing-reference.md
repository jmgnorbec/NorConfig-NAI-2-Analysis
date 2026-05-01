# Unit Testing Patterns

**Pattern Type:** Unit Testing  
**Best For:** Testing pure business logic  
**Source:** Habit Tracker  
**Complexity:** ⭐⭐☆☆☆

---

## Overview

Unit testing patterns for isolated, fast tests of business logic. Covers pure function testing, TDD workflow, mocking strategies, test data builders, and best practices for maintainable unit tests.

**Key Characteristics:**
- Test single unit (function, class, module)
- No external dependencies (no database, API, filesystem)
- Fast execution (< 10ms per test)
- Deterministic results (same input → same output)
- Easy to debug (isolated failures)

---

## When to Use Unit Tests

### ✅ Unit Test These:
- **Pure functions** (calculations, transformations)
- **Business logic** (rules, workflows)
- **Validators** (data validation, constraints)
- **Utility functions** (date helpers, formatters)
- **Domain models** (entity behavior)

### ❌ Don't Unit Test These:
- **Database queries** (use integration tests)
- **API endpoints** (use integration tests)
- **External services** (use integration tests or mock)
- **Configuration loading** (integration or E2E)
- **Trivial code** (getters/setters, simple assignments)

---

## Pure Function Testing

### What is a Pure Function?

**Pure function characteristics:**
1. Same input → same output (deterministic)
2. No side effects (no state changes, I/O, mutations)
3. No external dependencies

**Example pure function:**
```python
def calculate_streak(completions: list[date]) -> int:
    """Calculate current streak from completion dates.
    
    Pure function:
    - Same input always returns same output
    - No side effects (doesn't modify input)
    - No external dependencies (no database, API calls)
    """
    if not completions:
        return 0
    
    today = date.today()
    sorted_dates = sorted(completions, reverse=True)
    
    streak = 0
    expected_date = today
    
    for completion_date in sorted_dates:
        if completion_date == expected_date:
            streak += 1
            expected_date -= timedelta(days=1)
        else:
            break
    
    return streak
```

---

### Test Pure Functions

```python
import pytest
from datetime import date, timedelta
from app.services.streak import calculate_streak

class TestStreakCalculation:
    """Tests for current streak calculation."""
    
    def test_empty_list_returns_zero(self):
        """No completions should return zero streak."""
        result = calculate_streak([])
        assert result == 0
    
    def test_single_completion_today_returns_one(self):
        """Single completion today should be streak of 1."""
        today = date.today()
        result = calculate_streak([today])
        assert result == 1
    
    def test_consecutive_days_count_as_streak(self):
        """Consecutive completions should count as streak."""
        today = date.today()
        dates = [
            today,
            today - timedelta(days=1),
            today - timedelta(days=2)
        ]
        result = calculate_streak(dates)
        assert result == 3
    
    def test_gap_breaks_streak(self):
        """Missing day should break the streak."""
        today = date.today()
        dates = [
            today,
            today - timedelta(days=2)  # Gap on yesterday
        ]
        result = calculate_streak(dates)
        assert result == 1  # Only today counts
    
    def test_future_dates_ignored(self):
        """Future completions should not count."""
        today = date.today()
        dates = [
            today + timedelta(days=1),  # Future
            today
        ]
        result = calculate_streak(dates)
        assert result == 1
    
    def test_unordered_input_handled_correctly(self):
        """Function should handle unsorted dates."""
        today = date.today()
        dates = [
            today - timedelta(days=1),
            today - timedelta(days=2),
            today  # Out of order
        ]
        result = calculate_streak(dates)
        assert result == 3
```

**Why these are good unit tests:**
- ✅ Fast (no I/O)
- ✅ Isolated (no dependencies)
- ✅ Deterministic (same input → same output)
- ✅ Test edge cases (empty, single, gaps)
- ✅ Clear intent (descriptive names)

---

## Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

**1. RED: Write failing test first**

```python
def test_calculate_completion_rate():
    """Calculate percentage of days completed."""
    total_days = 30
    completed_days = 21
    
    result = calculate_completion_rate(total_days, completed_days)
    
    assert result == 70.0  # 21/30 = 70%
```

**Run test:**
```bash
pytest tests/unit/test_streak.py::test_calculate_completion_rate
# FAIL: NameError: name 'calculate_completion_rate' is not defined
```

---

**2. GREEN: Write minimal code to pass**

```python
def calculate_completion_rate(total_days: int, completed_days: int) -> float:
    """Calculate completion rate as percentage."""
    return (completed_days / total_days) * 100
```

**Run test:**
```bash
pytest tests/unit/test_streak.py::test_calculate_completion_rate
# PASS
```

---

**3. REFACTOR: Improve code while tests pass**

```python
def calculate_completion_rate(total_days: int, completed_days: int) -> float:
    """Calculate completion rate as percentage.
    
    Args:
        total_days: Total number of days
        completed_days: Number of completed days
        
    Returns:
        Completion rate as percentage (0-100)
        
    Raises:
        ValueError: If total_days is zero or negative
    """
    if total_days <= 0:
        raise ValueError("total_days must be positive")
    
    return round((completed_days / total_days) * 100, 2)
```

**Add tests for edge cases:**
```python
def test_calculate_completion_rate_zero_days_raises():
    """Should raise error for zero total days."""
    with pytest.raises(ValueError):
        calculate_completion_rate(0, 0)

def test_calculate_completion_rate_rounds_to_two_decimals():
    """Should round to 2 decimal places."""
    result = calculate_completion_rate(3, 2)
    assert result == 66.67
```

---

### TDD Benefits

**Why TDD?**
- ✅ **Better design** - Forces thinking about interface first
- ✅ **Better coverage** - Every line has a test
- ✅ **Regression protection** - Tests prevent breaking changes
- ✅ **Documentation** - Tests show expected behavior
- ✅ **Confidence** - Refactor freely with passing tests

**When to use TDD:**
- Writing new features from scratch
- Complex business logic
- Bug fixing (write test that reproduces bug)
- API design (define interface via tests)

**When to skip TDD:**
- Exploratory coding (prototyping)
- Simple CRUD operations
- Trivial code (getters/setters)

---

## Mocking Strategies

### When to Mock

**Mock external dependencies:**
```python
# Mock these:
❌ Database calls
❌ API requests
❌ File I/O
❌ Current time/date
❌ Random numbers
❌ External services

# Don't mock these:
✅ Pure functions in same module
✅ Data structures (lists, dicts)
✅ Domain objects (dataclasses, Pydantic models)
```

---

### Mock vs Real

**Prefer real objects when possible:**

```python
# ✅ Good: Use real data structure
def test_filter_completions():
    completions = [
        {"date": "2025-01-01", "status": "completed"},
        {"date": "2025-01-02", "status": "skipped"}
    ]
    result = filter_completed(completions)
    assert len(result) == 1

# ❌ Bad: Mock simple data structure
def test_filter_completions():
    mock_completions = Mock()
    mock_completions.__iter__.return_value = iter([...])
    # Too complex for testing simple logic
```

---

### Mock External Dependencies

**Example: Mock date for deterministic tests**

```python
from unittest.mock import patch
from datetime import date

@patch('app.services.streak.date')
def test_streak_with_fixed_date(mock_date):
    """Test streak calculation with fixed date."""
    # Arrange: Fix today's date
    mock_date.today.return_value = date(2025, 1, 15)
    
    # Act
    completions = [date(2025, 1, 15), date(2025, 1, 14)]
    result = calculate_streak(completions)
    
    # Assert
    assert result == 2
```

**Alternative: Dependency injection (better)**

```python
def calculate_streak(completions: list[date], today: date | None = None) -> int:
    """Calculate current streak.
    
    Args:
        completions: List of completion dates
        today: Current date (defaults to today, injectable for testing)
    """
    if today is None:
        today = date.today()
    
    # ... rest of logic

# Test without mocking
def test_streak_with_explicit_date():
    today = date(2025, 1, 15)
    completions = [date(2025, 1, 15), date(2025, 1, 14)]
    result = calculate_streak(completions, today=today)
    assert result == 2
```

---

### Mock Service Dependencies

```python
from unittest.mock import Mock

def test_habit_service_calls_repository():
    """Service should delegate to repository."""
    # Arrange: Mock repository
    mock_repo = Mock()
    mock_repo.get_by_id.return_value = Habit(id=1, name="Exercise")
    
    # Act: Create service with mock
    service = HabitService(repository=mock_repo)
    habit = service.get_habit(1)
    
    # Assert: Verify interaction
    mock_repo.get_by_id.assert_called_once_with(1)
    assert habit.name == "Exercise"

def test_service_handles_not_found():
    """Service should handle missing habit."""
    mock_repo = Mock()
    mock_repo.get_by_id.return_value = None
    
    service = HabitService(repository=mock_repo)
    
    with pytest.raises(NotFoundError):
        service.get_habit(999)
```

---

## Test Data Builders

### Simple Test Data

```python
from datetime import date

def test_completion_date_formatting():
    """Test date formatting utility."""
    completion_date = date(2025, 1, 15)
    result = format_completion_date(completion_date)
    assert result == "January 15, 2025"
```

---

### Factory Functions

```python
from dataclasses import dataclass

@dataclass
class Habit:
    id: int
    name: str
    color: str
    created_at: date

def create_habit(
    id: int = 1,
    name: str = "Test Habit",
    color: str = "#10B981",
    created_at: date | None = None
) -> Habit:
    """Factory for creating test habits."""
    if created_at is None:
        created_at = date.today()
    return Habit(id=id, name=name, color=color, created_at=created_at)

# Use in tests
def test_habit_name_formatting():
    habit = create_habit(name="exercise")
    result = format_habit_name(habit)
    assert result == "Exercise"  # Capitalized

def test_multiple_habits():
    habit1 = create_habit(id=1, name="Exercise")
    habit2 = create_habit(id=2, name="Reading")
    # ...
```

---

### Builder Pattern

```python
class HabitBuilder:
    """Builder for test habits with fluent API."""
    
    def __init__(self):
        self.id = 1
        self.name = "Test Habit"
        self.color = "#10B981"
        self.created_at = date.today()
    
    def with_id(self, id: int):
        self.id = id
        return self
    
    def with_name(self, name: str):
        self.name = name
        return self
    
    def with_color(self, color: str):
        self.color = color
        return self
    
    def created_on(self, date: date):
        self.created_at = date
        return self
    
    def build(self) -> Habit:
        return Habit(
            id=self.id,
            name=self.name,
            color=self.color,
            created_at=self.created_at
        )

# Use in tests
def test_habit_builder():
    habit = (HabitBuilder()
        .with_id(42)
        .with_name("Morning Run")
        .with_color("#EF4444")
        .created_on(date(2025, 1, 1))
        .build())
    
    assert habit.id == 42
    assert habit.name == "Morning Run"
```

---

### Fixture Factories

```python
import pytest

@pytest.fixture
def habit_factory():
    """Factory fixture for creating habits."""
    def _create_habit(name: str = "Test Habit", color: str = "#10B981"):
        return Habit(
            id=1,
            name=name,
            color=color,
            created_at=date.today()
        )
    return _create_habit

def test_with_factory_fixture(habit_factory):
    """Use factory fixture to create test data."""
    exercise = habit_factory(name="Exercise")
    reading = habit_factory(name="Reading", color="#3B82F6")
    
    assert exercise.name == "Exercise"
    assert reading.color == "#3B82F6"
```

---

## Assert Patterns

### Equality Assertions

```python
def test_equality():
    result = calculate(5, 3)
    assert result == 8

def test_inequality():
    result = calculate(5, 3)
    assert result != 7

def test_identity():
    result = get_singleton()
    assert result is INSTANCE

def test_none():
    result = find_habit("missing")
    assert result is None
```

---

### Collection Assertions

```python
def test_list_membership():
    habits = get_habits()
    assert "Exercise" in [h.name for h in habits]

def test_list_length():
    habits = get_habits()
    assert len(habits) == 3

def test_list_contents():
    habits = get_habits()
    assert habits == [
        Habit(id=1, name="Exercise"),
        Habit(id=2, name="Reading")
    ]

def test_list_order():
    habits = get_sorted_habits()
    names = [h.name for h in habits]
    assert names == sorted(names)
```

---

### Numeric Assertions

```python
def test_greater_than():
    streak = calculate_streak(completions)
    assert streak > 0

def test_range():
    rate = calculate_completion_rate(30, 21)
    assert 0 <= rate <= 100

def test_approximate():
    import math
    result = calculate_average()
    assert math.isclose(result, 67.33, abs_tol=0.01)
```

---

### String Assertions

```python
def test_string_contains():
    message = format_message(habit)
    assert "Exercise" in message

def test_string_starts_with():
    formatted = format_habit_name("exercise")
    assert formatted.startswith("E")

def test_regex_match():
    import re
    color = validate_color("#10B981")
    assert re.match(r'^#[0-9A-F]{6}$', color)
```

---

## Edge Case Testing

### Boundary Conditions

```python
def test_empty_input():
    result = calculate_streak([])
    assert result == 0

def test_single_item():
    result = calculate_streak([date.today()])
    assert result == 1

def test_maximum_value():
    large_list = [date.today() - timedelta(days=i) for i in range(365)]
    result = calculate_streak(large_list)
    assert result == 365

def test_negative_input():
    with pytest.raises(ValueError):
        calculate_completion_rate(-1, 0)

def test_zero_value():
    with pytest.raises(ZeroDivisionError):
        calculate_rate(10, 0)
```

---

### Error Paths

```python
def test_invalid_input_type():
    with pytest.raises(TypeError):
        calculate_streak("not a list")

def test_missing_required_field():
    with pytest.raises(ValueError, match="name is required"):
        create_habit(name=None)

def test_validation_error():
    with pytest.raises(ValueError, match="color must be hex"):
        create_habit(name="Test", color="invalid")
```

---

### Null Safety

```python
def test_none_input_handled():
    result = format_description(None)
    assert result == ""

def test_empty_string_handled():
    result = format_description("")
    assert result == ""

def test_whitespace_handled():
    result = format_description("   ")
    assert result == ""
```

---

## Test Organization

### Group Related Tests

```python
class TestStreakCalculation:
    """Tests for current streak calculation."""
    
    def test_empty_list(self):
        assert calculate_streak([]) == 0
    
    def test_single_day(self):
        assert calculate_streak([date.today()]) == 1
    
    def test_consecutive_days(self):
        dates = [date.today() - timedelta(days=i) for i in range(3)]
        assert calculate_streak(dates) == 3


class TestLongestStreak:
    """Tests for longest streak calculation."""
    
    def test_empty_list(self):
        assert calculate_longest_streak([]) == 0
    
    def test_single_streak(self):
        dates = [date(2025, 1, 1), date(2025, 1, 2)]
        assert calculate_longest_streak(dates) == 2
```

---

### One Assertion Per Test (Guideline)

```python
# ✅ Good: One concept per test
def test_creates_habit_with_name():
    habit = create_habit(name="Exercise")
    assert habit.name == "Exercise"

def test_creates_habit_with_default_color():
    habit = create_habit(name="Exercise")
    assert habit.color == "#10B981"

# ⚠️ Acceptable: Related assertions
def test_creates_habit_with_defaults():
    habit = create_habit(name="Exercise")
    assert habit.name == "Exercise"
    assert habit.color == "#10B981"
    assert habit.created_at is not None

# ❌ Bad: Unrelated assertions
def test_multiple_operations():
    habit1 = create_habit(name="Exercise")
    assert habit1.name == "Exercise"
    
    habit2 = update_habit(habit1, name="Running")
    assert habit2.name == "Running"
    
    delete_habit(habit2)
    # Too much in one test!
```

---

## Test Naming Conventions

### Pattern: `test_<what>_<expected>_<condition>`

```python
# ✅ Good names
def test_streak_returns_zero_for_empty_list()
def test_streak_counts_consecutive_days()
def test_habit_name_cannot_be_blank()
def test_completion_raises_error_if_duplicate_date()

# ❌ Bad names
def test_streak()                    # What about streak?
def test_1()                         # Meaningless
def test_it_works()                  # Too vague
def test_calculate_streak_function() # Obvious from function call
```

---

### Behavior-Driven Names

```python
# State what should happen
def test_should_increment_streak_on_consecutive_day()
def test_should_break_streak_on_gap()
def test_should_raise_error_on_invalid_color()
```

---

## Performance Testing

### Simple Timing

```python
import time

def test_streak_calculation_performance():
    """Streak calculation should be fast."""
    dates = [date.today() - timedelta(days=i) for i in range(1000)]
    
    start = time.time()
    result = calculate_streak(dates)
    duration = time.time() - start
    
    assert duration < 0.1  # Should complete in < 100ms
    assert result == 1000
```

---

### Parametrized Performance Tests

```python
@pytest.mark.parametrize("size", [10, 100, 1000, 10000])
def test_scales_linearly(size):
    """Algorithm should scale O(n)."""
    dates = [date.today() - timedelta(days=i) for i in range(size)]
    
    start = time.time()
    calculate_streak(dates)
    duration = time.time() - start
    
    # Linear scaling: 10,000 items should take < 10ms
    assert duration < (size / 1000000)
```

---

## Best Practices

### ✅ Do:
- **Test behavior, not implementation**
- **Use descriptive test names**
- **Write tests before or with code** (TDD)
- **Test edge cases** (empty, null, boundary)
- **Keep tests isolated** (no dependencies)
- **Use fixtures for shared setup**
- **Mock external dependencies**
- **One test per concept**

### ❌ Don't:
- **Test private methods** (test public API)
- **Test framework code** (trust FastAPI, pytest)
- **Test trivial code** (getters/setters)
- **Use sleeps or timeouts** (make tests deterministic)
- **Share state between tests**
- **Make tests depend on execution order**
- **Over-mock** (prefer real objects when simple)

---

## Common Anti-Patterns

### ❌ Testing Implementation Details

```python
# ❌ Bad: Tests internal structure
def test_uses_list_comprehension():
    result = calculate_streak([date.today()])
    # This test breaks if we change implementation from
    # list comprehension to for loop
```

```python
# ✅ Good: Tests behavior
def test_returns_correct_streak():
    result = calculate_streak([date.today()])
    assert result == 1
```

---

### ❌ Fragile Tests

```python
# ❌ Bad: Hardcoded date
def test_todays_streak():
    completions = [date(2025, 1, 15)]  # Will fail tomorrow!
    result = calculate_streak(completions)
    assert result == 1

# ✅ Good: Relative date
def test_todays_streak():
    completions = [date.today()]
    result = calculate_streak(completions)
    assert result == 1
```

---

### ❌ Test Interdependence

```python
# ❌ Bad: Tests depend on order
def test_create_habit():
    global habit_id
    habit = create_habit("Exercise")
    habit_id = habit.id

def test_update_habit():
    # Depends on test_create_habit running first
    update_habit(habit_id, name="Running")

# ✅ Good: Independent tests
def test_create_habit():
    habit = create_habit("Exercise")
    assert habit.name == "Exercise"

def test_update_habit():
    habit = create_habit("Exercise")
    updated = update_habit(habit.id, name="Running")
    assert updated.name == "Running"
```

---

## Source References

**Extracted from:**
- Habit Tracker: `backend/tests/test_streak.py` (pure function testing)
- Habit Tracker: `.claude/reference/testing-and-logging.md` (unit testing patterns)
- Industry best practices: TDD, mocking strategies, test organization

**Related Patterns:**
- 📎 [Testing Pyramid](testing-pyramid.md) - Overall strategy (70% unit tests)
- 📎 [Pytest Patterns](pytest-patterns.md) - Pytest-specific features
- 📎 [FastAPI Testing Patterns](fastapi-testing-patterns.md) - Integration tests

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0
