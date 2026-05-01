# Testing Pyramid Strategy

**Pattern Type:** Testing Philosophy  
**Best For:** Comprehensive test coverage, balanced test suites  
**Source:** Habit Tracker + Industry Best Practices  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

The Testing Pyramid is a strategy for organizing automated tests into layers based on speed, scope, and maintainability. More tests at the bottom (fast, focused units) and fewer at the top (slow, broad end-to-end tests).

**Key Characteristics:**
- **70% Unit tests**: Fast, isolated, single-function tests
- **20% Integration tests**: Multiple components working together
- **10% E2E tests**: Full system, critical user journeys only

---

## The Pyramid

```
         ╱╲
        ╱  ╲          E2E Tests (10%)
       ╱    ╲         - Full system
      ╱──────╲        - Browser automation
     ╱        ╲       - Slow (minutes)
    ╱──────────╲      - Fragile (environment-dependent)
   ╱            ╲     
  ╱   Integration╲    Integration Tests (20%)
 ╱──────Tests────╲   - API + Database
╱                 ╲  - Medium speed (seconds)
╱───────────────────╲ - Moderate maintenance
╱                    ╲
╱      Unit Tests     ╲ Unit Tests (70%)
──────────────────────── - Single function/class
                        - Fast (milliseconds)
                        - Easy to maintain
```

---

## Test Layer Comparison

| Layer | Percentage | Speed | Scope | Maintenance | When Breaks |
|-------|------------|-------|-------|-------------|-------------|
| **Unit** | 70% | 1-10 ms | Single function | Low | Logic error |
| **Integration** | 20% | 0.1-2 sec | Multiple components | Medium | Interface mismatch |
| **E2E** | 10% | 10-60 sec | Full system | High | UI, timing, env |

---

## When to Use Each Layer

### Unit Tests (70%)

**What to test:**
- ✅ Pure functions (calculations, transformations)
- ✅ Business logic (rules, validations)
- ✅ Utility functions (date helpers, formatters)
- ✅ Validators (Pydantic, Zod)
- ✅ State management (hooks, stores)

**Example scenarios:**
- Streak calculation logic
- Date range validation
- Currency formatting
- Password strength checking
- Data transformations

**Example:**
```python
# Unit test - Pure function
def test_calculate_streak_returns_zero_for_empty_list():
    result = calculate_streak([])
    assert result == 0

def test_calculate_streak_counts_consecutive_days():
    dates = [date(2025, 1, 1), date(2025, 1, 2), date(2025, 1, 3)]
    result = calculate_streak(dates)
    assert result == 3
```

**Advantages:**
- ⚡ **Fast**: Run hundreds in seconds
- 🎯 **Focused**: One thing at a time
- 🔧 **Easy to debug**: No external dependencies
- 📈 **High coverage**: Test edge cases exhaustively

**When NOT to use:**
- Database operations (use integration)
- API calls (use integration)
- UI rendering (use component tests)

---

### Integration Tests (20%)

**What to test:**
- ✅ API endpoints (request → response)
- ✅ Database operations (CRUD, queries)
- ✅ Service interactions (auth service + database)
- ✅ Multiple layers working together

**Example scenarios:**
- POST /api/habits creates habit in database
- GET /api/habits returns all habits
- PUT /api/habits/:id updates existing habit
- Authentication flow (login → JWT → protected route)

**Example:**
```python
# Integration test - API + Database
def test_create_habit_saves_to_database(client, db_session):
    response = client.post(
        "/api/habits",
        json={"name": "Exercise", "description": "Daily workout"}
    )

    assert response.status_code == 201
    
    # Verify database persistence
    habit = db_session.query(Habit).filter_by(name="Exercise").first()
    assert habit is not None
    assert habit.description == "Daily workout"
```

**Advantages:**
- 🔗 **Real interactions**: Tests actual integration points
- 🛡️ **Contract validation**: Ensures APIs work as documented
- 💾 **Database verification**: Tests queries and constraints

**Trade-offs:**
- Slower than unit tests (seconds vs milliseconds)
- Requires test database setup
- More complex fixture management

**When NOT to use:**
- Testing pure calculations (use unit)
- Testing UI interactions (use E2E)
- Testing every edge case (use unit for that)

---

### E2E Tests (10%)

**What to test:**
- ✅ Critical user journeys (login → dashboard → action)
- ✅ Full stack integration (frontend → API → database)
- ✅ Cross-browser compatibility
- ✅ Visual regression testing

**Example scenarios:**
- User creates habit → appears in list → completes habit → streak increments
- User logs in → sees dashboard → edits profile → logs out
- Payment flow (cart → checkout → payment → confirmation)

