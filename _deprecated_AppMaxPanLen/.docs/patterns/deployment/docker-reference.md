# Docker Patterns

**Pattern Type:** Core Infrastructure  
**Best For:** Containerization, consistent deployment  
**Source:** Enterprise application  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

Docker containerization patterns for Python FastAPI services, Node.js applications, and multi-stage builds. Covers Dockerfile best practices, layer caching, and production optimization.

**Key Characteristics:**
- Multi-stage builds for smaller images
- Layer caching for faster builds
- Security best practices (non-root user, minimal base images)
- Environment-specific optimization
- Build-time vs runtime dependencies

---

## When to Use

### ✅ Always Use Docker For:
- **Production deployment** (consistent environment)
- **Multi-service applications** (orchestration with compose)
- **Team collaboration** (same setup for all developers)
- **CI/CD pipelines** (build once, deploy anywhere)

### ❌ Skip Docker When:
- Local-only scripts or utilities
- Development-only tools
- Single-file applications

---

## Key Dockerfile Patterns

### 1. Python FastAPI Service (Single-Stage)

**Best for:** Simple Python services, development

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Prevent Python from writing pyc files and bufferring stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /api

# Install dependencies first (better caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install system packages if needed (e.g., psql client)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       postgresql-client \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY app ./app
COPY migrations ./migrations

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Key decisions:**
- `python:3.12-slim` (smaller than full Python image, but includes build tools)
- Install dependencies **before** copying code (layer caching)
- `--no-cache-dir` (reduces image size)
- Clean up apt cache with `rm -rf /var/lib/apt/lists/*`
- Expose port for documentation (not security)

**Layer optimization:**
```
Layer 1: Base image (300 MB) ─────────────► Rarely changes
Layer 2: Dependencies (50 MB) ────────────► Changes when requirements.txt changes
Layer 3: System packages (20 MB) ─────────► Rarely changes
Layer 4: Application code (5 MB) ─────────► Changes frequently
```

---

### 2. Node.js Multi-Stage Build (React + Express)

**Best for:** Frontend + BFF (Backend-for-Frontend)

```dockerfile
# --- Build UI (React + Vite) ---
FROM node:20-alpine AS build-ui
WORKDIR /app

# Copy package files first (caching)
COPY package*.json ./
COPY tsconfig.json ./
COPY ui/package*.json ./ui/

# Install dependencies
RUN npm install --no-fund --no-audit

# Copy UI source and build
COPY ui/ ./ui/
RUN npm run build:ui

# --- Build BFF (Express + TypeScript) ---
FROM node:20-alpine AS build-bff
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY bff/package*.json ./bff/

# Install dependencies
RUN npm install --no-fund --no-audit

# Copy BFF source and build
COPY bff/ ./bff/
RUN npm run build:bff

# --- Runtime (Nginx + Node.js) ---
FROM node:20-alpine AS runtime

# Install nginx for serving React build
RUN apk add --no-cache nginx

# Copy built UI from build-ui stage
COPY --from=build-ui /app/ui/dist /usr/share/nginx/html

# Copy built BFF from build-bff stage
WORKDIR /app/bff
COPY --from=build-bff /app/bff/dist ./dist
COPY --from=build-bff /app/bff/package*.json ./
COPY --from=build-bff /app/node_modules ../node_modules

# Copy static assets (logo, favicon)
COPY ./images /usr/share/nginx/html/images

# Copy nginx config
RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/http.d/default.conf
COPY ./nginx.conf /etc/nginx/http.d/default.conf

# Create startup script to run both nginx and BFF
RUN printf '#!/bin/sh\n\
nginx\n\
cd /app/bff && NODE_ENV=production node dist/index.js\n' > /start.sh && \
chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
```

**Why multi-stage?**
- Build stage includes dev dependencies (TypeScript, build tools)
- Runtime stage only includes production dependencies (smaller image)
- Final image: **~150 MB** (vs 800 MB with dev dependencies)

