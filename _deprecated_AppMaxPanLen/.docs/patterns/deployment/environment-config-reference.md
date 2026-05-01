# Environment Configuration Patterns

**Pattern Type:** Configuration Management  
**Best For:** Secrets management, multi-environment deployments  
**Source:** Enterprise application + Best Practices  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

Environment configuration patterns for managing secrets, environment variables, and configuration across development, staging, and production environments. Covers `.env` files, Docker secrets, GitHub secrets, and secure configuration practices.

**Key Characteristics:**
- Environment-specific configuration (dev, staging, prod)
- Secure secrets management (never commit secrets)
- Hierarchical configuration (defaults → environment → runtime)
- Secret generation and rotation
- Configuration validation

---

## When to Use

### ✅ Use Environment Configuration For:
- **Different environments** (dev uses SQLite, prod uses PostgreSQL)
- **Secrets management** (API keys, database passwords, JWT secrets)
- **Feature flags** (enable/disable features per environment)
- **Service URLs** (localhost in dev, domains in prod)
- **Multi-developer teams** (each developer has own `.env`)

### ❌ Avoid When:
- Configuration never changes (can hardcode)
- Single environment only (but still use for secrets)

---

## Configuration Hierarchy

**Loading order (most specific wins):**

```
1. Hardcoded defaults (in code)
   ↓
2. .env file (committed template: .env.example)
   ↓
3. .env.local (local developer overrides, gitignored)
   ↓
4. Docker compose environment (production)
   ↓
5. Runtime environment variables (highest priority)
```

**Example:**
```python
# app/config.py
import os

# 1. Hardcoded default
DEBUG = os.getenv("DEBUG", "false").lower() == "true"

# 2. No default (must be provided)
DATABASE_URL = os.getenv("DATABASE_URL")  # Raises error if missing
```

---

## .env File Patterns

### 1. Template File (.env.example)

**Commit this to git** (no secrets, just structure):

```bash
# .env.example
# Copy to .env and fill in values

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Auth Secrets (generate with: openssl rand -base64 32)
JWT_SECRET=your-jwt-secret-here
OAUTH_ENCRYPTION_KEY=your-encryption-key-here
SERVICE_SECRET=your-service-secret-here

# Service Configuration
AUTH_PUBLIC=false
SERVICE_SEMVER=0.1.0

# SMTP Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Twilio SMS (optional)
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890

# Traefik (production only)
TRAEFIK_EMAIL=admin@yourdomain.com
TRAEFIK_NETWORK=traefik
UI_HOST=app.yourdomain.com
```

**Instructions for new developers:**
```bash
# Copy template
cp .env.example .env

# Fill in real values
nano .env
```

---

### 2. Actual .env File (Gitignored)

**Never commit this** (contains real secrets):

```bash
# .env (gitignored)
# Development environment

DATABASE_URL=postgresql://app_root:DevPassword123@localhost:5432/app_db_dev

JWT_SECRET=abc123GeneratedSecret456
OAUTH_ENCRYPTION_KEY=xyz789EncryptionKey012
SERVICE_SECRET=def345ServiceSecret678

AUTH_PUBLIC=false
SERVICE_SEMVER=0.1.0-dev

# Local overrides
DEBUG=true
LOG_LEVEL=DEBUG
```

**Add to `.gitignore`:**
```
.env
.env.local
.env.*.local
*.env
```

**Exception:** `.env.example` is committed (template only)

---

### 3. Environment-Specific Files

**Structure:**
```
project/
├── .env.example          # Template (committed)
├── .env                  # Local dev (gitignored)
├── .env.local            # Local overrides (gitignored)
├── deploy/
│   ├── local/
│   │   └── .env.local    # Local docker-compose env
│   ├── staging/
│   │   └── .env.staging  # Staging environment (gitignored)
│   └── prod/
│       └── .env.prod     # Production environment (gitignored)
```

**Load environment-specific file:**
```bash
# Development (loads .env + .env.local)
docker compose --env-file .env.local up

# Staging
docker compose --env-file deploy/staging/.env.staging up

# Production
docker compose --env-file deploy/prod/.env.prod up
```

