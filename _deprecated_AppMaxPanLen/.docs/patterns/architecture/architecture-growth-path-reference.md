# Architecture Growth Path - Reference

**Overview:** See [ArchitectureGrowthPath.md](../../ArchitectureGrowthPath.md) for stage descriptions and decision triggers.

**Purpose:** Detailed step-by-step migration guides with code examples for evolving your architecture.

---

## Stage 1 → Stage 2 Migration

**Goal:** Transform local MVP into production-ready system with PostgreSQL, Docker, and CI/CD.

**Duration:** 1-2 weeks  
**Complexity:** Medium

---

### Step 1: PostgreSQL Migration (Day 1-2)

#### Update Database Connection

**Before:**
```python
# backend/app/database.py
SQLALCHEMY_DATABASE_URL = "sqlite:///./database/app.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
```

**After:**
```python
# backend/app/database.py
from app.config import settings
engine = create_engine(settings.DATABASE_URL)
```

#### Migration Script

```python
# scripts/migrate_sqlite_to_postgres.py
import sqlite3
import psycopg2
from psycopg2.extras import execute_values

# Read from SQLite
sqlite_conn = sqlite3.connect("./database/app.db")
sqlite_conn.row_factory = sqlite3.Row
cursor = sqlite_conn.cursor()

# Write to PostgreSQL
pg_conn = psycopg2.connect("postgresql://user:password@localhost:5432/app_db")
pg_cursor = pg_conn.cursor()

# Migrate each table
for row in cursor.execute("SELECT * FROM items"):
    pg_cursor.execute(
        "INSERT INTO items (id, name, description, created_at) VALUES (%s, %s, %s, %s)",
        (row['id'], row['name'], row['description'], row['created_at'])
    )

pg_conn.commit()
```

📎 **Pattern:** [postgresql-overview.md](../database/postgresql-overview.md)

---

### Step 2: Dockerize Services (Day 3-4)

#### Create Dockerfiles

**Backend Dockerfile:**
```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY pyproject.toml .
RUN pip install uv && uv pip install -r pyproject.toml

COPY app/ ./app/

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Frontend Dockerfile:**
```dockerfile
# frontend/Dockerfile
FROM node:20 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Docker Compose

```yaml
# deploy/local/docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: app_password
      POSTGRES_DB: app_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ../../backend
    environment:
      DATABASE_URL: postgresql://app_user:app_password@postgres:5432/app_db
    ports:
      - "8000:8000"
    depends_on:
      - postgres

  frontend:
    build: ../../frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

**Test locally:**
```bash
cd deploy/local
docker compose up --build
```

📎 **Pattern:** [docker-overview.md](../deployment/docker-overview.md)

---

### Step 3: Setup CI/CD (Day 5)

#### GitHub Actions Workflow

```yaml
# .github/workflows/backend-ci.yml
name: Backend CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd backend
          pip install uv
          uv pip install -r pyproject.toml
      
      - name: Run tests
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
        run: |
          cd backend
          pytest tests/ -v
      
      - name: Build Docker image
        run: |
          cd backend
          docker build -t myapp-backend:${{ github.sha }} .
```

📎 **Pattern:** [github-actions-overview.md](../deployment/github-actions-overview.md)

---

### Step 4: VPS Deployment (Day 6-7)

#### Remote Docker Compose

```yaml
# deploy/remote/docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  backend:
    image: ghcr.io/yourorg/myapp-backend:latest
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
    restart: unless-stopped

  frontend:
    image: ghcr.io/yourorg/myapp-frontend:latest
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
    depends_on:
      - backend

volumes:
  postgres_data:
```

**Deployment script:**
```bash
#!/bin/bash
# deploy.sh

ssh user@your-vps.com << 'EOF'
  cd /opt/myapp
  docker compose pull
  docker compose up -d
  docker system prune -f
EOF
```

📎 **Guide:** [QuickStart-Production.md](../../QuickStart-Production.md)

---

### Step 5: Monitoring (Day 8)

#### Health Endpoints

```python
# backend/app/routers/health.py
from fastapi import APIRouter
from sqlalchemy import text

router = APIRouter()

@router.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        # Check database connection
        db.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}
```

#### Database Backups

```bash
# scripts/backup-db.sh
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql"

docker exec postgres pg_dump -U app_user app_db > /backups/${BACKUP_FILE}
gzip /backups/${BACKUP_FILE}

