# Testing Pyramid - Overview

**Pattern Type:** Testing Strategy  
**Complexity:** Beginner  
**Read Time:** ~3 minutes  
**Best For:** Balanced test coverage, comprehensive test suites

---

## When to Use This Strategy

### ✅ Use Testing Pyramid When

- **Building production applications** (need comprehensive test coverage)
- **Team collaboration** (shared testing standards)
- **Continuous integration** (automated test suites)
- **Long-term maintenance** (prevent regressions)
- **Balanced coverage needed** (speed + confidence)

### ❌ Don't Use Testing Pyramid When

- **Prototypes** (testing investment not worth it yet)
- **Static sites** (no logic to test)
- **Throwaway code** (one-time scripts)

### The Pyramid Distribution

| Layer | Percentage | Speed | Scope | Example |
|-------|------------|-------|-------|---------|
| **Unit** | 70% | 1-10 ms | Single function | `calculate_streak([dates])` |
| **Integration** | 20% | 0.1-2 sec | API + Database | `POST /api/habits` |
| **E2E** | 10% | 10-60 sec | Full browser | Click "Complete" → see streak update |

**Key insight:** More tests at bottom (fast), fewer at top (slow). Optimize for speed while maintaining confidence.

---

## Essential Structure

### The Testing Pyramid

```
         ╱╲
        ╱  ╲          E2E (10%) — Full system, slow, fragile
       ╱    ╲         - Playwright, browser automation
      ╱──────╲        - Critical user journeys only
     ╱        ╲       
    ╱──────────╲      Integration (20%) — API + DB, medium speed
   ╱            ╲     - FastAPI TestClient
  ╱   Integration╲    - Real database interactions
 ╱──────20%──────╲   
╱                 ╲  
╱───────────────────╲ Unit (70%) — Fast, isolated, easy maintenance
╱                    ╲ - Pure functions, business logic
╱      Unit Tests     ╲ - No external dependencies
──────────70%────────── - Milliseconds per test
```

### Project Structure

```
tests/
├── conftest.py              # Shared fixtures
├── unit/
│   ├── test_streak.py       # Pure business logic
│   ├── test_validators.py   # Data validation
│   └── test_utils.py        # Helper functions
├── integration/
│   ├── test_api_habits.py   # Habit endpoints
│   ├── test_api_auth.py     # Authentication
│   └── test_database.py     # Database operations
└── e2e/
    ├── habits.spec.js       # Create & complete habits
    └── calendar.spec.js     # Calendar interactions
```

---

## Minimal Working Examples

### 1. Unit Test (70% of tests)

**Pure function, no dependencies:**
```python
# app/services/streak.py
def calculate_streak(completions: list[date]) -> int:
    """Calculate streak from completion dates."""
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
import pytest
from datetime import date, timedelta
from app.services.streak import calculate_streak

def test_empty_list_returns_zero():
    result = calculate_streak([])
    assert result == 0

def test_single_completion_today():
    today = date.today()
    result = calculate_streak([today])
    assert result == 1

def test_consecutive_days_count():
    today = date.today()
    dates = [today, today - timedelta(days=1), today - timedelta(days=2)]
    result = calculate_streak(dates)
    assert result == 3

def test_gap_breaks_streak():
    today = date.today()
    dates = [today, today - timedelta(days=2)]  # Missing yesterday
    result = calculate_streak(dates)
    assert result == 1
```

**Run:** `pytest tests/unit/ -v` (runs in < 1 second)

### 2. Integration Test (20% of tests)

**API endpoint with database:**
```python
# tests/integration/test_api_habits.py
def test_create_habit_endpoint(client):
    """POST /api/habits creates habit in database."""
    response = client.post(
        "/api/habits",
        json={"name": "Exercise", "description": "Daily workout"}
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Exercise"
    assert "id" in data

def test_list_habits_returns_created_habits(client):
    """GET /api/habits returns all habits."""
    # Create habits
    client.post("/api/habits", json={"name": "Meditate"})
    client.post("/api/habits", json={"name": "Read"})
    
    # List habits
    response = client.get("/api/habits")
    
    assert response.status_code == 200
    habits = response.json()
    assert len(habits) == 2
    assert habits[0]["name"] == "Meditate"
    assert habits[1]["name"] == "Read"

def test_delete_habit_removes_from_database(client):
    """DELETE /api/habits/:id removes habit."""
    create_response = client.post("/api/habits", json={"name": "Exercise"})
    habit_id = create_response.json()["id"]
    
    delete_response = client.delete(f"/api/habits/{habit_id}")
    assert delete_response.status_code == 204
    
    # Verify removed
    list_response = client.get("/api/habits")
    assert len(list_response.json()) == 0
```

**Run:** `pytest tests/integration/ -v` (runs in 1-3 seconds)

### 3. E2E Test (10% of tests)

