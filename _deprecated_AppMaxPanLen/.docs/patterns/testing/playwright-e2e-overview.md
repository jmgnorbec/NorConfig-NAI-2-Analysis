# Playwright E2E Testing - Overview

**Pattern Type:** End-to-End Testing  
**Complexity:** Intermediate to Advanced  
**Read Time:** ~3 minutes  
**Best For:** Critical user journeys, browser automation, visual testing

---

## When to Use Playwright E2E Tests

### ✅ Use E2E Tests For

- **Critical user journeys** (signup → login → complete action → verify result)
- **Multi-step workflows** (create habit → mark complete → view streak)
- **Cross-browser testing** (Chromium, Firefox, WebKit)
- **Visual regression** (UI layout, styling consistency)
- **Full integration verification** (frontend + backend + database + browser)

### ❌ Don't Use E2E Tests For

- **Business logic** (use unit tests - 100x faster)
- **API endpoints** (use integration tests - 10x faster)
- **Every user interaction** (too slow, use component tests)
- **Edge cases** (better covered by unit tests)
- **Data validation** (unit test validators)

### vs. Other Test Types

| Test Type | Speed | Coverage | Confidence | Maintenance |
|-----------|-------|----------|------------|-------------|
| **Unit** | 1-10 ms | Single function | Low | Easy |
| **Integration** | 50-200 ms | API + DB | Medium | Medium |
| **E2E** | 5-60 sec | Full system | High | Hard |

**Key insight:** E2E tests give highest confidence but are slowest and most fragile. Use sparingly for critical paths only (10% of test suite).

---

## Essential Configuration

### Installation

```bash
# Initialize Playwright
npm init playwright@latest

# Install browsers
npx playwright install

# Install browsers with system dependencies (Linux)
npx playwright install --with-deps
```

### Configuration

**`playwright.config.js`:**
```javascript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,  // Retry flaky tests in CI
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  
  // Auto-start dev server
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Key settings:**
- `retries: 2` in CI (handles flaky tests)
- `trace: 'on-first-retry'` (debugging failed tests)
- `webServer` auto-starts dev server
- Multiple browsers for cross-browser testing

---

## Minimal Working Examples

### 1. Basic E2E Test

```javascript
// tests/e2e/habits.spec.js
import { test, expect } from '@playwright/test';

test('create and view habit', async ({ page }) => {
  // Navigate to app
  await page.goto('/');
  
  // Click "Add Habit" button
  await page.click('button:has-text("Add Habit")');
  
  // Fill form
  await page.fill('input[name="name"]', 'Exercise');
  await page.fill('textarea[name="description"]', 'Daily workout');
  
  // Submit
  await page.click('button[type="submit"]');
  
  // Verify habit appears
  await expect(page.locator('text=Exercise')).toBeVisible();
  await expect(page.locator('text=Daily workout')).toBeVisible();
});
```

**Run:** `npx playwright test`

### 2. Page Object Model (POM)

**Organize selectors and actions into reusable page objects:**

**`tests/e2e/pages/DashboardPage.js`:**
```javascript
export class DashboardPage {
  constructor(page) {
    this.page = page;
    // Selectors
    this.addHabitButton = page.locator('button:has-text("Add Habit")');
    this.habitNameInput = page.locator('input[name="name"]');
    this.habitDescInput = page.locator('textarea[name="description"]');
    this.submitButton = page.locator('button[type="submit"]');
  }

  async goto() {
    await this.page.goto('/');
  }

  async createHabit(name, description) {
    await this.addHabitButton.click();
    await this.habitNameInput.fill(name);
    await this.habitDescInput.fill(description);
    await this.submitButton.click();
  }

  async getHabitByName(name) {
    return this.page.locator(`text=${name}`);
  }
}
```

**Use in test:**
```javascript
import { DashboardPage } from './pages/DashboardPage';

