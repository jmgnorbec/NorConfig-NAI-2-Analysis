# Docker Containerization - Overview

**Pattern Type:** Core Infrastructure  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Consistent deployment, multi-service applications, CI/CD

---

## When to Use Docker

### ✅ Use Docker For

- **Production deployment** - Consistent environment across dev/staging/prod
- **Multi-service applications** - Orchestrate with Docker Compose
- **Team collaboration** - Same setup for all developers
- **CI/CD pipelines** - Build once, deploy anywhere
- **Dependency isolation** - Each service has own dependencies

### ❌ Skip Docker When

- **Local-only scripts** - Single Python file, no dependencies
- **Development-only tools** - CLI utilities, personal scripts
- **Learning basics** - Start with virtual environments first

### vs. Alternatives

| Approach | Pros | Cons |
|----------|------|------|
| **Docker** | Consistent, portable, isolated | Learning curve, overhead |
| **Virtual env** | Simple, lightweight | Not portable, OS-dependent |
| **VMs** | Full isolation | Heavy, slow startup |

**Key insight:** Docker gives consistency without VM overhead. Use for any app deployed to servers.

---

## Essential Configuration

### Installation

**Windows/Mac:**
- Download Docker Desktop: https://www.docker.com/products/docker-desktop

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Verify
docker --version  # 24.0+
```

### Basic Dockerfile Structure

**Every Dockerfile needs:**
```dockerfile
FROM <base-image>      # Start from official image
WORKDIR /app           # Set working directory
COPY <files> <dest>    # Copy code into container
RUN <build-commands>   # Install dependencies
EXPOSE <port>          # Document port (not security)
CMD ["<command>"]      # Run application
```

---

## Minimal Working Examples

### 1. Python FastAPI Service

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy and install dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Build and run:**
```bash
docker build -t my-api .
docker run -p 8000:8000 my-api
```

**Access:** http://localhost:8000

### 2. Node.js Multi-Stage Build (React + Express)

```dockerfile
# --- Stage 1: Build Frontend ---
FROM node:20-alpine AS build-ui
WORKDIR /app

COPY package*.json ./
COPY ui/package*.json ./ui/
RUN npm install

COPY ui/ ./ui/
RUN npm run build:ui

# --- Stage 2: Build Backend ---
FROM node:20-alpine AS build-bff
WORKDIR /app

COPY package*.json ./
COPY bff/package*.json ./bff/
RUN npm install

COPY bff/ ./bff/
RUN npm run build:bff

# --- Stage 3: Production ---
FROM node:20-alpine
WORKDIR /app

# Copy only production dependencies
COPY package*.json ./
RUN npm install --production

# Copy built artifacts
COPY --from=build-ui /app/ui/dist ./ui/dist
COPY --from=build-bff /app/bff/dist ./bff/dist

EXPOSE 3000

CMD ["node", "bff/dist/index.js"]
```

**Multi-stage benefits:**
- ✅ Smaller final image (no dev dependencies, no source files)
- ✅ Faster builds (parallel stages)
- ✅ Security (no build tools in production image)

**Build:**
```bash
docker build -t my-webui .
```

### 3. Development vs Production Image

**Development (hot reload):**
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

# Don't copy code - mount as volume instead
CMD ["uvicorn", "app.main:app", "--reload", "--host", "0.0.0.0"]
```

**Run with volume mount:**
```bash
docker run -v $(pwd)/app:/app/app -p 8000:8000 my-api-dev
```

**Production (optimized):**
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app  # Code baked into image
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0"]  # No --reload
```

---

## Common Operations

### Build and Run

```bash
# Build image
docker build -t my-app .

# Run container
docker run -d -p 8000:8000 --name my-container my-app

# View logs
docker logs my-container -f

# Stop and remove
docker stop my-container
docker rm my-container
```

### Layer Caching Optimization

**Order matters!** Place least-changing files first:

```dockerfile
# ✅ Correct order (best caching)
COPY requirements.txt .       # Changes rarely
RUN pip install -r requirements.txt
COPY app ./app                # Changes frequently

# ❌ Wrong order (cache invalidated on every code change)
COPY app ./app                # Changes frequently
COPY requirements.txt .
RUN pip install -r requirements.txt
```

### Multi-Platform Builds

**Build for multiple architectures:**
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t my-app .
```

**When needed:**
- Deploying to ARM servers (AWS Graviton, Apple Silicon)
- Supporting multiple CPU architectures

### System Package Installation

**Always clean up apt cache:**
```dockerfile
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       postgresql-client \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*  # Cleanup!
```

**Reduces image size by ~100MB.**

---

## Top 5 Gotchas

### 1. Wrong Layer Order (Cache Invalidation) ⚠️

```dockerfile
# ❌ Wrong: Code copied before dependencies
COPY . .
RUN pip install -r requirements.txt  # Reinstalls on every code change!

# ✅ Correct: Dependencies first
COPY requirements.txt .
RUN pip install -r requirements.txt  # Cached until requirements.txt changes
COPY . .
```

**Impact:** 30 second builds become 5 minutes.

### 2. Running as Root User (Security Risk)

```dockerfile
# ❌ Wrong: Runs as root (UID 0)
FROM python:3.12-slim
COPY . .
CMD ["python", "app.py"]

# ✅ Correct: Create non-root user
FROM python:3.12-slim
RUN useradd -m -u 1000 appuser
USER appuser
COPY --chown=appuser:appuser . .
CMD ["python", "app.py"]
```

**Impact:** Container escape vulnerabilities, privilege escalation.

### 3. Not Using .dockerignore

**Create `.dockerignore`:**
```
__pycache__/
*.pyc
.git/
.venv/
node_modules/
.env
*.log
```

**Impact without:** Build context bloated (5 MB → 500 MB), slower builds, secrets leaked.

### 4. Forgetting --no-cache-dir (Pip)

```dockerfile
# ❌ Wrong: 100 MB of pip cache in image
RUN pip install -r requirements.txt

# ✅ Correct: No cache
RUN pip install --no-cache-dir -r requirements.txt
```

**Impact:** Image 100-200 MB larger.

### 5. Hardcoded Localhost in CMD

```dockerfile
# ❌ Wrong: Not accessible outside container
CMD ["uvicorn", "app.main:app"]  # Binds to 127.0.0.1

# ✅ Correct: Bind to 0.0.0.0
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0"]
```

**Impact:** Can't access service from host machine.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Build takes forever | Wrong layer order | Move COPY after RUN install |
| Image 2 GB+ | Pip cache, dev dependencies | Use `--no-cache-dir`, multi-stage |
| Can't connect to service | Localhost binding | Use `--host 0.0.0.0` |
| Permission denied | Running as root | Create non-root user |
| Secrets in image | .dockerignore missing | Add .env, secrets to .dockerignore |

---

## References

📎 **Reference**: [docker-reference.md](docker-reference.md)  
**When to load**: Multi-stage builds (advanced patterns), build arguments, security hardening, health checks, image optimization (~400 lines)

📎 **Related patterns**:
- [docker-compose-overview.md](docker-compose-overview.md) - Multi-service orchestration
- [github-actions-overview.md](github-actions-overview.md) - Automated Docker builds
- [vps-deployment-overview.md](vps-deployment-overview.md) - Deploying to VPS

---

**Pattern Type:** Core Infrastructure  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
