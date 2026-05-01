# Architecture Patterns

**Purpose:** System design patterns for structuring your application at the service and component level.

---

## Pattern Structure

Each architecture pattern is split into two files for efficient navigation:

**Overview files** (~300 lines, 2-3 min read):
- When to use vs alternatives
- Evolution triggers (when to adopt)
- Essential configuration
- Minimal working examples
- Common operations
- Top 5 gotchas

**Reference files** (300-500 lines, 20+ min read):
- Complete implementation patterns
- Advanced configurations
- Migration strategies
- Real-world examples
- Edge cases and troubleshooting

**Naming convention:** `{pattern}-overview.md` + `{pattern}-reference.md`

---

## Available Patterns

### 1. Single-Service Architecture
**Complexity:** ⭐ Beginner  
**Best for:** MVPs, prototypes, solo developers, simple CRUD apps

| File | Purpose | Lines | Read Time |
|------|---------|-------|-----------|
| [single-service-overview.md](single-service-overview.md) | When to use, quick start, gotchas | ~300 | 3 min |
| [single-service-reference.md](single-service-reference.md) | Complete patterns, deployment, scaling | ~315 | 20 min |

**Key concepts:**
- One backend + one frontend + one database
- No service boundaries
- Simple deployment (single container or VM)
- Perfect for MVPs (<3 months) and learning projects

**Adopt when:**
- Solo developer or 1-2 person team
- Simple CRUD application
- Single-user or internal tool (<100 users)
- Focus on speed over scalability

### 2. Multi-Service Architecture
**Complexity:** ⭐⭐⭐⭐ Advanced  
**Best for:** Scaling teams, independent deployment, service isolation

| File | Purpose | Lines | Read Time |
|------|---------|-------|-----------|
| [multi-service-overview.md](multi-service-overview.md) | When to use, service boundaries, gotchas | ~300 | 3 min |
| [multi-service-reference.md](multi-service-reference.md) | Advanced patterns, observability, migration | ~490 | 25 min |

**Key concepts:**
- Multiple independent services (auth, API, frontend)
- Service-per-database schema
- Inter-service communication (HTTP REST, gRPC, events)
- Independent deployment and scaling

