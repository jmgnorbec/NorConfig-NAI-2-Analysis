# Traefik Reverse Proxy - Overview

**Pattern Type:** Infrastructure / Networking  
**Complexity:** Intermediate to Advanced  
**Read Time:** ~3 minutes  
**Best For:** Multi-service HTTPS, automatic TLS, Docker service discovery

---

## When to Use Traefik

### ✅ Use Traefik For

- **Multi-service applications** - Route by hostname/path (api.example.com, app.example.com)
- **Automatic HTTPS** - Let's Encrypt certificate management (auto-renewal)
- **Docker environments** - Service discovery via container labels
- **WebSocket applications** - Automatic connection upgrade handling
- **Dynamic routing** - Add services without restarting proxy

### ❌ Consider Alternatives When

- **Single service only** - Nginx simpler for one app
- **Static configuration** - Nginx/Caddy easier for fixed setups
- **Non-Docker deployments** - Traefik excels with containers
- **Learning basics** - Start with Nginx first (more common)

### vs. Alternatives

| Reverse Proxy | Pros | Cons |
|---------------|------|------|
| **Traefik** | Auto-discovery, dynamic, easy Docker | Less common, newer |
| **Nginx** | Well-known, fast, flexible | Manual config, complex |
| **Caddy** | Simplest config, auto-HTTPS | Fewer features |
| **HAProxy** | Enterprise-grade, fast | Complex config |

**Key insight:** Traefik best for Docker multi-service apps. Dynamic service discovery saves configuration headaches.

---

## Essential Configuration

### Architecture

```
Internet (HTTPS) → Traefik :443 → Backend Services

┌────────────────────────────────────────────┐
│        Internet (HTTPS requests)           │
└────────────────┬───────────────────────────┘
                 │ :443
                 ↓
┌────────────────────────────────────────────┐
│           Traefik Container                │
│  - TLS termination (Let's Encrypt)        │
│  - Routing (by hostname/path)             │
│  - Service discovery (Docker labels)      │
└──┬─────────────┬──────────────────────────┘
   │             │
   ↓             ↓
┌─────────┐  ┌─────────┐
│  WebUI  │  │   API   │
│  :3000  │  │  :8000  │
└─────────┘  └─────────┘
```

**Routing examples:**
- `https://app.example.com` → WebUI container
- `https://api.example.com` → API container
- `https://admin.example.com` → Admin container

### Installation

**Via Docker Compose:**
```bash
# Traefik handles routing, no manual Nginx config needed
docker compose up traefik
```

---

## Minimal Working Examples

### 1. Basic Traefik Setup

**traefik.yml** (static config):
```yaml
api:
  dashboard: true  # Dashboard at http://traefik:8080

entryPoints:
  web:
    address: ":80"      # HTTP
  websecure:
    address: ":443"     # HTTPS

providers:
  docker:
    exposedByDefault: false  # Only expose labeled services

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.11
    command:
      - --configFile=/traefik.yml
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro  # Docker API
      - ./traefik.yml:/traefik.yml:ro
      - traefik_certs:/letsencrypt                     # Certificate storage
    networks:
      - traefik

volumes:
  traefik_certs:

networks:
  traefik:
    driver: bridge
```

### 2. Expose Service with Traefik

**Add labels to service:**

```yaml
services:
  webui:
    image: my-webui
    labels:
      - traefik.enable=true
      - traefik.http.routers.webui.rule=Host(`app.example.com`)
      - traefik.http.routers.webui.entrypoints=websecure
      - traefik.http.routers.webui.tls.certresolver=letsencrypt
      - traefik.http.services.webui.loadbalancer.server.port=3000
    networks:
      - traefik
```

**What this does:**
1. `traefik.enable=true` - Traefik discovers this service
2. `rule=Host(...)` - Route requests to app.example.com
3. `entrypoints=websecure` - Use HTTPS (:443)
4. `tls.certresolver=letsencrypt` - Get TLS certificate automatically
5. `server.port=3000` - Forward to container port 3000

**Result:** https://app.example.com → webui:3000 (automatic HTTPS)

### 3. HTTP to HTTPS Redirect

**Add global redirect middleware:**

```yaml
services:
  traefik:
    image: traefik:v2.11
    command:
      - --configFile=/traefik.yml
      - --entrypoints.web.http.redirections.entryPoint.to=websecure
      - --entrypoints.web.http.redirections.entryPoint.scheme=https
```

**Or per-service:**
```yaml
labels:
  - traefik.http.routers.webui-http.rule=Host(`app.example.com`)
  - traefik.http.routers.webui-http.entrypoints=web
  - traefik.http.routers.webui-http.middlewares=redirect-to-https
  - traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https
```

**Result:** http://app.example.com → https://app.example.com (302 redirect)

### 4. Path-Based Routing

**Route by path prefix:**

```yaml
services:
  api:
    labels:
      - traefik.enable=true
      - traefik.http.routers.api.rule=Host(`example.com`) && PathPrefix(`/api`)
      - traefik.http.routers.api.entrypoints=websecure
      - traefik.http.routers.api.tls.certresolver=letsencrypt
      - traefik.http.services.api.loadbalancer.server.port=8000

  webui:
    labels:
      - traefik.enable=true
      - traefik.http.routers.webui.rule=Host(`example.com`)
      - traefik.http.routers.webui.entrypoints=websecure
      - traefik.http.routers.webui.tls.certresolver=letsencrypt
      - traefik.http.services.webui.loadbalancer.server.port=3000
```