test('create habit using page object', async ({ page }) => {
  const dashboard = new DashboardPage(page);
  
  await dashboard.goto();
  await dashboard.createHabit('Exercise', 'Daily workout');
  
  const habit = await dashboard.getHabitByName('Exercise');
  await expect(habit).toBeVisible();
});
```

### 3. Multi-Step User Journey

```javascript
test('complete habit and verify streak', async ({ page }) => {
  const dashboard = new DashboardPage(page);
  
  // 1. Navigate
  await dashboard.goto();
  
  // 2. Create habit
  await dashboard.createHabit('Meditate', '10 minutes daily');
  
  // 3. Complete habit
  await page.click('button:has-text("Complete")');
  
  // 4. Verify completion marked
  await expect(page.locator('.habit-card.completed')).toBeVisible();
  
  // 5. Verify streak updated
  await expect(page.locator('text=Streak: 1')).toBeVisible();
  
  // 6. Check calendar
  const today = new Date().getDate();
  const calendarDay = page.locator(`[data-date="${today}"]`);
  await expect(calendarDay).toHaveClass(/completed/);
});
```

### 4. Testing Authentication

```javascript
test('login and access protected page', async ({ page }) => {
  // Navigate to login
  await page.goto('/login');
  
  // Fill credentials
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');
  
  // Submit login
  await page.click('button[type="submit"]');
  
  // Wait for redirect
  await page.waitForURL('/dashboard');
  
  // Verify logged in
  await expect(page.locator('text=Welcome')).toBeVisible();
});

// Reusable auth fixture
test.beforeEach(async ({ page }) => {
  // Login before each test
  await page.goto('/login');
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  await page.waitForURL('/dashboard');
});
```

### 5. Visual Testing (Screenshots)

```javascript
test('dashboard layout', async ({ page }) => {
  await page.goto('/');
  
  // Take screenshot for visual comparison
  await expect(page).toHaveScreenshot('dashboard.png');
});

test('empty state', async ({ page }) => {
  await page.goto('/');
  
  // Screenshot specific element
  const emptyState = page.locator('.empty-state');
  await expect(emptyState).toHaveScreenshot('empty-state.png');
});
```

---

## Common Operations

### Locators (Finding Elements)

```javascript
// By text
page.locator('text=Exercise');

// By role
page.getByRole('button', { name: 'Submit' });

// By test ID (recommended)
page.locator('[data-testid="habit-card"]');

// By CSS selector
page.locator('.habit-card.active');

// Chaining
page.locator('.habit-list').locator('button').first();
```

### Interactions

```javascript
// Click
await page.click('button');

// Fill input
await page.fill('input[name="email"]', 'user@example.com');

// Select dropdown
await page.selectOption('select[name="category"]', 'health');

// Check checkbox
await page.check('input[type="checkbox"]');

// Upload file
await page.setInputFiles('input[type="file"]', 'path/to/file.pdf');
```

### Assertions

```javascript
// Visibility
await expect(page.locator('text=Success')).toBeVisible();
await expect(page.locator('text=Error')).toBeHidden();

// Text content
await expect(page.locator('h1')).toHaveText('Welcome');
await expect(page.locator('.status')).toContainText('Active');

// Attribute
await expect(page.locator('button')).toBeDisabled();
await expect(page.locator('input')).toHaveValue('Exercise');

// Count
await expect(page.locator('.habit-card')).toHaveCount(3);
```

### Waiting

```javascript
// Wait for element
await page.waitForSelector('text=Loaded');

// Wait for URL
await page.waitForURL('/dashboard');

// Wait for network
await page.waitForResponse(resp => resp.url().includes('/api/habits'));

// Wait for load state
await page.waitForLoadState('networkidle');
```

---

## Top 5 Gotchas

### 1. No Explicit Waits (Flaky Tests) ⚠️

```javascript
// ❌ Wrong: Race condition
await page.click('button:has-text("Save")');
const message = await page.locator('text=Saved').textContent();  // Flaky!

