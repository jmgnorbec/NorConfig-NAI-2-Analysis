# QuickStart: Production Project

**Goal:** Deploy a production-ready application in 2-4 weeks with scalability and reliability.

**Best for:** SaaS products, customer-facing apps, team projects, production deployment

**Reference project:** [AI Workflow Automation](../examples/REFERENCE_PROJECTS.md#2-ai-workflow-automation)

---

## What You'll Build

A production-ready system with:
- Multi-service architecture (optional, start with single)
- PostgreSQL database with migrations
- Docker containerization
- GitHub Actions CI/CD
- VPS deployment with TLS
- Comprehensive testing
- Monitoring and logging

**Time estimate:** 80-160 hours (2-4 weeks)

---

## Prerequisites

**Required:**
- Python 3.12+ with uv
- Node.js 20+ with npm
- Docker Desktop
- Git & GitHub account
- VPS account (Hetzner, DigitalOcean, or similar)
- Domain name (optional but recommended)

**Installation:**
```bash
# Install tools
pip install uv
docker --version
git --version

# Verify
python --version  # 3.12+
node --version    # 20+
docker compose version
```

---

## Architecture Decision

### Start with Single-Service

**Recommend:** Begin with single-service, split later if needed.

**Single-service** (Week 1-2):
```
┌─────────────────────────────────┐
│        Single Container         │
│  ┌──────────┐   ┌────────────┐ │
│  │ FastAPI  │   │   React    │ │
│  │ Backend  │───│  Frontend  │ │
│  └──────────┘   └────────────┘ │
│         │                       │
│    PostgreSQL                   │
└─────────────────────────────────┘
```

**Multi-service** (Week 3-4, if needed):
```
┌──────────┐   ┌─────────┐   ┌─────────┐
│   Auth   │   │   API   │   │  WebUI  │
│ Service  │───│ Service │───│  + BFF  │
└──────────┘   └─────────┘   └─────────┘
      │             │              │
      └─────────────┴──────────────┘
                    │
               PostgreSQL
```

**Decision criteria:**
- Single-service: Team < 5, tight coupling acceptable
- Multi-service: Team > 5, need independent deployments

📎 **Reference:** [multi-service-overview.md](patterns/architecture/multi-service-overview.md)

---

## Step 1: Project Structure (30 minutes)

### Single-Service Structure

```bash
mkdir my-project
cd my-project

# Backend
mkdir -p backend/{app/{routers,services,models},migrations,tests}

# Frontend
mkdir -p frontend/{ui/src/{components,features,lib},bff/src}

# Infrastructure
mkdir -p deploy/{local,production}
mkdir -p .github/workflows
```

### Multi-Service Structure (if needed)

```bash
mkdir my-project
cd my-project

# Services
mkdir -p auth/{app,migrations,tests}
mkdir -p api/{app,migrations,tests}
mkdir -p webui/{ui/src,bff/src}

# Infrastructure
mkdir -p deploy/{local,production}
mkdir -p postgres
mkdir -p .github/workflows
```

For this guide, we'll use **single-service** and show multi-service differences.

---

## Step 2: Database Setup (45 minutes)

### PostgreSQL with Docker Compose

**deploy/local/docker-compose.yml:**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: app_root
      POSTGRES_PASSWORD: dev_password_change_in_prod
      POSTGRES_DB: app_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app_root -d app_db"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

### Start PostgreSQL

```bash
cd deploy/local
docker compose up -d postgres
```

### Create Migrations

**backend/migrations/0001_initial_schema.sql:**
```sql
-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Create items table
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_items_user_id ON items(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to items table
CREATE TRIGGER update_items_updated_at 
    BEFORE UPDATE ON items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### Run Migration

```bash
docker exec -i postgres psql -U app_root -d app_db < backend/migrations/0001_initial_schema.sql
```

📎 **Reference:** [postgresql-overview.md](patterns/database/postgresql-overview.md)

---

## Step 3: Backend with Docker (1-2 hours)

### Create Dockerfile

**backend/Dockerfile** (copy from template):
```dockerfile
# Multi-stage build from templates/docker/Dockerfile.python.template
# Replace placeholders:
# {{ PYTHON_VERSION }} → 3.12
# {{ SERVICE_NAME }} → backend
# {{ PORT }} → 8000
# {{ HEALTH_ENDPOINT }} → health
# {{ START_COMMAND }} → uvicorn
# {{ START_ARGS }} → app.main:app --host 0.0.0.0 --port 8000
```

### Backend Configuration

**backend/app/config.py:**
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://app_root:dev_password@postgres:5432/app_db"
    JWT_SECRET: str = "change-this-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION: int = 3600
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### Database Service Layer

**backend/app/services/database.py:**
```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from ..config import settings

engine = create_engine(settings.DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### Docker Compose for Development

**deploy/local/docker-compose.full.yml:**
```yaml
version: '3.8'

services:
  postgres:
    # ... (same as before)

  backend:
    build:
      context: ../../backend
      dockerfile: Dockerfile
    container_name: backend
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://app_root:dev_password@postgres:5432/app_db
      JWT_SECRET: dev-secret-change-in-prod
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    build:
      context: ../../frontend
      dockerfile: Dockerfile
    container_name: frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### Build and Run

```bash
cd deploy/local
docker compose -f docker-compose.full.yml build
docker compose -f docker-compose.full.yml up -d
```

📎 **Reference:** [docker-overview.md](patterns/deployment/docker-overview.md)

---

## Step 4: CI/CD with GitHub Actions (1 hour)

### Build Workflow

**.github/workflows/build-backend.yml** (copy from template):
```yaml
# Copy from templates/github-actions/build-docker.yml.template
# Replace placeholders:
# {{ REGISTRY }} → ghcr.io
# {{ ORGANIZATION }} → your-github-username
# {{ SERVICE_NAME }} → backend
# {{ SERVICE_DIR }} → backend
```

### Test Workflow

**.github/workflows/test-backend.yml** (copy from template):
```yaml
# Copy from templates/github-actions/test-python.yml.template
# Replace placeholders as needed
```

### Configure GitHub Secrets

In GitHub repository settings → Secrets:
- `VPS_HOST` - Your VPS IP address
- `VPS_USER` - SSH username
- `VPS_SSH_KEY` - Private SSH key
- `DOCKER_TOKEN` - For GHCR if needed

### Push to GitHub

```bash
git init
git add .
git commit -m "feat: initial production setup"
git branch -M main
git remote add origin git@github.com:username/my-project.git
git push -u origin main
```

CI/CD will automatically:
1. Run tests
2. Build Docker images
3. Push to GitHub Container Registry

📎 **Reference:** [github-actions-overview.md](patterns/deployment/github-actions-overview.md)

---

## Step 5: VPS Deployment (2-3 hours)

### Provision VPS

**Recommended providers:**
- Hetzner Cloud (€4.5/month)
- DigitalOcean ($6/month)
- Linode ($5/month)

**Minimum specs:**
- 2 vCPU
- 2GB RAM
- 40GB SSD

### Initial Server Setup

```bash
# SSH into VPS
ssh root@your-vps-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Create app user
useradd -m -s /bin/bash appuser
usermod -aG docker appuser
```

### Setup Deployment Directory

```bash
# On VPS
mkdir -p /opt/myproject
chown -R appuser:appuser /opt/myproject

# Copy docker-compose to VPS
# From local machine:
scp deploy/production/docker-compose.yml appuser@your-vps-ip:/opt/myproject/
```

### Production Docker Compose

**deploy/production/docker-compose.yml:**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal

  backend:
    image: ghcr.io/your-username/backend:latest
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - postgres
    networks:
      - internal
      - web
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.yourdomain.com`)"
      - "traefik.http.routers.backend.tls.certresolver=letsencrypt"

  frontend:
    image: ghcr.io/your-username/frontend:latest
    restart: unless-stopped
    depends_on:
      - backend
    networks:
      - web
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`yourdomain.com`)"
      - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"

  traefik:
    image: traefik:v2.10
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
    networks:
      - web

