# Template Usage Guide

**Purpose:** Decision framework for choosing patterns based on project complexity and requirements.

**Core Philosophy:** Start simple, scale incrementally. This template provides ALL patterns upfront, but you only adopt what you need, when you need it.

---

## Quick Decision Matrix

Use this matrix to quickly determine which patterns to apply:

| Project Type | Architecture | Database | Deployment | Testing | Frontend |
|-------------|--------------|----------|------------|---------|----------|
| **MVP/Proof-of-Concept** | Single-service | SQLite | Local dev only | Unit + Integration | Basic React |
| **Small Production App** | Single-service | PostgreSQL | Docker + VPS | Unit + Integration + E2E | React + Tailwind |
| **Multi-Team Product** | Multi-service | PostgreSQL | Docker Compose + CI/CD | Full pyramid | React + MUI + BFF |
| **Complex Integrations** | Hexagonal | PostgreSQL | Kubernetes | Full pyramid + mocks | React + TypeScript + BFF |

**Guide Navigation:**
- **Simple projects:** See [QuickStart-Simple.md](QuickStart-Simple.md)
- **Production projects:** See [QuickStart-Production.md](QuickStart-Production.md)
- **Growth strategy:** See [ArchitectureGrowthPath.md](ArchitectureGrowthPath.md)

---

## Complexity Assessment

### Simple (Week 1-4)

**Characteristics:**
- Single developer or small team (2-3)
- CRUD operations
- Local development focus
- No external API integrations
- Basic authentication (or none)

**Pattern Selection:**
- ✅ Single-service architecture
- ✅ SQLite database
- ✅ Basic React components
- ✅ Unit + Integration tests
- ❌ Docker (develop locally)
- ❌ Multi-service architecture
- ❌ Complex deployment

**Time to first working version:** 1-3 days

**Examples:** Todo app, personal habit tracker, blog, note-taking app

📎 **Start here:** [QuickStart-Simple.md](QuickStart-Simple.md)

---

### Medium (Month 1-3)

**Characteristics:**
- Team of 3-5 developers
- Public-facing application
- Need production deployment
- Basic external integrations (email, storage)
- User authentication required

**Pattern Selection:**
- ✅ Single-service (start) → Multi-service (if needed)
- ✅ PostgreSQL database
- ✅ Docker containerization
- ✅ GitHub Actions CI/CD
- ✅ VPS deployment
- ✅ React + Tailwind/MUI
- ✅ Full testing pyramid
- ⚠️ BFF (only if needed for security/proxying)
- ❌ Hexagonal architecture (not yet)

**Time to production:** 2-4 weeks

**Examples:** SaaS MVP, internal tools, customer portal, content management system

📎 **Start here:** [QuickStart-Production.md](QuickStart-Production.md)

---

### Complex (Month 3+)

**Characteristics:**
- Multiple teams or services
- Complex external integrations (OAuth, webhooks, multi-provider)
- High scalability requirements
- Microservices architecture
- Multiple frontends (admin, user, mobile)

**Pattern Selection:**
- ✅ Multi-service architecture
- ✅ Hexagonal architecture (for integration services)
- ✅ PostgreSQL with migrations
- ✅ Docker Compose orchestration
- ✅ Traefik reverse proxy
- ✅ BFF pattern for frontends
- ✅ Full testing with adapter mocks
- ✅ Comprehensive monitoring

**Time to production:** 1-3 months

**Examples:** E-commerce platform, workflow automation, multi-tenant SaaS, API aggregation platform

📎 **Reference:** [examples/REFERENCE_PROJECTS.md](../examples/REFERENCE_PROJECTS.md) - AI Workflow Automation

---

## Pattern Selection by Concern

### Architecture Patterns

| Pattern | Use When | Don't Use When | Reference |
|---------|----------|----------------|-----------|
| **Single-service** | MVP, < 3 developers, simple CRUD | Multiple teams, complex integrations | [single-service-overview.md](patterns/architecture/single-service-overview.md) |
| **Multi-service** | > 5 developers, independent deployments | Small team, MVP, tight coupling acceptable | [multi-service-overview.md](patterns/architecture/multi-service-overview.md) |
| **Hexagonal** | Multiple external providers, complex business logic | Simple CRUD, no external integrations | [hexagonal-architecture-overview.md](patterns/architecture/hexagonal-architecture-overview.md) |