**Stage breakdown:**
1. **build-ui**: Compile React + Vite to static files
2. **build-bff**: Compile TypeScript Express server to JavaScript
3. **runtime**: Nginx (static files) + Node.js (BFF server)

---

### 3. Build Argument Pattern

**Best for:** Version injection, environment-specific builds

```dockerfile
FROM python:3.12-slim

# Accept build argument
ARG APP_VERSION=0.1.0
ENV APP_VERSION=${APP_VERSION}

WORKDIR /api
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Build with version:**
```bash
docker build --build-arg APP_VERSION=0.2.5 -t myapp:0.2.5 .
```

**Use in application:**
```python
# app/main.py
import os

APP_VERSION = os.getenv("APP_VERSION", "0.1.0")

@app.get("/health")
async def health():
    return {"status": "healthy", "version": APP_VERSION}
```

---

### 4. Development vs Production Dockerfile

**Strategy:** Use single Dockerfile with target stages

```dockerfile
# Base stage (shared)
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /api
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Development stage
FROM base AS development
RUN pip install --no-cache-dir pytest pytest-asyncio httpx
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# Production stage
FROM base AS production
COPY app ./app
COPY migrations ./migrations
# Run as non-root user for security
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /api
USER appuser
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Build and run:**
```bash
# Development
docker build --target development -t myapp:dev .
docker run -v $(pwd):/api myapp:dev  # Mount code for hot reload

# Production
docker build --target production -t myapp:prod .
docker run myapp:prod
```

---

## Layer Caching Best Practices

### ❌ Poor Caching (Rebuilds Everything)
```dockerfile
FROM python:3.12-slim
WORKDIR /api
COPY . .  # ← Changes frequently, invalidates all layers below
RUN pip install -r requirements.txt
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0"]
```

**Problem:** Every code change rebuilds pip install (slow)

### ✅ Good Caching (Faster Builds)
```dockerfile
FROM python:3.12-slim
WORKDIR /api
COPY requirements.txt ./  # ← Only changes when dependencies change
RUN pip install -r requirements.txt
COPY . .  # ← Frequent changes, but doesn't invalidate pip install
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0"]
```

**Benefit:** Pip install only runs when requirements.txt changes

**Caching rules:**
1. Order layers by change frequency (least → most)
2. Copy only files needed for each layer
3. Separate dependency installation from code copy

---

## Security Best Practices

### 1. Use Specific Base Image Tags

❌ **Don't:**
```dockerfile
FROM python:latest  # Tag can change, breaks reproducibility
```

✅ **Do:**
```dockerfile
FROM python:3.12-slim  # Specific version
```

### 2. Run as Non-Root User

❌ **Don't:**
```dockerfile
CMD ["uvicorn", "app.main:app"]  # Runs as root (uid 0)
```

✅ **Do:**
```dockerfile
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /api
USER appuser
CMD ["uvicorn", "app.main:app"]
```

### 3. Scan for Vulnerabilities

```bash
# Install Docker Scout
docker scout cve myapp:latest

# Example output:
#   ✓ High: 0
#   ! Medium: 3
#   ○ Low: 12
```

### 4. Use `.dockerignore`

```
# .dockerignore
__pycache__
*.pyc
.pytest_cache
.git
.env
node_modules
*.log
```

**Benefit:** Faster builds, smaller context, no secrets in image

---

## Image Size Optimization

### Strategy 1: Use Alpine Base Images

```dockerfile
# Before: 1.2 GB
FROM node:20

# After: 180 MB
FROM node:20-alpine
```

**Trade-off:** Alpine uses `musl` instead of `glibc` (rare compatibility issues)

### Strategy 2: Multi-Stage Builds

```dockerfile
# Build stage (800 MB with dev dependencies)
FROM node:20-alpine AS builder
RUN npm install && npm run build

# Production stage (150 MB - only runtime dependencies)
FROM node:20-alpine
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm install --production
```

**Savings:** 650 MB (81% reduction)

### Strategy 3: Clean Package Manager Cache

