# Docker Compose Patterns

**Pattern Type:** Orchestration  
**Best For:** Multi-container applications, development environments  
**Source:** Enterprise application  
**Complexity:** ⭐⭐⭐⭐☆

---

## Overview

Docker Compose orchestration patterns for managing multiple services, networks, volumes, and service dependencies. Covers production-ready compose files with health checks, extends pattern, and environment configuration.

**Key Characteristics:**
- Multi-service orchestration (auth, API, database, frontend)
- Service isolation with private networks
- Health check dependencies (`depends_on` with `service_healthy`)
- Extends pattern (DRY across environments)
- Volume management for data persistence

---

## When to Use

### ✅ Use Docker Compose For:
- **Multi-service applications** (auth + API + database + frontend)
- **Development environments** (one command to start everything)
- **Local integration testing** (all services together)
- **Simple production deployments** (single-server VPS)

### ❌ Don't Use Docker Compose For:
- **Large-scale production** (use Kubernetes instead)
- **Multi-host deployments** (Compose is single-host only)
- **Complex orchestration** (advanced scheduling, auto-scaling)

**Evolution:** Single-service → Docker Compose → Kubernetes

---

## Key Compose Patterns

### 1. Extends Pattern (DRY Configuration)

**Problem:** Duplicate service definitions across environments

**Solution:** Base service definition + environment-specific overrides

**Structure:**
```
project/
├── postgres/postgres.compose.yml     # Base postgres definition
├── auth/auth.compose.yml              # Base auth definition
├── api/api.compose.yml                # Base API definition
└── deploy/
    ├── local/docker-compose.local.yml    # Development
    └── prod/docker-compose.prod.yml      # Production
```

**Base service (auth/auth.compose.yml):**
```yaml
services:
  auth:
    image: ghcr.io/myorg/myapp/auth:main
    pull_policy: always
    container_name: auth
    restart: unless-stopped
    environment:
      - PYTHONUNBUFFERED=1
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
      - OAUTH_ENCRYPTION_KEY=${OAUTH_ENCRYPTION_KEY}
    labels:
      - traefik.enable=${AUTH_PUBLIC:-false}
      - traefik.http.routers.auth.rule=Host(`${AUTH_HOST}`)
```

**Environment-specific (deploy/local/docker-compose.local.yml):**
```yaml
version: '3.8'

networks:
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
    # Local override: mount code for hot reload
    volumes:
      - ../../auth/app:/auth/app

  api:
    extends:
      file: ../../api/api.compose.yml
      service: api
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - private
```

**Benefits:**
- ✅ Single source of truth for each service
- ✅ Environment-specific customization (local vs prod)
- ✅ Easy updates (change base file, all environments inherit)

---

### 2. Health Checks and Dependencies

**Pattern:** Wait for services to be healthy before starting dependents

```yaml
services:
  postgres:
    image: postgres:16
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app_root -d app_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    environment:
      - POSTGRES_USER=app_root
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=app_db

  auth:
    image: myapp/auth:latest
    depends_on:
      postgres:
        condition: service_healthy  # ← Wait for postgres to be healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/auth/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  api:
    image: myapp/api:latest
    depends_on:
      postgres:
        condition: service_healthy
      auth:
        condition: service_healthy  # ← Wait for auth to be healthy
```

**Startup order:**
1. postgres starts → health check passes
2. auth starts (postgres healthy) → health check passes
3. api starts (postgres + auth healthy)

**Without health checks:**
```yaml
depends_on:
  - postgres  # Only waits for container start, not readiness
```
**Problem:** API tries to connect to postgres before it's ready → crashes

---

### 3. Networks (Service Isolation)

**Pattern:** Separate public and private networks

```yaml
networks:
  public:
    driver: bridge
  private:
    driver: bridge

services:
  postgres:
    networks:
      - private  # Only accessible by backend services

  auth:
    networks:
      - private  # Can talk to postgres, not exposed

  api:
    networks:
      - private  # Can talk to postgres + auth

  webui:
    networks:
      - public   # Accessible from outside
      - private  # Can talk to auth + api
    ports:
      - "80:80"
```

**Network isolation:**
- **Public network**: Traefik → webui (HTTPS traffic)
- **Private network**: webui → auth, webui → api, services → postgres
- **No direct access**: Browser cannot reach postgres/auth/api