**Adopt when:**
- Team grows to 3+ developers
- Need independent deployment (deploy auth without restarting API)
- Service isolation required (auth failure doesn't kill API)
- Different scaling needs (API needs more resources)
- Security boundaries needed

### 3. Hexagonal Architecture (Process + Adapters)
**Complexity:** ⭐⭐⭐ Intermediate  
**Best for:** Multi-provider integrations, testable business logic

| File | Purpose | Lines | Read Time |
|------|---------|-------|-----------|
| [hexagonal-architecture-overview.md](hexagonal-architecture-overview.md) | When to use, adapter pattern, gotchas | ~300 | 3 min |
| [hexagonal-architecture-reference.md](hexagonal-architecture-reference.md) | Complete patterns, testing, migration | ~385 | 20 min |

**Key concepts:**
- Process layer: pure business logic (provider-agnostic)
- Adapter layer: external integrations (provider-specific)
- Connected adapters: pre-configured with credentials
- Normalized interfaces: all adapters for same service share common interface

**Adopt when:**
- Adding second provider (Gmail + Outlook, Stripe + PayPal)
- Business logic tangled with API calls
- Mocking pain in tests (hard to test without external APIs)
- Provider lock-in concerns

---

## Pattern Decision Guide

### For Developers

**Start with Single-Service if:**
- MVP or prototype (< 3 months)
- Solo developer or 1-2 person team
- Simple CRUD application
- Focus on shipping fast

**Evolve to Multi-Service when:**
- Team grows to 3+ developers (coordination issues)
- Need independent deployment (can't deploy without downtime)
- Service isolation required (security boundaries)
- Different scaling needs (API vs auth resource requirements)

**Add Hexagonal Architecture when:**
- Adding second provider (e.g., MS365 + Google email)
- Business logic mixed with external API calls
- Hard to test without external APIs (mocking pain)
- Want provider flexibility (swap vendors without refactoring)

### For AI Agents

**Context loading strategy:**

1. **Read overview first** (~3 min) - All patterns
   - Understand when to use vs alternatives
   - Check evolution triggers
   - See minimal examples

2. **Load reference if needed** (~20 min) - Specific pattern
   - Implementing the pattern
   - Advanced configuration
   - Troubleshooting issues
   - Migration from other pattern

3. **Cross-reference related patterns:**
   - Single-service → Multi-service (scaling)
   - Single-service → Hexagonal (multi-provider)
   - All architectures → deployment patterns (Docker, Compose)

---

## Evolution Matrix

| Current State | Problem | Next Pattern |
|---------------|---------|--------------|
| Single-service | Team growing (3+ devs) | Multi-service |
| Single-service | Need second provider | Hexagonal |
| Single-service | Service isolation needed | Multi-service |
| Multi-service | Multi-provider per service | Hexagonal (within services) |
| Any | External integrations | Hexagonal adapters |

---

## Architecture Growth Path

📎 **Overview:** [ArchitectureGrowthPath.md](../../ArchitectureGrowthPath.md) - Decision triggers and stage descriptions  
📎 **Reference:** [architecture-growth-path-reference.md](architecture-growth-path-reference.md) - Detailed migrations with code

```
Week 1-2: Local MVP (Stage 1)
  ├─ SQLite + FastAPI + React
  └─ Localhost development

Month 1-2: Production Ready (Stage 2)
  ├─ PostgreSQL + Docker + CI/CD
  └─ VPS deployment

Month 3-6: Multi-Service (Stage 3)
  ├─ Auth Service
  ├─ API Service
  ├─ Frontend Service
  └─ Traefik reverse proxy

Month 6+: Complex Integrations (Stage 4)
  ├─ Hexagonal Architecture
  ├─ Adapter layer
  └─ Multiple providers
```

**Key principle:** Evidence-based evolution. Wait for 2-3 pain points before advancing to next stage.

**Stage triggers:**
- **Stage 1 → 2:** Multiple devs, SQLite concurrency, users asking for access
- **Stage 2 → 3:** Team > 5 developers, need independent deployments, service boundaries clear
- **Stage 3 → 4:** Multiple providers (2+), integration logic tangled, hard to test externals

---

## Pattern Comparison

| Aspect | Single-Service | Multi-Service | Hexagonal |
|--------|----------------|---------------|-----------|
| **Complexity** | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Team Size** | 1-2 | 3+ | 2+ |
| **Deployment** | Simple | Complex | Medium |
| **Testing** | Easy | Hard | Easy |
| **Scaling** | Vertical | Horizontal | Vertical |
| **Provider Flexibility** | Low | Medium | High |
| **Development Speed** | Fast | Slow | Medium |
| **Maintenance** | Easy | Hard | Medium |

---

## Quick Reference

### Single-Service Commands
```bash
# Development
cd backend && uvicorn app.main:app --reload
cd frontend && npm run dev

# Deployment
docker compose up -d
```

### Multi-Service Commands
```bash
# Start all services
docker compose up -d

# Update one service
docker compose up -d auth  # Only restarts auth

# Check service communication
docker exec api curl http://auth:8000/auth/health
```

### Hexagonal Pattern Structure
```python
# Endpoint (system concerns)
adapter = await create_mail_adapter(credential_id)

# Process (pure business logic)
result = await process_email(message_id, adapter)
```

---

## Related Documentation

| Topic | Reference | When to Load |
|-------|-----------|--------------|
| **Deployment** | [deployment/README.md](../deployment/README.md) | Deploying any architecture |
| **Docker** | [docker-overview.md](../deployment/docker-overview.md) | Containerization basics |
| **Docker Compose** | [docker-compose-overview.md](../deployment/docker-compose-overview.md) | Multi-service orchestration |
| **Testing** | [testing/README.md](../testing/README.md) | Testing strategies per architecture |
| **Database** | [database/README.md](../database/README.md) | Database patterns per architecture |

---

**Pattern Count:** 3 core architectures  
**Last Updated:** 2026-03-07  
**Source Projects:** Production MVPs (single-service patterns), Enterprise applications (multi-service + hexagonal patterns)
