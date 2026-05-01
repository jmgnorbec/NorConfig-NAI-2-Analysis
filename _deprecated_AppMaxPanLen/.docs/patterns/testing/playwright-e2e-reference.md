# Playwright E2E Testing Patterns

**Pattern Type:** End-to-End Testing  
**Best For:** Critical user journeys, browser automation  
**Source:** Habit Tracker (documented patterns)  
**Complexity:** ⭐⭐⭐⭐☆

---

## Overview

Playwright end-to-end testing patterns for browser automation and user journey testing. Covers Page Object Model, selector strategies, wait patterns, visual testing, and CI integration.

**Key Characteristics:**
- Test full user workflows in real browser
- Slower execution (seconds per test)
- Highest confidence level
- Tests integration of all layers
- Catches visual/UX issues

---

## When to Use E2E Tests

### ✅ Use E2E Tests For:
- **Critical user journeys** (signup, login, checkout)
- **Multi-step workflows** (create habit → mark complete → view streak)
- **Cross-browser compatibility**
- **Visual regression** (UI layout, styling)
- **Integration verification** (frontend + backend + database)

### ❌ Don't Use E2E Tests For:
- **Pure business logic** (use unit tests)
- **API endpoint testing** (use integration tests)
- **Every user interaction** (too slow, use component tests)
- **Edge cases** (better covered by unit tests)

---

## Playwright Setup

### Installation

```bash
# Install Playwright
npm init playwright@latest

# Install browsers
npx playwright install
```

---

### Configuration

**`playwright.config.js`:**
```javascript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
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
  
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Key settings:**
- `fullyParallel`: Run tests concurrently
- `retries: 2`: Retry flaky tests in CI
- `trace: 'on-first-retry'`: Capture trace for debugging
- `webServer`: Auto-start dev server

---

## Page Object Model (POM)

### Why Page Objects?

**Benefits:**
- ✅ **Reusability** - Share page interactions across tests
- ✅ **Maintainability** - Update selectors in one place
- ✅ **Readability** - Hide complexity, expose intent
- ✅ **Type safety** - TypeScript support

---

### Basic Page Object

**`tests/e2e/pages/DashboardPage.js`:**
```javascript
export class DashboardPage {
  constructor(page) {
    this.page = page;
    
    // Selectors
    this.createHabitButton = page.getByRole('button', { name: 'Create Habit' });
    this.habitList = page.getByTestId('habit-list');
    this.habitItem = (name) => page.getByRole('listitem').filter({ hasText: name });
  }
  
  async goto() {
    await this.page.goto('/');
    await this.page.waitForLoadState('networkidle');
  }
  
  async createHabit(name, color = '#10B981') {
    await this.createHabitButton.click();
    
    // Fill form in dialog
    await this.page.getByLabel('Habit Name').fill(name);
    await this.page.getByLabel('Color').fill(color);
    await this.page.getByRole('button', { name: 'Save' }).click();
    
    // Wait for habit to appear
    await this.habitItem(name).waitFor();
  }
  
  async getHabitCount() {
    return await this.habitList.getByRole('listitem').count();
  }
  
  async completeHabit(name) {
    const habit = this.habitItem(name);
    await habit.getByRole('button', { name: 'Complete' }).click();
  }
  
  async getStreak(habitName) {
    const habit = this.habitItem(habitName);
    const streakText = await habit.getByTestId('streak').textContent();
    return parseInt(streakText);
  }
  
  async deleteHabit(name) {
    const habit = this.habitItem(name);
    await habit.getByRole('button', { name: 'Delete' }).click();
    
    // Confirm deletion
    await this.page.getByRole('button', { name: 'Confirm' }).click();
    
    // Wait for habit to disappear
    await habit.waitFor({ state: 'detached' });
  }
}
```

---

### Test Using Page Object

**`tests/e2e/habits.spec.js`:**
```javascript
import { test, expect } from '@playwright/test';
import { DashboardPage } from './pages/DashboardPage';