**External networks (Traefik):**
```yaml
networks:
  traefik:
    external: true
    name: ${TRAEFIK_NETWORK}

services:
  webui:
    networks:
      - traefik  # Attached to existing Traefik network
```

---

### 4. Volumes (Data Persistence)

**Named volumes (recommended):**
```yaml
volumes:
  pgdata:       # Managed by Docker
  loki-data:

services:
  postgres:
    volumes:
      - pgdata:/var/lib/postgresql/data

  loki:
    volumes:
      - loki-data:/loki
```

**Bind mounts (development):**
```yaml
services:
  auth:
    volumes:
      - ./auth/app:/auth/app  # Mount local code for hot reload
      - ./auth/migrations:/auth/migrations
```

**Volume types comparison:**

| Type | Use Case | Persistence | Portability |
|------|----------|-------------|-------------|
| Named volume | Production data | ✅ Survives restarts | ✅ Docker-managed |
| Bind mount | Development | ✅ Local filesystem | ❌ Path-dependent |
| tmpfs | Temporary data | ❌ Lost on restart | N/A |

---

### 5. Environment Variables

**Pass from host `.env` file:**
```yaml
# docker-compose.yml
services:
  auth:
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
      - OAUTH_ENCRYPTION_KEY=${OAUTH_ENCRYPTION_KEY}
```

**`.env` file (root directory):**
```bash
# Database
DATABASE_URL=postgresql://app_root:password@postgres:5432/app_db

# Auth Secrets (generate with: openssl rand -base64 32)
JWT_SECRET=your-jwt-secret-here
OAUTH_ENCRYPTION_KEY=your-encryption-key-here

# Service Configuration
AUTH_PUBLIC=false
TRAEFIK_NETWORK=traefik
```

**Default values:**
```yaml
environment:
  - AUTH_PUBLIC=${AUTH_PUBLIC:-false}  # Default to false if not set
  - JWT_EXPIRY=${JWT_EXPIRY:-3600}      # Default 1 hour
```

---

## Full Example: Multi-Service Application

**Project structure:**
```
project/
├── .env                                # Environment variables
├── postgres/postgres.compose.yml
├── auth/auth.compose.yml
├── api/api.compose.yml
├── webui/webui.compose.yml
└── deploy/
    └── local/docker-compose.local.yml
```

**Main orchestration file (deploy/local/docker-compose.local.yml):**
```yaml
version: '3.8'

networks:
  public:
    driver: bridge
  private:
    driver: bridge

volumes:
  pgdata_local:

services:
  postgres:
    extends:
      file: ../../postgres/postgres.compose.yml
      service: postgres
    volumes:
      - pgdata_local:/var/lib/postgresql/data
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
    ports:
      - "3001:80"
    networks:
      - public
      - private
```

**Start everything:**
```bash
cd deploy/local
docker compose up --build
```

---

## Common Commands

### Start Services

```bash
# Start all services
docker compose up

# Start in background (detached)
docker compose up -d

# Rebuild and start
docker compose up --build

# Start specific service
docker compose up auth
```

### Stop Services

```bash
# Stop all services (keep containers)
docker compose stop

# Stop and remove containers
docker compose down

# Stop and remove containers + volumes
docker compose down -v
```

### View Logs

```bash
# All services
docker compose logs

# Follow logs (live tail)
docker compose logs -f

# Specific service
docker compose logs -f auth

# Last 50 lines
docker compose logs --tail 50 auth
```

### Rebuild Services

```bash
# Rebuild specific service
docker compose build auth

# Rebuild all
docker compose build

# Force no cache
docker compose build --no-cache
```

### Scale Services

```bash
# Run 3 instances of API service
docker compose up --scale api=3
```

**Note:** Requires removing `container_name` and using random ports

---

## Production Patterns

### 1. Pull Policy (Always Use Latest)

```yaml
services:
  auth:
    image: ghcr.io/myorg/myapp/auth:main
    pull_policy: always  # ← Always pull latest image
```

**Benefit:** GitHub Actions pushes new image → `docker compose up` pulls it automatically

### 2. Restart Policy

```yaml
services:
  auth:
    restart: unless-stopped  # Restart on failure, but not if manually stopped
```