**Routing:**
- `https://example.com/api/users` → api:8000
- `https://example.com/` → webui:3000

### 5. Private Service (No Traefik)

**Internal-only service:**

```yaml
services:
  postgres:
    image: postgres:16-alpine
    # NO traefik.enable label - not exposed to internet
    networks:
      - private  # Different network, internal only

  api:
    labels:
      - traefik.enable=true
      - traefik.http.routers.api.rule=Host(`api.example.com`)
    networks:
      - traefik   # Internet-facing
      - private   # Can talk to postgres
```

**Result:** API can reach postgres, but postgres not exposed to internet.

---

## Common Operations

### View Traefik Dashboard

**Enable dashboard:**
```yaml
api:
  dashboard: true
```

**Access:**
- Local: http://localhost:8080/dashboard/
- Production: Add authentication labels

**Dashboard shows:**
- Active routers and services
- TLS certificates
- Middleware chains

### Check Certificates

```bash
# List certificates in container
docker exec traefik ls -la /letsencrypt/

# View certificate details
docker exec traefik cat /letsencrypt/acme.json | jq '.'
```

### Force Certificate Renewal

```bash
# Delete certificate storage
docker compose down
docker volume rm traefik_certs
docker compose up -d

# Traefik will request new certificates
```

### Debugging Routing

**Check Traefik logs:**
```bash
docker compose logs traefik -f
```

**Common log messages:**
- "Router [name] detected" - Service discovered
- "Certificate obtained" - Let's Encrypt succeeded
- "Cannot obtain Let's Encrypt certificate" - DNS/port issue

---

## Top 5 Gotchas

### 1. exposedByDefault=true (Security Risk) ⚠️

```yaml
# ❌ Wrong: Exposes ALL containers to internet
providers:
  docker:
    exposedByDefault: true  # Every container routed!

# ✅ Correct: Opt-in exposure only
providers:
  docker:
    exposedByDefault: false
    # Only containers with traefik.enable=true exposed
```

**Impact:** Database, internal services exposed publicly.

### 2. Port 80/443 Already in Use

```bash
# Error: "bind: address already in use"

# Check what's using ports
netstat -tuln | grep ':80\|:443'

# Stop conflicting service (Nginx, Apache)
sudo systemctl stop nginx
```

**Impact:** Traefik won't start, no routing.

### 3. Missing loadbalancer.server.port

```yaml
# ❌ Wrong: Traefik doesn't know which container port
labels:
  - traefik.enable=true
  - traefik.http.routers.api.rule=Host(`api.example.com`)
  # Missing port! Traefik guesses (often wrong)

# ✅ Correct: Specify port explicitly
labels:
  - traefik.enable=true
  - traefik.http.routers.api.rule=Host(`api.example.com`)
  - traefik.http.services.api.loadbalancer.server.port=8000
```

**Impact:** 502 Bad Gateway, can't reach service.

### 4. Let's Encrypt Rate Limits

**Let's Encrypt limits:**
- 5 failed attempts per hour per domain
- 50 certificates per domain per week

**During development:**
```yaml
# Use staging environment (no rate limits)
certificatesResolvers:
  letsencrypt:
    acme:
      caServer: https://acme-staging-v02.api.letsencrypt.org/directory
      email: admin@example.com
      storage: /letsencrypt/acme.json
```

**Staging certificates not trusted** - for testing only.

### 5. Wrong Network Configuration

```yaml
# ❌ Wrong: Service and Traefik on different networks
services:
  traefik:
    networks:
      - traefik
  
  api:
    networks:
      - private  # Can't communicate!

# ✅ Correct: Same network for communication
services:
  traefik:
    networks:
      - traefik
  
  api:
    networks:
      - traefik  # Must be on same network
```

**Impact:** 502 Bad Gateway, service unreachable.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| 502 Bad Gateway | Wrong port, wrong network | Check port label, network config |
| Certificate not issued | Port 80/443 blocked | Check firewall, DNS A record |
| Service not detected | Missing traefik.enable | Add `traefik.enable=true` label |
| Rate limit hit | Too many cert requests | Use staging CA during development |
| Database exposed | exposedByDefault=true | Set to false, use opt-in |

---

## References

📎 **Reference**: [traefik-reference.md](traefik-reference.md)  
**When to load**: Middleware (auth, rate limit, CORS), advanced routing (priority, regex), ACME DNS challenge, TCP/UDP routing, multiple entrypoints (~480 lines)

📎 **Related patterns**:
- [docker-compose-overview.md](docker-compose-overview.md) - Orchestrating with Traefik
- [vps-deployment-overview.md](vps-deployment-overview.md) - Production Traefik setup
- [environment-config-overview.md](environment-config-overview.md) - Traefik configuration

---

**Pattern Type:** Infrastructure / Networking  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate to Advanced ⭐⭐⭐⭐☆