test.describe('Habit Management', () => {
  test('should create new habit', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();
    
    await dashboard.createHabit('Exercise');
    
    const count = await dashboard.getHabitCount();
    expect(count).toBe(1);
  });
  
  test('should complete habit and increment streak', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();
    
    // Setup: Create habit
    await dashboard.createHabit('Morning Run');
    
    // Act: Complete habit
    await dashboard.completeHabit('Morning Run');
    
    // Assert: Streak increments
    const streak = await dashboard.getStreak('Morning Run');
    expect(streak).toBe(1);
  });
  
  test('should delete habit', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();
    
    // Setup: Create habit
    await dashboard.createHabit('Temporary Habit');
    expect(await dashboard.getHabitCount()).toBe(1);
    
    // Act: Delete habit
    await dashboard.deleteHabit('Temporary Habit');
    
    // Assert: Habit removed
    expect(await dashboard.getHabitCount()).toBe(0);
  });
});
```

---

## Selector Strategies

### Priority Order (Best to Worst)

**1. Role-based selectors (Best)**
```javascript
// ✅ Best: Accessible to screen readers, semantic
await page.getByRole('button', { name: 'Create Habit' });
await page.getByRole('textbox', { name: 'Habit Name' });
await page.getByRole('dialog');
await page.getByRole('listitem');
```

**2. Label selectors**
```javascript
// ✅ Good: Tied to form labels (accessible)
await page.getByLabel('Habit Name');
await page.getByLabel('Color');
await page.getByLabel('Description');
```

**3. Text selectors**
```javascript
// ⚠️ OK: Works for unique text
await page.getByText('Create New Habit');
await page.getByText('No habits yet');
```

**4. Test ID selectors**
```javascript
// ⚠️ OK: Stable but adds test-specific markup
await page.getByTestId('habit-list');
await page.getByTestId('streak-counter');
```

**5. CSS/XPath selectors (Avoid)**
```javascript
// ❌ Fragile: Breaks on markup changes
await page.locator('.habit-card > .habit-name');
await page.locator('//div[@class="habit-list"]/div[1]');
```

---

### Combining Selectors

```javascript
// Filter by text
await page.getByRole('listitem').filter({ hasText: 'Exercise' });

// Navigate within locator
const habit = page.getByRole('listitem', { name: 'Exercise' });
await habit.getByRole('button', { name: 'Complete' }).click();

// Chain selectors
await page.getByTestId('habit-list')
  .getByRole('listitem')
  .first()
  .click();
```

---

## Wait Strategies

### Auto-Waiting (Default)

**Playwright auto-waits for elements:**
```javascript
// Automatically waits for:
// - Element to be attached to DOM
// - Element to be visible
// - Element to be stable (not animating)
// - Element to receive events (not obscured)

await page.getByRole('button', { name: 'Save' }).click();
// No manual wait needed!
```

---

### Explicit Waits

**Wait for element:**
```javascript
// Wait for element to appear
await page.getByText('Habit created').waitFor();

// Wait for element to disappear
await page.getByText('Loading...').waitFor({ state: 'detached' });

// Wait for element to be visible
await page.getByRole('dialog').waitFor({ state: 'visible' });

// Wait for element to be hidden
await page.getByRole('dialog').waitFor({ state: 'hidden' });
```

**Wait for network:**
```javascript
// Wait for network to be idle
await page.goto('/');
await page.waitForLoadState('networkidle');

// Wait for specific request
await page.waitForRequest(req => req.url().includes('/api/habits'));

// Wait for specific response
await page.waitForResponse(resp => resp.url().includes('/api/habits') && resp.status() === 201);
```

**Wait for function:**
```javascript
// Wait for custom condition
await page.waitForFunction(() => {
  return document.querySelectorAll('.habit-card').length > 0;
});

// Wait with timeout
await page.waitForFunction(
  () => document.querySelector('.streak').textContent === '5',
  { timeout: 5000 }
);
```

---

### Timeout Configuration

```javascript
// Per action
await page.getByRole('button').click({ timeout: 5000 });

// Per test
test.setTimeout(30000);

// Global (playwright.config.js)
export default defineConfig({
  timeout: 30000,
  expect: {
    timeout: 5000,
  },
});
```

---

## Assertions

### Element Assertions

```javascript
import { expect } from '@playwright/test';

// Visibility
await expect(page.getByText('Exercise')).toBeVisible();
await expect(page.getByText('Loading...')).toBeHidden();

// Text content
await expect(page.getByRole('heading')).toHaveText('My Habits');
await expect(page.getByTestId('streak')).toContainText('5');

// Count
await expect(page.getByRole('listitem')).toHaveCount(3);

// Attribute
await expect(page.getByRole('button')).toBeEnabled();
await expect(page.getByRole('button')).toBeDisabled();
await expect(page.getByRole('link')).toHaveAttribute('href', '/habits');

// CSS
await expect(page.locator('.habit-card')).toHaveClass(/completed/);
await expect(page.locator('.habit-card')).toHaveCSS('background-color', 'rgb(16, 185, 129)');
```

---

### Value Assertions

```javascript
// Input values
await expect(page.getByLabel('Habit Name')).toHaveValue('Exercise');
await expect(page.getByLabel('Color')).toHaveValue('#10B981');

// Checkbox
await expect(page.getByRole('checkbox')).toBeChecked();
await expect(page.getByRole('checkbox')).not.toBeChecked();
```

---

### URL Assertions

```javascript
// Full URL
await expect(page).toHaveURL('http://localhost:5173/habits');