networks:
  web:
    external: true
  internal:
    driver: bridge

volumes:
  postgres_data:
```

### Traefik Configuration

**deploy/production/traefik.yml:**
```yaml
global:
  sendAnonymousUsage: false

api:
  dashboard: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@example.com
      storage: /acme.json
      httpChallenge:
        entryPoint: web

providers:
  docker:
    exposedByDefault: false
    network: web
```

### Environment Variables

**deploy/production/.env:**
```bash
DB_USER=app_root
DB_PASSWORD=<generate-strong-password>
DB_NAME=app_db
JWT_SECRET=<generate-strong-secret>
```

Generate secrets:
```bash
# JWT Secret
openssl rand -base64 32

# DB Password
openssl rand -base64 24
```

### Deploy

```bash
# On VPS
cd /opt/myproject

# Create network
docker network create web

# Create acme.json for Let's Encrypt
touch acme.json
chmod 600 acme.json

# Pull images
docker compose pull

# Start services
docker compose up -d

# Check logs
docker compose logs -f
```

📎 **Reference:** [vps-overview.md](patterns/deployment/vps-overview.md)

---

## Step 6: Monitoring & Logging (1 hour)

### Health Checks

All services should have health endpoints:

**Backend:**
```python
@app.get("/health")
async def health_check():
    # Check database connection
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db_status = "healthy"
    except:
        db_status = "unhealthy"
    finally:
        db.close()
    
    return {
        "status": "healthy" if db_status == "healthy" else "unhealthy",
        "database": db_status,
    }
