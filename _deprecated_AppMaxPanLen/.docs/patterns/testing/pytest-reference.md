# Pytest Unit Testing Patterns

**Pattern Type:** Unit Testing  
**Best For:** Fast, isolated function tests  
**Source:** Habit Tracker  
**Complexity:** ⭐⭐☆☆☆

---

## Overview

Pytest patterns for writing fast, maintainable unit tests in Python. Covers fixtures, parametrization, mocking, and test organization for testing business logic without external dependencies.

**Key Characteristics:**
- Fast execution (milliseconds per test)
- No external dependencies (database, API, filesystem)
- Test pure functions and business logic
- Easy to debug (isolated failures)

---

## When to Use

### ✅ Use Pytest Unit Tests For:
- **Pure functions** (calculations, transformations)
- **Business logic** (rules, validations)
- **Utility functions** (date helpers, formatters)
- **Pydantic validators** (custom validators)
- **Data structures** (classes, dataclasses)

### ❌ Don't Use Unit Tests For:
- **Database operations** (use integration tests)
- **API calls** (use integration tests)
- **File I/O** (use integration or mock)
- **External services** (mock or integration)

---

## Basic Pytest Patterns

### 1. Simple Assertions

**Test file: `tests/unit/test_streak.py`**

```python
from datetime import date, timedelta
from app.services.streak import calculate_streak

def test_returns_zero_for_empty_list():
    """Empty completions list should return zero streak."""
    result = calculate_streak([])
    assert result == 0

def test_returns_one_for_single_day():
    """Single completion should return streak of 1."""
    today = date.today()
    completions = [today]
    
    result = calculate_streak(completions)
    
    assert result == 1

def test_counts_consecutive_days():
    """Consecutive completions should count as streak."""
    today = date.today()
    completions = [
        today,
        today - timedelta(days=1),
        today - timedelta(days=2)
    ]
    
    result = calculate_streak(completions)
    
    assert result == 3

def test_gap_breaks_streak():
    """Missing day should break the streak."""
    today = date.today()
    completions = [
        today,
        today - timedelta(days=2)  # Gap on yesterday
    ]
    
    result = calculate_streak(completions)
    
    assert result == 1  # Only today counts
```

**Assertion types:**
```python
# Equality
assert result == expected
assert result != unexpected

# Identity
assert result is None
assert result is not None

# Membership
assert item in collection
assert item not in collection

# Type checking
assert isinstance(result, str)

# Boolean
assert condition
assert not condition

# Comparison
assert result > 0
assert result <= 100
```

---

### 2. Class-Based Test Organization

**Group related tests in classes:**

```python
from app.services.streak import calculate_streak, calculate_longest_streak

class TestStreakCalculation:
    """Tests for current streak calculation."""
    
    def test_empty_list_returns_zero(self):
        assert calculate_streak([]) == 0
    
    def test_single_completion_today(self):
        today = date.today()
        assert calculate_streak([today]) == 1
    
    def test_consecutive_days(self):
        today = date.today()
        dates = [today - timedelta(days=i) for i in range(5)]
        assert calculate_streak(dates) == 5


class TestLongestStreak:
    """Tests for longest streak calculation."""
    
    def test_empty_list_returns_zero(self):
        assert calculate_longest_streak([]) == 0
    
    def test_single_streak(self):
        dates = [date(2025, 1, 1), date(2025, 1, 2)]
        assert calculate_longest_streak(dates) == 2
    
    def test_multiple_streaks_returns_longest(self):
        dates = [
            date(2025, 1, 1),  # Streak 1 (1 day)
            date(2025, 1, 5), date(2025, 1, 6), date(2025, 1, 7),  # Streak 2 (3 days)
        ]
        assert calculate_longest_streak(dates) == 3
```

**Benefits:**
- ✅ Logical grouping
- ✅ Shared setup (fixtures can be class-scoped)
- ✅ Better test discovery
- ✅ Clearer test output

---

## Fixtures

### 1. Basic Fixtures

**Fixtures provide reusable test data:**

```python
# tests/conftest.py
import pytest
from datetime import date

@pytest.fixture
def today():
    """Current date for testing."""
    return date.today()

@pytest.fixture
def sample_completions():
    """Sample completion dates."""
    today = date.today()
    return [
        today,
        today - timedelta(days=1),
        today - timedelta(days=2)
    ]
```

