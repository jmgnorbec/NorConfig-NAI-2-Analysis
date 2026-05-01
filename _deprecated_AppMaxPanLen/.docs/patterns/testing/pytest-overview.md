# Pytest Patterns - Overview

**Pattern Type:** Unit Testing Framework  
**Complexity:** Beginner to Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Python unit tests with fixtures, parametrization, and mocking

---

## When to Use Pytest

### ✅ Use Pytest When

- **Python project** (pytest is Python standard for testing)
- **Unit testing business logic** (pure functions, calculations)
- **Need fixtures** (reusable test data, setup/teardown)
- **Parametrized tests** (same test, multiple inputs)
- **Mocking external dependencies** (API calls, database)

### ❌ Don't Use Pytest When

- **Integration testing** (use TestClient for APIs, though pytest still orchestrates)
- **Browser automation** (use Playwright)
- **Non-Python code** (use language-specific tools)

### vs. unittest

| Feature | pytest | unittest |
|---------|--------|----------|
| **Assertions** | Plain `assert` | `self.assertEqual()` |
| **Fixtures** | Function decorators | `setUp()`/`tearDown()` |
| **Parametrization** | `@pytest.mark.parametrize` | Manual loops |
| **Test discovery** | Automatic | Requires `unittest.main()` |
| **Community** | Larger ecosystem | Built-in to Python |

**Key insight:** Pytest reduces boilerplate with plain assertions and powerful fixtures.

---

## Essential Configuration

### Installation

```bash
# Install pytest
pip install pytest

# Install coverage plugin
pip install pytest-cov

# Install asyncio support (for async tests)
pip install pytest-asyncio
```

### Configuration File

**`pytest.ini`:**
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Output options
addopts = 
    -v
    --tb=short
    --strict-markers

# Markers for organizing tests
markers =
    unit: Unit tests (fast, no I/O)
    integration: Integration tests (database, API)
    slow: Slow tests (> 1 second)
```

**`pyproject.toml` (alternative):**
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = ["-v", "--tb=short"]
```

---

## Minimal Working Examples

### 1. Basic Unit Test

```python
# app/services/streak.py
from datetime import date, timedelta

def calculate_streak(completions: list[date]) -> int:
    """Calculate current streak from completion dates."""
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

# tests/unit/test_streak.py
from datetime import date, timedelta
from app.services.streak import calculate_streak

def test_empty_list_returns_zero():
    result = calculate_streak([])
    assert result == 0

def test_single_day_returns_one():
    today = date.today()
    result = calculate_streak([today])
    assert result == 1

def test_consecutive_days():
    today = date.today()
    dates = [today, today - timedelta(days=1), today - timedelta(days=2)]
    result = calculate_streak(dates)
    assert result == 3
```

**Run:** `pytest tests/unit/test_streak.py -v`

### 2. Fixtures (Reusable Setup)

```python
# tests/conftest.py
import pytest
from datetime import date, timedelta

@pytest.fixture
def today():
    """Current date fixture."""
    return date.today()

@pytest.fixture
def habit_data():
    """Sample habit data."""
    return {
        "name": "Exercise",
        "description": "Daily workout",
        "frequency": "daily"
    }

@pytest.fixture
def consecutive_dates(today):
    """Generate consecutive dates."""
    return [
        today,
        today - timedelta(days=1),
        today - timedelta(days=2)
    ]

# tests/unit/test_streak.py
def test_consecutive_dates_fixture(consecutive_dates):
    result = calculate_streak(consecutive_dates)
    assert result == 3

def test_habit_creation(habit_data):
    habit = Habit(**habit_data)
    assert habit.name == "Exercise"
    assert habit.frequency == "daily"
```

### 3. Parametrized Tests

**Test same logic with multiple inputs:**
```python
import pytest
from app.services.validators import is_valid_email

@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("user.name@example.co.uk", True),
    ("invalid", False),
    ("@example.com", False),
    ("user@", False),
    ("", False),
])
def test_email_validation(email, expected):
    result = is_valid_email(email)
    assert result == expected
```

**Output:**
```
test_email_validation[user@example.com-True] PASSED
test_email_validation[user.name@example.co.uk-True] PASSED
test_email_validation[invalid-False] PASSED
test_email_validation[@example.com-False] PASSED
test_email_validation[user@-False] PASSED
test_email_validation[-False] PASSED
```

### 4. Mocking External Dependencies

```python
from unittest.mock import Mock, patch
import pytest

# Function that calls external API
def fetch_user_data(user_id: int) -> dict:
    response = requests.get(f"https://api.example.com/users/{user_id}")
    return response.json()

# Test with mock
@patch('requests.get')
def test_fetch_user_data(mock_get):
    # Setup mock
    mock_response = Mock()
    mock_response.json.return_value = {"id": 1, "name": "Alice"}
    mock_get.return_value = mock_response
    
    # Test
    result = fetch_user_data(1)
    
    # Verify
    assert result["name"] == "Alice"
    mock_get.assert_called_once_with("https://api.example.com/users/1")
```

### 5. Class-Based Test Organization

```python
class TestStreakCalculation:
    """Group related tests in a class."""
    
    def test_empty_list(self):
        result = calculate_streak([])
        assert result == 0
    
    def test_single_day(self, today):
        result = calculate_streak([today])
        assert result == 1
    
    def test_consecutive_days(self, consecutive_dates):
        result = calculate_streak(consecutive_dates)
        assert result == 3
    
    def test_gap_breaks_streak(self, today):
        dates = [today, today - timedelta(days=2)]
        result = calculate_streak(dates)
        assert result == 1
```

---

## Common Operations

### Running Tests