```

### Structured Logging

**backend/app/logging_config.py:**
```python
import structlog

def configure_logging():
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.dev.ConsoleRenderer()  # JSON in production
        ],
        wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
        cache_logger_on_first_use=False,
    )
```

### Uptime Monitoring

Use external service:
- UptimeRobot (free tier)
- Pingdom
- StatusCake

Monitor endpoints:
- `https://yourdomain.com/health`
- `https://api.yourdomain.com/health`

---

## Step 7: Testing Strategy (2-3 hours)

### Testing Pyramid: 70/20/10

**Unit Tests (70%):**
- Business logic
- Validators
- Utilities

**Integration Tests (20%):**
- API endpoints
- Database operations

**E2E Tests (10%):**
- Critical user flows
- Authentication
- Data persistence

### Complete Test Suite

**backend/tests/conftest.py:**
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.database import Base, get_db

@pytest.fixture(scope="session")
def test_engine():
    engine = create_engine("postgresql://test:test@localhost:5433/test_db")
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def test_db(test_engine):
    TestingSessionLocal = sessionmaker(bind=test_engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.rollback()
        db.close()

@pytest.fixture
def client(test_db):
    def override_get_db():
        yield test_db
    app.dependency_overrides[get_db] = override_get_db
    return TestClient(app)
```

### Run Tests in CI/CD

Tests run automatically on every push (configured in GitHub Actions).

📎 **Reference:** [testing-pyramid-overview.md](patterns/testing/testing-pyramid-overview.md)

---

## Checklist

- [ ] PostgreSQL running in Docker
- [ ] Migrations applied
- [ ] Backend containerized and running
- [ ] Frontend containerized and running
- [ ] GitHub Actions CI/CD configured
- [ ] VPS provisioned and configured
- [ ] Traefik + TLS certificates working
- [ ] Domain pointing to VPS
- [ ] Health checks monitoring
- [ ] Backup strategy configured
- [ ] All tests passing

---

## Common Issues

### Database Connection Errors

**Problem:** Backend can't connect to PostgreSQL

**Solution:**
- Check `DATABASE_URL` format
- Verify Docker network connectivity: `docker exec backend ping postgres`
- Check PostgreSQL logs: `docker logs postgres`

### TLS Certificate Issues

**Problem:** Let's Encrypt certificate not issued

**Solution:**
- Verify domain DNS points to VPS
- Check `acme.json` permissions: `chmod 600 acme.json`
- Check Traefik logs: `docker logs traefik`

### Performance Issues

**Problem:** Slow response times

**Solution:**
- Add database indexes
- Enable PostgreSQL connection pooling
- Add caching layer (Redis)
- Profile slow queries

---

## Next Steps

### Scaling Considerations

When to split into multi-service:
- Team > 5 developers
- Need independent deployments
- Clear service boundaries emerge

### Adding Features

- **Authentication:** JWT with refresh tokens
- **External APIs:** Adopt hexagonal architecture
- **File uploads:** S3-compatible storage
- **Background jobs:** Celery or similar
- **Caching:** Redis
- **Search:** Elasticsearch or PostgreSQL full-text

### Growth Path

See [ArchitectureGrowthPath.md](ArchitectureGrowthPath.md) for evolution strategies.

---

**Estimated Total Time:** 80-160 hours (2-4 weeks)

**Reference Project:** [AI Workflow Automation](../examples/REFERENCE_PROJECTS.md#2-ai-workflow-automation)

**Pattern Library:** [.docs/patterns/](patterns/)

**Template Version:** 1.0.0
