# Docker Compose - Overview

**Pattern Type:** Orchestration  
**Complexity:** Intermediate to Advanced  
**Read Time:** ~3 minutes  
**Best For:** Multi-service applications, development environments

---

## When to Use Docker Compose

### ✅ Use Docker Compose For

- **Multi-service applications** - Auth + API + Database + Frontend
- **Development environments** - One command starts everything
- **Local integration testing** - All services together
- **Simple production deployments** - Single-server VPS
- **Microservices coordination** - Service dependencies, networks

### ❌ Don't Use Docker Compose For

- **Large-scale production** - Use Kubernetes instead (100+ containers)
- **Multi-host deployments** - Compose is single-host only
- **Complex orchestration** - Auto-scaling, advanced scheduling
- **High availability** - No built-in redundancy

### Evolution Path

```
Single service → Docker Compose → Kubernetes
(1 container)    (2-20 containers)  (20+ containers, multi-host)
```

**Key insight:** Compose perfect for small-medium apps. Graduate to Kubernetes when you need multi-host or auto-scaling.

---

## Essential Configuration

### Installation

**Docker Desktop (Windows/Mac):** Compose included

**Linux:**
```bash
# Compose V2 (plugin)
apt install docker-compose-plugin

# Verify
docker compose version  # v2.20+
```

### Basic docker-compose.yml Structure

```yaml
version: '3.8'

services:
  api:
    image: my-api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db
    networks:
      - private

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - private

volumes:
  postgres_data:

networks:
  private:
    driver: bridge
```

---

## Minimal Working Examples

### 1. Simple Multi-Service (FastAPI + Postgres)

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://app:secret@db:5432/appdb
    depends_on:
      db:
        condition: service_healthy
    networks:
      - private

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=app
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=appdb
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - private

volumes:
  db_data:

networks:
  private:
    driver: bridge
```

**Commands:**
```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

**Access API:** http://localhost:8000

### 2. Extends Pattern (DRY Configuration)

**Problem:** Same service config across dev/staging/prod

**Solution:** Base definitions + environment overrides

**Structure:**
```
project/
├── api/api.compose.yml          # Base API definition
├── db/db.compose.yml            # Base DB definition
└── deploy/
    ├── local/
    │   └── docker-compose.local.yml
    └── prod/
        └── docker-compose.prod.yml
```

**Base (api/api.compose.yml):**
```yaml
services:
  api:
    image: ghcr.io/myorg/myapp/api:main
    restart: unless-stopped
    environment:
      - PYTHONUNBUFFERED=1
      - DATABASE_URL=${DATABASE_URL}
```

**Local override (deploy/local/docker-compose.local.yml):**
```yaml
version: '3.8'

networks:
  private:
    driver: bridge

services:
  db:
    extends:
      file: ../../db/db.compose.yml
      service: db
    networks:
      - private

  api:
    extends:
      file: ../../api/api.compose.yml
      service: api
    depends_on:
      db:
        condition: service_healthy
    networks:
      - private
    # Development override: mount code for hot reload
    volumes:
      - ../../api/app:/api/app
```

**Run:**
```bash
cd deploy/local
docker compose -f docker-compose.local.yml up
```

**Benefits:**
- ✅ Single source of truth per service
- ✅ Environment-specific customization
- ✅ Easy updates (change base, all inherit)

### 3. Health Check Dependencies

**Problem:** API starts before database is ready

**Solution:** `depends_on` with `condition: service_healthy`

```yaml
services:
  api:
    image: my-api
    depends_on:
      db:
        condition: service_healthy  # Wait for health check
      redis:
        condition: service_started   # Just wait for start

  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    # No health check - starts fast enough
```

**Health check types:**
- `service_started` - Container running (fast but risky)
- `service_healthy` - Health check passes (reliable)
- `service_completed_successfully` - Init container finished

### 4. Development with Hot Reload

```yaml
services:
  api:
    build: ./backend
    volumes:
      - ./backend/app:/app/app  # Mount source code
    environment:
      - DEBUG=true
    command: uvicorn app.main:app --reload --host 0.0.0.0

  frontend:
    build: ./frontend
    volumes:
      - ./frontend/src:/app/src  # Mount source
      - /app/node_modules         # Don't mount node_modules
    environment:
      - VITE_API_URL=http://localhost:8000
```

