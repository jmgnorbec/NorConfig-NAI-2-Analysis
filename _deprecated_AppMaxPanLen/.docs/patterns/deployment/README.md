# Deployment Patterns

**Purpose:** Docker containerization, CI/CD automation, and production deployment patterns.

---

## Pattern Structure

Each deployment pattern is split into two files:

- **`{pattern}-overview.md`** (~300 lines, 2-3 min read) - Quick decision-making reference:
  - When to use (vs alternatives)
  - Essential configuration (minimal setup)
  - Minimal working examples (copy-paste ready)
  - Common operations (frequent tasks)
  - Top 5 gotchas (critical mistakes to avoid)
  - Quick troubleshooting

- **`{pattern}-reference.md`** (~400-600 lines, 20+ min read) - Comprehensive implementation guide:
  - Complete configuration options
  - All examples and edge cases
  - Advanced patterns
  - Performance optimization
  - Full troubleshooting guide

**When to use:**
- **Overview** - Understanding deployment strategy, quick setup, choosing approach
- **Reference** - Advanced configuration, production optimization, debugging

---

## Available Patterns

### 1. Docker Containerization

**What:** Build Docker images (single-stage, multi-stage)  
**When:** Any application deployed to servers (dev, staging, prod)

- 📘 [docker-overview.md](docker-overview.md) - Dockerfile patterns, layer caching, multi-stage builds
- 📖 [docker-reference.md](docker-reference.md) - Build arguments, health checks, security hardening

**Start here:** Creating first Dockerfile, optimizing build times.

---

### 2. Docker Compose Orchestration

**What:** Multi-container orchestration (services, networks, volumes)  
**When:** Multi-service applications (auth + API + database + frontend)

- 📘 [docker-compose-overview.md](docker-compose-overview.md) - Basic compose, extends pattern, health checks
- 📖 [docker-compose-reference.md](docker-compose-reference.md) - Profiles, secrets, advanced networking

**Start here:** Running multiple services together, service dependencies.

---

### 3. Environment Configuration

**What:** Managing environment variables, secrets, multi-environment configs  
**When:** Different settings per environment (dev, staging, prod)

- 📘 [environment-config-overview.md](environment-config-overview.md) - .env files, secret generation, Docker Compose integration
- 📖 [environment-config-reference.md](environment-config-reference.md) - Vault, AWS Secrets Manager, 12-factor app

**Start here:** Creating .env files, securing secrets, managing configurations.

---

### 4. GitHub Actions CI/CD

**What:** Automated Docker builds and container registry publishing  
**When:** GitHub-hosted projects needing automated builds

- 📘 [github-actions-overview.md](github-actions-overview.md) - Basic workflows, GHCR publishing, triggers
- 📖 [github-actions-reference.md](github-actions-reference.md) - Multi-platform builds, caching, deployment workflows

**Start here:** Automating Docker builds, publishing to GHCR.

---

### 5. Traefik Reverse Proxy

**What:** Automatic HTTPS with Let's Encrypt, dynamic routing  
**When:** Multi-service applications needing HTTPS and routing

- 📘 [traefik-overview.md](traefik-overview.md) - Basic setup, TLS, routing rules
- 📖 [traefik-reference.md](traefik-reference.md) - Middleware, advanced routing, TCP/UDP

**Start here:** Setting up reverse proxy, automatic TLS certificates.

---

### 6. VPS Deployment

**What:** Deploying to Virtual Private Server (cost-effective hosting)  
**When:** Small-to-medium apps (<10k users), full control needed

- 📘 [vps-deployment-overview.md](vps-deployment-overview.md) - VPS setup, GHCR authentication, deployment workflow
- 📖 [vps-deployment-reference.md](vps-deployment-reference.md) - SSH keys, monitoring, backup strategies, security

**Start here:** First production deployment, choosing VPS provider.

---

## Pattern Decision Guide

### For AI Agents Loading Context