// URL pattern
await expect(page).toHaveURL(/\/habits\/\d+/);

// Title
await expect(page).toHaveTitle('Habit Tracker');
```

---

## Test Isolation

### Independent Tests

```javascript
test.describe('Habit Workflow', () => {
  // ✅ Each test is independent
  test('create habit', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Create' }).click();
    // ... test logic
  });
  
  test('complete habit', async ({ page }) => {
    // Setup: Create habit first
    await page.goto('/');
    await page.getByRole('button', { name: 'Create' }).click();
    await page.getByLabel('Name').fill('Exercise');
    await page.getByRole('button', { name: 'Save' }).click();
    
    // Test: Complete habit
    await page.getByRole('button', { name: 'Complete' }).click();
    await expect(page.getByTestId('streak')).toHaveText('1');
  });
});
```

---

### Shared Setup with beforeEach

```javascript
test.describe('Habit Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    
    // Create test habit
    await page.getByRole('button', { name: 'Create' }).click();
    await page.getByLabel('Name').fill('Exercise');
    await page.getByRole('button', { name: 'Save' }).click();
  });
  
  test('should complete habit', async ({ page }) => {
    // Habit already exists from beforeEach
    await page.getByRole('button', { name: 'Complete' }).click();
    await expect(page.getByTestId('streak')).toHaveText('1');
  });
  
  test('should delete habit', async ({ page }) => {
    await page.getByRole('button', { name: 'Delete' }).click();
    await page.getByRole('button', { name: 'Confirm' }).click();
    await expect(page.getByText('No habits yet')).toBeVisible();
  });
});
```

---

### Fixtures (Advanced)

```javascript
import { test as base } from '@playwright/test';
import { DashboardPage } from './pages/DashboardPage';

// Extend base test with custom fixtures
export const test = base.extend({
  dashboardWithHabit: async ({ page }, use) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();
    await dashboard.createHabit('Exercise');
    await use(dashboard);
  },
});

// Use fixture in tests
test('should complete habit', async ({ dashboardWithHabit }) => {
  await dashboardWithHabit.completeHabit('Exercise');
  const streak = await dashboardWithHabit.getStreak('Exercise');
  expect(streak).toBe(1);
});
```

---

## Visual Testing

### Screenshot Comparison

```javascript
test('should match dashboard layout', async ({ page }) => {
  await page.goto('/');
  
  // Take screenshot and compare
  await expect(page).toHaveScreenshot('dashboard.png');
  
  // First run: Creates baseline
  // Subsequent runs: Compares against baseline
  // Fails if diff exceeds threshold
});
```

---

### Partial Screenshots

```javascript
test('should match habit card design', async ({ page }) => {
  await page.goto('/');
  
  const habitCard = page.getByTestId('habit-card').first();
  await expect(habitCard).toHaveScreenshot('habit-card.png');
});
```

---

### Mask Dynamic Content

```javascript
test('should match layout excluding dates', async ({ page }) => {
  await page.goto('/');
  
  await expect(page).toHaveScreenshot('dashboard.png', {
    mask: [
      page.locator('.timestamp'),  // Mask timestamps
      page.locator('.streak-counter')  // Mask changing counters
    ],
  });
});
```

---

## Mobile Testing

### Device Emulation

```javascript
import { devices } from '@playwright/test';

test('should work on mobile', async ({ browser }) => {
  const iPhone = devices['iPhone 13'];
  const context = await browser.newContext({
    ...iPhone,
  });
  const page = await context.newPage();
  
  await page.goto('/');
  await expect(page.getByRole('heading')).toBeVisible();
});
```

---

### Configuration for Multiple Devices

**`playwright.config.js`:**
```javascript
export default defineConfig({
  projects: [
    { name: 'Desktop Chrome', use: { ...devices['Desktop Chrome'] } },
    { name: 'Desktop Safari', use: { ...devices['Desktop Safari'] } },
    { name: 'iPhone 13', use: { ...devices['iPhone 13'] } },
    { name: 'Pixel 5', use: { ...devices['Pixel 5'] } },
  ],
});
```

**Run mobile tests:**
```bash
npx playwright test --project="iPhone 13"
```

---

## Authentication

### Reuse Authentication State

**`tests/e2e/auth.setup.js`:**
```javascript
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Login' }).click();
  
  await page.waitForURL('/dashboard');
  
  // Save authentication state
  await page.context().storageState({ path: 'tests/e2e/.auth/user.json' });
});
```

**Use in tests:**
```javascript
// playwright.config.js
export default defineConfig({
  use: {
    storageState: 'tests/e2e/.auth/user.json',
  },
});