### Database Patterns

| Pattern | Use When | Don't Use When | Reference |
|---------|----------|----------------|-----------|
| **SQLite** | Local dev, MVP, single-user, < 1GB data | Production, concurrent writes, > 1GB | [sqlite-overview.md](patterns/database/sqlite-overview.md) |
| **PostgreSQL** | Production, concurrent access, > 1GB data | Local MVP, single-user apps | [postgresql-overview.md](patterns/database/postgresql-overview.md) |
| **Manual migrations** | Full control, simple schema, small team | Large team, complex schemas (use Alembic) | [migrations-overview.md](patterns/database/migrations-overview.md) |

### Deployment Patterns

| Pattern | Use When | Don't Use When | Reference |
|---------|----------|----------------|-----------|
| **Docker** | Production deployment, reproducible builds | Local dev only (overhead not worth it) | [docker-overview.md](patterns/deployment/docker-overview.md) |
| **Docker Compose** | Multi-service, orchestration, dev parity | Single service, simple deployment | [docker-compose-overview.md](patterns/deployment/docker-compose-overview.md) |
| **GitHub Actions** | Open source, GitHub repo, simple CI/CD | Complex pipelines (use Jenkins/GitLab) | [github-actions-overview.md](patterns/deployment/github-actions-overview.md) |
| **VPS Deployment** | Cost-effective, full control, low-medium traffic | High traffic, auto-scaling needs (use cloud) | [vps-overview.md](patterns/deployment/vps-overview.md) |
| **Traefik** | Multi-service routing, automatic TLS | Single service (Nginx sufficient) | [traefik-overview.md](patterns/deployment/traefik-overview.md) |

### Testing Patterns

| Pattern | Use When | Don't Use When | Reference |
|---------|----------|----------------|-----------|
| **70/20/10 Pyramid** | Standard projects, good coverage | Compliance needs (may need more E2E) | [testing-pyramid-overview.md](patterns/testing/testing-pyramid-overview.md) |
| **pytest fixtures** | Python projects, shared test setup | Simple tests (fixtures add complexity) | [pytest-overview.md](patterns/testing/pytest-overview.md) |
| **TestClient** | FastAPI integration tests | E2E tests (use real HTTP) | [testclient-overview.md](patterns/testing/testclient-overview.md) |
| **Playwright** | Critical user flows, regression testing | API-only services (no UI) | [playwright-overview.md](patterns/testing/playwright-overview.md) |

### Frontend Patterns

| Pattern | Use When | Don't Use When | Reference |
|---------|----------|----------------|-----------|
| **Feature folders** | All React projects | Server-side rendering (different org) | [feature-folder-structure-overview.md](patterns/frontend/feature-folder-structure-overview.md) |
| **TanStack Query** | API-driven apps, caching needs | Static sites, no server data | [tanstack-query-overview.md](patterns/frontend/tanstack-query-overview.md) |
| **BFF Pattern** | Security concerns, multiple APIs, cookies | Simple API proxy (overkill) | [bff-pattern-overview.md](patterns/frontend/bff-pattern-overview.md) |
| **MUI** | Admin panels, data-heavy UIs | Marketing sites (too heavy) | [mui-patterns-overview.md](patterns/frontend/mui-patterns-overview.md) |
| **Tailwind CSS** | Custom designs, utility-first styling | Component libraries sufficient (MUI, etc.) | N/A (example in habit-tracker) |

---

## Decision Flowcharts

### Architecture Decision

```
START
  ↓
  Do you need external API integrations? (MS365, Google, multiple providers)
    YES → Hexagonal Architecture
    NO → ↓
  ↓
  Do you have > 5 developers or need independent deployments?
    YES → Multi-service Architecture
    NO → Single-service Architecture
```

### Database Decision

```
START
  ↓
  Is this production? (real users, not just you)
    NO → SQLite (simpler setup)
    YES → ↓
  ↓
  Do you need concurrent writes or > 1GB data?
    YES → PostgreSQL
    NO → SQLite (with upgrade path to PostgreSQL)
```

