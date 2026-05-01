# Multi-Service Architecture

**Pattern Type:** Complex  
**Best For:** Team scaling, service isolation, independent deployment  
**Source:** Enterprise application (multi-service)  
**Complexity:** ⭐⭐⭐⭐☆

---

## Overview

Multi-service architecture splits your application into multiple independent services, each with its own codebase, database schema, and deployment lifecycle. Services communicate over HTTP or message queues.

**Key Characteristics:**
- Multiple independent services (auth, API, frontend, etc.)
- Service-per-database schema (logical or physical separation)
- Inter-service communication (HTTP REST, gRPC, events)
- Independent deployment and scaling
- Service boundaries aligned with business domains

---

## When to Use

### ✅ Ideal For:
- **Team scaling** (3+ developers, multiple teams)
- **Independent deployment** (auth updates without API restart)
- **Service isolation** (auth failure doesn't bring down API)
- **Different scaling needs** (scale API separately from auth)
- **Security boundaries** (separate auth from business logic)
- **Technology diversity** (Python API, Node.js BFF, Go services)
- **Long-lived projects** (12+ months, evolving architecture)

### ❌ Avoid When:
- Solo developer or small team (< 3 people)
- Simple CRUD application
- MVP/prototype phase
- Project < 6 months timeline
- No clear service boundaries
- Overhead outweighs benefits

### When to Adopt (Evolution Trigger)

Adopt multi-service when you experience ONE of these:

1. **Team coordination issues** - Merge conflicts, blocking deployments
2. **Security requirements** - Need to isolate auth from business logic
3. **Scaling mismatches** - API needs more resources than auth
4. **Deployment coupling** - Can't deploy features independently
5. **Technology constraints** - Want to use different stacks per service

---

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────┐
│                      Browser                               │
└──────────────────────┬─────────────────────────────────────┘
                       │ HTTPS
                       ↓
┌────────────────────────────────────────────────────────────┐
│               Traefik (Reverse Proxy)                      │
│  - TLS termination                                         │
│  - Request routing                                         │
│  - Load balancing                                          │
└──────────┬─────────────────┬──────────────────────────────┘
           │                 │
┌──────────┴────────┐  ┌────┴──────────────────────────────┐
│   WebUI Service   │  │  Public Network                   │
│  ┌──────────────┐ │  │                                   │
│  │ React UI     │ │  │  Services accessible via Traefik  │
│  │ (Nginx)      │ │  │                                   │
│  └──────┬───────┘ │  └───────────────────────────────────┘
│         │         │
│  ┌──────┴───────┐ │
│  │ BFF (Node)   │─┼──┐
│  │ - Cookie JWT │ │  │ Private network calls
│  │ - API proxy  │ │  │ (service-to-service)
│  └──────────────┘ │  │
└───────────────────┘  │
                       │
           ┌───────────┴──────────────┐
           │   Private Network        │
           │                          │
   ┌───────┴────────┐   ┌────────────┴──────┐
   │  Auth Service  │   │   API Service     │
   │  ┌──────────┐  │   │  ┌─────────────┐  │
   │  │ FastAPI  │  │   │  │  FastAPI    │  │
   │  │ - OTP    │  │   │  │  - Business │  │
   │  │ - JWT    │  │   │  │    logic    │  │
   │  │ - OAuth  │  │   │  │  - Webhooks │  │
   │  └────┬─────┘  │   │  └──────┬──────┘  │
   │       │        │   │         │         │
   └───────┼────────┘   └─────────┼─────────┘
           │                      │
           │                      │
     auth schema            api schema
           │                      │
           └──────────┬───────────┘
                      │
              ┌───────┴────────┐
              │   PostgreSQL   │
              │  - auth.*      │
              │  - api.*       │
              └────────────────┘
```

---

## Example Structure (AI Workflow)

```
project/
├── auth/                      # Authentication service
│   ├── app/
│   │   ├── main.py           # FastAPI app
│   │   ├── routers/          # Auth endpoints
│   │   │   ├── admin.py      # User management
│   │   │   ├── credentials.py# OAuth credentials
│   │   │   └── oauth.py      # OAuth flows
│   │   └── services/
│   │       ├── database.py   # auth.* schema access
│   │       ├── otp.py        # OTP generation
│   │       └── jwt.py        # JWT token management
│   ├── migrations/           # auth schema migrations
│   ├── auth.compose.yml      # Docker service definition
│   └── Dockerfile
│
├── api/                       # Business logic service
│   ├── app/
│   │   ├── main.py           # FastAPI app
│   │   ├── routes/           # API endpoints
│   │   ├── processes/        # Business workflows
│   │   ├── adapters/         # External integrations
│   │   └── services/
│   │       └── database.py   # api.* schema access
│   ├── migrations/           # api schema migrations
│   ├── api.compose.yml       # Docker service definition
│   └── Dockerfile
│
├── webui/                     # Frontend service
│   ├── ui/                   # React application
│   │   ├── src/
│   │   └── package.json
│   ├── bff/                  # Backend-for-Frontend
│   │   ├── src/
│   │   │   ├── server.ts     # Express app
│   │   │   └── routes/       # Proxy routes
│   │   └── package.json
│   ├── webui.compose.yml
│   └── Dockerfile            # Multi-stage (UI + BFF + Nginx)
│
├── postgres/                  # Database service
│   └── postgres.compose.yml
│
└── deploy/
    ├── local/
    │   └── docker-compose.local.yml  # Orchestration
    └── traefik/
        └── traefik.yml               # Reverse proxy config
```

---

## Key Implementation Patterns

### 1. Service-to-Service Communication

**BFF calls Auth service:**
```typescript
// webui/bff/src/routes/auth.ts
import express from 'express';

const router = express.Router();

// Proxy to auth service
router.post('/login', async (req, res) => {
  try {
    // Call auth service (private network)
    const response = await fetch('http://auth:8000/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body)
    });
    
    const data = await response.json();
    
    if (response.ok) {
      // Set JWT as httpOnly cookie
      res.cookie('session_token', data.access_token, {
        httpOnly: true,
        secure: true,
        sameSite: 'strict'
      });
      res.json({ success: true });
    } else {
      res.status(response.status).json(data);
    }
  } catch (error) {
    res.status(500).json({ error: 'Service unavailable' });
  }
});

