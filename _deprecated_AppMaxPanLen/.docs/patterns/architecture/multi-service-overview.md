# Multi-Service Architecture - Overview

**Pattern Type:** Complex  
**Complexity:** Advanced  
**Read Time:** ~3 minutes  
**Best For:** Scaling teams, independent deployment, service isolation

---

## When to Use Multi-Service

### ✅ Use Multi-Service For

- **Team scaling** - 3+ developers, need parallel work without conflicts
- **Independent deployment** - Deploy auth without restarting API
- **Service isolation** - Auth failure doesn't bring down API
- **Security boundaries** - Separate authentication from business logic
- **Different scaling needs** - Scale API independently from auth
- **Technology diversity** - Mix Python, Node.js, Go per service
- **Clear domain boundaries** - Auth, API, Billing, Notifications

### ❌ Avoid Multi-Service When

- **Solo developer** - Coordination overhead not worth it
- **Simple CRUD app** - Single service sufficient
- **MVP/prototype** - Ship fast first, split later
- **Project < 6 months** - Won't hit scaling issues
- **No clear boundaries** - Don't force artificial splits
- **Team < 3 people** - Single service easier to manage

### Evolution Trigger

**Adopt multi-service when you experience ONE of these:**

1. **Team coordination pain** - Merge conflicts, deployment blocking
2. **Security requirements** - Need to isolate auth from business logic
3. **Scaling mismatch** - API needs 4GB RAM, auth needs 512MB
4. **Deployment coupling** - Can't ship features independently
5. **Technology constraints** - Want different languages per domain

**Don't adopt** just because it's "better architecture" - wait for real need.

---

## Essential Configuration

### Service Boundaries (Typical)

**Common split:**
- **Auth Service** - User authentication, OAuth, JWT, OTP
- **API Service** - Business logic, workflows, webhooks
- **WebUI Service** - Frontend (React) + BFF (Express proxy)
- **Database** - Shared or separate schemas per service

**Communication:**
- Private network for inter-service calls
- Public network (via Traefik) for browser → services

### Architecture

```
Internet → Traefik → WebUI (public)
                  ↓
          Private Network
                  ↓
           Auth + API + DB
```

**Key decisions:**
- One database with schemas vs separate databases
- HTTP REST vs gRPC vs message queue
- Service discovery (DNS, Consul, none)
- Authentication flow (JWT, session cookies)

---

## Minimal Working Examples

### 1. Service Split Decision

**auth/ service responsibilities:**
- `/auth/admin/users` - User management
- `/auth/admin/credentials` - OAuth credentials
- `/auth/otp/send` - Send OTP codes
- `/auth/jwt/verify` - Verify JWT tokens
- Database schema: `auth.*`

**api/ service responsibilities:**
- `/api/habits` - Business logic
- `/api/completions` - Feature workflows
- `/api/webhooks` - External integrations
- Database schema: `api.*`

**webui/ service responsibilities:**
- `/` - React frontend (Nginx)
- `/bff/*` - Express proxy (JWT cookies)
- No database (stateless)

### 2. Docker Compose Setup

**docker-compose.yml:**
```yaml
version: '3.8'

networks:
  traefik:    # Public-facing
  private:    # Internal only

services:
  traefik:
    image: traefik:v2.11
    ports:
      - "80:80"
      - "443:443"
    networks:
      - traefik

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - private

  auth:
    image: ghcr.io/myorg/myapp/auth:main
    environment:
      - DATABASE_URL=${AUTH_DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - postgres
    networks:
      - private
      - traefik  # If auth has public webhooks

  api:
    image: ghcr.io/myorg/myapp/api:main
    environment:
      - DATABASE_URL=${API_DATABASE_URL}
      - AUTH_CLIENT_SECRET=${AUTH_CLIENT_SECRET}
    depends_on:
      - postgres
      - auth
    networks:
      - private

  webui:
    image: ghcr.io/myorg/myapp/webui:main
    environment:
      - AUTH_SERVICE_URL=http://auth:8000
      - API_SERVICE_URL=http://api:8000
    labels:
      - traefik.enable=true
      - traefik.http.routers.webui.rule=Host(`app.example.com`)
      - traefik.http.routers.webui.tls.certresolver=letsencrypt
    networks:
      - traefik
      - private

volumes:
  postgres_data:
```

### 3. Inter-Service Authentication

**API calls Auth for JWT verification:**

**api/app/services/auth_client.py:**
```python
import httpx

AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL", "http://auth:8000")
AUTH_CLIENT_SECRET = os.getenv("AUTH_CLIENT_SECRET")

async def verify_jwt(token: str) -> dict:
    """Verify JWT by calling auth service"""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{AUTH_SERVICE_URL}/auth/jwt/verify",
            headers={"X-Service-Secret": AUTH_CLIENT_SECRET},
            json={"token": token}
        )
        response.raise_for_status()
        return response.json()
```

**api/app/dependencies.py:**
```python
from fastapi import Depends, HTTPException, Header
from app.services.auth_client import verify_jwt

async def get_current_user(authorization: str = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "Missing authorization")
    
    token = authorization.split(" ")[1]
    
    try:
        user_data = await verify_jwt(token)
        return user_data
    except Exception:
        raise HTTPException(401, "Invalid token")
```

**api/app/routes/habits.py:**
```python
from fastapi import APIRouter, Depends
from app.dependencies import get_current_user

router = APIRouter()

@router.get("/api/habits")
async def list_habits(user = Depends(get_current_user)):
    # user is verified by auth service
    return {"habits": [...], "user_id": user["user_id"]}
```

### 4. Database Schema Separation