**Options:**
- `no`: Never restart (default)
- `always`: Always restart (even after manual stop)
- `on-failure`: Only on non-zero exit code
- `unless-stopped`: Always restart unless manually stopped

### 3. Resource Limits

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

**Note:** `deploy` section only works with `docker compose` v2 or Swarm mode

---

## Development Patterns

### 1. Hot Reload with Volume Mounts

```yaml
services:
  auth:
    volumes:
      - ../../auth/app:/auth/app  # Mount source code
    command: uvicorn app.main:app --reload  # Enable hot reload
```

**Benefit:** Code changes → auto-restart → see changes immediately

### 2. Override File (docker-compose.override.yml)

**docker-compose.yml** (base, committed to git):
```yaml
services:
  auth:
    image: myapp/auth:latest
```

**docker-compose.override.yml** (local, not committed):
```yaml
services:
  auth:
    volumes:
      - ./auth/app:/auth/app
    environment:
      - DEBUG=true
```

**Compose automatically merges both files:**
```bash
docker compose up  # Uses docker-compose.yml + docker-compose.override.yml
```

---

## Traefik Integration

**External Traefik network:**
```yaml
networks:
  traefik:
    external: true
    name: traefik

services:
  webui:
    networks:
      - traefik
    labels:
      - traefik.enable=true
      - traefik.docker.network=traefik
      - traefik.http.routers.webui.rule=Host(`app.example.com`)
      - traefik.http.routers.webui.entrypoints=websecure
      - traefik.http.routers.webui.tls=true
      - traefik.http.routers.webui.tls.certresolver=letsencrypt
      - traefik.http.services.webui.loadbalancer.server.port=80
```

**Steps:**
1. Create Traefik network once: `docker network create traefik`
2. Start Traefik (runs separately)
3. Start application services (attach to Traefik network)
4. Traefik auto-discovers services via Docker labels

---

## Debugging Tips

### Check Service Status

```bash
docker compose ps
# NAME      IMAGE           STATUS              PORTS
# auth      myapp/auth      Up 5 minutes        8000/tcp
# postgres  postgres:16     Up 5 minutes (healthy)
```

### Inspect Networks

```bash
# List networks
docker network ls

# Inspect network (see connected containers)
docker network inspect myproject_private
```

### Execute Commands in Container

```bash
# Run shell in running container
docker compose exec auth sh

# Run one-off command
docker compose exec postgres psql -U app_root -d app_db

# Run as root (for debugging)
docker compose exec --user root auth sh
```

### Health Check Status

```bash
docker compose ps
# Shows (healthy) or (unhealthy) next to STATUS
```

---

## Common Pitfalls

### ❌ Don't:
- **Hardcode secrets** in compose files (use `.env` or Docker secrets)
- **Use `depends_on` without health checks** (race conditions)
- **Expose ports unnecessarily** (use private networks)
- **Mount production data as bind mounts** (use named volumes)
- **Forget `.env` file** in `.gitignore` (secrets leak)

### ✅ Do:
- **Use extends pattern** for DRY configuration
- **Define health checks** for all services
- **Use private networks** for service isolation
- **Use named volumes** for production data
- **Use `.env.example`** as template (commit this, not `.env`)

---

## Testing Compose Files

### Validate Syntax

```bash
docker compose config  # Shows merged config (validates syntax)
```

### Dry Run

```bash
docker compose up --no-start  # Creates containers without starting
```

### Check Service Dependencies

```bash
docker compose up postgres  # Only starts postgres (no dependents)
docker compose up api        # Starts api + its dependencies (postgres)
```

---

## Source References

**Extracted from:**
- AI Workflow: `deploy/local/docker-compose.local.yml` (extends pattern, networks, volumes)
- AI Workflow: `auth/auth.compose.yml`, `api/api.compose.yml`, `webui/webui.compose.yml` (service definitions)
- AI Workflow: `postgres/postgres.compose.yml` (health checks)

**Related Patterns:**
- 📎 [Docker Patterns](docker-patterns.md) - Dockerfile best practices
- 📎 [Traefik Patterns](traefik-patterns.md) - Reverse proxy setup
- 📎 [Environment Config Patterns](environment-config-patterns.md) - Managing secrets

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Enterprise application v0.2.11/v0.5.5
