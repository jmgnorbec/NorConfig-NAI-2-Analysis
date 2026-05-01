# Environment Configuration - Overview

**Pattern Type:** Configuration Management  
**Complexity:** Simple to Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Secrets management, multi-environment deployments

---

## When to Use Environment Configuration

### ✅ Use Environment Variables For

- **Environment-specific settings** - Dev uses SQLite, prod uses PostgreSQL
- **Secrets** - API keys, passwords, JWT secrets, encryption keys
- **Service URLs** - Localhost in dev, domains in prod
- **Feature flags** - Enable/disable features per environment
- **Third-party integrations** - Twilio, SendGrid, OAuth credentials

### ❌ Don't Use Environment Variables For

- **Application logic** - Belongs in code, not config
- **Large datasets** - Use config files or databases
- **Frequent changes** - If it changes hourly, not env var

### vs. Alternatives

| Approach | Pros | Cons |
|----------|------|------|
| **.env files** | Simple, standard, git-safe | Manual sync across envs |
| **Config management** (Vault) | Centralized, audited | Complex setup, overhead |
| **Hardcoded** | Fast, no setup | Insecure, inflexible |

**Key insight:** .env files for dev, environment variables for production, never commit secrets.

---

## Essential Configuration

### Configuration Hierarchy

**Loading order (most specific wins):**

```
1. Hardcoded defaults (in code)
   ↓
2. .env.example (template, committed)
   ↓
3. .env (local overrides, gitignored)
   ↓
4. Docker Compose environment
   ↓
5. Runtime environment variables (highest priority)
```

### .gitignore Setup

**CRITICAL:** Add these to `.gitignore`:

```gitignore
# Environment secrets
.env
.env.local
.env.*.local

# Keep templates
!.env.example
```

### Generate Secrets

**Common secret types:**

```bash
# JWT secret (32+ bytes)
openssl rand -base64 32

# Encryption key (Fernet format for Python)
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# UUID (service secrets)
python -c "import uuid; print(uuid.uuid4())"

# Random password
openssl rand -base64 24
```

---

## Minimal Working Examples

### 1. Template File (.env.example)

**Commit this to git** (no secrets, just structure):

```bash
# .env.example
# Copy to .env and fill in real values

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Auth Secrets (generate with: openssl rand -base64 32)
JWT_SECRET=your-jwt-secret-here
OAUTH_ENCRYPTION_KEY=your-encryption-key-here
SERVICE_SECRET=your-service-secret-here

# Service Configuration
DEBUG=false
SERVICE_PORT=8000
SERVICE_VERSION=0.1.0

# SMTP Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Feature Flags
ENABLE_REGISTRATION=true
ENABLE_EMAIL_NOTIFICATIONS=false
```

**Setup instructions for developers:**
```bash
# Copy template
cp .env.example .env

# Generate secrets
openssl rand -base64 32  # Copy to JWT_SECRET

# Fill in real values
nano .env
```

### 2. Python Configuration Loading

**backend/app/config.py:**
```python
import os
from pathlib import Path

# Load .env file if exists
from dotenv import load_dotenv
load_dotenv()

# Required settings (no default - will raise error)
DATABASE_URL = os.getenv("DATABASE_URL")
JWT_SECRET = os.getenv("JWT_SECRET")

if not DATABASE_URL or not JWT_SECRET:
    raise ValueError("DATABASE_URL and JWT_SECRET must be set")

# Optional settings with defaults
DEBUG = os.getenv("DEBUG", "false").lower() == "true"
SERVICE_PORT = int(os.getenv("SERVICE_PORT", "8000"))
SERVICE_VERSION = os.getenv("SERVICE_VERSION", "0.1.0")

# Optional integrations
SMTP_HOST = os.getenv("SMTP_HOST")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587")) if os.getenv("SMTP_PORT") else None
SMTP_USER = os.getenv("SMTP_USER")
SMTP_PASS = os.getenv("SMTP_PASS")

# Feature flags
ENABLE_REGISTRATION = os.getenv("ENABLE_REGISTRATION", "true").lower() == "true"
```

**Usage in app:**
```python
from app.config import DATABASE_URL, JWT_SECRET, DEBUG

# Use config values
engine = create_engine(DATABASE_URL)
jwt.decode(token, JWT_SECRET)

if DEBUG:
    print("Debug mode enabled")
```

### 3. Docker Compose with .env

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  api:
    image: my-api
    environment:
      # Load from .env file (root directory)
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
      - DEBUG=${DEBUG:-false}  # Default value
    env_file:
      - .env  # Load all variables from file
```

**Run:**
```bash
# Docker Compose automatically loads .env
docker compose up
```

### 4. Environment-Specific Files

**Different configs per environment:**

```
project/
├── .env.example          # Template (committed)
├── .env                  # Local dev (gitignored)
├── .env.test             # Test environment (gitignored)
├── .env.staging          # Staging (gitignored)
└── .env.production       # Production (gitignored)
```

**Load specific environment:**
```bash
# Load test environment
docker compose --env-file .env.test up