---

## Secret Generation

### 1. JWT Secret (Random String)

**Generate:**
```bash
# Method 1: OpenSSL (32 bytes = 43 chars base64)
openssl rand -base64 32

# Method 2: Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Method 3: Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

**Example output:**
```
abc123XYZ789RandomSecretString456def==
```

**Use in `.env`:**
```bash
JWT_SECRET=abc123XYZ789RandomSecretString456def==
```

---

### 2. Encryption Key (Fernet Key)

**For encrypting OAuth tokens in database:**

```bash
# Python Fernet key (44 chars base64)
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

**Example output:**
```
XYZ789abc123EncryptionKeyString456==
```

**Use in `.env`:**
```bash
OAUTH_ENCRYPTION_KEY=XYZ789abc123EncryptionKeyString456==
```

---

### 3. Database Password

**Generate strong password:**
```bash
# 24-character random password
openssl rand -base64 24
```

**Example output:**
```
Abc123Xyz789SecurePassword==
```

**Use in `.env`:**
```bash
DATABASE_URL=postgresql://app_root:Abc123Xyz789SecurePassword==@postgres:5432/app_db
```

**Note:** URL-encode special characters (`@`, `:`, `/`, `?`, `#`)

---

## Docker Compose Environment Variables

### 1. Pass from .env File

**docker-compose.yml:**
```yaml
services:
  auth:
    environment:
      # Single variable
      - DATABASE_URL=${DATABASE_URL}
      
      # Multiple variables
      - JWT_SECRET=${JWT_SECRET}
      - OAUTH_ENCRYPTION_KEY=${OAUTH_ENCRYPTION_KEY}
      
      # With default value
      - DEBUG=${DEBUG:-false}
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
```

**Loaded from `.env` in same directory**

---

### 2. Environment File (Alternative)

**docker-compose.yml:**
```yaml
services:
  auth:
    env_file:
      - .env                # Default environment
      - .env.local          # Local overrides (optional)
```

**All variables in `.env` automatically available in container**

**Precedence:**
1. `environment:` in compose file (highest)
2. Last `env_file` listed
3. First `env_file` listed

---

### 3. Inline Environment Block

**For values that never change:**

```yaml
services:
  postgres:
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER: app_root
      POSTGRES_PASSWORD: ${DB_PASSWORD}  # Only secret is variable
```

---

## GitHub Actions Secrets

### 1. Add Secret to Repository

1. Go to: `https://github.com/yourorg/yourrepo/settings/secrets/actions`
2. Click "New repository secret"
3. Add:
   - **Name**: `VPS_SSH_KEY`
   - **Value**: (paste private SSH key)
4. Save

**Common secrets:**
- `VPS_HOST`: Production server IP/domain
- `VPS_SSH_KEY`: SSH private key for deployment
- `DATABASE_URL`: Production database connection
- `JWT_SECRET`: JWT signing secret
- `GHCR_TOKEN`: GitHub Personal Access Token for GHCR

---

### 2. Use Secret in Workflow

**`.github/workflows/deploy.yml`:**
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
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

**Never:**
- ❌ Echo secrets: `echo ${{ secrets.JWT_SECRET }}`
- ❌ Commit secrets to `.github/workflows/*.yml`

**Always:**
- ✅ Use `${{ secrets.SECRET_NAME }}`
- ✅ Secrets are automatically masked in logs

---

### 3. Automatic GITHUB_TOKEN

**No setup needed** (GitHub provides automatically):

```yaml
- name: Login to GHCR
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}  # Automatic, always available
```

**Permissions:**
```yaml
permissions:
  contents: read    # Read code
  packages: write   # Push to GHCR
```

---

## Configuration Validation

### 1. Runtime Validation (Python)

**Fail fast if required config missing:**

