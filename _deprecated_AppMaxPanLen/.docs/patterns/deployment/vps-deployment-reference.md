# VPS Deployment Patterns

**Pattern Type:** Production Deployment  
**Best For:** Small-to-medium applications, cost-effective hosting  
**Source:** Enterprise application (Hostinger VPS)  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

VPS (Virtual Private Server) deployment patterns for Docker-based applications. Covers container registry authentication, deployment workflows, update strategies, and troubleshooting for single-server deployments.

**Key Characteristics:**
- Single-server deployment (all services on one VPS)
- Private container registry (GHCR) authentication
- Docker-based orchestration (Docker Compose or UI)
- Automated builds (GitHub Actions) + manual deployments
- Cost-effective for small-medium workloads

---

## When to Use

### ✅ Use VPS Deployment For:
- **Small-to-medium applications** (< 10k users)
- **Cost-sensitive projects** ($5-30/month vs $50-200 for managed platforms)
- **Full control needed** (custom Docker setup, SSH access)
- **Multi-service applications** (auth, API, database, frontend)
- **Learning/prototyping** (production-like environment)

### ❌ Consider Alternatives When:
- **Large-scale applications** (10k+ users) → Kubernetes, AWS ECS
- **Global distribution needed** → CDN + multi-region deployment
- **Managed services preferred** (Heroku, Render, Fly.io)
- **No DevOps experience** → Platform-as-a-Service easier

**VPS Providers:**
- **Hostinger**: $5-20/month, Docker UI built-in
- **DigitalOcean**: $6-24/month, excellent docs
- **Linode/Akamai**: $5-20/month, good performance
- **Hetzner**: €4-15/month, best price/performance (EU)
- **Vultr**: $6-24/month, many locations

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────┐
│           Local Development                     │
│  - Write code                                   │
│  - Push to GitHub main branch                  │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│         GitHub Actions (CI/CD)                  │
│  - Triggered on push to main                   │
│  - Build Docker images                         │
│  - Push to GHCR (private registry)             │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│   GitHub Container Registry (GHCR)              │
│  - ghcr.io/user/app/auth:main                  │
│  - ghcr.io/user/app/api:main                   │
│  - ghcr.io/user/app/webui:main                 │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│           VPS Server                            │
│  - Docker authenticated to GHCR                │
│  - Pull latest images                          │
│  - Recreate/restart containers                 │
│                                                 │
│  Services:                                     │
│  ├── Traefik (reverse proxy, TLS)             │
│  ├── Postgres (database)                      │
│  ├── Auth service                              │
│  ├── API service                               │
│  └── WebUI service                             │
└─────────────────────────────────────────────────┘
```

---

## One-Time VPS Setup

### 1. Initial Server Configuration

**SSH into VPS:**
```bash
ssh root@your-vps-ip
```

**Update system:**
```bash
apt update && apt upgrade -y
```

**Install Docker:**
```bash
# Official Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Verify installation
docker --version
docker compose version
```

**Create non-root user (security):**
```bash
# Create user
adduser deploy
usermod -aG docker deploy  # Add to docker group
usermod -aG sudo deploy    # Add to sudo group

# Switch to user
su - deploy
```

**Configure firewall:**
```bash
# Allow SSH, HTTP, HTTPS
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

---

### 2. Authenticate to Private Container Registry (GHCR)

**Create GitHub Personal Access Token (PAT):**

1. Go to: https://github.com/settings/tokens/new
2. Settings:
   - **Note**: "VPS GHCR Access"
   - **Expiration**: No expiration (or 90 days)
   - **Scopes**: ✅ `read:packages`
3. Click "Generate token"
4. **Copy the token** (starts with `ghp_...`)

**Login to GHCR on VPS:**
```bash
docker login ghcr.io -u yourusername
# Password: paste GitHub PAT
# Login Succeeded ✓
```

**Verify authentication:**
```bash
docker pull ghcr.io/yourusername/yourapp/auth:main
# Should download successfully
```

✅ **This only needs to be done once.** Docker stores credentials in `~/.docker/config.json`

---

### 3. Deploy Application Files

**Transfer compose files to VPS:**

**Option A: Git clone (recommended):**
```bash
# On VPS
git clone https://github.com/yourusername/yourapp.git
cd yourapp
```

**Option B: SCP (manual transfer):**
```bash
# From local machine
scp -r deploy/ root@your-vps-ip:/opt/yourapp/
```

**Create `.env` file:**
```bash
cd /opt/yourapp/deploy/prod
nano .env
```

**Example `.env`:**
```bash
# Database
DATABASE_URL=postgresql://app_root:SecurePassword@postgres:5432/app_db

# Secrets (generate with: openssl rand -base64 32)
JWT_SECRET=your-generated-jwt-secret-here
OAUTH_ENCRYPTION_KEY=your-generated-encryption-key-here
SERVICE_SECRET=your-generated-service-secret-here

# Traefik
TRAEFIK_EMAIL=admin@yourdomain.com
TRAEFIK_NETWORK=traefik
UI_HOST=app.yourdomain.com

# Service Configuration
AUTH_PUBLIC=false
UI_ENTRYPOINTS=websecure
TRAEFIK_CERT_RESOLVER=letsencrypt
```

