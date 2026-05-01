# Unit Testing Patterns - Overview

**Pattern Type:** Unit Testing Best Practices  
**Complexity:** Beginner  
**Read Time:** ~3 minutes  
**Best For:** Testing pure business logic in isolation

---

## When to Use Unit Tests

### ✅ Unit Test These

- **Pure functions** (same input → same output, no side effects)
- **Business logic** (calculations, rules, workflows)
- **Validators** (data validation, constraints)
- **Utility functions** (date helpers, formatters, parsers)
- **Domain models** (entity behavior, state transitions)

### ❌ Don't Unit Test These

- **Database queries** (use integration tests)
- **API endpoints** (use integration tests)
- **External services** (use integration tests or mock)
- **Configuration loading** (integration or E2E tests)
- **Trivial code** (getters/setters, simple assignments)

### Characteristics of Good Unit Tests

| Characteristic | Description | Example |
|----------------|-------------|---------|
| **Fast** | < 10ms per test | Calculate streak in 2ms |
| **Isolated** | No external dependencies | No database, API, filesystem |
| **Deterministic** | Same input → same output | No random numbers, current date |
| **Focused** | Test one thing | One function, one scenario |
| **Readable** | Clear intent | `test_gap_breaks_streak()` |

**Key insight:** Unit tests are the foundation of your test pyramid. They should be fast, numerous, and easy to maintain.

---

## Essential Patterns

### Pure Function Definition

A **pure function** is:
1. **Deterministic**: Same input always produces same output
2. **No side effects**: Doesn't modify external state
3. **No external dependencies**: No I/O, no database, no API calls

**Example pure function:**
```python
def calculate_streak(completions: list[date]) -> int:
    """
    Pure function: Calculate current streak from completion dates.
    
    - Deterministic: Same dates → same streak
    - No side effects: Doesn't modify input
    - No dependencies: Only uses input parameter
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

**Example impure function (don't unit test):**
```python
def save_habit(habit_data: dict) -> int:
    """
    Impure function: Has side effects (database write).
    
    Use integration test instead!
    """
    habit = Habit(**habit_data)
    db.session.add(habit)
    db.session.commit()
    return habit.id
```

---

## Minimal Working Examples

### 1. Basic Unit Test

```python
# tests/unit/test_streak.py
from datetime import date, timedelta
from app.services.streak import calculate_streak

def test_empty_list_returns_zero():
    """No completions should return zero streak."""
    result = calculate_streak([])
    assert result == 0

def test_single_completion_today():
    """Single completion today should be streak of 1."""
    today = date.today()
    result = calculate_streak([today])
    assert result == 1

def test_consecutive_days_count():
    """Consecutive days should count as streak."""
    today = date.today()
    dates = [
        today,
        today - timedelta(days=1),
        today - timedelta(days=2)
    ]
    result = calculate_streak(dates)
    assert result == 3

def test_gap_breaks_streak():
    """Missing day should break the streak."""
    today = date.today()
    dates = [
        today,
        today - timedelta(days=2)  # Missing yesterday
    ]
    result = calculate_streak(dates)
    assert result == 1  # Only today counts
```

### 2. Test Edge Cases

```python
def test_today_missing_returns_zero():
    """No completion today should return zero streak."""
    yesterday = date.today() - timedelta(days=1)
    result = calculate_streak([yesterday])
    assert result == 0

def test_unsorted_dates_handled():
    """Function should handle unsorted input."""
    today = date.today()
    dates = [
        today - timedelta(days=2),
        today,
        today - timedelta(days=1)
    ]
    result = calculate_streak(dates)
    assert result == 3

def test_duplicate_dates_counted_once():
    """Duplicate dates should be counted only once."""
    today = date.today()
    dates = [today, today, today]  # 3 duplicates
    result = calculate_streak(dates)
    assert result == 1  # Only count once
```

### 3. TDD (Test-Driven Development) Workflow

```python
# 1. Write failing test first (RED)
def test_format_duration_formats_seconds():
    result = format_duration(90)
    assert result == "1m 30s"

# 2. Implement minimal code to pass (GREEN)
def format_duration(seconds: int) -> str:
    minutes = seconds // 60
    secs = seconds % 60
    return f"{minutes}m {secs}s"

# 3. Refactor while keeping tests green (REFACTOR)
def format_duration(seconds: int) -> str:
    """Format seconds as human-readable duration."""
    if seconds < 60:
        return f"{seconds}s"
    minutes = seconds // 60
    secs = seconds % 60
    return f"{minutes}m {secs}s" if secs > 0 else f"{minutes}m"

# 4. Add more test cases
def test_format_duration_under_minute():
    assert format_duration(45) == "45s"

def test_format_duration_exact_minutes():
    assert format_duration(120) == "2m"
```

### 4. Arrange-Act-Assert (AAA) Pattern

```python
def test_calculate_completion_rate():
    # Arrange: Setup test data
    total_days = 10
    completed_days = 7
    
    # Act: Execute function
    result = calculate_completion_rate(completed_days, total_days)
    
    # Assert: Verify output
    assert result == 0.7

def test_validate_email_rejects_invalid():
    # Arrange
    invalid_email = "not-an-email"
    
    # Act
    result = is_valid_email(invalid_email)
    
    # Assert
    assert result is False
```

### 5. Class-Based Organization

```python
class TestStreakCalculation:
    """Group related tests for streak calculation."""
    
    def test_empty_list(self):
        result = calculate_streak([])
        assert result == 0
    
    def test_single_day(self):
        today = date.today()
        result = calculate_streak([today])
        assert result == 1
    
    def test_consecutive_days(self):
        today = date.today()
        dates = [today, today - timedelta(days=1)]
        result = calculate_streak(dates)
        assert result == 2