```python
# app/config.py
import os
import sys

class Config:
    # Required (no default)
    DATABASE_URL = os.getenv("DATABASE_URL")
    JWT_SECRET = os.getenv("JWT_SECRET")
    OAUTH_ENCRYPTION_KEY = os.getenv("OAUTH_ENCRYPTION_KEY")
    
    # Optional (with defaults)
    DEBUG = os.getenv("DEBUG", "false").lower() == "true"
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    SERVICE_SEMVER = os.getenv("SERVICE_SEMVER", "0.1.0")
    
    @classmethod
    def validate(cls):
        """Validate required configuration"""
        missing = []
        
        if not cls.DATABASE_URL:
            missing.append("DATABASE_URL")
        if not cls.JWT_SECRET:
            missing.append("JWT_SECRET")
        if not cls.OAUTH_ENCRYPTION_KEY:
            missing.append("OAUTH_ENCRYPTION_KEY")
        
        if missing:
            print(f"❌ Missing required environment variables: {', '.join(missing)}")
            sys.exit(1)

# Call on startup
Config.validate()
```

**Or use Pydantic:**
```python
from pydantic import BaseSettings, Field

class Settings(BaseSettings):
    database_url: str  # Required (raises error if missing)
    jwt_secret: str
    oauth_encryption_key: str
    
    debug: bool = False  # Optional with default
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"

settings = Settings()  # Validates on instantiation
```

---

### 2. Startup Health Check

**Check database connection before accepting requests:**

```python
# app/main.py
from fastapi import FastAPI
from app.database import db_service

app = FastAPI()

@app.on_event("startup")
async def startup():
    # Validate database connection
    try:
        await db_service.execute("SELECT 1")
        print("✅ Database connected")
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        raise
```

**Container won't report healthy until startup succeeds**

---

## Multi-Environment Strategy

### Development (.env)
```bash
DATABASE_URL=sqlite:///./dev.db  # SQLite for simplicity
DEBUG=true
LOG_LEVEL=DEBUG
AUTH_PUBLIC=false
```

### Staging (.env.staging)
```bash
DATABASE_URL=postgresql://app_root:StagingPass@staging-db:5432/app_db_staging
DEBUG=false
LOG_LEVEL=INFO
AUTH_PUBLIC=true
AUTH_WEBHOOK_HOST=staging-webhook.example.com
UI_HOST=staging.app.example.com
```

### Production (.env.prod)
```bash
DATABASE_URL=postgresql://app_root:ProdPassword@prod-db:5432/app_db
DEBUG=false
LOG_LEVEL=WARNING
AUTH_PUBLIC=true
AUTH_WEBHOOK_HOST=webhook.example.com
UI_HOST=app.example.com
TRAEFIK_EMAIL=admin@example.com
```

---

## Docker Secrets (Advanced)

**For Docker Swarm or high-security requirements:**

**Create secret:**
```bash
echo "my-jwt-secret" | docker secret create jwt_secret -
```

**Use in compose (Swarm mode):**
```yaml
services:
  auth:
    secrets:
      - jwt_secret
    environment:
      - JWT_SECRET_FILE=/run/secrets/jwt_secret

secrets:
  jwt_secret:
    external: true
```

**Read in application:**
```python
# app/config.py
import os

def read_secret(secret_name):
    secret_file = os.getenv(f"{secret_name.upper()}_FILE")
    if secret_file and os.path.exists(secret_file):
        with open(secret_file) as f:
            return f.read().strip()
    return os.getenv(secret_name.upper())

JWT_SECRET = read_secret("JWT_SECRET")
```

**Note:** Most VPS deployments use `.env` files (simpler than Swarm secrets)

---

## Security Best Practices

### 1. Never Commit Secrets

**Always gitignore:**
```
# .gitignore
.env
.env.local
.env.*.local
*.env
!.env.example
```

**Check for leaked secrets:**
```bash
# Search git history for secrets
git log -p | grep -i "password\|secret\|key"

# Use tools like gitleaks or truffleHog
docker run -v $(pwd):/path trufflesecurity/trufflehog:latest filesystem /path
```

---

### 2. Rotate Secrets Regularly

