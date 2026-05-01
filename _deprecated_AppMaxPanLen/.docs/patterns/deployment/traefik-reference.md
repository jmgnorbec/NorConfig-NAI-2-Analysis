# Traefik Reverse Proxy Patterns

**Pattern Type:** Infrastructure / Networking  
**Best For:** TLS termination, routing, multi-service applications  
**Source:** Enterprise application  
**Complexity:** ⭐⭐⭐⭐☆

---

## Overview

Traefik reverse proxy patterns for Docker-based applications. Covers automatic TLS with Let's Encrypt, routing rules, service discovery, and multi-service configurations. Traefik sits between the internet and your services, handling HTTPS, routing, and load balancing.

**Key Characteristics:**
- Automatic service discovery (reads Docker labels)
- TLS certificate management (Let's Encrypt automatic renewal)
- HTTP to HTTPS redirection
- Dynamic routing based on hostname/path
- WebSocket support

---

## When to Use

### ✅ Use Traefik For:
- **Multi-service applications** (route to auth, API, webui based on hostname/path)
- **Automatic HTTPS** (Let's Encrypt certificate management)
- **Docker environments** (service discovery via labels)
- **Multiple domains** (app.example.com, admin.example.com)
- **WebSocket applications** (Traefik handles upgrades automatically)

### ❌ Consider Alternatives When:
- **Single service only** (Nginx might be simpler)
- **Static configuration** (Nginx or Caddy easier for fixed setups)
- **Non-Docker deployments** (Traefik excels with containers)
- **No HTTPS needed** (development only)

**Alternatives:**
- **Nginx**: Manual config, more common, steeper learning curve
- **Caddy**: Simpler config, automatic HTTPS, less features
- **HAProxy**: Enterprise-grade, complex config

---

## Architecture

```
Internet (HTTPS) → Traefik → Docker Services

┌────────────────────────────────────────────────────┐
│                   Internet                         │
└─────────────────────┬──────────────────────────────┘
                      │ HTTPS (443)
                      ↓
┌─────────────────────────────────────────────────────┐
│                 Traefik Container                   │
│  - TLS termination (Let's Encrypt)                 │
│  - Routing rules (host, path)                      │
│  - Service discovery (Docker labels)               │
└─────────┬──────────────┬──────────────────────────┘
          │              │
          ↓              ↓
┌─────────────┐    ┌─────────────┐
│   WebUI     │    │   Auth      │
│   :80       │    │   :8000     │
└─────────────┘    └─────────────┘
                         │
                         ↓
                   ┌─────────────┐
                   │     API     │
                   │   :8000     │
                   └─────────────┘
```

**Routing logic:**
- `https://app.example.com` → WebUI container
- `https://auth.example.com/webhook` → Auth container (if public)
- Services talk to each other via internal Docker network (no Traefik)

---

## Basic Traefik Setup

### 1. Traefik Configuration File

**File:** `traefik.yml` (static configuration)

```yaml
api:
  dashboard: true  # Enable dashboard at http://traefik:8080

entryPoints:
  web:
    address: ":80"     # HTTP port
  websecure:
    address: ":443"    # HTTPS port

providers:
  docker:
    exposedByDefault: false  # Only expose services with traefik.enable=true

certificatesResolvers:
  letsencrypt:
    acme:
      email: ${TRAEFIK_EMAIL}
      storage: /letsencrypt/acme.json  # Certificate storage
      httpChallenge:
        entryPoint: web  # Use HTTP-01 challenge
```

**Key settings:**
- **`exposedByDefault: false`**: Security best practice (opt-in exposure)
- **`httpChallenge`**: Let's Encrypt verification via HTTP
- **`storage`**: Certificates persisted in volume

---

### 2. Traefik Docker Compose

**File:** `traefik/traefik.compose.yml`

```yaml
version: '3.8'

networks:
  traefik:
    external: true

volumes:
  letsencrypt:

services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"      # HTTP
      - "443:443"    # HTTPS
      - "8080:8080"  # Dashboard (optional, secure in production)
    networks:
      - traefik
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro  # Docker API (read-only)
      - ./traefik.yml:/etc/traefik/traefik.yml:ro     # Static config
      - letsencrypt:/letsencrypt                       # Certificate storage
    environment:
      - TRAEFIK_EMAIL=${TRAEFIK_EMAIL}
    labels:
      # Dashboard secured with basic auth (optional)
      - traefik.enable=true
      - traefik.http.routers.dashboard.rule=Host(`traefik.example.com`)
      - traefik.http.routers.dashboard.entrypoints=websecure
      - traefik.http.routers.dashboard.tls.certresolver=letsencrypt
      - traefik.http.routers.dashboard.service=api@internal
```

**Security notes:**
- **Docker socket read-only**: Limits Traefik permissions
- **Dashboard optional**: Remove port 8080 in production or secure with auth
- **Certificate volume**: Persists Let's Encrypt certs across restarts

---

### 3. Create Traefik Network

**Run once:**
```bash
docker network create traefik
```

**This network is shared by all services** that Traefik routes to.

---

### 4. Start Traefik

```bash
cd traefik
docker compose up -d

# Check status
docker logs traefik

# View dashboard (if enabled)
# http://your-vps-ip:8080
```

---

## Service Configuration (Docker Labels)

### Pattern: Expose Service to Traefik

**Service compose file (e.g., `webui/webui.compose.yml`):**

```yaml
networks:
  traefik:
    external: true

services:
  webui:
    image: ghcr.io/yourorg/yourapp/webui:main
    container_name: webui
    restart: unless-stopped
    networks:
      - traefik
    labels:
      # Enable Traefik for this service
      - traefik.enable=true
      
      # Specify which network Traefik uses to reach this service
      - traefik.docker.network=traefik
      
      # Routing rule (by hostname)
      - traefik.http.routers.webui.rule=Host(`app.example.com`)
      
      # Entrypoint (websecure = HTTPS port 443)
      - traefik.http.routers.webui.entrypoints=websecure
      
      # Enable TLS
      - traefik.http.routers.webui.tls=true
      
      # Use Let's Encrypt certificate resolver
      - traefik.http.routers.webui.tls.certresolver=letsencrypt
      
      # Specify container port (Traefik forwards to this)
      - traefik.http.services.webui.loadbalancer.server.port=80
```

**How it works:**
1. Request: `https://app.example.com` reaches Traefik
2. Traefik reads labels: "Route Host(`app.example.com`) to webui container"
3. Traefik terminates TLS (HTTPS → HTTP)
4. Traefik forwards to `webui:80` on private network
5. WebUI responds → Traefik sends HTTPS response to client

---

## Routing Patterns

### 1. Hostname-Based Routing (Subdomains)

**Route different services to different subdomains:**

```yaml
# WebUI: app.example.com
labels:
  - traefik.http.routers.webui.rule=Host(`app.example.com`)

# API: api.example.com
labels:
  - traefik.http.routers.api.rule=Host(`api.example.com`)

# Auth: auth.example.com
labels:
  - traefik.http.routers.auth.rule=Host(`auth.example.com`)
```

**DNS setup:**
```
app.example.com  → A record → VPS IP
api.example.com  → A record → VPS IP
auth.example.com → A record → VPS IP
```

---

### 2. Path-Based Routing

**Route paths on same domain to different services:**

```yaml
# WebUI: app.example.com/
labels:
  - traefik.http.routers.webui.rule=Host(`app.example.com`) && PathPrefix(`/`)
  - traefik.http.routers.webui.priority=1  # Lower priority (catch-all)

# API: app.example.com/api
labels:
  - traefik.http.routers.api.rule=Host(`app.example.com`) && PathPrefix(`/api`)
  - traefik.http.routers.api.priority=10  # Higher priority

# Auth: app.example.com/auth
labels:
  - traefik.http.routers.auth.rule=Host(`app.example.com`) && PathPrefix(`/auth`)
  - traefik.http.routers.auth.priority=10
```

**Priority matters:**
- Higher priority = matched first
- Specific paths get higher priority than catch-all

---

### 3. Combined Rules (AND/OR)

```yaml
# Match multiple subdomains
- traefik.http.routers.app.rule=Host(`app.example.com`) || Host(`www.app.example.com`)

# Match subdomain AND path
- traefik.http.routers.admin.rule=Host(`admin.example.com`) && PathPrefix(`/dashboard`)

# Match subdomain OR specific path on main domain
- traefik.http.routers.api.rule=Host(`api.example.com`) || (Host(`app.example.com`) && PathPrefix(`/api`))
```

---

### 4. Optional Public Exposure (Private by Default)

**Pattern:** Service private unless explicitly exposed

```yaml
services:
  auth:
    labels:
      # Disabled by default (keep auth service private)
      - traefik.enable=${AUTH_PUBLIC:-false}
      
      # Rules only apply if AUTH_PUBLIC=true
      - traefik.http.routers.auth-webhook.rule=Host(`${AUTH_WEBHOOK_HOST}`) && PathPrefix(`${AUTH_WEBHOOK_PATH_PREFIX:-/webhook}`)
      - traefik.http.routers.auth-webhook.entrypoints=websecure
      - traefik.http.routers.auth-webhook.tls.certresolver=letsencrypt
```

**Environment variable (`.env`):**
```bash
# Keep auth private
AUTH_PUBLIC=false

# Or expose webhook endpoint
AUTH_PUBLIC=true
AUTH_WEBHOOK_HOST=webhook.example.com
AUTH_WEBHOOK_PATH_PREFIX=/webhook
```

**Use case:** Auth service internal-only, except webhook for external integrations

---

## HTTPS and Certificates

### Automatic Let's Encrypt

**Traefik handles everything:**
1. Service starts with `tls.certresolver=letsencrypt`
2. Traefik requests certificate from Let's Encrypt
3. Let's Encrypt verifies domain (HTTP-01 challenge at `http://domain/.well-known/acme-challenge/`)
4. Certificate issued and stored in `/letsencrypt/acme.json`
5. Automatic renewal before expiration (90 days)

**Requirements:**
- ✅ Domain DNS points to VPS IP
- ✅ Ports 80 and 443 open
- ✅ Valid email in `TRAEFIK_EMAIL`

### HTTP to HTTPS Redirect

**Automatically redirect HTTP → HTTPS:**

```yaml
# traefik.yml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure  # Redirect to HTTPS
          scheme: https
  websecure:
    address: ":443"
```

**Result:**
- `http://app.example.com` → `https://app.example.com` (automatic redirect)

---

## Common Configurations

### 1. WebUI + Backend Services

**WebUI exposed publicly, backend private:**

```yaml
# WebUI (public)
services:
  webui:
    networks:
      - traefik
      - private  # Can reach auth/api on private network
    labels:
      - traefik.enable=true
      - traefik.http.routers.webui.rule=Host(`app.example.com`)
      - traefik.http.routers.webui.entrypoints=websecure
      - traefik.http.routers.webui.tls.certresolver=letsencrypt

# Auth (private, not exposed via Traefik)
services:
  auth:
    networks:
      - private  # No traefik network
    labels:
      - traefik.enable=false

# API (private, not exposed via Traefik)
services:
  api:
    networks:
      - private
    labels:
      - traefik.enable=false
```

**Communication:**
- Browser → Traefik (HTTPS) → WebUI
- WebUI → Auth/API (HTTP on private network, no Traefik)

---

### 2. Multiple Environments (Staging/Production)

**Use environment variables for different domains:**

```yaml
labels:
  - traefik.http.routers.webui.rule=Host(`${UI_HOST}`)
  - traefik.http.routers.webui.entrypoints=${UI_ENTRYPOINTS:-websecure}
  - traefik.http.routers.webui.tls.certresolver=${TRAEFIK_CERT_RESOLVER:-letsencrypt}
```

**Production `.env`:**
```bash
UI_HOST=app.example.com
UI_ENTRYPOINTS=websecure
TRAEFIK_CERT_RESOLVER=letsencrypt
```

**Staging `.env`:**
```bash
UI_HOST=staging.app.example.com
UI_ENTRYPOINTS=websecure
TRAEFIK_CERT_RESOLVER=letsencrypt
```

---

## Debugging Traefik

### View Routes

**Check Traefik dashboard:**
- URL: `http://your-vps-ip:8080`
- Shows all detected services and routes

**Or check logs:**
```bash
docker logs traefik

# Example output:
# Router webui@docker rule Host(`app.example.com`)
# Service webui@docker added
```

### Common Issues

**1. Service not routing**

**Check:**
- Service has `traefik.enable=true` label
- Service attached to `traefik` network
- DNS points to VPS IP

```bash
# Test DNS
nslookup app.example.com
# Should return VPS IP

# Check Traefik detected service
docker logs traefik | grep webui
```

**2. Certificate not issued**

**Check:**
- DNS resolves correctly
- Ports 80/443 open in firewall
- Email valid in `TRAEFIK_EMAIL`

```bash
# Check Let's Encrypt challenge
curl http://app.example.com/.well-known/acme-challenge/test
# Should reach Traefik (404 is ok, connection refused is not)

# Check certificate file
docker exec traefik cat /letsencrypt/acme.json
# Should contain certificates
```

**3. WebSocket connection fails**

**Traefik supports WebSockets automatically**, but if issues:

```yaml
labels:
  # Explicitly enable WebSocket (usually not needed)
  - traefik.http.services.webui.loadbalancer.server.scheme=http
```

---

## Production Hardening

### 1. Secure Dashboard

**Option A: Disable dashboard**
```yaml
# traefik.yml
api:
  dashboard: false  # Disable dashboard
```

**Option B: Basic authentication**
```bash
# Generate password hash
htpasswd -nb admin SecurePassword
# Output: admin:$apr1$abc123...
```

```yaml
labels:
  - traefik.http.routers.dashboard.middlewares=dashboard-auth
  - traefik.http.middlewares.dashboard-auth.basicauth.users=admin:$$apr1$$abc123...
```

**Note:** Double `$$` in compose files (escaping)

### 2. Rate Limiting

```yaml
labels:
  - traefik.http.middlewares.rate-limit.ratelimit.average=100
  - traefik.http.middlewares.rate-limit.ratelimit.burst=50
  - traefik.http.routers.webui.middlewares=rate-limit
```

**Settings:**
- `average`: Max requests per second
- `burst`: Allow temporary spikes

### 3. Security Headers

```yaml
labels:
  - traefik.http.middlewares.security-headers.headers.framedeny=true
  - traefik.http.middlewares.security-headers.headers.sslredirect=true
  - traefik.http.middlewares.security-headers.headers.stsSeconds=31536000
  - traefik.http.routers.webui.middlewares=security-headers
```

---

## Alternative: Caddy (Simpler)

If Traefik feels complex, **Caddy** is simpler:

**Caddy config (Caddyfile):**
```
app.example.com {
    reverse_proxy webui:80
}

api.example.com {
    reverse_proxy api:8000
}
```

**That's it.** Caddy automatically handles HTTPS. But less features than Traefik.

---

## Common Pitfalls

### ❌ Don't:
- **Expose dashboard publicly** without authentication
- **Forget `exposedByDefault: false`** (security risk)
- **Use both hostname and path routing** without priority (conflicts)
- **Forget to create Traefik network** (`docker network create traefik`)
- **Use invalid email** for Let's Encrypt (certificate requests fail)

### ✅ Do:
- **One service = one router** (clear separation)
- **Use environment variables** for multi-environment support
- **Keep backend services private** (only expose via BFF/WebUI)
- **Test DNS before deploying** (Let's Encrypt needs working DNS)
- **Check Traefik logs** when routes not working

---

## Source References

**Extracted from:**
- AI Workflow: `deploy/traefik/traefik.yml` (static configuration)
- AI Workflow: `webui/webui.compose.yml` (service labels)
- AI Workflow: `auth/auth.compose.yml` (optional public exposure pattern)

**Related Patterns:**
- 📎 [Docker Compose Patterns](docker-compose-patterns.md) - Multi-service orchestration
- 📎 [VPS Deployment Patterns](vps-deployment-patterns.md) - Production deployment
- 📎 [Environment Config Patterns](environment-config-patterns.md) - Managing domain/email config

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Enterprise application v0.2.11/v0.5.5
