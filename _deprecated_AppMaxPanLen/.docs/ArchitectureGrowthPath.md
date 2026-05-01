# Architecture Growth Path

**Purpose:** Evidence-based guidance for evolving architecture from MVP to production-ready system.

**Core Principle:** Adopt complexity only when you have clear evidence it's needed.

---

## Overview

```
Week 1-2          Month 1-2         Month 3-6         Month 6+
┌─────────┐      ┌─────────┐      ┌──────────┐     ┌───────────┐
│  Local  │  →   │  Docker │  →   │  Multi-  │  →  │  Complex  │
│   MVP   │      │  + VPS  │      │  Service │     │Integration│
└─────────┘      └─────────┘      └──────────┘     └───────────┘
SQLite           PostgreSQL        PostgreSQL       PostgreSQL
No tests         Unit + Integ      Full Pyramid     + Adapters
Local dev        Production        CI/CD mature     Orchestration
```

**Key philosophy:** Each stage builds on the previous, no rewrites needed.

---

## Stage 1: Local MVP (Week 1-2)

### What You Have
- Single-service architecture
- SQLite database
- Basic React frontend
- Running on localhost
- Maybe some unit tests

### Characteristics
- 1-2 developers
- Exploring problem space
- Rapid iteration
- No users yet

### Tech Stack
```
Backend: FastAPI + SQLAlchemy + SQLite
Frontend: React + TanStack Query
Testing: pytest (unit tests)
Deployment: localhost only
```

### Patterns Applied
- ✅ Single-service
- ✅ SQLite
- ✅ Feature folders
- ✅ TanStack Query
- ❌ Docker
- ❌ CI/CD
- ❌ Production database

### Success Metrics
- [ ] Core features working
- [ ] 5-10 manual test users
- [ ] Decision to proceed to production

### Pain Points That Trigger Next Stage
1. **Multiple developers** need consistent environments
2. **Users asking** when they can access it
3. **SQLite concurrency** issues (write locks)
4. **Want to show** to stakeholders remotely

**When you see 2+ of these, move to Stage 2.**

📎 **Quick Start Guide:** [QuickStart-Simple.md](QuickStart-Simple.md)

---

## Stage 2: Production Ready (Month 1-2)

### What Changes
- ✅ Migrate SQLite → PostgreSQL
- ✅ Add Docker containerization
- ✅ Deploy to VPS
- ✅ Setup GitHub Actions CI/CD
- ✅ Expand test coverage
- ✅ Add monitoring

### Patterns Applied (Added)
- ✅ PostgreSQL
- ✅ Docker
- ✅ Docker Compose
- ✅ GitHub Actions
- ✅ VPS deployment
- ✅ Full testing pyramid

### Success Metrics
- [ ] Production deployment stable
- [ ] 50-100 active users
- [ ] CI/CD running smoothly
- [ ] < 1% error rate
- [ ] Response time < 500ms

### Pain Points That Trigger Next Stage
1. **Team size** > 5 developers (coordination overhead)
2. **Need independent deployments** (frontend vs backend)
3. **External API integrations** needed (OAuth, webhooks)
4. **Service boundaries** becoming clear
5. **Deployment conflicts** between teams

**When you see 3+ of these, move to Stage 3.**