**Full user journey in browser:**
```javascript
// tests/e2e/habits.spec.js
import { test, expect } from '@playwright/test';

test('complete habit and see streak update', async ({ page }) => {
  // Navigate
  await page.goto('/');
  
  // Create habit
  await page.click('button:has-text("Add Habit")');
  await page.fill('input[name="name"]', 'Exercise');
  await page.fill('textarea[name="description"]', 'Daily workout');
  await page.click('button[type="submit"]');
  
  // Verify created
  await expect(page.locator('text=Exercise')).toBeVisible();
  
  // Complete habit
  await page.click('button:has-text("Complete")');
  
  // Verify streak
  await expect(page.locator('text=Streak: 1')).toBeVisible();
  
  // Verify calendar marked
  const today = new Date().getDate();
  await expect(page.locator(`[data-date="${today}"]`)).toHaveClass(/completed/);
});
```

**Run:** `npx playwright test` (runs in 10-30 seconds)

---

## Layer Decision Guide

### What to Test Where

**Unit tests (70%):**
- ✅ Streak calculation
- ✅ Date validation
- ✅ Data transformations
- ✅ Business rules
- ❌ Database queries
- ❌ API calls
- ❌ UI rendering

**Integration tests (20%):**
- ✅ POST /api/habits creates habit
- ✅ GET /api/habits returns all
- ✅ Authentication flow
- ✅ Database constraints
- ❌ Business logic (unit test it)
- ❌ Browser interactions (E2E test it)

**E2E tests (10%):**
- ✅ Critical user journey (signup → create habit → mark complete)
- ✅ Visual regression (UI looks correct)
- ✅ Cross-browser compatibility
- ❌ Edge cases (unit test them)
- ❌ Every button click (too slow)

---

## Top 5 Gotchas

### 1. Too Many E2E Tests (Inverted Pyramid) ⚠️

```python
# ❌ Wrong: 100 E2E tests, 10 unit tests (inverted)
tests/e2e/  # 100 files
tests/unit/ # 10 files

# ✅ Correct: Follow 70-20-10 distribution
tests/unit/        # 70 files
tests/integration/ # 20 files
tests/e2e/         # 10 files
```

**Impact:** Test suite takes 30+ minutes to run, becomes unmaintainable, developers skip tests.

### 2. Testing Business Logic in E2E

```javascript
// ❌ Wrong: E2E test for calculation logic
test('streak calculation handles gaps', async ({ page }) => {
  // 50 lines of browser automation to test calculation
});

// ✅ Correct: Unit test for calculation
def test_streak_calculation_handles_gaps():
    dates = [today, today - timedelta(days=2)]
    assert calculate_streak(dates) == 1
```

**Impact:** Slow feedback (30 sec vs 10 ms), brittle tests, hard to debug.

### 3. No Integration Tests (Gap Between Unit and E2E)

```python
# ❌ Wrong: Only unit + E2E, no integration
tests/unit/        # Business logic
tests/e2e/         # Full browser tests
# Missing: API + database integration!

# ✅ Correct: All three layers
tests/unit/        # Pure functions
tests/integration/ # API + database
tests/e2e/         # Critical journeys
```

**Impact:** Bugs in API layer only caught by slow E2E tests or production.

### 4. Integration Tests Without Clean Database

```python
# ❌ Wrong: Tests share database state
def test_list_habits(client):
    habits = client.get("/api/habits").json()
    assert len(habits) == 2  # Assumes 2 exist from previous test!

# ✅ Correct: Fresh database per test
@pytest.fixture
def db_session():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    yield session
    session.close()
    Base.metadata.drop_all(bind=engine)
```

**Impact:** Tests pass/fail depending on order, impossible to debug.

### 5. E2E Tests Without Waits (Flaky Tests)

```javascript
// ❌ Wrong: No wait, assumes instant load
await page.click('button:has-text("Save")');
await expect(page.locator('text=Saved')).toBeVisible();  // Flaky!

// ✅ Correct: Built-in waits
await page.click('button:has-text("Save")');
await expect(page.locator('text=Saved')).toBeVisible({ timeout: 5000 });
```

**Impact:** Tests randomly fail, team loses trust in tests.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Test suite takes > 10 min | Too many E2E tests | Convert 80% of E2E to integration/unit |
| Tests fail randomly | Flaky E2E, no waits | Add explicit waits, use Playwright auto-wait |
| Tests pass individually, fail together | Shared state | Fresh database per test (fixtures) |
| Hard to find test for feature | Poor organization | Follow unit/integration/e2e structure |
| Bugs in API not caught | No integration tests | Add integration tests for all endpoints |

---

## References

📎 **Reference**: [testing-pyramid-reference.md](testing-pyramid-reference.md)  
**When to load**: Detailed test distribution strategies, advanced patterns (contract testing, snapshot testing), test data management, CI/CD integration, metrics and reporting (~430 lines)

📎 **Related patterns**:
- [pytest-patterns.md](pytest-overview.md) - Python unit testing
- [fastapi-testing-patterns.md](fastapi-testing-overview.md) - API integration testing
- [playwright-e2e-patterns.md](playwright-e2e-overview.md) - Browser automation

---

**Pattern Type:** Testing Strategy  
**Last Updated:** 2026-03-07  
**Complexity:** Beginner ⭐⭐⭐☆☆