**Decision-making (load overviews):**
- Choosing containerization strategy → [docker-overview.md](docker-overview.md)
- Running multiple services locally → [docker-compose-overview.md](docker-compose-overview.md)
- Managing secrets and env vars → [environment-config-overview.md](environment-config-overview.md)
- Automating Docker builds → [github-actions-overview.md](github-actions-overview.md)
- Setting up HTTPS and routing → [traefik-overview.md](traefik-overview.md)
- Deploying to production → [vps-deployment-overview.md](vps-deployment-overview.md)

**Implementation (load references on-demand):**
- Multi-stage build optimization → [docker-reference.md](docker-reference.md)
- Docker Compose extends pattern → [docker-compose-reference.md](docker-compose-reference.md)
- Secret rotation strategies → [environment-config-reference.md](environment-config-reference.md)
- Multi-platform GitHub Actions builds → [github-actions-reference.md](github-actions-reference.md)
- Traefik middleware chains → [traefik-reference.md](traefik-reference.md)
- VPS monitoring and backups → [vps-deployment-reference.md](vps-deployment-reference.md)

### For Developers Learning Patterns

| Scenario | Start With | Then Read |
|----------|------------|-----------|
| **First Docker image** | docker-overview | docker-reference |
| **Multi-service app** | docker-compose-overview | docker-compose-reference |
| **CI/CD setup** | github-actions-overview | environment-config-overview |
| **Production deploy** | vps-deployment-overview | traefik-overview |
| **HTTPS setup** | traefik-overview | vps-deployment-reference |
| **Secret management** | environment-config-overview | environment-config-reference |

### Project Phase Decision Matrix

| Phase | Deployment Patterns | Rationale |
|-------|---------------------|-----------|
| **Week 1 (MVP)** | Docker + Docker Compose | Local development consistency |
| **Month 1 (Alpha)** | + Environment Config + GitHub Actions | Automated builds, CI/CD |
| **Month 3 (Beta)** | + VPS Deployment | Real production environment |
| **Production** | + Traefik | HTTPS, professional routing |

---

## Deployment Growth Path

```
Phase 1: Local Development
├── Dockerfile (single service)
└── docker-compose.yml (local only)

Phase 2: CI/CD
├── GitHub Actions workflows
└── GHCR (container registry)

Phase 3: Production Deployment
├── VPS server
├── Docker Compose (production)
└── Environment variables

Phase 4: Professional Setup
├── Traefik (reverse proxy)
├── Let's Encrypt (HTTPS)
└── Monitoring & backups
```

---

## Quick Reference

### Docker Quick Start

```bash
# Build image
docker build -t my-app .

# Run container
docker run -p 8000:8000 my-app

# Multi-service with Compose
docker compose up -d
```

### GitHub Actions Quick Start

**.github/workflows/build.yml:**
```yaml
name: Build Docker image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/my-app:main
```

### VPS Deployment Quick Start

```bash
# 1. Setup VPS
curl -fsSL https://get.docker.com | sh

# 2. Authenticate to GHCR
echo $TOKEN | docker login ghcr.io -u username --password-stdin

# 3. Deploy
docker compose -f docker-compose.prod.yml up -d --pull always
```

---

## Key Principles

1. **Build once, deploy anywhere** - Docker images are portable
2. **Environment-specific config** - Same image, different .env files
3. **Automate builds** - CI/CD prevents manual errors
4. **Secure secrets** - Never commit .env, use environment variables
5. **Reverse proxy for production** - Traefik handles TLS and routing

---

## Loading Strategy Summary

**For quick decisions (2-3 min):** Load overview files  
**For deep implementation (20+ min):** Load reference files on-demand

**Override + reference pattern:** All overviews include 📎 anchor to reference file with "When to load" guidance.

---

**Template Version:** 1.0.0  
**Last Updated:** 2026-03-07  
**Patterns Complete:** 6/6 (docker, docker-compose, environment-config, github-actions, traefik, vps-deployment)
