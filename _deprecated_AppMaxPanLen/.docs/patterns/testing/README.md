# Testing Patterns

**Purpose:** Testing strategies and patterns for comprehensive test coverage (unit, integration, E2E).

---

## Pattern Structure

Each testing pattern is split into two files:

- **`{pattern}-overview.md`** (~300 lines, 2-3 min read) - Quick decision-making reference:
  - When to use (vs alternatives)
  - Essential configuration (minimal setup)
  - Minimal working examples (copy-paste ready)
  - Common operations (frequent tasks)
  - Top 5 gotchas (critical mistakes to avoid)
  - Quick troubleshooting

- **`{pattern}-reference.md`** (~400-800 lines, 20+ min read) - Comprehensive implementation guide:
  - Complete configuration options
  - All examples and edge cases
  - Advanced patterns
  - Performance optimization
  - Full troubleshooting guide

**When to use:**
- **Overview** - Understanding testing strategy, choosing test types, quick setup
- **Reference** - Advanced patterns, CI/CD setup, debugging, performance

---

## Available Patterns

### 1. Testing Pyramid Strategy

**What:** Testing distribution (70% unit, 20% integration, 10% E2E)  
**When:** Every project with automated tests (defines test strategy)

- 📘 [testing-pyramid-overview.md](testing-pyramid-overview.md) - Layer distribution, what to test where
- 📖 [testing-pyramid-reference.md](testing-pyramid-reference.md) - Anti-patterns, test organization, CI/CD

**Start here:** Defining test strategy, understanding speed vs confidence tradeoff.

---

### 2. pytest Patterns (Python)

**What:** Python unit testing framework (fixtures, parametrization, mocking)  
**When:** Python projects with business logic to test

- 📘 [pytest-overview.md](pytest-overview.md) - Basic tests, fixtures, parametrize, mocking
- 📖 [pytest-reference.md](pytest-reference.md) - Advanced fixtures, plugins, async testing

**Start here:** Writing first unit test, setting up fixtures, mocking dependencies.

---

### 3. FastAPI Integration Testing

**What:** API endpoint testing with TestClient and real database  
**When:** FastAPI projects (integration between routes, business logic, database)

- 📘 [fastapi-testing-overview.md](fastapi-testing-overview.md) - TestClient, in-memory SQLite, testing CRUD
- 📖 [fastapi-testing-reference.md](fastapi-testing-reference.md) - Auth testing, file uploads, async operations

**Start here:** Testing API endpoints, setting up test database, dependency injection.

---

### 4. Unit Testing Patterns

**What:** Testing pure functions and business logic (no dependencies, no side effects)  
**When:** Testing calculations, validators, utilities, domain logic

- 📘 [unit-testing-overview.md](unit-testing-overview.md) - Pure functions, AAA pattern, TDD
- 📖 [unit-testing-reference.md](unit-testing-reference.md) - Mocking strategies, edge cases, test organization

**Start here:** Understanding what makes good unit test, TDD workflow.

---

### 5. Playwright E2E Testing

**What:** Browser automation for end-to-end testing (critical user journeys)  
**When:** Testing frontend + backend + browser integration (10% of test suite)

- 📘 [playwright-e2e-overview.md](playwright-e2e-overview.md) - Page Object Model, basic E2E tests
- 📖 [playwright-e2e-reference.md](playwright-e2e-reference.md) - Network mocking, visual regression, CI/CD

**Start here:** Writing first E2E test, Page Object Model pattern.

---

## Pattern Decision Guide

### For AI Agents Loading Context

**Decision-making (load overviews):**
- Choosing testing pyramid distribution → [testing-pyramid-overview.md](testing-pyramid-overview.md)
- Deciding what to test where (unit vs integration vs E2E) → [testing-pyramid-overview.md](testing-pyramid-overview.md)
- Writing first Python test → [pytest-overview.md](pytest-overview.md)
- Testing pure functions → [unit-testing-overview.md](unit-testing-overview.md)
- Testing API endpoints → [fastapi-testing-overview.md](fastapi-testing-overview.md)
- Testing critical user journeys → [playwright-e2e-overview.md](playwright-e2e-overview.md)

**Implementation (load references on-demand):**
- Advanced pytest fixtures (scope, autouse, parametrize with IDs) → [pytest-reference.md](pytest-reference.md)
- In-memory SQLite troubleshooting (foreign keys, StaticPool) → [fastapi-testing-reference.md](fastapi-testing-reference.md)
- Mocking external APIs → [unit-testing-reference.md](unit-testing-reference.md)
- Playwright network interception → [playwright-e2e-reference.md](playwright-e2e-reference.md)
- CI/CD test configuration → [testing-pyramid-reference.md](testing-pyramid-reference.md)

### For Developers Learning Patterns

| Scenario | Start With | Then Read |
|----------|------------|-----------|
| **New project** | testing-pyramid-overview | pytest-overview, unit-testing-overview |
| **Adding first test** | pytest-overview | unit-testing-overview |
| **Testing API** | fastapi-testing-overview | testing-pyramid-overview |
| **Testing frontend** | playwright-e2e-overview | testing-pyramid-overview |
| **Flaky tests** | playwright-e2e-overview (gotchas) | playwright-e2e-reference |
| **Slow test suite** | testing-pyramid-overview (distribution) | testing-pyramid-reference |

### Project Phase Decision Matrix

| Phase | Testing Patterns | Rationale |
|-------|-----------------|-----------|
| **Week 1 (MVP)** | Testing pyramid + Unit testing | Define strategy, test business logic |
| **Month 1 (Alpha)** | + pytest patterns | Setup fixtures, organize tests |
| **Month 3 (Beta)** | + FastAPI testing | Integration tests for API stability |
| **Production** | + Playwright E2E | Critical path validation |

---

## Quick Reference

### Test Distribution (Testing Pyramid)

```
        /\
       /  \      10% E2E (5-60 sec per test)
      /____\     Full system, high confidence
     /      \
    /        \   20% Integration (50-200 ms)
   /__________\  API + DB, medium confidence
  /            \
 /              \ 70% Unit (1-10 ms per test)
/________________\ Pure functions, low confidence
```

### Test Organization

```
tests/
├── conftest.py              # Shared fixtures
├── unit/
│   ├── test_calculations.py # Pure functions
│   └── test_validators.py   # Business rules
├── integration/
│   ├── test_api_habits.py   # API endpoints
│   └── test_api_completions.py
└── e2e/
    ├── pages/               # Page objects
    └── habits.spec.js       # User journeys
```

### Key Principles

1. **70-20-10 distribution** - Unit tests are foundation
2. **Pure functions in unit tests** - No DB, no network, no side effects
3. **Integration tests use real DB** - In-memory SQLite for speed
4. **E2E tests for critical paths only** - Too slow, too fragile for everything
5. **No hardcoded dates** - Use `date.today()` or freeze time

---

## Loading Strategy Summary

**For quick decisions (2-3 min):** Load overview files  
**For deep implementation (20+ min):** Load reference files on-demand

**Override + reference pattern:** All overviews include 📎 anchor to reference file with "When to load" guidance.

---

**Template Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Patterns Complete:** 5/5 (testing-pyramid, pytest, fastapi-testing, unit-testing, playwright-e2e)