// ✅ Correct: Use built-in auto-wait
await page.click('button:has-text("Save")');
await expect(page.locator('text=Saved')).toBeVisible();  // Auto-waits
```

**Impact:** Tests randomly fail, team loses trust.

### 2. Not Using Page Object Model

```javascript
// ❌ Wrong: Selectors duplicated in every test
test('test 1', async ({ page }) => {
  await page.click('button:has-text("Add Habit")');
  await page.fill('input[name="name"]', 'Exercise');
});

test('test 2', async ({ page }) => {
  await page.click('button:has-text("Add Habit")');  // Duplicate!
  await page.fill('input[name="name"]', 'Meditate');
});

// ✅ Correct: Use Page Object
const dashboard = new DashboardPage(page);
await dashboard.createHabit('Exercise', 'Workout');
```

**Impact:** Selector change breaks 50 tests, hard to maintain.

### 3. Testing Too Much in E2E

```javascript
// ❌ Wrong: E2E test for validation logic
test('email validation', async ({ page }) => {
  await page.goto('/signup');
  await page.fill('input[name="email"]', 'invalid');
  await page.click('button[type="submit"]');
  await expect(page.locator('text=Invalid email')).toBeVisible();
  // Test 50 edge cases... (30 seconds per test)
});

// ✅ Correct: Unit test validation, E2E test happy path only
// Unit test (1ms)
def test_email_validation():
    assert is_valid_email("invalid") is False

// E2E test (5 sec) - happy path only
test('signup flow', async ({ page }) => {
  await signupUser('user@example.com', 'password123');
  await expect(page).toHaveURL('/dashboard');
});
```

**Impact:** Test suite takes 1 hour to run, developers skip tests.

### 4. Hardcoded Test Data

```javascript
// ❌ Wrong: Hardcoded date breaks test tomorrow
test('view today completions', async ({ page }) => {
  await page.goto('/calendar');
  await expect(page.locator('[data-date="15"]')).toHaveClass(/completed/);
});

// ✅ Correct: Dynamic dates
test('view today completions', async ({ page }) => {
  const today = new Date().getDate();
  await page.goto('/calendar');
  await expect(page.locator(`[data-date="${today}"]`)).toHaveClass(/completed/);
});
```

**Impact:** Tests fail unpredictably based on current date.

### 5. No Test Isolation (Shared State)

```javascript
// ❌ Wrong: Tests depend on each other
test('create habit', async ({ page }) => {
  await createHabit('Exercise');
});

test('complete habit', async ({ page }) => {
  await completeHabit('Exercise');  // Assumes Exercise exists!
});

// ✅ Correct: Each test independent
test('complete habit', async ({ page }) => {
  await createHabit('Exercise');  // Setup within test
  await completeHabit('Exercise');
});
```

**Impact:** Tests fail in different order, impossible to debug.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Tests randomly fail | No waits, race conditions | Use `await expect().toBeVisible()` |
| Selector change breaks many tests | No Page Object Model | Create page objects |
| Test suite > 30 min | Too many E2E tests | Convert 80% to integration/unit |
| Tests fail on different dates | Hardcoded dates | Use `new Date()` dynamically |
| Tests work individually, fail together | Shared state | Make each test independent |

---

## References

📎 **Reference**: [playwright-e2e-reference.md](playwright-e2e-reference.md)  
**When to load**: Advanced patterns (API mocking, network interception, mobile emulation), parallel testing, CI/CD integration, visual regression testing, performance testing, debugging strategies (~730 lines)

📎 **Related patterns**:
- [testing-pyramid.md](testing-pyramid-overview.md) - Testing strategy (when to use E2E)
- [pytest-patterns.md](pytest-overview.md) - Unit testing business logic
- [fastapi-testing-patterns.md](fastapi-testing-overview.md) - Integration testing APIs

---

**Pattern Type:** End-to-End Testing  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate to Advanced ⭐⭐⭐⭐☆
