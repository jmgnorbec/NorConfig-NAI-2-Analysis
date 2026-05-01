# VPS Deployment - Overview

**Pattern Type:** Production Deployment  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Small-to-medium apps, cost-effective hosting, full control

---

## When to Use VPS Deployment

### ✅ Use VPS For

- **Small-to-medium applications** - < 10k users
- **Cost-sensitive projects** - $5-30/month vs $50-200 managed platforms
- **Full control needed** - Custom Docker setup, SSH access, system packages
- **Multi-service applications** - Auth + API + Database + Frontend on one server
- **Learning/prototyping** - Production-like environment for experiments

### ❌ Consider Alternatives When

- **Large-scale applications** - 10k+ users → Kubernetes, AWS ECS, Azure
- **Global distribution** - Multi-region → CDN + cloud providers
- **No DevOps experience** - Platform-as-a-Service easier (Heroku, Render, Fly.io)
- **Managed database needed** - Separate DB hosting (AWS RDS, PlanetScale)
- **Auto-scaling required** - Cloud platforms better

### VPS Providers

| Provider | Price/Month | Best For |
|----------|-------------|----------|
| **Hostinger** | $5-20 | Docker UI built-in, beginners |
| **DigitalOcean** | $6-24 | Excellent docs, community |
| **Linode** (Akamai) | $5-20 | Good performance, support |
| **Hetzner** | €4-15 | Best price/performance (EU) |
| **Vultr** | $6-24 | Many regions, good network |

**Key insight:** VPS gives production experience without cloud complexity. Perfect for indie developers and small teams.

---

## Essential Configuration

### Deployment Architecture

```
Developer → GitHub → GitHub Actions → GHCR → VPS

1. Write code, push to GitHub main
2. GitHub Actions builds Docker images
3. Images pushed to GHCR (private registry)
4. SSH to VPS, pull latest images, restart containers
```

### VPS Specifications

**Minimum (small app):**
- 1 vCPU
- 2 GB RAM
- 50 GB SSD
- Public IP + domain

**Recommended (multi-service):**
- 2 vCPU
- 4 GB RAM
- 80 GB SSD
- Backups enabled

---

## Minimal Working Examples

### 1. Initial VPS Setup

**One-time configuration:**

```bash
# 1. SSH into VPS
ssh root@your-vps-ip

# 2. Update system
apt update && apt upgrade -y

# 3. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 4. Verify installation
docker --version         # 24.0+
docker compose version   # 2.20+

# 5. Create non-root user (security)
adduser deploy
usermod -aG docker deploy
usermod -aG sudo deploy

# 6. Switch to deploy user
su - deploy
```

### 2. Authenticate to GHCR

**Allow VPS to pull private images:**

```bash
# 1. Create GitHub Personal Access Token
# GitHub → Settings → Developer settings → Personal access tokens
# Permissions: read:packages

# 2. Log in to GHCR on VPS
echo $YOUR_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

# 3. Verify login
docker pull ghcr.io/yourorg/yourapp/api:main
```

**Credentials stored in:** `~/.docker/config.json`

### 3. Deploy with Docker Compose

**Clone repository or copy compose file:**

```bash
# Option 1: Clone repo (if public or using deploy keys)
git clone https://github.com/yourorg/yourapp.git
cd yourapp/deploy/prod

# Option 2: Copy compose file only
scp docker-compose.prod.yml deploy@vps:/home/deploy/app/
```

**docker-compose.prod.yml:**
```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.11
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_certs:/letsencrypt
    command:
      - --configFile=/traefik.yml
    networks:
      - traefik

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - private

  api:
    image: ghcr.io/yourorg/yourapp/api:main
    pull_policy: always  # Always pull latest
    restart: unless-stopped
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - postgres
    networks:
      - traefik
      - private

  webui:
    image: ghcr.io/yourorg/yourapp/webui:main
    pull_policy: always
    restart: unless-stopped
    labels:
      - traefik.enable=true
      - traefik.http.routers.webui.rule=Host(`app.example.com`)
      - traefik.http.routers.webui.entrypoints=websecure
      - traefik.http.routers.webui.tls.certresolver=letsencrypt
    networks:
      - traefik

volumes:
  traefik_certs:
  postgres_data:

networks:
  traefik:
  private:
```

**Start services:**
```bash
docker compose -f docker-compose.prod.yml up -d
```

### 4. Update Deployment

**Pull latest images and restart:**