**Secure `.env` file:**
```bash
chmod 600 .env           # Only owner can read/write
chown deploy:deploy .env
```

---

## Deployment Methods

### Method 1: Docker UI (Hostinger, Easiest)

**Best for:** Hostinger VPS, visual interface preferred

**Initial setup:**
1. Navigate to Hostinger Docker Manager (VPS dashboard → Docker)
2. Upload compose file via UI or link to GitHub repo
3. Set environment variables in UI panel
4. Click "Deploy" or "Start"

**Update workflow (after GitHub Actions builds new image):**
1. Go to Hostinger Docker Manager
2. Select service (auth, api, webui)
3. Click **"Recreate"** or **"Update"**
   - Automatically pulls latest image
   - Stops old container
   - Starts new container with updated code
4. Check logs for errors

**Pros:**
- ✅ Visual interface (beginner-friendly)
- ✅ Built-in log viewer
- ✅ Easy environment variable management
- ✅ One-click recreate

**Cons:**
- ❌ Hostinger-specific (not portable)
- ❌ Limited to supported VPS providers

---

### Method 2: Docker Compose CLI (Universal)

**Best for:** Any VPS, scriptable deployments, automation

**Start services:**
```bash
cd /opt/yourapp/deploy/prod
docker compose up -d
```

**Update services (after new image pushed):**
```bash
cd /opt/yourapp/deploy/prod

# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d

# Or: restart specific service
docker compose up -d --force-recreate auth
```

**Stop services:**
```bash
docker compose down         # Stop and remove containers
docker compose down -v      # Also remove volumes (⚠️ deletes data)
```

**View logs:**
```bash
docker compose logs -f              # All services
docker compose logs -f auth         # Specific service
docker compose logs --tail 100 api  # Last 100 lines
```

**Pros:**
- ✅ Works on any VPS
- ✅ Scriptable (automation friendly)
- ✅ Portable (same commands everywhere)
- ✅ Industry standard

**Cons:**
- ❌ Terminal-only (no UI)
- ❌ Manual pull + restart required

---

### Method 3: Automated Deployment Script

**Best for:** Frequent deployments, CI/CD pipelines

**Create deployment script (`deploy.sh`):**
```bash
#!/bin/bash
set -e  # Exit on error

echo "🚀 Deploying application..."

# Pull latest code
cd /opt/yourapp
git pull origin main

# Pull latest images
cd deploy/prod
docker compose pull

# Recreate services with new images
docker compose up -d --force-recreate

# Health check
sleep 10
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Deployment successful!"
else
    echo "❌ Health check failed!"
    exit 1
fi
```

**Make executable:**
```bash
chmod +x deploy.sh
```

**Run deployment:**
```bash
./deploy.sh
```

**Or: Trigger from GitHub Actions (advanced):**
```yaml
# .github/workflows/deploy.yml
- name: Deploy to VPS
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.VPS_HOST }}
    username: deploy
    key: ${{ secrets.VPS_SSH_KEY }}
    script: |
      cd /opt/yourapp
      ./deploy.sh
```

---

## Health Checks and Monitoring

### Built-in Health Endpoints

**Expose health checks in each service:**
```python
# Python FastAPI
@app.get("/auth/health")
async def health():
    return {"status": "healthy", "service": "auth", "version": "0.2.11"}

@app.get("/auth/db/health")
async def db_health():
    try:
        await db.execute("SELECT 1")
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}
```

**Test health checks:**
```bash
# From VPS
curl http://localhost:8000/auth/health
curl http://localhost:8000/api/health

# From outside (via Traefik)
curl https://app.yourdomain.com/api/health
```

### Monitor with Uptime Kuma (Optional)

**Deploy monitoring dashboard:**
```bash
docker run -d --restart=always \
  --name uptime-kuma \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  louislam/uptime-kuma:1
```

**Access:** http://your-vps-ip:3001

**Add monitors:**
- Auth health: http://auth:8000/auth/health
- API health: http://api:8000/api/health
- Database health: http://auth:8000/auth/db/health

---

## Troubleshooting

### Service Won't Start

**Check logs:**
```bash
docker logs auth --tail 100
docker logs api --tail 100 -f  # Follow logs
```

**Common issues:**
- ❌ **Missing environment variable**: Check `.env` file
- ❌ **Database connection failed**: Verify `DATABASE_URL`
- ❌ **Port conflict**: Another service using same port
- ❌ **Image pull failed**: Re-authenticate to GHCR

**Inspect container:**
```bash
docker inspect auth           # Full container config
docker exec -it auth sh       # Shell into running container
```

---

### "No such image" or "pull access denied"

**Problem:** Docker cannot pull private images from GHCR