**JWT Secret rotation:**
1. Generate new secret: `openssl rand -base64 32`
2. Add to `.env`: `JWT_SECRET=new-secret`
3. Restart service: `docker compose restart auth`
4. Old tokens invalidated (users re-login)

**Database password rotation:**
1. Change password in postgres: `ALTER USER app_root WITH PASSWORD 'new-password';`
2. Update `.env`: `DATABASE_URL=postgresql://app_root:new-password@...`
3. Restart services: `docker compose restart auth api`

---

### 3. Principle of Least Privilege

**Only share secrets that are needed:**

```yaml
# Auth needs database + JWT
services:
  auth:
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
      - OAUTH_ENCRYPTION_KEY=${OAUTH_ENCRYPTION_KEY}

# API needs database + service secret (not OAuth key)
  api:
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - SERVICE_SECRET=${SERVICE_SECRET}
      # No JWT_SECRET or OAUTH_ENCRYPTION_KEY
```

---

### 4. Secure File Permissions

**On VPS:**
```bash
# .env file readable only by owner
chmod 600 .env
chown deploy:deploy .env

# Check
ls -la .env
# -rw------- 1 deploy deploy 1234 Mar 7 10:00 .env
```

---

## Configuration Documentation

**Include in project README:**

```markdown
## Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | JWT signing secret (32+ chars) | Generate: `openssl rand -base64 32` |
| `OAUTH_ENCRYPTION_KEY` | Fernet key for OAuth tokens | Generate: `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"` |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `false` | Enable debug mode |
| `LOG_LEVEL` | `INFO` | Logging level: DEBUG, INFO, WARNING, ERROR |
| `AUTH_PUBLIC` | `false` | Expose auth webhook endpoint |

### Setup

1. Copy template: `cp .env.example .env`
2. Generate secrets (see table above)
3. Fill in values in `.env`
4. Never commit `.env` to git
```

---

## Common Pitfalls

### ❌ Don't:
- **Commit `.env` files** with real secrets
- **Use weak secrets** ("password123")
- **Reuse secrets** across environments (dev/prod same secret)
- **Hardcode secrets** in Dockerfiles or code
- **Share secrets** via email or Slack

### ✅ Do:
- **Use `.env.example`** as template (commit this)
- **Generate strong secrets** (32+ random characters)
- **Different secrets per environment** (dev ≠ staging ≠ prod)
- **Pass secrets via environment variables** or Docker secrets
- **Use password managers** for team secret sharing (1Password, Bitwarden)

---

## Debugging Tips

### Check Loaded Environment Variables

**Inside running container:**
```bash
docker exec auth env  # List all environment variables

# Check specific variable
docker exec auth printenv DATABASE_URL

# Or shell into container
docker exec -it auth sh
echo $DATABASE_URL
```

### Validate .env File

**Check syntax (no spaces around `=`):**
```bash
# ❌ Wrong
DATABASE_URL = postgresql://...

# ✅ Correct
DATABASE_URL=postgresql://...
```

**Check for typos:**
```bash
# Typo in variable name
DATABSE_URL=postgresql://...  # Missing 'A'

# Application expects DATABASE_URL (won't find it)
```

### Test Configuration Loading

**Python:**
```python
# test_config.py
from app.config import Config

Config.validate()  # Raises error if missing
print("✅ Configuration valid")
print(f"  DATABASE_URL: {Config.DATABASE_URL[:20]}...")  # Print first 20 chars
print(f"  DEBUG: {Config.DEBUG}")
```

**Run:**
```bash
python test_config.py
```

---

## Source References

**Extracted from:**
- AI Workflow: `.env.example` patterns (not committed, but documented)
- AI Workflow: `auth/auth.compose.yml` (environment variable usage)
- AI Workflow: `.github/workflows/build-auth.yml` (GitHub secrets)

**Related Patterns:**
- 📎 [Docker Compose Patterns](docker-compose-patterns.md) - Loading .env files
- 📎 [GitHub Actions Patterns](github-actions-patterns.md) - GitHub secrets
- 📎 [VPS Deployment Patterns](vps-deployment-patterns.md) - Production .env setup

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Enterprise application + Industry Best Practices