```bash
# Run all tests
pytest

# Run specific file
pytest tests/unit/test_streak.py

# Run specific test
pytest tests/unit/test_streak.py::test_empty_list_returns_zero

# Run specific class
pytest tests/unit/test_streak.py::TestStreakCalculation

# Run with coverage
pytest --cov=app --cov-report=html

# Run only unit tests (using markers)
pytest -m unit

# Run in parallel (requires pytest-xdist)
pytest -n auto
```

### Fixture Scopes

```python
# Function scope (default): New instance per test
@pytest.fixture(scope="function")
def db_session():
    session = create_session()
    yield session
    session.close()

# Class scope: Shared across tests in same class
@pytest.fixture(scope="class")
def api_client():
    return APIClient()

# Module scope: Shared across tests in same file
@pytest.fixture(scope="module")
def database():
    setup_db()
    yield
    teardown_db()

# Session scope: Shared across entire test session
@pytest.fixture(scope="session")
def config():
    return load_config()
```

### Custom Markers

```python
# Mark tests
@pytest.mark.slow
def test_complex_calculation():
    pass

@pytest.mark.integration
def test_database_query():
    pass

# Run specific marks
pytest -m slow              # Run only slow tests
pytest -m "not slow"        # Skip slow tests
pytest -m "unit and not slow"  # Combine markers
```

---

## Top 5 Gotchas

### 1. Forgetting to Use Fixtures ⚠️

```python
# ❌ Wrong: Duplicate setup in every test
def test_streak_one():
    today = date.today()
    dates = [today, today - timedelta(days=1)]
    result = calculate_streak(dates)
    assert result == 2

def test_streak_two():
    today = date.today()  # Duplicate!
    dates = [today, today - timedelta(days=1), today - timedelta(days=2)]
    result = calculate_streak(dates)
    assert result == 3

# ✅ Correct: Use fixture
@pytest.fixture
def today():
    return date.today()

def test_streak_one(today):
    dates = [today, today - timedelta(days=1)]
    result = calculate_streak(dates)
    assert result == 2
```

**Impact:** Duplicate code, harder to maintain.

### 2. Mutable Fixture Shared Across Tests

```python
# ❌ Wrong: List mutated across tests
@pytest.fixture
def dates():
    return [date.today()]  # Same list instance!

def test_one(dates):
    dates.append(date.today() - timedelta(days=1))
    assert len(dates) == 2

def test_two(dates):
    assert len(dates) == 1  # FAILS! dates still has 2 items

# ✅ Correct: Use function scope (default)
@pytest.fixture
def dates():
    return [date.today()]  # New list per test
```

**Impact:** Tests fail mysteriously, order-dependent failures.

### 3. Not Using `conftest.py`

```python
# ❌ Wrong: Duplicate fixtures in every test file
# tests/unit/test_streak.py
@pytest.fixture
def today():
    return date.today()

# tests/unit/test_habits.py
@pytest.fixture
def today():  # Duplicate!
    return date.today()

# ✅ Correct: Share in conftest.py
# tests/conftest.py (discovered automatically)
@pytest.fixture
def today():
    return date.today()

# Now available in all test files
```

**Impact:** Duplicate fixtures, inconsistent test data.

### 4. Parametrize with Non-Descriptive IDs

```python
# ❌ Wrong: Can't tell which case failed
@pytest.mark.parametrize("email,valid", [
    ("user@example.com", True),
    ("invalid", False),
])
def test_email(email, valid):
    assert is_valid_email(email) == valid

# Output: test_email[user@example.com-True] — OK
# Output: test_email[invalid-False] — hard to read

# ✅ Correct: Add descriptive IDs
@pytest.mark.parametrize("email,valid", [
    ("user@example.com", True),
    ("invalid", False),
], ids=["valid_email", "invalid_no_at_sign"])
def test_email(email, valid):
    assert is_valid_email(email) == valid

# Output: test_email[valid_email] PASSED
# Output: test_email[invalid_no_at_sign] FAILED
```

**Impact:** Hard to identify failing test cases.

### 5. Not Cleaning Up After Tests

```python
# ❌ Wrong: Test creates file, doesn't clean up
def test_save_data():
    save_to_file("test.json", {"data": "value"})
    assert file_exists("test.json")
    # test.json left behind!

# ✅ Correct: Use fixture with cleanup
@pytest.fixture
def temp_file():
    filepath = "test.json"
    yield filepath
    if os.path.exists(filepath):
        os.remove(filepath)

def test_save_data(temp_file):
    save_to_file(temp_file, {"data": "value"})
    assert file_exists(temp_file)
    # Cleanup handled by fixture
```

**Impact:** Polluted test environment, order-dependent failures.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Fixture not found | Not in conftest.py | Move fixture to conftest.py or import |
| Tests pass individually, fail together | Mutable fixture shared | Use function scope (default) |
| Parametrize output hard to read | No IDs provided | Add `ids` parameter |
| Test files not discovered | Wrong naming | Use `test_*.py` or `*_test.py` |
| Slow test suite | Running integration as unit | Use markers: `pytest -m unit` |

---

## References

📎 **Reference**: [pytest-reference.md](pytest-reference.md)  
**When to load**: Advanced fixtures (factories, autouse), async testing, plugin development, coverage configuration, test organization strategies, debugging techniques (~660 lines)

📎 **Related patterns**:
- [testing-pyramid.md](testing-pyramid-overview.md) - Overall testing strategy
- [unit-testing-patterns.md](unit-testing-overview.md) - Unit testing best practices
- [fastapi-testing-patterns.md](fastapi-testing-overview.md) - Integration testing with FastAPI

---

**Pattern Type:** Unit Testing Framework  
**Last Updated:** 2026-03-07  
**Complexity:** Beginner to Intermediate ⭐⭐☆☆☆