**Benefits:**
- ✅ Code changes reflected immediately
- ✅ No container rebuild needed
- ✅ Fast feedback loop

---

## Common Operations

### Basic Commands

```bash
# Start services
docker compose up -d              # Detached mode
docker compose up                 # Foreground with logs

# View logs
docker compose logs -f            # All services
docker compose logs api -f        # Specific service

# Stop services
docker compose stop               # Preserve containers
docker compose down               # Remove containers
docker compose down -v            # Remove containers + volumes

# Rebuild images
docker compose build              # All services
docker compose build api          # Specific service

# Restart service
docker compose restart api

# Execute command in running container
docker compose exec api bash
```

### Networking

**Services can reach each other by service name:**
```yaml
services:
  api:
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
      # ────────────────────────────────────┬────────────────
      #                                     Use service name!
```

**Private network isolation:**
```yaml
networks:
  public:    # Internet-facing
  private:   # Internal only

services:
  nginx:
    networks:
      - public    # Can be accessed from internet
      - private   # Can talk to API

  api:
    networks:
      - private   # Can't be accessed from internet
```

### Environment Variables

**3 ways to provide:**

1. **Inline:**
```yaml
services:
  api:
    environment:
      - DEBUG=true
```

2. **From .env file:**
```yaml
services:
  api:
    environment:
      - DATABASE_URL=${DATABASE_URL}  # From .env file
```

3. **env_file directive:**
```yaml
services:
  api:
    env_file:
      - .env
      - .env.local  # Overrides .env
```

---

## Top 5 Gotchas

### 1. No Health Checks (Race Conditions) ⚠️

```yaml
# ❌ Wrong: API starts before DB ready
services:
  api:
    depends_on:
      - db  # Just waits for container start

# ✅ Correct: Wait for DB health check
services:
  api:
    depends_on:
      db:
        condition: service_healthy
  
  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 5s
```

**Impact:** API crashes with "connection refused" on startup.

### 2. Forgetting Network Configuration

```yaml
# ❌ Wrong: Services can't talk to each other
services:
  api:
    # No networks defined - uses default
  db:
    networks:
      - private  # Different network!

# ✅ Correct: All services on same network
services:
  api:
    networks:
      - private
  db:
    networks:
      - private
```

**Impact:** "Name or service not known" DNS errors.

### 3. Volume Mounting node_modules

```yaml
# ❌ Wrong: Overrides container's node_modules
volumes:
  - ./frontend:/app  # Mounts host's node_modules!

# ✅ Correct: Exclude node_modules
volumes:
  - ./frontend:/app
  - /app/node_modules  # Anonymous volume - uses container's
```

**Impact:** Module not found errors, wrong dependencies.

### 4. Not Using Named Volumes

```yaml
# ❌ Wrong: Anonymous volume - lost on down
services:
  db:
    volumes:
      - /var/lib/postgresql/data  # Where is this?

# ✅ Correct: Named volume - persists
services:
  db:
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:  # Managed by Docker
```

**Impact:** Database data lost on `docker compose down`.

### 5. Hardcoded Ports (Port Conflicts)

```yaml
# ❌ Wrong: Port 8000 might be in use
services:
  api:
    ports:
      - "8000:8000"  # Fails if host:8000 occupied

# ✅ Better: Use random host port
services:
  api:
    ports:
      - "8000"  # Docker assigns random port
```

**Impact:** "Address already in use" errors.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| API can't connect to DB | No health check | Add `depends_on: service_healthy` |
| Service not found | Wrong network | Put all services on same network |
| Module not found (Node) | Mounted node_modules | Exclude with anonymous volume |
| Data lost on restart | Anonymous volume | Use named volumes |
| Port conflict | Hardcoded port in use | Use dynamic port or change |

---

## References

📎 **Reference**: [docker-compose-reference.md](docker-compose-reference.md)  
**When to load**: Advanced patterns (extends, profiles, secrets), production optimization, Traefik integration, multi-environment setup (~520 lines)

📎 **Related patterns**:
- [docker-overview.md](docker-overview.md) - Building Docker images
- [traefik-overview.md](traefik-overview.md) - Reverse proxy with Compose
- [environment-config-overview.md](environment-config-overview.md) - Managing .env files

---

**Pattern Type:** Orchestration  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate to Advanced ⭐⭐⭐⭐☆