### Deployment Decision

```
START
  ↓
  Are you deploying to production?
    NO → Run locally (uvicorn, npm run dev)
    YES → ↓
  ↓
  Do you have multiple services?
    YES → Docker Compose + Traefik
    NO → ↓
  ↓
  Do you need reproducible builds?
    YES → Docker
    NO → Direct deployment to VPS
```

---

## Common Scenarios

### Scenario 1: Weekend Project

**Goal:** Build a personal productivity app in 2 days

**Pattern Selection:**
- Single-service architecture
- SQLite database
- React with Tailwind CSS
- No Docker (run locally)
- Basic pytest tests

**Estimated Time:** 8-16 hours

📎 **Guide:** [QuickStart-Simple.md](QuickStart-Simple.md)

---

### Scenario 2: Startup MVP

**Goal:** Launch SaaS product in 4 weeks, needs authentication and payments

**Pattern Selection:**
- Single-service architecture
- PostgreSQL database
- Docker for deployment
- GitHub Actions CI/CD
- VPS deployment (Hetzner/DigitalOcean)
- React + TanStack Query
- Full testing pyramid

**Estimated Time:** 80-120 hours

📎 **Guide:** [QuickStart-Production.md](QuickStart-Production.md)

---

### Scenario 3: Enterprise Integration Platform

**Goal:** Build workflow automation connecting MS365, Google, Slack

**Pattern Selection:**
- Multi-service architecture (auth, api, frontend)
- Hexagonal architecture for API service
- PostgreSQL with manual migrations
- Docker Compose orchestration
- Traefik reverse proxy
- BFF for frontend
- React + TypeScript + MUI
- Comprehensive testing with adapter mocks

**Estimated Time:** 300-500 hours

📎 **Reference:** [examples/REFERENCE_PROJECTS.md](../examples/REFERENCE_PROJECTS.md) - AI Workflow Automation

---

## Anti-Patterns to Avoid

### ❌ Starting Too Complex

**Mistake:** Using hexagonal architecture + multi-service for a simple CRUD app

**Why it's wrong:**
- Overhead of adapter layers for no external integrations
- Service boundaries add complexity without benefit
- Slower development velocity

**Instead:** Start with single-service, refactor to hexagonal when you add external APIs

---

### ❌ Staying Too Simple

**Mistake:** SQLite in production with 100+ concurrent users

**Why it's wrong:**
- SQLite locks on writes (concurrency issues)
- Single file vulnerability (corruption risk)
- Limited scaling options

**Instead:** Migrate to PostgreSQL when planning production launch

---

### ❌ Premature Microservices

**Mistake:** Splitting into 10 services on day 1

**Why it's wrong:**
- Overhead of service boundaries unclear
- Network latency and failure modes
- Deployment complexity

**Instead:** Start with single-service, split when team size or domain boundaries justify it

---

### ❌ No Testing Strategy

**Mistake:** Writing E2E tests only, or no tests at all

**Why it's wrong:**
- E2E tests slow and brittle
- No safety net for refactoring
- Bugs caught late

**Instead:** Follow 70/20/10 pyramid: mostly unit tests, some integration, few E2E

---

### ❌ Ignoring Growth Path

**Mistake:** Building architecture with no path to scale

**Why it's wrong:**
- Rewrite required when growing
- Technical debt accumulates
- Lost development time

**Instead:** Use patterns that support evolution (service pattern, clear layers, interfaces)

---

## Pattern Adoption Timeline

### Week 1: Foundation
- ✅ Single-service structure
- ✅ Basic CRUD endpoints
- ✅ SQLite database
- ✅ Unit tests for business logic

### Week 2-4: Core Features
- ✅ Authentication
- ✅ Integration tests
- ✅ React frontend basics
- ✅ TanStack Query for data fetching

### Month 2: Production Prep
- ✅ Migrate to PostgreSQL
- ✅ Docker containerization
- ✅ GitHub Actions CI/CD
- ✅ VPS deployment