**Option A: Schemas in one database (simpler):**
```sql
-- auth schema
CREATE SCHEMA IF NOT EXISTS auth;
CREATE TABLE auth.users (...);
CREATE TABLE auth.credentials (...);

-- api schema
CREATE SCHEMA IF NOT EXISTS api;
CREATE TABLE api.habits (...);
CREATE TABLE api.completions (...);
```

**Connection strings:**
```bash
AUTH_DATABASE_URL=postgresql://user:pass@postgres:5432/myapp?options=-c%20search_path=auth
API_DATABASE_URL=postgresql://user:pass@postgres:5432/myapp?options=-c%20search_path=api
```

**Option B: Separate databases (more isolation):**
```sql
CREATE DATABASE auth_db;
CREATE DATABASE api_db;
```

**Connection strings:**
```bash
AUTH_DATABASE_URL=postgresql://user:pass@postgres:5432/auth_db
API_DATABASE_URL=postgresql://user:pass@postgres:5432/api_db
```

### 5. Service-to-Service Secrets

**Secure inter-service communication:**

**.env:**
```bash
# Service secrets (generate with: openssl rand -base64 32)
AUTH_CLIENT_SECRET=abc123...
API_CLIENT_SECRET=def456...

# Services verify each other using these secrets
```

**auth/app/dependencies.py:**
```python
from fastapi import Header, HTTPException
import os

AUTH_CLIENT_SECRET = os.getenv("AUTH_CLIENT_SECRET")

def verify_service_secret(x_service_secret: str = Header(None)):
    if x_service_secret != AUTH_CLIENT_SECRET:
        raise HTTPException(403, "Invalid service secret")
```

**auth/app/routes/internal.py:**
```python
from fastapi import APIRouter, Depends
from app.dependencies import verify_service_secret

router = APIRouter()

@router.post("/auth/jwt/verify")
async def verify_jwt(
    token_data: dict,
    _verified = Depends(verify_service_secret)
):
    # Only callable by services with correct secret
    return {"user_id": 123, "email": "user@example.com"}
```

---

## Common Operations

### Start All Services

```bash
docker compose up -d
```

### View Service Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs auth -f
docker compose logs api -f
```

### Update One Service

```bash
# Rebuild and restart only auth
docker compose build auth
docker compose up -d auth

# API keeps running (no downtime)
```

### Check Inter-Service Communication

```bash
# From host: Check auth service
curl http://localhost:8000/auth/health

# From API container: Check auth service
docker exec api curl http://auth:8000/auth/health
```

---

## Top 5 Gotchas

### 1. Services Can't Communicate (Wrong Network) ⚠️

```yaml
# ❌ Wrong: Services on different networks
services:
  auth:
    networks:
      - traefik
  api:
    networks:
      - private  # Can't reach auth!

# ✅ Correct: Both on private network
services:
  auth:
    networks:
      - private
  api:
    networks:
      - private
```

**Impact:** API can't call auth, 500 errors.

### 2. Hardcoded Service URLs (Breaks in Docker)

```python
# ❌ Wrong: Hardcoded localhost
AUTH_SERVICE_URL = "http://localhost:8000"

# ✅ Correct: Use service name
AUTH_SERVICE_URL = "http://auth:8000"  # Docker DNS
```

**Impact:** Service discovery fails, connection refused.

### 3. Circular Service Dependencies

```yaml
# ❌ Wrong: Circular dependency
services:
  auth:
    depends_on:
      - api  # Auth needs API
  api:
    depends_on:
      - auth  # API needs auth (circular!)

# ✅ Correct: One-way dependency
services:
  auth:
    # No dependency on API
  api:
    depends_on:
      - auth  # API calls auth (one-way)
```

**Impact:** Services never start, deadlock.

### 4. No Service-to-Service Authentication

```python
# ❌ Wrong: Any service can call internal endpoints
@router.post("/auth/jwt/verify")
async def verify_jwt(token_data: dict):
    return jwt.decode(token_data["token"])
    # No verification! Anyone can call this!

# ✅ Correct: Require service secret
@router.post("/auth/jwt/verify")
async def verify_jwt(
    token_data: dict,
    x_service_secret: str = Header(None)
):
    if x_service_secret != AUTH_CLIENT_SECRET:
        raise HTTPException(403, "Unauthorized")
    return jwt.decode(token_data["token"])
```

**Impact:** Security breach, internal APIs exposed.

### 5. Database Connection Exhaustion

```python
# ❌ Wrong: Each service uses unlimited connections
# 3 services × 50 connections = 150 connections!

# ✅ Correct: Limit connections per service
# database.py
engine = create_engine(
    DATABASE_URL,
    pool_size=5,        # Max 5 connections
    max_overflow=10,    # Extra 10 during spikes
)
```

**Impact:** "too many connections" database errors.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Service not reachable | Wrong network | Put services on same network |
| Connection refused | Hardcoded localhost | Use service name (http://auth:8000) |
| Services won't start | Circular dependency | Remove circular depends_on |
| Too many DB connections | No pool limits | Set pool_size and max_overflow |
| Internal APIs exposed | No service auth | Add X-Service-Secret header |

---

## References

📎 **Reference**: [multi-service-reference.md](multi-service-reference.md)  
**When to load**: Advanced patterns (message queues, gRPC, service mesh), distributed tracing, observability, migration from monolith (~490 lines)

📎 **Related patterns**:
- [single-service-overview.md](single-service-overview.md) - When to stay monolithic
- [hexagonal-architecture-overview.md](hexagonal-architecture-overview.md) - Adapter pattern within services
- [docker-compose-overview.md](../deployment/docker-compose-overview.md) - Orchestration
- [traefik-overview.md](../deployment/traefik-overview.md) - Reverse proxy

---

**Pattern Type:** Complex  
**Last Updated:** 2026-03-07  
**Complexity:** Advanced ⭐⭐⭐⭐☆
