# Hexagonal Architecture (Process + Adapters) - Overview

**Pattern Type:** Intermediate to Advanced  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Multi-provider integrations, testable business logic, provider flexibility

---

## When to Use Hexagonal Architecture

### ✅ Use Hexagonal For

- **Multi-provider support** - Gmail + Outlook + SendGrid for email
- **Business logic isolation** - Test without external APIs
- **Provider flexibility** - Swap Stripe for PayPal without changing business code
- **Complex workflows** - Orchestrate multiple external systems
- **Future-proofing** - Add providers without refactoring core logic
- **Testing requirements** - Mock adapters easily in tests

### ❌ Avoid Hexagonal When

- **Single provider only** - No need for abstraction (YAGNI)
- **Simple CRUD app** - Adds unnecessary complexity
- **MVP/prototype** - Ship fast, refactor later
- **Team unfamiliar with pattern** - Learning curve not worth it
- **Project < 6 months** - Won't add second provider

### Evolution Trigger

**Adopt hexagonal when you experience ONE of these:**

1. **Second provider** - Adding Gmail after implementing Outlook
2. **Business logic tangled with API calls** - Hard to test or change
3. **Mocking pain** - Complex mocks for external APIs in tests
4. **Provider lock-in concerns** - Want flexibility to change vendors

**Don't adopt** just for "clean architecture" - wait until you actually need multi-provider support.

---

## Essential Configuration

### Layer Boundaries

```
HTTP Layer (Routes)
    ↓ inject adapter
Process Layer (Business Logic)
    ↓ uses adapter interface
Adapter Layer (External APIs)
    ↓
External Services (MS365, Google, etc.)
```

**Key principle:** Business logic never knows which provider. Receives adapters, calls methods.

### Directory Structure

```
api/app/
├── routes/
│   ├── processes.py       # Business workflow endpoints
│   └── webhooks.py        # Provider-specific webhooks
│
├── processes/             # PURE BUSINESS LOGIC
│   ├── email_processor.py    # Email analysis
│   ├── quote_handler.py      # Quote processing
│   └── workspace_manager.py  # Workspace creation
│
└── adapters/              # EXTERNAL INTEGRATIONS
    ├── factories.py       # Create connected adapters
    ├── ms365/
    │   ├── mail.py       # MS365 email adapter
    │   └── _o365_auth.py # MS365 auth
    └── googlews/
        ├── mail.py       # Google email adapter
        └── _google_auth.py
```

---

## Minimal Working Examples

### 1. Adapter Interface (Abstract)

**Define common interface all email adapters must implement:**

```python
# adapters/base.py
from abc import ABC, abstractmethod

class EmailAdapter(ABC):
    """Common interface for all email providers"""
    
    @abstractmethod
    async def send_email(self, to: str, subject: str, body: str) -> dict:
        """Send email via provider"""
        pass
    
    @abstractmethod
    async def list_messages(self, folder: str = "inbox", limit: int = 10) -> list:
        """List messages from folder"""
        pass
    
    @abstractmethod
    async def get_message(self, message_id: str) -> dict:
        """Get single message by ID"""
        pass
```

### 2. Provider Adapters (Concrete)

**MS365 adapter:**

```python
# adapters/ms365/mail.py
from adapters.base import EmailAdapter
from adapters.ms365._o365_auth import get_graph_client

class MS365MailAdapter(EmailAdapter):
    def __init__(self, credential_id: str):
        self.credential_id = credential_id
        self.graph_client = None
    
    async def _ensure_authenticated(self):
        if not self.graph_client:
            self.graph_client = await get_graph_client(self.credential_id)
    
    async def send_email(self, to: str, subject: str, body: str) -> dict:
        await self._ensure_authenticated()
        
        message = {
            "subject": subject,
            "body": {"contentType": "HTML", "content": body},
            "toRecipients": [{"emailAddress": {"address": to}}]
        }
        
        result = await self.graph_client.me.send_mail(message)
        return {"provider": "ms365", "message_id": result.id}
    
    async def list_messages(self, folder: str = "inbox", limit: int = 10) -> list:
        await self._ensure_authenticated()
        
        messages = await self.graph_client.me.mail_folders[folder].messages.get(
            top=limit,
            select=["id", "subject", "from", "receivedDateTime"]
        )
        
        # Normalize to common format
        return [
            {
                "id": msg.id,
                "subject": msg.subject,
                "from": msg.sender.email_address.address,
                "date": msg.received_date_time.isoformat(),
                "provider": "ms365"
            }
            for msg in messages.value
        ]
```

**Google adapter (same interface):**