```dockerfile
# Python
RUN pip install --no-cache-dir -r requirements.txt

# Node.js
RUN npm install --no-fund --no-audit && npm cache clean --force

# Apt (Debian/Ubuntu)
RUN apt-get update && apt-get install -y package \
    && rm -rf /var/lib/apt/lists/*
```

---

## Common Dockerfile Commands

### COPY vs ADD

✅ **Use COPY** (explicit, predictable):
```dockerfile
COPY requirements.txt ./
COPY app ./app
```

❌ **Avoid ADD** (auto-extracts tar, fetches URLs):
```dockerfile
ADD requirements.txt ./  # Use COPY instead
```

**Exception:** Only use ADD when you need tar extraction

### CMD vs ENTRYPOINT

**CMD** (can be overridden):
```dockerfile
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0"]
```
```bash
docker run myapp python -m pytest  # Replaces CMD
```

**ENTRYPOINT** (fixed, append args):
```dockerfile
ENTRYPOINT ["uvicorn", "app.main:app"]
CMD ["--host", "0.0.0.0"]  # Default args
```
```bash
docker run myapp --reload  # Runs: uvicorn app.main:app --reload
```

**Best practice:** Use CMD for simple apps, ENTRYPOINT + CMD for tooling

### ENV vs ARG

**ARG** (build-time only):
```dockerfile
ARG VERSION=1.0.0
RUN echo "Building version ${VERSION}"
```

**ENV** (build + runtime):
```dockerfile
ENV APP_VERSION=1.0.0
# Available in running container
```

---

## Build Optimization Tips

### 1. Use BuildKit

```bash
# Enable BuildKit (faster, better caching)
export DOCKER_BUILDKIT=1
docker build -t myapp .

# Or inline:
DOCKER_BUILDKIT=1 docker build -t myapp .
```

**Benefits:** Parallel builds, better caching, secret management

### 2. Multi-Platform Builds

```bash
# Build for multiple architectures
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
```

### 3. Cache Mounts (BuildKit)

```dockerfile
# Mount pip cache across builds
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

**Benefit:** Share package cache between builds (faster)

---

## Testing Dockerfiles

### Build and Run Locally

```bash
# Build
docker build -t myapp:test .

# Run interactively
docker run -it myapp:test sh

# Check file structure
docker run myapp:test ls -la /api

# Inspect image
docker inspect myapp:test
```

### Verify Image Size

```bash
docker images myapp:test
# REPOSITORY   TAG    IMAGE ID       SIZE
# myapp        test   abc123def456   250MB
```

**Target sizes:**
- Python FastAPI: 200-400 MB
- Node.js (Alpine): 150-300 MB
- Multi-stage Node: 100-200 MB

---

## Common Pitfalls

### ❌ Don't:
- **Copy entire context** (`COPY . .` at start)
- **Install unnecessary packages** (bloat image size)
- **Run as root** (security risk)
- **Use `latest` tag** (breaks reproducibility)
- **Hardcode secrets** (`ENV API_KEY=abc123`)

### ✅ Do:
- **Copy dependencies first** (better caching)
- **Use `.dockerignore`** (faster builds)
- **Run as non-root user** (security)
- **Use specific tags** (`python:3.12-slim`)
- **Pass secrets at runtime** (`docker run -e API_KEY=...`)

---

## Source References

**Extracted from:**
- AI Workflow: `api/Dockerfile` (Python FastAPI pattern)
- AI Workflow: `auth/Dockerfile` (Python with psql client)
- AI Workflow: `webui/Dockerfile` (Node multi-stage: React + BFF + Nginx)

**Related Patterns:**
- 📎 [Docker Compose Patterns](docker-compose-patterns.md) - Multi-container orchestration
- 📎 [GitHub Actions Patterns](github-actions-patterns.md) - CI/CD builds
- 📎 [Environment Config Patterns](environment-config-patterns.md) - Managing secrets

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Enterprise application v0.2.11/v0.5.5