# Keep only last 7 days
find /backups -name "backup_*.sql.gz" -mtime +7 -delete
```

---

## Stage 2 → Stage 3 Migration

**Goal:** Split monolith into separate services with independent deployment.

**Duration:** 4-6 weeks  
**Complexity:** High

---

### Step 1: Plan Service Boundaries (Week 1)

#### Identify Separations

**Authentication logic → Auth service:**
- User registration, login, JWT generation
- User profile management
- Password reset

**Business logic → API service:**
- Core domain functionality
- Data processing
- Business rules

**UI rendering → Frontend:**
- React components
- Client-side routing
- State management

#### Design Contracts

```python
# API contract: Auth Service
POST /auth/register
POST /auth/login
POST /auth/verify-token
GET /auth/user/{id}
PATCH /auth/user/{id}

# API contract: API Service
GET /api/items
POST /api/items
GET /api/items/{id}
PATCH /api/items/{id}
DELETE /api/items/{id}
```

---

### Step 2: Extract Auth Service (Week 2-3)

#### Create Auth Service Structure

```
auth/
├── Dockerfile
├── app/
│   ├── main.py
│   ├── database.py
│   ├── models/
│   │   └── user.py
│   ├── routers/
│   │   └── auth.py
│   └── utils/
│       └── jwt.py
└── tests/
```

#### Auth Service Implementation

```python
# auth/app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime, timedelta
import jwt

router = APIRouter()

@router.post("/auth/login")
async def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Generate JWT
    token_data = {
        "sub": str(user.id),
        "email": user.email,
        "exp": datetime.utcnow() + timedelta(hours=24)
    }
    token = jwt.encode(token_data, SECRET_KEY, algorithm="HS256")
    
    return {"access_token": token, "token_type": "bearer"}

@router.post("/auth/verify")
async def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return {"user_id": payload["sub"], "valid": True}
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

---

### Step 3: Update API Service (Week 4)

#### Service-to-Service Communication

```python
# api/app/dependencies.py
import httpx
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer

security = HTTPBearer()

async def get_current_user(token: HTTPAuthorizationCredentials = Depends(security)):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://auth:8000/auth/verify",
            json={"token": token.credentials}
        )
        
        if response.status_code != 200:
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        
        return response.json()

# api/app/routers/items.py
@router.post("/api/items")
async def create_item(
    item: ItemCreate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    new_item = Item(**item.dict(), user_id=current_user["user_id"])
    db.add(new_item)
    db.commit()
    return new_item
```

---

### Step 4: Setup Traefik (Week 5)

#### Traefik Configuration

```yaml
# deploy/docker-compose.yml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"  # Traefik dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped

  auth:
    build: ../auth
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.auth.rule=PathPrefix(`/auth`)"
      - "traefik.http.services.auth.loadbalancer.server.port=8000"
    depends_on:
      - postgres

  api:
    build: ../api
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=PathPrefix(`/api`)"
      - "traefik.http.services.api.loadbalancer.server.port=8000"
    depends_on:
      - postgres
      - auth

  frontend:
    build: ../frontend
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=PathPrefix(`/`)"
      - "traefik.http.services.frontend.loadbalancer.server.port=80"
    depends_on:
      - api

  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: app_password
      POSTGRES_DB: app_db
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

📎 **Pattern:** [traefik-overview.md](../deployment/traefik-overview.md)

---

### Step 5: Testing Strategy (Week 6)

#### Contract Testing

```python
# tests/contract/test_auth_service.py
import pytest
import httpx