### Month 3: Scaling
- ✅ Add E2E tests (Playwright)
- ✅ Performance optimization
- ⚠️ Consider multi-service if needed
- ⚠️ Add hexagonal if external integrations needed

### Month 6+: Maturity
- ⚠️ Multi-service architecture (if justified)
- ⚠️ Traefik for service routing
- ⚠️ BFF for frontend security
- ⚠️ Advanced monitoring

**Key principle:** Each step is optional. Only adopt when you have a clear need.

---

## Getting Started

### New Project Checklist

1. **Assess complexity** using matrix above
2. **Choose guide:**
   - Simple: [QuickStart-Simple.md](QuickStart-Simple.md)
   - Production: [QuickStart-Production.md](QuickStart-Production.md)
3. **Copy relevant templates** from `templates/`
4. **Reference patterns** as you implement features
5. **Study examples:**
   - Simple: [examples/api-hello-world.py](../examples/api-hello-world.py)
   - Complex: [examples/REFERENCE_PROJECTS.md](../examples/REFERENCE_PROJECTS.md)

### Evolution Strategy

**Start with minimum viable patterns:**
1. Single-service + SQLite + Basic React
2. Add features iteratively
3. **When pain points emerge**, adopt next pattern:
   - Slow tests → More unit tests, fewer E2E
   - Concurrency issues → Migrate to PostgreSQL
   - Complex integrations → Adopt hexagonal architecture
   - Multiple teams → Consider multi-service

📎 **Evolution guide:** [ArchitectureGrowthPath.md](ArchitectureGrowthPath.md)

---

## Pattern Library Quick Links

### Architecture
- [Single-service](patterns/architecture/single-service-overview.md) - Start here for MVPs
- [Multi-service](patterns/architecture/multi-service-overview.md) - When team > 5 people
- [Hexagonal](patterns/architecture/hexagonal-architecture-overview.md) - External integrations

### Deployment
- [Docker](patterns/deployment/docker-overview.md) - Containerization basics
- [Docker Compose](patterns/deployment/docker-compose-overview.md) - Multi-service orchestration
- [GitHub Actions](patterns/deployment/github-actions-overview.md) - CI/CD automation
- [VPS](patterns/deployment/vps-overview.md) - Cost-effective hosting
- [Traefik](patterns/deployment/traefik-overview.md) - Reverse proxy + TLS
- [Environment Config](patterns/deployment/environment-config-overview.md) - .env management

### Testing
- [Testing Pyramid](patterns/testing/testing-pyramid-overview.md) - 70/20/10 strategy
- [pytest](patterns/testing/pytest-overview.md) - Python testing framework
- [TestClient](patterns/testing/testclient-overview.md) - FastAPI integration tests
- [Unit Tests](patterns/testing/unit-tests-overview.md) - Testing business logic
- [Playwright](patterns/testing/playwright-overview.md) - E2E browser tests

### Frontend
- [Feature Folders](patterns/frontend/feature-folder-structure-overview.md) - React organization
- [React Patterns](patterns/frontend/react-patterns-overview.md) - Component best practices
- [TanStack Query](patterns/frontend/tanstack-query-overview.md) - Server state management
- [BFF Pattern](patterns/frontend/bff-pattern-overview.md) - Backend-for-frontend
- [MUI Patterns](patterns/frontend/mui-patterns-overview.md) - Material UI components

### Database
- [SQLite](patterns/database/sqlite-overview.md) - Local development database
- [PostgreSQL](patterns/database/postgresql-overview.md) - Production database
- [Migrations](patterns/database/migrations-overview.md) - Schema evolution
- [Service Pattern](patterns/database/service-pattern-overview.md) - Data access layer
- [Models vs Schemas](patterns/database/models-vs-schemas-overview.md) - SQLAlchemy + Pydantic

---

**Last Updated:** 2026-03-07  
**Template Version:** 1.0.0

**Next Steps:**
- Simple project: [QuickStart-Simple.md](QuickStart-Simple.md)
- Production project: [QuickStart-Production.md](QuickStart-Production.md)
- Evolution strategy: [ArchitectureGrowthPath.md](ArchitectureGrowthPath.md)