# Or set environment in code
from dotenv import load_dotenv
load_dotenv('.env.test')
```

### 5. Secrets in CI/CD (GitHub Actions)

**Store secrets in GitHub Settings → Secrets:**

**Workflow (.github/workflows/deploy.yml):**
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to VPS
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
        run: |
          # Secrets available as environment variables
          echo "Deploying with config..."
```

**Set GitHub secrets:**
```bash
# Via GitHub CLI
gh secret set DATABASE_URL --body "postgresql://..."
gh secret set JWT_SECRET --body "$(openssl rand -base64 32)"

# Or via GitHub UI: Settings → Secrets → New repository secret
```

---

## Common Operations

### Development Setup

```bash
# 1. Copy template
cp .env.example .env

# 2. Generate secrets
echo "JWT_SECRET=$(openssl rand -base64 32)" >> .env
echo "OAUTH_ENCRYPTION_KEY=$(python -c 'from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())')" >> .env

# 3. Edit remaining values
nano .env
```

### Validating Configuration

**Check if all required variables set:**

```python
# config.py
REQUIRED_VARS = ["DATABASE_URL", "JWT_SECRET", "OAUTH_ENCRYPTION_KEY"]

missing = [var for var in REQUIRED_VARS if not os.getenv(var)]
if missing:
    raise ValueError(f"Missing required environment variables: {', '.join(missing)}")
```

### Rotating Secrets

```bash
# 1. Generate new secret
NEW_SECRET=$(openssl rand -base64 32)

# 2. Update .env file
sed -i "s/JWT_SECRET=.*/JWT_SECRET=$NEW_SECRET/" .env

# 3. Restart services
docker compose restart
```

---

## Top 5 Gotchas

### 1. Committing Secrets to Git ⚠️

```bash
# ❌ Wrong: .env in git (SECURITY RISK!)
git add .env  # Contains real secrets!

# ✅ Correct: Only commit template
git add .env.example  # No secrets, just structure
```

**Impact:** Credentials leaked publicly, security breach.

**Recovery if committed:**
```bash
# Remove from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# Rotate ALL secrets immediately
```

### 2. No Defaults for Missing Variables

```python
# ❌ Wrong: Silent failure
DEBUG = os.getenv("DEBUG")  # None if missing

# ✅ Correct: Explicit default or error
DEBUG = os.getenv("DEBUG", "false").lower() == "true"
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL required")
```

**Impact:** App crashes with confusing errors.

### 3. Type Confusion (Strings vs Booleans)

```python
# ❌ Wrong: "false" string is truthy!
DEBUG = os.getenv("DEBUG", "false")
if DEBUG:  # Always True! ("false" is truthy string)
    print("Debug mode")

# ✅ Correct: Parse boolean
DEBUG = os.getenv("DEBUG", "false").lower() == "true"
```

**Impact:** Debug mode always on, security issue.

### 4. Missing .env File (No Error)

```python
# ❌ Wrong: Silent failure if .env missing
from dotenv import load_dotenv
load_dotenv()  # Does nothing if .env doesn't exist

# ✅ Better: Check file exists or validate required vars
if Path(".env").exists():
    load_dotenv()
else:
    print("Warning: .env file not found")

# Always validate required vars
if not os.getenv("DATABASE_URL"):
    raise ValueError("DATABASE_URL required")
```

**Impact:** App uses wrong defaults, production failure.

### 5. Docker Compose Can't Find .env

```yaml
# ❌ Wrong: .env in wrong location
services/
  api/
    docker-compose.yml  # Looking for .env here
.env  # But .env is in root!

# ✅ Correct: Specify env_file path
services:
  api:
    env_file:
      - ../../.env  # Relative path to root .env
```

**Impact:** Variables not loaded, services fail to start.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Secrets committed to git | .env not in .gitignore | Add to .gitignore, rotate secrets |
| Variable is None | No default, .env missing | Add default or validate existence |
| Debug always on | String "false" is truthy | Parse: `.lower() == "true"` |
| TypeError: int() | Port/number as string | Parse: `int(os.getenv(...))` |
| Variables not loaded | .env in wrong location | Use `env_file` with path |

---

## References

📎 **Reference**: [environment-config-reference.md](environment-config-reference.md)  
**When to load**: Advanced patterns (Vault integration, secret rotation, 12-factor app, multi-region config, AWS Secrets Manager), validation schemas (~570 lines)

📎 **Related patterns**:
- [docker-compose-overview.md](docker-compose-overview.md) - Using .env with Compose
- [github-actions-overview.md](github-actions-overview.md) - Secrets in CI/CD
- [vps-deployment-overview.md](vps-deployment-overview.md) - Production env setup

---

**Pattern Type:** Configuration Management  
**Last Updated:** 2026-03-07  
**Complexity:** Simple to Intermediate ⭐⭐⭐☆☆