**Example:**
```javascript
// E2E test - Full system
test('user can create and complete a habit', async ({ page }) => {
  await page.goto('/');
  
  // Create habit
  await page.click('button:has-text("Add Habit")');
  await page.fill('input[name="name"]', 'Exercise');
  await page.click('button:has-text("Save")');
  
  // Verify habit appears
  await expect(page.locator('text=Exercise')).toBeVisible();
  
  // Complete habit
  await page.click('button:has-text("Complete")');
  
  // Verify streak incremented
  await expect(page.locator('text=Streak: 1')).toBeVisible();
});
```

**Advantages:**
- 🏁 **Full confidence**: Tests actual user experience
- 🌐 **Cross-browser**: Catches browser-specific issues
- 📸 **Visual verification**: Screenshot comparison catches UI bugs

**Trade-offs:**
- 🐌 **Slow**: 10-60 seconds per test
- 💸 **Expensive**: CI minutes cost money
- 🔧 **Fragile**: Timing issues, environment dependencies
- 🛠️ **Hard to debug**: Many layers involved

**When NOT to use:**
- Testing every edge case (use unit)
- Testing error handling (use integration)
- Testing non-critical flows

---

## Anti-Patterns

### ❌ Inverted Pyramid (Too Many E2E Tests)

```
     ╱────────────────╲      E2E Tests (70%)
    ╱──────────────────╲     Problems:
   ╱  Integration Tests ╲    - Slow test suite (hours)
  ╱──────────────────────╲   - Fragile (fails often)
 ╱      Unit Tests        ╲  - Expensive CI minutes
─────────────────────────────  - Hard to debug failures
```

**Result:** Developers avoid running tests → tests ignored → codebase quality degrades

---

### ❌ Ice Cream Cone (No Unit Tests)

```
          ╱╲
         ╱  ╲           E2E Tests
        ╱    ╲          
       ╱──────╲         
      ╱        ╲        Integration Tests
     ╱──────────╲       
    ╱            ╲      
   ╱──────────────╲     
  ╱────────────────╲    Manual Testing
 ╱──────────────────╲   
──────────────────────   Unit Tests (minimal)
```

**Result:** Slow feedback, hard to debug, expensive, fragile

---

### ❌ Hourglass (Missing Integration)

```
          ╱╲
         ╱  ╲           E2E Tests (many)
        ╱    ╲          
       ╱──────╲         
      ╱ (gap)  ╲        Integration Tests (few/none)
     ╱          ╲       
    ╱────────────╲      
   ╱              ╲     
  ╱  Unit Tests   ╲     Unit Tests (many)
 ╱────────────────╲     
```

**Result:** Tests pass but integration fails in production

---

## Test Distribution Guidelines

### Small Project (< 1000 LOC)

```
E2E:         2-5 tests     (Critical flows only)
Integration: 10-20 tests   (API endpoints)
Unit:        30-100 tests  (Business logic)
```

**Total runtime:** < 30 seconds

---

### Medium Project (1k-10k LOC)

```
E2E:         5-15 tests    (Key user journeys)
Integration: 50-100 tests  (All API routes, service interactions)
Unit:        200-500 tests (All business logic, utilities)
```

**Total runtime:** 1-3 minutes

---

### Large Project (> 10k LOC)

```
E2E:         20-50 tests   (Full user workflows)
Integration: 200-500 tests (All endpoints, adapter interfaces)
Unit:        1000+ tests   (Comprehensive coverage)
```

**Total runtime:** 5-15 minutes (parallelized in CI)

---

## Coverage Targets

### By Layer

| Layer | Target Coverage | Why |
|-------|-----------------|-----|
| **Business Logic** | 90-100% | Critical correctness |
| **API Routes** | 80-90% | Happy path + errors |
| **Utilities** | 100% | Reused everywhere |
| **UI Components** | 60-80% | Happy path + key interactions |

### Overall

- **Minimum acceptable**: 70% overall coverage
- **Recommended**: 80-90% coverage
- **Not a goal**: 100% coverage (diminishing returns)

**Coverage alone is not enough** - must test right things at right layer.

---

## Test Naming Conventions

### Descriptive Names (Behavior-Driven)

✅ **Good:**
```python
def test_calculate_streak_returns_zero_for_empty_list()
def test_create_habit_returns_201_and_saves_to_database()
def test_user_cannot_complete_archived_habit()
```

❌ **Bad:**
```python
def test_streak()
def test_habit_creation()
def test_habit_1()
```

### Pattern: `test_<action>_<expected_result>_<condition>`

---

## Test Organization

### Directory Structure

```
project/
├── tests/
│   ├── conftest.py             # Shared fixtures
│   ├── pytest.ini              # Configuration
│   ├── unit/
│   │   ├── conftest.py         # Unit fixtures
│   │   ├── test_streak.py
│   │   ├── test_validators.py
│   │   └── test_utilities.py
│   ├── integration/
│   │   ├── conftest.py         # DB/API fixtures
│   │   ├── test_api_habits.py
│   │   └── test_api_completions.py
│   └── e2e/
│       ├── playwright.config.js
│       ├── pages/
│       │   └── DashboardPage.js
│       └── habits.spec.js
└── frontend/src/
    └── features/
        └── habits/
            └── __tests__/
                └── HabitCard.test.jsx
```