@pytest.mark.asyncio
async def test_auth_login_contract():
    """Verify auth service login contract"""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://auth:8000/auth/login",
            json={"email": "test@example.com", "password": "password123"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "token_type" in data
        assert data["token_type"] == "bearer"

@pytest.mark.asyncio
async def test_auth_verify_contract():
    """Verify auth service token verification contract"""
    async with httpx.AsyncClient() as client:
        # Get token first
        login_response = await client.post(
            "http://auth:8000/auth/login",
            json={"email": "test@example.com", "password": "password123"}
        )
        token = login_response.json()["access_token"]
        
        # Verify token
        verify_response = await client.post(
            "http://auth:8000/auth/verify",
            json={"token": token}
        )
        
        assert verify_response.status_code == 200
        data = verify_response.json()
        assert "user_id" in data
        assert "valid" in data
        assert data["valid"] is True
```

📎 **Pattern:** [multi-service-overview.md](../architecture/multi-service-overview.md)

---

## Stage 3 → Stage 4 Migration

**Goal:** Add hexagonal architecture for complex external integrations.

**Duration:** 6-8 weeks  
**Complexity:** High

---

### Step 1: Identify Adapters (Week 1)

#### Map External Dependencies

**Email providers:**
- MS365 Graph API
- Google Gmail API
- SendGrid API

**Design normalized interfaces:**

```python
# api/app/adapters/protocols.py
from typing import Protocol, List

class MailAdapter(Protocol):
    """Normalized interface for email providers"""
    
    async def send(
        self, 
        recipient: str, 
        subject: str, 
        body: str
    ) -> dict:
        """Send email, return status"""
        ...
    
    async def list_messages(
        self, 
        folder: str = "inbox"
    ) -> List[dict]:
        """List messages from folder"""
        ...
    
    async def get_message(
        self, 
        message_id: str
    ) -> dict:
        """Get single message by ID"""
        ...
```

---

### Step 2: Extract Business Logic (Week 2-3)

#### Create Process Layer

```
api/app/processes/
├── __init__.py
├── email.py          # Email workflows
├── document.py       # Document processing
└── notification.py   # Notification logic
```

#### Business Logic Implementation

```python
# api/app/processes/email.py
async def send_notification_email(
    recipient: str,
    body: str,
    mail_adapter: MailAdapter
) -> dict:
    """
    Send notification email using any mail provider.
    Pure business logic - platform-agnostic.
    """
    # Business rules
    if not recipient or "@" not in recipient:
        raise ValueError("Invalid recipient email")
    
    # Format email (business concern)
    subject = "Notification from MyApp"
    formatted_body = f"""
    Hello,
    
    {body}
    
    Best regards,
    MyApp Team
    """
    
    # Delegate to adapter (technical concern)
    result = await mail_adapter.send(recipient, subject, formatted_body)
    
    return {"status": "sent", "recipient": recipient}
```

---

### Step 3: Create Adapters (Week 4-5)

#### MS365 Adapter

```python
# api/app/adapters/ms365/mail.py
from O365 import Account

class MS365MailAdapter:
    """MS365-specific implementation"""
    
    def __init__(self, graph_client: Account):
        self.graph_client = graph_client
        self.mailbox = graph_client.mailbox()
    
    async def send(self, recipient: str, subject: str, body: str) -> dict:
        """Send email via MS365 Graph API"""
        message = self.mailbox.new_message()
        message.to.add(recipient)
        message.subject = subject
        message.body = body
        
        success = message.send()
        
        return {
            "status": "sent" if success else "failed",
            "provider": "ms365",
            "message_id": message.object_id if success else None
        }
    
    async def list_messages(self, folder: str = "inbox") -> List[dict]:
        """List messages from folder"""
        mailbox_folder = self.mailbox.get_folder(folder_name=folder)
        messages = mailbox_folder.get_messages(limit=50)
        
        return [
            {
                "id": msg.object_id,
                "subject": msg.subject,
                "from": msg.sender.address,
                "received": msg.received.isoformat()
            }
            for msg in messages
        ]
    
    async def get_message(self, message_id: str) -> dict:
        """Get single message"""
        message = self.mailbox.get_message(object_id=message_id)
        
        return {
            "id": message.object_id,
            "subject": message.subject,
            "from": message.sender.address,
            "body": message.body,
            "received": message.received.isoformat()
        }
```

#### Google Adapter

```python
# api/app/adapters/google/mail.py
from googleapiclient.discovery import build
import base64

class GoogleMailAdapter:
    """Google-specific implementation"""
    
    def __init__(self, gmail_service):
        self.service = gmail_service
    
    async def send(self, recipient: str, subject: str, body: str) -> dict:
        """Send email via Gmail API"""
        message = {
            'raw': base64.urlsafe_b64encode(
                f"To: {recipient}\r\nSubject: {subject}\r\n\r\n{body}".encode()
            ).decode()
        }
        
        result = self.service.users().messages().send(
            userId='me',
            body=message
        ).execute()
        
        return {
            "status": "sent",
            "provider": "google",
            "message_id": result['id']
        }
    
    async def list_messages(self, folder: str = "inbox") -> List[dict]:
        """List messages from folder"""
        results = self.service.users().messages().list(
            userId='me',
            labelIds=[folder.upper()],
            maxResults=50
        ).execute()
        
        messages = results.get('messages', [])
        
        return [
            {
                "id": msg['id'],
                "thread_id": msg['threadId']
            }
            for msg in messages
        ]
    
    async def get_message(self, message_id: str) -> dict:
        """Get single message"""
        message = self.service.users().messages().get(
            userId='me',
            id=message_id,
            format='full'
        ).execute()
        
        headers = {h['name']: h['value'] for h in message['payload']['headers']}
        
        return {
            "id": message['id'],
            "subject": headers.get('Subject'),
            "from": headers.get('From'),
            "body": message['snippet'],
            "received": message['internalDate']
        }
```

---

### Step 4: Connected Adapter Pattern (Week 6)

#### Adapter Factory

```python
# api/app/routes/email.py
from app.adapters.ms365.mail import MS365MailAdapter
from app.adapters.google.mail import GoogleMailAdapter
from app.processes.email import send_notification_email

async def create_mail_adapter(credential_id: int) -> MailAdapter:
    """
    System concern: create adapter with credentials.
    This is where technical details live (auth, client setup).
    """
    # Fetch credential from database
    credential = await get_credential(credential_id)
    
    if credential.provider == "ms365":
        # MS365-specific authentication
        graph_client = get_graph_client(
            client_id=credential.client_id,
            client_secret=credential.client_secret,
            tenant_id=credential.tenant_id
        )
        return MS365MailAdapter(graph_client)
    
    elif credential.provider == "google":
        # Google-specific authentication
        gmail_client = build_gmail_client(
            credentials=credential.oauth_token
        )
        return GoogleMailAdapter(gmail_client)
    
    else:
        raise ValueError(f"Unknown provider: {credential.provider}")

@router.post("/send-email")
async def send_email_endpoint(request: SendEmailRequest):
    """
    HTTP endpoint - handles system concerns.
    Delegates business logic to process layer.
    """
    # System concern: create connected adapter
    mail_adapter = await create_mail_adapter(request.credential_id)
    
    # Business concern: delegated to process
    result = await send_notification_email(
        recipient=request.recipient,
        body=request.body,
        mail_adapter=mail_adapter
    )
    
    return result
```

📎 **Pattern:** [hexagonal-architecture-overview.md](hexagonal-architecture-overview.md)

---

### Step 5: Testing with Mocks (Week 7-8)

#### Mock Adapter

```python
# tests/unit/test_email_process.py
from unittest.mock import MagicMock, AsyncMock
import pytest
from app.processes.email import send_notification_email
from app.adapters.protocols import MailAdapter

@pytest.fixture
def mock_mail_adapter():
    """Create mock adapter for testing"""
    adapter = MagicMock(spec=MailAdapter)
    adapter.send = AsyncMock(return_value={
        "status": "sent",
        "message_id": "mock-123"
    })
    return adapter

@pytest.mark.asyncio
async def test_send_notification_email(mock_mail_adapter):
    """Test business logic without hitting real APIs"""
    result = await send_notification_email(
        recipient="user@example.com",
        body="Test notification",
        mail_adapter=mock_mail_adapter
    )
    
    # Verify business logic
    assert result["status"] == "sent"
    assert result["recipient"] == "user@example.com"
    
    # Verify adapter was called correctly
    mock_mail_adapter.send.assert_called_once()
    call_args = mock_mail_adapter.send.call_args[1]
    assert call_args["recipient"] == "user@example.com"
    assert "Test notification" in call_args["body"]
    assert "Notification from MyApp" in call_args["subject"]

@pytest.mark.asyncio
async def test_send_notification_email_invalid_recipient(mock_mail_adapter):
    """Test validation in business logic"""
    with pytest.raises(ValueError, match="Invalid recipient"):
        await send_notification_email(
            recipient="invalid",
            body="Test",
            mail_adapter=mock_mail_adapter
        )
    
    # Adapter should not be called
    mock_mail_adapter.send.assert_not_called()
```

---

## Best Practices

### When to Migrate

**Don't migrate early:**
- Premature optimization wastes time
- Adds unnecessary complexity
- Slows development velocity

**Do migrate when:**
- Clear pain points (2-3 triggers per stage)
- Success metrics from previous stage met
- Evidence of need, not speculation

### Migration Strategy

**Incremental approach:**
1. Extract one component at a time
2. Test thoroughly before next extraction
3. Keep old and new running in parallel initially
4. Rollback plan for each step

**Avoid big-bang rewrites:**
- High risk of failure
- Long periods without deployable code
- Hard to debug when problems arise

### Testing During Migration

**Maintain test coverage:**
- Write tests before refactoring
- Keep existing tests passing
- Add integration tests for new boundaries
- Use contract tests between services

---

## Troubleshooting

### Common Migration Issues

**Problem:** Service can't reach other service  
**Solution:** Check Docker network configuration, ensure services are on same network

**Problem:** Database connection fails after migration  
**Solution:** Verify connection string, check firewall rules, ensure database is accessible from new location

**Problem:** Tests failing after hexagonal refactor  
**Solution:** Update test imports, ensure mocks implement correct Protocol, check for circular dependencies

---

**Reference Version:** 1.0.0  
**Last Updated:** 2026-04-17