// Tests automatically use authenticated state
test('protected page', async ({ page }) => {
  await page.goto('/dashboard');  // Already logged in
  await expect(page.getByText('Welcome')).toBeVisible();
});
```

---

## API Mocking

### Mock API Responses

```javascript
test('should handle API error', async ({ page }) => {
  // Mock failing API
  await page.route('**/api/habits', route => {
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Server error' }),
    });
  });
  
  await page.goto('/');
  
  await expect(page.getByText('Failed to load habits')).toBeVisible();
});

test('should use mock data', async ({ page }) => {
  await page.route('**/api/habits', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify([
        { id: 1, name: 'Mock Habit', color: '#10B981' }
      ]),
    });
  });
  
  await page.goto('/');
  
  await expect(page.getByText('Mock Habit')).toBeVisible();
});
```

---

## Running Tests

### Basic Commands

```bash
# Run all tests
npx playwright test

# Run specific file
npx playwright test habits.spec.js

# Run specific test
npx playwright test -g "should create habit"

# Run in UI mode (interactive)
npx playwright test --ui

# Run in headed mode (see browser)
npx playwright test --headed

# Run specific project
npx playwright test --project=chromium
```

---

### Debug Mode

```bash
# Debug mode (opens inspector)
npx playwright test --debug

# Debug specific test
npx playwright test habits.spec.js:10 --debug
```

---

### Parallel Execution

```bash
# Run in parallel (default)
npx playwright test

# Single worker (sequential)
npx playwright test --workers=1

# Specific number of workers
npx playwright test --workers=4
```

---

### Reports

```bash
# Generate HTML report
npx playwright test --reporter=html

# Show report
npx playwright show-report

# CI-friendly reporters
npx playwright test --reporter=line      # Minimal output
npx playwright test --reporter=dot       # Progress dots
npx playwright test --reporter=json      # Machine-readable
```

---

## CI Integration

### GitHub Actions

**`.github/workflows/e2e.yml`:**
```yaml
name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  e2e:
    timeout-minutes: 10
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps
      
      - name: Run E2E tests
        run: npx playwright test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

---

### Docker

**`Dockerfile.test`:**
```dockerfile
FROM mcr.microsoft.com/playwright:v1.40.0-jammy

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

CMD ["npx", "playwright", "test"]
```

**Run in Docker:**
```bash
docker build -f Dockerfile.test -t project-e2e .
docker run project-e2e
```

---

## Best Practices

### ✅ Do:
- **Use Page Object Model** for reusability
- **Prefer role-based selectors** (accessible)
- **Test critical user journeys** (not every interaction)
- **Keep tests independent** (no shared state)
- **Use fixtures** for common setup
- **Mock flaky external dependencies**
- **Run tests in CI** on every pull request
- **Review visual diffs** before accepting

### ❌ Don't:
- **Test implementation details** (test user behavior)
- **Use fragile CSS selectors**
- **Write slow tests** (optimize with API setup)
- **Test every edge case** (use unit tests)
- **Skip error handling** (test error states)
- **Ignore flaky tests** (fix or remove)
- **Over-use screenshots** (expensive, maintenance burden)

---

## Anti-Patterns

### ❌ Waiting with sleep

```javascript
// ❌ Bad: Arbitrary wait
await page.click('button');
await page.waitForTimeout(3000);  // Hope 3s is enough

// ✅ Good: Wait for specific condition
await page.click('button');
await page.getByText('Success').waitFor();
```

---

### ❌ Polling for state

```javascript
// ❌ Bad: Poll for element
let visible = false;
for (let i = 0; i < 10; i++) {
  if (await page.locator('.success').isVisible()) {
    visible = true;
    break;
  }
  await page.waitForTimeout(500);
}

// ✅ Good: Use built-in waiting
await expect(page.locator('.success')).toBeVisible();
```

---

### ❌ Fragile selectors

```javascript
// ❌ Bad: CSS selector tied to markup
await page.locator('div > div > button:nth-child(2)').click();

// ✅ Good: Semantic selector
await page.getByRole('button', { name: 'Delete' }).click();
```

---

## Source References

**Extracted from:**
- Habit Tracker: `.claude/reference/testing-and-logging.md` (Playwright patterns)
- Playwright documentation: Best practices and patterns
- Industry standards: Page Object Model, selector strategies

**Related Patterns:**
- 📎 [Testing Pyramid](testing-pyramid.md) - E2E tests at top (10%)
- 📎 [Frontend Testing Patterns](frontend-testing-patterns.md) - Component tests
- 📎 [FastAPI Testing Patterns](fastapi-testing-patterns.md) - API tests

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Habit Tracker v1.0.0 (documented patterns)