---

## Running Tests

### By Layer

```bash
# Backend
pytest tests/unit                    # Fast (< 1 sec)
pytest tests/integration             # Medium (5-10 sec)
pytest --slow                        # E2E (30+ sec)

# Frontend
npm test                             # Component tests
npx playwright test                  # E2E tests
```

### By Speed

```bash
# Fast tests only (unit + integration)
pytest -m "not slow"

# All tests
pytest

# Specific test
pytest tests/unit/test_streak.py::test_calculate_streak_empty
```

### In CI/CD

```yaml
# .github/workflows/test.yml
- name: Unit tests
  run: pytest tests/unit

- name: Integration tests
  run: pytest tests/integration

- name: E2E tests (only on main)
  if: github.ref == 'refs/heads/main'
  run: npx playwright test
```

---

## When to Add Tests

### Test-Driven Development (TDD)

1. **Write failing test** (red)
2. **Write minimal code to pass** (green)
3. **Refactor** (clean)

**Best for:** Well-defined requirements, algorithms, bug fixes

---

### Test-After Development

1. **Write feature**
2. **Add tests for happy path**
3. **Add tests for edge cases**

**Best for:** Exploratory work, prototypes, unclear requirements

---

### Bug-Driven Testing

1. **Bug reported**
2. **Write failing test** that reproduces bug
3. **Fix bug** (test now passes)
4. **Verify** bug can't happen again

---

## Cost-Benefit Analysis

### Unit Test Example

**Investment:** 2 minutes to write  
**Benefit:** 
- Runs in 1 ms
- Catches bugs instantly
- Documents expected behavior
- Enables refactoring confidence

**ROI:** 🟢 High

---

### Integration Test Example

**Investment:** 5 minutes to write (setup fixtures)  
**Benefit:**
- Runs in 0.5 sec
- Catches integration bugs
- Tests real database behavior

**ROI:** 🟢 High

---

### E2E Test Example

**Investment:** 20 minutes to write (page objects, waits)  
**Benefit:**
- Runs in 30 sec
- Fragile (fails on timeout, animation)
- Catches critical user-facing bugs

**ROI:** 🟡 Medium (only for critical flows)

---

## Common Pitfalls

### ❌ Don't:
- **Test implementation details** (test behavior, not internal state)
- **Over-rely on E2E tests** (slow, fragile, expensive)
- **Skip integration tests** (unit tests alone miss integration bugs)
- **Aim for 100% coverage** (diminishing returns)
- **Write flaky tests** (use deterministic data, avoid sleep/waits)

### ✅ Do:
- **Focus on behavior** (what it does, not how)
- **Test edge cases in unit tests** (fast, comprehensive)
- **Test happy path in integration** (API contracts)
- **Test critical journeys in E2E** (user value, business impact)
- **Keep tests fast** (< 10 min total suite)

---

## Practical Example: Habit Tracker

### Unit Tests (70% - 50 tests)

```python
# Streak calculation
test_streak_empty_list()
test_streak_single_day()
test_streak_consecutive_days()
test_streak_gap_breaks()
test_streak_skipped_day_continues()
test_longest_streak_calculation()

# Validators
test_habit_name_cannot_be_blank()
test_habit_color_must_be_hex()
test_completion_date_cannot_be_future()

# (40+ similar unit tests)
```

**Runtime:** < 1 second total

---

### Integration Tests (20% - 15 tests)

```python
# Habits API
test_create_habit_returns_201()
test_create_habit_saves_to_database()
test_list_habits_returns_all()
test_update_habit_changes_fields()
test_archive_habit_hides_from_list()

# Completions API
test_mark_completed_increments_streak()
test_mark_completed_updates_today_flag()
test_cannot_complete_archived_habit()

# (8+ similar integration tests)
```

**Runtime:** 5 seconds total

---

### E2E Tests (10% - 3 tests)

```javascript
// Critical user journeys
test('user can create and complete habit')
test('user can view habit history')
test('user can archive and restore habit')
```

**Runtime:** 30 seconds total

---

**Total: 68 tests in ~35 seconds**

---

## Source References

**Extracted from:**
- Habit Tracker: `.claude/reference/testing-and-logging.md` (testing pyramid section)
- Habit Tracker: Test files structure (unit, integration split)
- Industry Best Practices: Martin Fowler's Testing Pyramid

**Related Patterns:**
- 📎 [Pytest Patterns](pytest-patterns.md) - Unit testing implementation
- 📎 [FastAPI Testing Patterns](fastapi-testing-patterns.md) - Integration testing
- 📎 [Playwright E2E Patterns](playwright-e2e-patterns.md) - End-to-end testing

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0 + Industry Standards