export default router;
```

### 2. Service Isolation

**Each service has independent codebase:**

```yaml
# auth/auth.compose.yml
services:
  auth:
    build: .
    ports:
      - \"8000:8000\"
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/app_db
      - JWT_SECRET=${JWT_SECRET}
      - AUTH_VERSION=0.2.11
    healthcheck:
      test: [\"CMD\", \"curl\", \"-f\", \"http://localhost:8000/auth/health\"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - private
```

```yaml
# api/api.compose.yml
services:
  api:
    build: .
    ports:
      - \"8000:8000\"
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/app_db
      - AUTH_SERVICE_URL=http://auth:8000
      - API_VERSION=0.5.5
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - private
```

### 3. Database Schema Separation

**Logical separation in single database:**

```sql
-- auth/migrations/0001_init.sql
CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE auth.users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE auth.credentials (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES auth.users(id),
    provider VARCHAR(50) NOT NULL,
    access_token TEXT
);
```

```sql
-- api/migrations/0001_init.sql
CREATE SCHEMA IF NOT EXISTS api;

CREATE TABLE api.quotes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,  -- Reference auth.users (but no FK)
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Service access patterns:**
```python
# auth/app/services/database.py
async def get_user(user_id: int):
    query = \"SELECT * FROM auth.users WHERE id = %s\"
    # Only auth service accesses auth.* schema

# api/app/services/database.py
async def get_quote(quote_id: int):
    query = \"SELECT * FROM api.quotes WHERE id = %s\"
    # Only api service accesses api.* schema
```

### 4. Docker Compose Orchestration

**Main orchestration file:**

```yaml
# deploy/local/docker-compose.local.yml
version: '3.8'

networks:
  public:
    driver: bridge
  private:
    driver: bridge

services:
  postgres:
    extends:
      file: ../../postgres/postgres.compose.yml
      service: postgres
    networks:
      - private

  auth:
    extends:
      file: ../../auth/auth.compose.yml
      service: auth
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - private

  api:
    extends:
      file: ../../api/api.compose.yml
      service: api
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - private

  webui:
    extends:
      file: ../../webui/webui.compose.yml
      service: webui
    depends_on:
      - auth
      - api
    networks:
      - public
      - private

  traefik:
    image: traefik:v2.10
    ports:
      - \"80:80\"
      - \"443:443\"
    volumes:
      - ./traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - public
```

### 5. Health Checks

**Each service exposes health endpoint:**

```python
# auth/app/main.py
@app.get(\"/auth/health\")
async def health():
    return {\"status\": \"healthy\", \"service\": \"auth\", \"version\": \"0.2.11\"}

@app.get(\"/auth/db/health\")
async def db_health():
    try:
        await db_service.execute(\"SELECT 1\")
        return {\"status\": \"healthy\", \"database\": \"connected\"}
    except Exception as e:
        return {\"status\": \"unhealthy\", \"error\": str(e)}
```

---

## BFF Pattern (Backend-for-Frontend)

### Why BFF?

**Problems BFF solves:**
1. **JWT in localStorage is insecure** (XSS attacks)
2. **CORS complexity** (cross-origin requests)
3. **API aggregation** (reduce roundtrips)
4. **Request transformation** (frontend-optimized responses)

**BFF responsibilities:**
- Set JWT as httpOnly cookies (secure)
- Proxy API requests with authentication
- Aggregate multiple backend calls
- Handle CORS properly

**BFF structure:**
```
webui/bff/
├── src/
│   ├── server.ts          # Express entry point
│   ├── middleware/
│   │   └── auth.ts        # JWT cookie validation
│   └── routes/
│       ├── auth.ts        # Proxy auth service
│       └── api.ts         # Proxy API service
└── package.json
```

**Example BFF proxy:**
```typescript
// webui/bff/src/routes/api.ts
router.get('/api/*', authenticateJWT, async (req, res) => {
  const apiPath = req.path.replace('/api', '');
  const token = req.cookies.session_token;
  
  const response = await fetch(`http://api:8000${apiPath}`, {
    headers: { Authorization: `Bearer ${token}` }
  });
  
  const data = await response.json();
  res.status(response.status).json(data);
});
```

---

## Deployment

### Local Development

```bash
# Start all services
docker-compose -f deploy/local/docker-compose.local.yml up --build