**Use in tests:**
```python
def test_streak_with_fixture(sample_completions):
    result = calculate_streak(sample_completions)
    assert result == 3
```

---

### 2. Fixture Scopes

**Control fixture lifecycle:**

```python
@pytest.fixture(scope="function")  # Default - new instance per test
def db_session():
    session = create_session()
    yield session
    session.close()

@pytest.fixture(scope="class")  # One instance per test class
def api_client():
    client = APIClient()
    yield client
    client.cleanup()

@pytest.fixture(scope="module")  # One instance per test file
def database():
    db = setup_database()
    yield db
    teardown_database(db)

@pytest.fixture(scope="session")  # One instance for entire test run
def config():
    return load_config()
```

---

### 3. Fixture Factories

**Generate multiple test instances:**

```python
import pytest
from dataclasses import dataclass
from datetime import date

@dataclass
class MockCompletion:
    completed_date: str
    status: str = "completed"

@pytest.fixture
def make_completion():
    """Factory fixture to create mock completions."""
    def _make(date_str: str, status: str = "completed"):
        return MockCompletion(completed_date=date_str, status=status)
    return _make
```

**Use factory:**
```python
def test_skipped_days(make_completion):
    completions = [
        make_completion("2025-01-01", "completed"),
        make_completion("2025-01-02", "skipped"),
        make_completion("2025-01-03", "completed")
    ]
    
    result = calculate_streak(completions)
    assert result == 2  # Skipped days don't break streak
```

---

### 4. Autouse Fixtures

**Run automatically for all tests:**

```python
import pytest
import structlog

@pytest.fixture(autouse=True)
def reset_logging():
    """Reset logging configuration before each test."""
    structlog.reset_defaults()
    yield
    structlog.reset_defaults()

@pytest.fixture(autouse=True)
def freeze_time():
    """Fix time at 2025-01-01 for all tests."""
    with freeze_time("2025-01-01"):
        yield
```

---

## Parametrized Tests

### 1. Simple Parametrization

**Test same function with multiple inputs:**

```python
import pytest

@pytest.mark.parametrize("input_value,expected", [
    ([], 0),
    ([date(2025, 1, 1)], 1),
    ([date(2025, 1, 1), date(2025, 1, 2)], 2),
    ([date(2025, 1, 1), date(2025, 1, 3)], 1),  # Gap
])
def test_streak_calculation(input_value, expected):
    """Test streak calculation with various inputs."""
    result = calculate_streak(input_value)
    assert result == expected
```

**Pytest output:**
```
test_streak_calculation[input_value0-0] PASSED
test_streak_calculation[input_value1-1] PASSED
test_streak_calculation[input_value2-2] PASSED
test_streak_calculation[input_value3-1] PASSED
```

---

### 2. Named Parameters

**Use ids for readable test names:**

```python
@pytest.mark.parametrize("completions,expected", [
    ([], 0),
    ([date(2025, 1, 1)], 1),
    ([date(2025, 1, 1), date(2025, 1, 2)], 2),
], ids=["empty", "single", "consecutive"])
def test_streak(completions, expected):
    assert calculate_streak(completions) == expected
```

**Output:**
```
test_streak[empty] PASSED
test_streak[single] PASSED
test_streak[consecutive] PASSED
```

---

### 3. Multiple Parameters

**Parametrize multiple arguments:**

```python
@pytest.mark.parametrize("habit_name", ["Exercise", "Reading", "Meditation"])
@pytest.mark.parametrize("color", ["#10B981", "#3B82F6", "#EF4444"])
def test_habit_creation(habit_name, color):
    """Test habit creation with various names and colors."""
    habit = create_habit(name=habit_name, color=color)
    assert habit.name == habit_name
    assert habit.color == color
```

**Runs 9 tests (3 names × 3 colors)**

---

### 4. Parametrize with Fixtures

**Combine parametrization with fixtures:**

```python
@pytest.fixture
def habit_service():
    return HabitService()

@pytest.mark.parametrize("name", ["", "   ", None])
def test_invalid_habit_names(habit_service, name):
    """Test that invalid names raise ValueError."""
    with pytest.raises(ValueError):
        habit_service.create_habit(name=name)
```

---

## Exception Testing

### 1. Expect Exception