```python
# adapters/googlews/mail.py
from adapters.base import EmailAdapter
from adapters.googlews._google_auth import get_gmail_service

class GoogleMailAdapter(EmailAdapter):
    def __init__(self, credential_id: str):
        self.credential_id = credential_id
        self.gmail_service = None
    
    async def _ensure_authenticated(self):
        if not self.gmail_service:
            self.gmail_service = await get_gmail_service(self.credential_id)
    
    async def send_email(self, to: str, subject: str, body: str) -> dict:
        await self._ensure_authenticated()
        
        message = {
            "raw": base64.urlsafe_b64encode(
                f"To: {to}\nSubject: {subject}\n\n{body}".encode()
            ).decode()
        }
        
        result = self.gmail_service.users().messages().send(
            userId="me", body=message
        ).execute()
        
        return {"provider": "google", "message_id": result["id"]}
    
    async def list_messages(self, folder: str = "INBOX", limit: int = 10) -> list:
        await self._ensure_authenticated()
        
        messages = self.gmail_service.users().messages().list(
            userId="me", labelIds=[folder], maxResults=limit
        ).execute()
        
        # Normalize to common format
        return [
            {
                "id": msg["id"],
                "subject": msg["subject"],
                "from": msg["from"],
                "date": msg["internalDate"],
                "provider": "google"
            }
            for msg in messages.get("messages", [])
        ]
```

### 3. Process Layer (Provider-Agnostic)

**Business logic doesn't know about providers:**

```python
# processes/email_processor.py
from adapters.base import EmailAdapter

async def process_inbox_emails(
    mail_adapter: EmailAdapter,  # Could be MS365 or Google
    folder: str = "inbox"
) -> dict:
    """
    Process emails from inbox - works with ANY email provider
    """
    
    # Get recent messages (adapter handles provider details)
    messages = await mail_adapter.list_messages(folder, limit=50)
    
    # Business logic (same for all providers)
    unread_count = 0
    important_count = 0
    
    for msg in messages:
        if msg.get("is_unread"):
            unread_count += 1
        if "urgent" in msg.get("subject", "").lower():
            important_count += 1
            
            # Send notification (same adapter interface)
            await mail_adapter.send_email(
                to="admin@example.com",
                subject=f"Urgent: {msg['subject']}",
                body=f"Urgent email from {msg['from']}"
            )
    
    return {
        "total": len(messages),
        "unread": unread_count,
        "important": important_count,
        "provider": messages[0]["provider"] if messages else None
    }
```

### 4. Endpoint Layer (Creates Connected Adapters)

**Routes create adapters and inject into processes:**

```python
# routes/processes.py
from fastapi import APIRouter, HTTPException
from adapters.factories import create_mail_adapter
from processes.email_processor import process_inbox_emails

router = APIRouter()

@router.post("/api/processes/email/analyze")
async def analyze_emails(
    credential_id: str,
    folder: str = "inbox"
):
    """
    Analyze emails - works with MS365 or Google based on credential_id
    """
    
    # Create connected adapter (system concern - credentials)
    mail_adapter = await create_mail_adapter(credential_id)
    
    # Call business process (pure logic - no credential knowledge)
    result = await process_inbox_emails(mail_adapter, folder)
    
    return result
```

**Adapter factory:**

```python
# adapters/factories.py
from adapters.ms365.mail import MS365MailAdapter
from adapters.googlews.mail import GoogleMailAdapter

async def create_mail_adapter(credential_id: str):
    """
    Create connected mail adapter based on credential type
    """
    
    # Query database for credential
    credential = await get_credential(credential_id)
    
    if credential["provider"] == "ms365":
        return MS365MailAdapter(credential_id)
    elif credential["provider"] == "google":
        return GoogleMailAdapter(credential_id)
    else:
        raise ValueError(f"Unknown provider: {credential['provider']}")
```

### 5. Testing (Mock Adapters)

**Test business logic without external APIs:**

```python
# tests/test_email_processor.py
import pytest
from processes.email_processor import process_inbox_emails
from adapters.base import EmailAdapter

class MockEmailAdapter(EmailAdapter):
    """Fake adapter for testing"""
    
    async def send_email(self, to: str, subject: str, body: str):
        return {"provider": "mock", "message_id": "test-123"}
    
    async def list_messages(self, folder: str = "inbox", limit: int = 10):
        return [
            {
                "id": "1",
                "subject": "URGENT: Meeting",
                "from": "boss@example.com",
                "date": "2026-03-07T10:00:00Z",
                "is_unread": True,
                "provider": "mock"
            },
            {
                "id": "2",
                "subject": "Newsletter",
                "from": "news@example.com",
                "date": "2026-03-07T09:00:00Z",
                "is_unread": False,
                "provider": "mock"
            }
        ]
    
    async def get_message(self, message_id: str):
        return {"id": message_id, "provider": "mock"}

@pytest.mark.asyncio
async def test_process_inbox_identifies_urgent():
    """Test business logic without external APIs"""
    
    adapter = MockEmailAdapter()
    result = await process_inbox_emails(adapter)
    
    assert result["total"] == 2
    assert result["unread"] == 1
    assert result["important"] == 1  # "URGENT" in subject
```