# View logs for specific service
docker-compose logs -f auth

# Rebuild single service
docker-compose up --build auth
```

### Production (with Traefik)

```yaml
# Traefik routes
services:
  webui:
    labels:
      - \"traefik.enable=true\"
      - \"traefik.http.routers.webui.rule=Host(`app.example.com`)\"
      - \"traefik.http.routers.webui.entrypoints=websecure\"
      - \"traefik.http.routers.webui.tls.certresolver=letsencrypt\"
```

---

## Testing Strategy

### Unit Tests (per service)

Each service has its own test suite:

```bash
# Test auth service
cd auth && pytest tests/

# Test API service
cd api && pytest tests/
```

### Integration Tests (cross-service)

Test service boundaries:

```python
# tests/integration/test_auth_api.py
import pytest
import httpx

@pytest.mark.asyncio
async def test_login_returns_valid_token():
    async with httpx.AsyncClient() as client:
        # Call auth service
        auth_response = await client.post(
            \"http://auth:8000/auth/login\",
            json={\"email\": \"user@example.com\", \"password\": \"test\"}
        )
        token = auth_response.json()[\"access_token\"]
        
        # Use token with API service
        api_response = await client.get(
            \"http://api:8000/api/quotes\",
            headers={\"Authorization\": f\"Bearer {token}\"}
        )
        assert api_response.status_code == 200
```

---

## Scaling Considerations

### When to Evolve

Consider further splitting when:

1. **Service too large** - Single service > 20k LOC
2. **Domain complexity** - Clear business domain boundaries emerge
3. **Team structure** - Teams organized around domains
4. **Technology needs** - Need different stacks per domain

### Evolution Path

Single-Service → **Multi-Service** (2-4 services) → **Microservices** (10+ services)

**Common splits:**
1. **Auth service** (first split - security boundary)
2. **API service** (business logic)
3. **BFF service** (frontend security)
4. **Worker service** (background processing)
5. **Notification service** (emails, SMS)

---

## Trade-offs

### Advantages ✅
- **Team scaling** - Multiple teams work independently
- **Deployment independence** - Deploy services separately
- **Technology flexibility** - Different stacks per service
- **Service isolation** - Failures don't cascade
- **Scaling flexibility** - Scale services independently
- **Security boundaries** - Isolate sensitive services

### Disadvantages ❌
- **Operational complexity** - More services to monitor
- **Network latency** - Inter-service HTTP calls
- **Data consistency** - No distributed transactions
- **Debugging difficulty** - Trace requests across services
- **Deployment coordination** - Need orchestration tooling
- **Testing complexity** - Integration tests more involved

---

## Common Pitfalls

### ❌ Don't:
- **Nano-services** - Too many tiny services (coordination nightmare)
- **Shared database tables** - Services directly query each other's tables
- **Chatty services** - Services make 10+ calls per user request
- **No service contracts** - APIs change without versioning
- **Distributed monolith** - Services tightly coupled via synchronous calls

### ✅ Do:
- **Coarse-grained services** - Start with 2-4 services, split as needed
- **Schema separation** - Each service owns its data
- **Async where possible** - Use events/queues for non-blocking ops
- **API versioning** - `/v1/`, `/v2/` endpoints
- **Circuit breakers** - Handle service failures gracefully

---

## Source References

**Extracted from:**
- AI Workflow: `deploy/local/docker-compose.local.yml` (orchestration)
- AI Workflow: `auth/`, `api/`, `webui/` folder structures
- AI Workflow: `.github/copilot-instructions.md` (service descriptions)
- AI Workflow: `webui/bff/` (BFF implementation)
- AI Workflow: Service compose files (`*.compose.yml`)

**Related Patterns:**
- 📎 [Single-Service Architecture](single-service.md) - Starting point
- 📎 [Hexagonal Architecture](hexagonal-architecture.md) - Can combine with multi-service
- 📎 [BFF Pattern](../frontend/bff-pattern.md) - Frontend security layer
- 📎 [Docker Patterns](../deployment/docker-patterns.md) - Container setup

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 6, 2026  
**Source Project:** Enterprise application v0.2.11/v0.5.5