📎 **Quick Start Guide:** [QuickStart-Production.md](QuickStart-Production.md)  
📎 **Detailed Migration:** [architecture-growth-path-reference.md](patterns/architecture/architecture-growth-path-reference.md#stage-1-to-2)

---

## Stage 3: Multi-Service (Month 3-6)

### What Changes
- ✅ Split into separate services (auth, api, frontend)
- ✅ Docker Compose orchestration
- ✅ Traefik reverse proxy
- ⚠️ Consider BFF for frontend (if security/proxying needed)
- ⚠️ Consider hexagonal for API (if external integrations)

### Service Split Options

| Option | When to Use | Services |
|--------|-------------|----------|
| **Simple Split** | Team coordination issues | API + Frontend + PostgreSQL |
| **Auth Separation** | Complex authentication | Auth + API + Frontend + PostgreSQL |
| **Full + BFF** | Multiple frontends, security concerns | Auth + API + WebUI (React+BFF) + PostgreSQL |

### Patterns Applied (Added)
- ✅ Multi-service architecture
- ✅ Traefik reverse proxy
- ✅ Service-to-service communication
- ✅ Contract testing
- ⚠️ BFF (if needed)

### Success Metrics
- [ ] Services deploy independently
- [ ] Team velocity improved
- [ ] Service boundaries clear
- [ ] No cross-service data access
- [ ] 200-500 active users

### Pain Points That Trigger Next Stage
1. **Multiple external providers** (MS365, Google, Slack)
2. **Complex integration logic** mixing with business logic
3. **Provider-specific** error handling everywhere
4. **Hard to test** external dependencies
5. **Want to swap providers** without rewriting logic

**When you see 3+ of these, move to Stage 4.**

📎 **Pattern:** [multi-service-overview.md](patterns/architecture/multi-service-overview.md)  
📎 **Detailed Migration:** [architecture-growth-path-reference.md](patterns/architecture/architecture-growth-path-reference.md#stage-2-to-3)

---

## Stage 4: Complex Integrations (Month 6+)

### What Changes
- ✅ Adopt hexagonal architecture for API service
- ✅ Create adapter layer for external providers
- ✅ Normalize interfaces across providers
- ✅ Comprehensive adapter mocking in tests

### When to Apply Hexagonal

**Signals you need it:**
- Integrating with > 2 external providers
- Same functionality, different providers (e.g., "send email" via SendGrid or MS365)
- Business logic tangled with API client code
- Difficult to test without hitting real APIs

**Don't use if:**
- Simple CRUD app
- Single external API
- No provider abstraction needed

### Architecture Transformation

**Pattern:** Separate business logic (processes) from integration logic (adapters)

**Layers:**
- **Routes** - HTTP handling (request validation, response formatting)
- **Processes** - Business workflows (platform-agnostic)
- **Adapters** - External integrations (provider-specific)

### Patterns Applied (Added)
- ✅ Hexagonal architecture
- ✅ Adapter layer
- ✅ Connected adapter pattern
- ✅ Comprehensive mocking

### Success Metrics
- [ ] Provider swaps without business logic changes
- [ ] Tests run without external APIs
- [ ] Clear separation of concerns
- [ ] Easy to add new providers
- [ ] 500+ active users

📎 **Pattern:** [hexagonal-architecture-overview.md](patterns/architecture/hexagonal-architecture-overview.md)  
📎 **Detailed Migration:** [architecture-growth-path-reference.md](patterns/architecture/architecture-growth-path-reference.md#stage-3-to-4)

---

## Decision Framework

### Quick Assessment

**Answer these questions to identify your current stage:**

1. **Users:** How many active users? (0 = Stage 1, <100 = Stage 2, <500 = Stage 3, 500+ = Stage 4)
2. **Team:** How many developers? (1-2 = Stage 1, 3-5 = Stage 2, 5+ = Stage 3+)
3. **Deployment:** Where does it run? (localhost = Stage 1, VPS = Stage 2, orchestrated = Stage 3+)
4. **Integrations:** External providers? (0-1 = Stage 1-2, 2-3 = Stage 3, 3+ = Stage 4)

### Migration Timeline

| From Stage | To Stage | Typical Duration | Effort |
|------------|----------|------------------|--------|
| 1 → 2 | Local → Production | 1-2 weeks | Medium |
| 2 → 3 | Monolith → Multi-Service | 4-6 weeks | High |
| 3 → 4 | Simple → Hexagonal | 6-8 weeks | High |

### Common Mistakes

❌ **Premature optimization:**
- Building multi-service for MVP
- Adding hexagonal before external integrations
- Using production stack locally

✅ **Evidence-based evolution:**
- Wait for pain points (2-3 triggers)
- Measure success metrics
- Validate assumptions before proceeding

---

## Related Resources

**Documentation:**
- 📎 [Architecture.md](Architecture.md) - How to document your architecture
- 📎 [USAGE_GUIDE.md](USAGE_GUIDE.md) - Pattern selection guidance

**Quick Start Guides:**
- 📎 [QuickStart-Simple.md](QuickStart-Simple.md) - Stage 1 setup
- 📎 [QuickStart-Production.md](QuickStart-Production.md) - Stage 2 setup

**Detailed Migrations:**
- 📎 [architecture-growth-path-reference.md](patterns/architecture/architecture-growth-path-reference.md) - Step-by-step migration guides

**Pattern Library:**
- 📎 [patterns/architecture/](patterns/architecture/) - Architecture patterns
- 📎 [patterns/database/](patterns/database/) - Database patterns
- 📎 [patterns/deployment/](patterns/deployment/) - Deployment patterns

---

**Guide Version:** 1.0.0  
**Last Updated:** 2026-04-17