class TestEmailValidation:
    """Group related tests for email validation."""
    
    def test_valid_email(self):
        assert is_valid_email("user@example.com") is True
    
    def test_missing_at_sign(self):
        assert is_valid_email("userexample.com") is False
    
    def test_missing_domain(self):
        assert is_valid_email("user@") is False
```

---

## Common Operations

### Testing Exceptions

```python
import pytest

def test_divide_by_zero_raises_error():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)

def test_invalid_date_raises_error():
    with pytest.raises(ValueError):
        parse_date("not-a-date")
```

### Testing Return Values

```python
def test_returns_correct_type():
    result = calculate_streak([])
    assert isinstance(result, int)

def test_returns_non_negative():
    result = calculate_streak([date.today()])
    assert result >= 0
```

### Testing Side Effects (with Mocks)

```python
from unittest.mock import Mock, patch

def send_notification(user_id: int, message: str):
    """Impure: Calls external service."""
    api_client.send(user_id, message)

@patch('app.services.notifications.api_client')
def test_send_notification(mock_api_client):
    send_notification(123, "Hello")
    
    mock_api_client.send.assert_called_once_with(123, "Hello")
```

---

## Top 5 Gotchas

### 1. Testing Impure Functions as Unit Tests ⚠️

```python
# ❌ Wrong: Unit testing database operation
def test_save_habit():
    habit = save_habit({"name": "Exercise"})  # Database write!
    assert habit.id is not None

# ✅ Correct: Integration test for database
def test_save_habit(client):
    response = client.post("/api/habits", json={"name": "Exercise"})
    assert response.status_code == 201
```

**Impact:** Slow tests, database setup required, not isolated.

### 2. Using `date.today()` Without Mocking

```python
# ❌ Wrong: Test breaks tomorrow
def test_streak_calculation():
    dates = [date(2025, 1, 15), date(2025, 1, 14)]
    result = calculate_streak(dates)
    assert result == 2  # FAILS tomorrow!

# ✅ Correct: Use relative dates or mock
from unittest.mock import patch

@patch('app.services.streak.date')
def test_streak_calculation(mock_date):
    mock_date.today.return_value = date(2025, 1, 15)
    dates = [date(2025, 1, 15), date(2025, 1, 14)]
    result = calculate_streak(dates)
    assert result == 2
```

**Impact:** Tests fail unpredictably based on current date.

### 3. Testing Multiple Things in One Test

```python
# ❌ Wrong: Tests too much
def test_habit_operations():
    habit = create_habit("Exercise")
    assert habit.name == "Exercise"
    
    habit = update_habit(habit, "Workout")
    assert habit.name == "Workout"
    
    delete_habit(habit)
    assert habit_exists(habit.id) is False

# ✅ Correct: Separate tests
def test_create_habit():
    habit = create_habit("Exercise")
    assert habit.name == "Exercise"

def test_update_habit():
    habit = create_habit("Exercise")
    updated = update_habit(habit, "Workout")
    assert updated.name == "Workout"
```

**Impact:** Hard to debug, unclear which assertion failed.

### 4. No Test for Edge Cases

```python
# ❌ Wrong: Only happy path
def test_calculate_streak():
    dates = [date.today()]
    result = calculate_streak(dates)
    assert result == 1

# ✅ Correct: Test edge cases
def test_calculate_streak_empty_list():
    assert calculate_streak([]) == 0

def test_calculate_streak_duplicate_dates():
    dates = [date.today(), date.today()]
    assert calculate_streak(dates) == 1

def test_calculate_streak_unsorted():
    dates = [date.today() - timedelta(days=1), date.today()]
    assert calculate_streak(dates) == 2
```

**Impact:** Edge cases break in production.

### 5. Non-Descriptive Test Names

```python
# ❌ Wrong: Unclear intent
def test_1():
    result = calculate_streak([])
    assert result == 0

def test_2():
    result = calculate_streak([date.today()])
    assert result == 1

# ✅ Correct: Descriptive names
def test_empty_list_returns_zero():
    result = calculate_streak([])
    assert result == 0

def test_single_completion_today_returns_one():
    result = calculate_streak([date.today()])
    assert result == 1
```

**Impact:** Hard to understand what failed from test output.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Test breaks on different dates | Using `date.today()` | Mock date or use relative dates |
| Slow unit tests (> 100ms) | Testing I/O operations | Move to integration tests, unit test logic only |
| Test passes but production fails | Missing edge cases | Add tests for empty, null, boundary values |
| Can't tell what failed | Poor test names | Use descriptive names: `test_what_when_expected()` |
| Tests depend on each other | Shared state | Make each test independent with setup/teardown |

---

## References

📎 **Reference**: [unit-testing-reference.md](unit-testing-reference.md)  
**When to load**: Advanced patterns (test data builders, property-based testing with Hypothesis), mocking strategies, test organization, TDD workflows, testing async code (~725 lines)

📎 **Related patterns**:
- [testing-pyramid.md](testing-pyramid-overview.md) - Testing strategy
- [pytest-patterns.md](pytest-overview.md) - Pytest framework patterns
- [fastapi-testing-patterns.md](fastapi-testing-overview.md) - Integration testing

---

**Pattern Type:** Unit Testing Best Practices  
**Last Updated:** 2026-03-07  
**Complexity:** Beginner ⭐⭐☆☆☆