---

## Common Operations

### Add New Provider

**To add SendGrid:**

1. Create adapter:
```python
# adapters/sendgrid/mail.py
class SendGridMailAdapter(EmailAdapter):
    async def send_email(self, to: str, subject: str, body: str):
        # SendGrid-specific implementation
        pass
```

2. Update factory:
```python
# adapters/factories.py
async def create_mail_adapter(credential_id: str):
    credential = await get_credential(credential_id)
    
    if credential["provider"] == "sendgrid":
        return SendGridMailAdapter(credential_id)
    # ... existing providers
```

3. **Business logic unchanged!** All processes work with new provider automatically.

### Switch Providers

```python
# No code changes needed
# Just change credential_id in API call:

# Before (MS365):
POST /api/processes/email/analyze
{"credential_id": "ms365-cred-123"}

# After (Google):
POST /api/processes/email/analyze
{"credential_id": "google-cred-456"}
```

---

## Top 5 Gotchas

### 1. Adapter Doesn't Follow Interface ⚠️

```python
# ❌ Wrong: Missing method from interface
class BadAdapter(EmailAdapter):
    async def send_email(self, to: str, subject: str, body: str):
        pass
    # Missing list_messages() and get_message()!

# ✅ Correct: Implement all interface methods
class GoodAdapter(EmailAdapter):
    async def send_email(self, to: str, subject: str, body: str):
        pass
    async def list_messages(self, folder: str, limit: int):
        pass
    async def get_message(self, message_id: str):
        pass
```

**Impact:** Runtime errors, process calls fail.

### 2. Process Layer Knows About Providers

```python
# ❌ Wrong: Business logic checks provider type
async def process_emails(adapter: EmailAdapter):
    if isinstance(adapter, MS365MailAdapter):
        # MS365-specific logic
        pass
    elif isinstance(adapter, GoogleMailAdapter):
        # Google-specific logic
        pass

# ✅ Correct: Provider-agnostic logic
async def process_emails(adapter: EmailAdapter):
    messages = await adapter.list_messages()
    # Same logic for all providers
```

**Impact:** Defeats purpose of hexagonal architecture.

### 3. Passing Credentials Instead of Adapters

```python
# ❌ Wrong: Process receives credential_id
async def process_emails(credential_id: str):
    # Process layer handling auth (system concern!)
    adapter = await create_mail_adapter(credential_id)

# ✅ Correct: Process receives adapter
async def process_emails(mail_adapter: EmailAdapter):
    # Process layer only knows adapter interface
```

**Impact:** Business logic coupled to credential management.

### 4. Not Normalizing Adapter Output

```python
# ❌ Wrong: Return provider-specific format
async def list_messages(self):
    # MS365 returns different format than Google!
    return raw_graph_api_response

# ✅ Correct: Normalize to common format
async def list_messages(self):
    messages = await self.graph_client.get_messages()
    return [
        {
            "id": msg.id,
            "subject": msg.subject,
            "from": msg.sender.email,
            "date": msg.date.isoformat(),
            "provider": "ms365"
        }
        for msg in messages
    ]
```

**Impact:** Process layer breaks when adding new provider.

### 5. Adapter Factory in Process Layer

```python
# ❌ Wrong: Process creates adapter
async def process_emails(credential_id: str):
    adapter = create_mail_adapter(credential_id)
    # Process shouldn't know about factories!

# ✅ Correct: Endpoint creates adapter
@router.post("/analyze")
async def analyze(credential_id: str):
    adapter = await create_mail_adapter(credential_id)
    result = await process_emails(adapter)
```

**Impact:** Can't test process without database/credentials.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| AttributeError on adapter | Missing interface method | Implement all abstract methods |
| Hard to add provider | Process checks provider type | Make process provider-agnostic |
| Can't test process | Process creates adapters | Inject adapters from endpoint |
| Process breaks with new provider | Output not normalized | Return common format from adapters |
| Process knows about auth | Credentials passed to process | Pass connected adapter instead |

---

## References

📎 **Reference**: [hexagonal-architecture-reference.md](hexagonal-architecture-reference.md)  
**When to load**: Advanced patterns (event-driven, CQRS), migration strategies, testing patterns, real-world examples (~385 lines)

📎 **Related patterns**:
- [single-service-overview.md](single-service-overview.md) - Simpler alternative
- [multi-service-overview.md](multi-service-overview.md) - Service boundaries
- [pytest-overview.md](../testing/pytest-overview.md) - Testing adapters

---

**Pattern Type:** Intermediate to Advanced  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