```python
import pytest

def test_division_by_zero_raises():
    with pytest.raises(ZeroDivisionError):
        result = 1 / 0

def test_invalid_input_raises_value_error():
    with pytest.raises(ValueError):
        calculate_streak("not a list")

def test_raises_with_message():
    with pytest.raises(ValueError, match="cannot be empty"):
        create_habit(name="")
```

---

### 2. Inspect Exception

```python
def test_exception_details():
    with pytest.raises(ValueError) as exc_info:
        create_habit(name="")
    
    # Check exception message
    assert "name" in str(exc_info.value)
    assert exc_info.type is ValueError
```

---

## Mocking

### 1. Mock Functions

```python
from unittest.mock import Mock, patch

def test_service_calls_repository():
    # Create mock
    mock_repo = Mock()
    mock_repo.get_by_id.return_value = Habit(id=1, name="Exercise")
    
    # Inject mock
    service = HabitService(repository=mock_repo)
    
    # Test
    result = service.get_habit(1)
    
    # Verify
    mock_repo.get_by_id.assert_called_once_with(1)
    assert result.name == "Exercise"
```

---

### 2. Patch Functions

```python
from datetime import date

@patch('app.services.streak.date')
def test_streak_with_fixed_date(mock_date):
    """Test streak calculation with fixed date."""
    mock_date.today.return_value = date(2025, 1, 15)
    
    completions = [date(2025, 1, 15), date(2025, 1, 14)]
    result = calculate_streak(completions)
    
    assert result == 2
```

---

### 3. Mock External Services

```python
@patch('app.services.email.smtplib.SMTP')
def test_sends_email(mock_smtp):
    """Test email sending without actually sending."""
    mock_server = mock_smtp.return_value.__enter__.return_value
    
    send_email(to="test@example.com", subject="Test")
    
    mock_server.send_message.assert_called_once()
```

---

## Test Markers

### 1. Built-in Markers

```python
@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.platform == "win32", reason="Unix only")
def test_unix_feature():
    pass

@pytest.mark.xfail(reason="Known bug #123")
def test_buggy_feature():
    pass
```

---

### 2. Custom Markers

**Define in `pytest.ini`:**
```ini
[pytest]
markers =
    unit: Unit tests (fast, no I/O)
    slow: Slow running tests
    external: Tests that call external APIs
```

**Use in tests:**
```python
@pytest.mark.unit
def test_pure_calculation():
    assert calculate_streak([]) == 0

@pytest.mark.slow
def test_large_dataset():
    data = generate_large_dataset()
    result = process(data)
    assert len(result) > 1000

@pytest.mark.external
def test_api_integration():
    response = call_external_api()
    assert response.status == 200
```

**Run by marker:**
```bash
pytest -m unit           # Only unit tests
pytest -m "not slow"     # Skip slow tests
pytest -m "unit or slow" # Unit OR slow tests
```

---

## Test Organization

### 1. Directory Structure

```
tests/
├── conftest.py              # Shared fixtures
├── pytest.ini               # Configuration
└── unit/
    ├── conftest.py          # Unit-specific fixtures
    ├── test_streak.py       # Business logic tests
    ├── test_validators.py   # Validation tests
    └── test_utilities.py    # Helper function tests
```

---

### 2. File Naming

**Convention: `test_*.py` or `*_test.py`**

```
✅ Good:
tests/unit/test_streak.py
tests/unit/test_habit_service.py

❌ Bad:
tests/unit/streak_tests.py      # Won't be discovered
tests/unit/test.py               # Too generic
```

---

### 3. Test Naming

**Pattern: `test_<what>_<expected>_<condition>`**

```python
✅ Good:
def test_streak_returns_zero_for_empty_list()
def test_streak_counts_consecutive_days()
def test_habit_name_cannot_be_blank()

❌ Bad:
def test_streak()               # What about streak?
def test_1()                    # Meaningless
def test_it_works()             # Too vague
```

---

## Configuration

### pytest.ini

```ini
[pytest]
# Test discovery
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Markers
markers =
    unit: Unit tests (fast, isolated)
    integration: Integration tests (database, API)
    slow: Slow running tests
    external: Tests calling external APIs

# Output
addopts =
    --verbose
    --strict-markers
    --tb=short
    -ra

# Coverage
filterwarnings =
    error
    ignore::UserWarning
```

---