**Solution:**
```bash
# Re-authenticate
docker login ghcr.io -u yourusername
# Paste GitHub PAT

# Verify
docker pull ghcr.io/yourorg/yourapp/auth:main
```

**Check credentials:**
```bash
cat ~/.docker/config.json  # Should show ghcr.io entry
```

---

### Service Crashes After Update

**Problem:** New image has bug, service keeps restarting

**Solution: Rollback to previous image**

**Option A: Use specific tag (SHA)**
```bash
# Find previous working SHA from GitHub Actions
docker pull ghcr.io/yourorg/yourapp/auth:sha-abc123

# Update compose file temporarily
# image: ghcr.io/yourorg/yourapp/auth:sha-abc123

docker compose up -d --force-recreate auth
```

**Option B: Revert git commit**
```bash
git log --oneline  # Find last working commit
git checkout abc123
./deploy.sh
```

---

### High Memory Usage

**Check resource usage:**
```bash
docker stats  # Real-time stats for all containers
```

**Set memory limits (docker-compose.yml):**
```yaml
services:
  api:
    deploy:
      resources:
        limits:
          memory: 1G
```

**Restart to apply:**
```bash
docker compose up -d --force-recreate api
```

---

### Out of Disk Space

**Check disk usage:**
```bash
df -h                        # Overall disk usage
docker system df             # Docker disk usage
```

**Clean up:**
```bash
# Remove unused images
docker image prune -a

# Remove stopped containers
docker container prune

# Remove unused volumes (⚠️ can delete data)
docker volume prune

# Clean everything (⚠️ nuclear option)
docker system prune -a --volumes
```

---

## Security Best Practices

### 1. Use Non-Root User in Containers

**Dockerfile:**
```dockerfile
RUN adduser --disabled-password appuser
USER appuser
CMD ["uvicorn", "app.main:app"]
```

### 2. Keep Secrets Out of Git

**Never commit:**
- ❌ `.env` files with real secrets
- ❌ GitHub PAT tokens
- ❌ Database passwords

**Always:**
- ✅ Use `.env.example` as template
- ✅ Add `.env` to `.gitignore`
- ✅ Generate secrets on VPS directly

### 3. Enable Automatic Security Updates

```bash
# Ubuntu/Debian
apt install unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
```

### 4. Use SSH Key Authentication

**Disable password authentication:**
```bash
# /etc/ssh/sshd_config
PasswordAuthentication no
PubkeyAuthentication yes

# Restart SSH
systemctl restart sshd
```

### 5. Regular Backups

**Backup database:**
```bash
# Inside postgres container
docker exec postgres pg_dump -U app_root app_db > backup_$(date +%F).sql

# Or from host
docker exec postgres pg_dump -U app_root app_db | gzip > backup.sql.gz
```

**Backup volumes:**
```bash
docker run --rm -v pgdata:/data -v $(pwd):/backup \
  alpine tar czf /backup/pgdata-backup.tar.gz /data
```

---

## Common Pitfalls

### ❌ Don't:
- **Run as root** (security risk)
- **Hardcode secrets** in compose files
- **Forget to set restart policy** (containers don't auto-restart)
- **Use `latest` tag in production** (hard to rollback)
- **Expose unnecessary ports** (keep services internal)

### ✅ Do:
- **Use health checks** (ensure services ready before dependents start)
- **Set restart: unless-stopped** (containers auto-restart after crashes)
- **Use private networks** (isolate database from public internet)
- **Monitor disk space** (Docker images accumulate over time)
- **Document deployment process** (for team or future you)

---

## Deployment Checklist

**Before first deployment:**
- [ ] VPS created and accessible via SSH
- [ ] Docker and Docker Compose installed
- [ ] Firewall configured (ports 22, 80, 443)
- [ ] GitHub PAT created and GHCR authentication configured
- [ ] `.env` file created with all required secrets
- [ ] Compose files transferred to VPS
- [ ] Traefik network created
- [ ] DNS records pointing to VPS IP

**Routine deployment (after code changes):**
- [ ] Code pushed to main branch
- [ ] GitHub Actions build successful
- [ ] New image available in GHCR
- [ ] Pull latest images on VPS
- [ ] Recreate affected services
- [ ] Verify health checks pass
- [ ] Check logs for errors
- [ ] Test application functionality

---

## Source References

**Extracted from:**
- AI Workflow: `.docs/HowToGuides/deploy-to-hostinger.md` (full deployment process)
- AI Workflow: `deploy/local/docker-compose.local.yml` (compose orchestration)
- AI Workflow: Service compose files (`auth.compose.yml`, `api.compose.yml`)

**Related Patterns:**
- 📎 [Docker Patterns](docker-patterns.md) - Dockerfile optimization
- 📎 [Docker Compose Patterns](docker-compose-patterns.md) - Orchestration
- 📎 [GitHub Actions Patterns](github-actions-patterns.md) - Automated builds
- 📎 [Traefik Patterns](traefik-patterns.md) - Reverse proxy setup

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Enterprise application (Hostinger VPS deployment)