```bash
# 1. Pull latest images from GHCR
docker compose -f docker-compose.prod.yml pull

# 2. Recreate containers with new images
docker compose -f docker-compose.prod.yml up -d

# 3. View logs
docker compose -f docker-compose.prod.yml logs -f
```

**Alternative (faster):**
```bash
# One command: pull + up
docker compose -f docker-compose.prod.yml up -d --pull always
```

### 5. Automated Deployment Script

**deploy.sh:**
```bash
#!/bin/bash
set -e

echo "🚀 Deploying to production..."

# Pull latest images
docker compose -f docker-compose.prod.yml pull

# Recreate containers
docker compose -f docker-compose.prod.yml up -d

# Remove old images
docker image prune -f

echo "✅ Deployment complete!"
```

**Run:**
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Common Operations

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs api -f

# Last 100 lines
docker compose logs api --tail 100
```

### Restart Service

```bash
# Restart specific service
docker compose restart api

# Restart all services
docker compose restart
```

### Database Backup

```bash
# Backup PostgreSQL
docker exec postgres pg_dumpall -U postgres > backup-$(date +%Y%m%d).sql

# Restore backup
cat backup-20260307.sql | docker exec -i postgres psql -U postgres
```

### Check Disk Space

```bash
# Disk usage
df -h

# Docker space usage
docker system df

# Clean up unused resources
docker system prune -a --volumes  # WARNING: removes stopped containers
```

### SSL Certificate Check

```bash
# Check certificate expiry
echo | openssl s_client -connect app.example.com:443 2>/dev/null | openssl x509 -noout -dates

# Traefik handles renewal automatically (Let's Encrypt)
```

---

## Top 5 Gotchas

### 1. GHCR Authentication Expires ⚠️

```bash
# Symptom: "pull access denied"
docker compose pull
# Error: denied: permission_denied

# Fix: Re-authenticate
echo $GITHUB_TOKEN | docker login ghcr.io -u username --password-stdin
```

**Impact:** Can't pull new images, deployment fails.

**Permanent fix:** Use GitHub App tokens (no expiration).

### 2. Port 80/443 Already in Use

```bash
# Error: "bind: address already in use"

# Check what's using ports
sudo netstat -tuln | grep ':80\|:443'

# Kill conflicting service
sudo systemctl stop apache2
sudo systemctl stop nginx
```

**Impact:** Traefik won't start, no HTTPS.

### 3. DNS Not Pointing to VPS

```bash
# Check DNS resolution
dig app.example.com +short
# Should return: your-vps-ip

# If not, update DNS A records at domain registrar
# Wait 5-60 minutes for propagation
```

**Impact:** Let's Encrypt can't verify domain, no TLS certificate.

### 4. Firewall Blocking Ports

```bash
# Check firewall (UFW on Ubuntu)
sudo ufw status

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

**Impact:** Can't access website, TLS verification fails.

### 5. Out of Disk Space

```bash
# Check disk space
df -h
# /dev/vda1  78%   (high!)

# Clean up Docker
docker system prune -a  # Remove unused images/containers

# Delete old backups
rm /home/deploy/backup-*.sql

# Increase VPS disk size (via provider control panel)
```

**Impact:** Database writes fail, services crash.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Pull access denied | GHCR auth expired | Re-authenticate with token |
| Can't access website | DNS not set | Point A record to VPS IP |
| Port already in use | Nginx/Apache running | Stop conflicting service |
| No HTTPS | DNS wrong, firewall | Check DNS, allow ports 80/443 |
| Out of disk | Too many images/logs | Run `docker system prune -a` |

---

## Security Checklist

**Before production:**

- [ ] Firewall enabled (UFW)
- [ ] SSH key authentication (disable password)
- [ ] Non-root user for deployment
- [ ] Secrets in .env file (not in compose file)
- [ ] Regular backups enabled
- [ ] HTTPS with valid certificate
- [ ] Fail2ban installed (SSH brute-force protection)

---

## References

📎 **Reference**: [vps-deployment-reference.md](vps-deployment-reference.md)  
**When to load**: SSH key setup, automated deployment workflows, monitoring (Prometheus, Grafana), backup strategies, security hardening, scaling strategies (~500 lines)

📎 **Related patterns**:
- [docker-compose-overview.md](docker-compose-overview.md) - Multi-service orchestration
- [traefik-overview.md](traefik-overview.md) - HTTPS and routing
- [github-actions-overview.md](github-actions-overview.md) - Automated builds
- [environment-config-overview.md](environment-config-overview.md) - Managing secrets

---

**Pattern Type:** Production Deployment  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