### pyproject.toml (Alternative)

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = [
    "--verbose",
    "--strict-markers",
]
markers = [
    "unit: Unit tests",
    "integration: Integration tests",
]
```

---

## Running Tests

### Basic Commands

```bash
# Run all tests
pytest

# Run specific file
pytest tests/unit/test_streak.py

# Run specific test
pytest tests/unit/test_streak.py::test_empty_list

# Run specific class
pytest tests/unit/test_streak.py::TestStreakCalculation

# Run tests matching pattern
pytest -k "streak"              # Tests with "streak" in name
pytest -k "not slow"            # Skip tests with "slow" in name
```

---

### Useful Options

```bash
# Verbose output
pytest -v

# Stop on first failure
pytest -x

# Last failed tests only
pytest --lf

# Show local variables on failure
pytest -l

# Run in parallel (requires pytest-xdist)
pytest -n auto

# Quiet mode (minimal output)
pytest -q
```

---

## Coverage

### Install Coverage Plugin

```bash
pip install pytest-cov
```

### Run with Coverage

```bash
# Basic coverage
pytest --cov=app

# With HTML report
pytest --cov=app --cov-report=html

# Terminal report with missing lines
pytest --cov=app --cov-report=term-missing

# Fail if under 80%
pytest --cov=app --cov-fail-under=80
```

### Configuration

```toml
# pyproject.toml
[tool.coverage.run]
source = ["app"]
omit = [
    "*/tests/*",
    "*/__pycache__/*",
    "*/migrations/*",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
fail_under = 80
```

---

## Best Practices

### ✅ Do:
- **One concept per test** (test one thing at a time)
- **Descriptive test names** (explain what and why)
- **Arrange-Act-Assert** pattern (setup, execute, verify)
- **Test edge cases** (empty, null, boundary values)
- **Use fixtures** for shared setup
- **Keep tests fast** (< 10 ms per unit test)

### ❌ Don't:
- **Test implementation details** (test behavior, not internals)
- **Use external dependencies** (database, API, filesystem)
- **Write flaky tests** (non-deterministic, timing-dependent)
- **Duplicate test logic** (use parametrization)
- **Leave commented-out tests** (delete or skip explicitly)

---

## Common Patterns

### Arrange-Act-Assert (AAA)

```python
def test_habit_creation():
    # Arrange (setup)
    name = "Exercise"
    description = "Daily workout"
    
    # Act (execute)
    habit = create_habit(name=name, description=description)
    
    # Assert (verify)
    assert habit.name == name
    assert habit.description == description
```

---

### Given-When-Then (BDD Style)

```python
def test_completing_habit_increments_streak():
    # Given: A habit with 2-day streak
    habit = Habit(name="Exercise", current_streak=2)
    
    # When: User completes the habit
    habit.mark_completed()
    
    # Then: Streak increments to 3
    assert habit.current_streak == 3
```

---

### Test Doubles

```python
# Dummy (unused parameter)
def test_with_dummy():
    logger = Mock()  # Never called
    service = Service(logger=logger)
    service.do_something()

# Stub (predefined responses)
def test_with_stub():
    repo = Mock()
    repo.get.return_value = Habit(id=1)
    service = Service(repo)
    
# Mock (verify calls)
def test_with_mock():
    repo = Mock()
    service = Service(repo)
    service.save_habit(Habit())
    repo.save.assert_called_once()
```

---

## Debugging Failed Tests

### Show Output

```bash
# Show print statements
pytest -s

# Show local variables on failure
pytest -l

# Full traceback
pytest --tb=long

# Drop into debugger on failure
pytest --pdb
```

### Use Logging

```python
import logging

def test_with_logging(caplog):
    """Capture log output."""
    caplog.set_level(logging.INFO)
    
    do_something_that_logs()
    
    assert "Expected message" in caplog.text
```

---

## Source References

**Extracted from:**
- Habit Tracker: `backend/tests/test_streak.py` (unit test examples)
- Habit Tracker: `backend/tests/conftest.py` (fixture patterns)
- Habit Tracker: `.claude/reference/testing-and-logging.md` (pytest patterns)

**Related Patterns:**
- 📎 [Testing Pyramid](testing-pyramid.md) - Overall testing strategy
- 📎 [FastAPI Testing Patterns](fastapi-testing-patterns.md) - Integration tests
- 📎 [Frontend Testing Patterns](frontend-testing-patterns.md) - Component tests

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0
