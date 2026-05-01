# Hexagonal Architecture (Process + Adapters)

**Pattern Type:** Complex  
**Best For:** Multi-provider integrations, flexible business logic, testable architecture  
**Source:** Enterprise application (hexagonal)  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

Hexagonal architecture (also called Ports and Adapters) separates business logic from external dependencies. The core business processes remain pure and provider-agnostic, while adapters handle all external integrations.

**Key Insight:** Same business process works with ANY provider (MS365, Google, SendGrid, etc.) by swapping adapters.

**Key Characteristics:**
- **Process layer**: Pure business logic, no provider knowledge
- **Adapter layer**: Provider-specific integrations (MS365, Google, etc.)
- **Connected adapters**: Pre-configured with credentials at endpoint layer
- **Dependency injection**: Processes receive adapters, not credentials
- **Normalized interfaces**: All adapters for same service share common interface

---

## When to Use

### ✅ Ideal For:
- **Multi-provider integrations** (Gmail + Outlook, Stripe + PayPal)
- **Business logic isolation** (test without external APIs)
- **Provider flexibility** (swap providers without changing business code)
- **Complex workflows** (orchestrate multiple external systems)
- **Testing requirements** (mock adapters easily)
- **Future-proofing** (add providers without refactoring)

### ❌ Avoid When:
- Single provider only (adds unnecessary complexity)
- Simple CRUD operations
- MVP/prototype phase
- Team unfamiliar with pattern
- Project < 6 months timeline

### When to Adopt (Evolution Trigger)

Adopt hexagonal when you experience ONE of these:

1. **Second provider** - Adding Gmail after starting with Outlook
2. **Business logic tangled with API calls** - Hard to test or understand
3. **Mocking pain** - Complex mocks for external APIs in tests
4. **Provider lock-in concerns** - Want flexibility to change vendors

**Don't adopt** just because it's "better architecture" - wait for real need.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    HTTP Layer                           │
│  ┌─────────────────────────────────────────────┐       │
│  │       Endpoint (FastAPI Route)              │       │
│  │  - Request validation                       │       │
│  │  - Create connected adapter                 │       │
│  │  - Call process with adapter                │       │
│  └──────────────┬──────────────────────────────┘       │
│                 │ inject adapter                        │
│                 ↓                                       │
│  ┌─────────────────────────────────────────────┐       │
│  │       Process Layer (Pure Logic)            │       │
│  │  - Business workflows                       │       │
│  │  - Platform-agnostic                        │       │
│  │  - Receives adapters, not credentials       │       │
│  │  - Example: process_email(), create_quote() │       │
│  └──────────────┬──────────────────────────────┘       │
│                 │ uses adapter interface                │
│                 ↓                                       │
└─────────────────────────────────────────────────────────┘
                  │
         adapter.send_email()
         adapter.list_messages()
                  │
┌─────────────────┴───────────────────────────────────────┐
│              Adapter Layer                              │
│  ┌───────────────────┐    ┌───────────────────┐       │
│  │   MS365 Adapter   │    │  Google Adapter   │       │
│  │  - Graph API      │    │  - Gmail API      │       │
│  │  - OAuth tokens   │    │  - OAuth tokens   │       │
│  │  - Retries        │    │  - Retries        │       │
│  │  - Rate limiting  │    │  - Rate limiting  │       │
│  └────────┬──────────┘    └────────┬──────────┘       │
│           │                         │                   │
└───────────┼─────────────────────────┼───────────────────┘
            │                         │
            ↓                         ↓
   Microsoft Graph API          Google Gmail API
```

---

## Example Structure (AI Workflow)

```
api/app/
├── routes/                    # HTTP endpoints
│   ├── processes.py          # Business workflow routes
│   └── ms365.py              # MS365 webhook routes
│
├── processes/                # PURE BUSINESS LOGIC
│   ├── email_processor.py   # Email analysis workflow
│   ├── quote_handler.py     # Quote processing workflow
│   └── workspace_manager.py # Workspace creation workflow
│
├── adapters/                 # EXTERNAL INTEGRATIONS
│   ├── factories.py         # Create connected adapters
│   ├── ms365/
│   │   ├── mail.py          # MS365 email adapter
│   │   ├── calendar.py      # MS365 calendar adapter
│   │   └── _o365_auth.py    # MS365 authentication
│   ├── googlews/
│   │   ├── mail.py          # Google email adapter
│   │   └── _google_auth.py  # Google authentication
│   └── interfaces/           # Shared adapter contracts
│       └── mail.py           # MailAdapter interface
│
└── services/
    └── database.py           # Database service
```

---

## Key Implementation Patterns

### 1. Connected Adapter Pattern

**Problem:** Processes shouldn't know about credential_ids or authentication.

**Solution:** Create adapters at endpoint layer, pass to processes.

```python
# ❌ WRONG - Process knows about credentials
async def process_email(message_id: str, credential_id: str):
    token = await get_credential_token(credential_id)  # Bad!
    # ... business logic ...

# ✅ RIGHT - Process receives configured adapter
async def process_email(message_id: str, mail_adapter: MailAdapter):
    messages = await mail_adapter.list_messages()  # Clean!
    # ... business logic ...
```

**At endpoint layer:**
```python
# api/app/routes/processes.py
from ..adapters.factories import create_mail_adapter
from ..processes.email_processor import process_email

@router.post(\"/processes/email/analyze\")
async def analyze_email(
    request: EmailAnalysisRequest,
    credential_id: str = Depends(get_current_credential)
):
    # System concern: create adapter with credentials
    mail_adapter = await create_mail_adapter(credential_id)
    
    # Business concern: process with adapter
    result = await process_email(request.message_id, mail_adapter)
    return result
```

### 2. Adapter Interface

**Define common interface all providers must implement:**

```python
# api/app/adapters/interfaces/mail.py
from typing import Protocol, List

class MailAdapter(Protocol):
    \"\"\"Mail adapter interface - all providers must implement.\"\"\"
    
    async def list_messages(
        self,
        folder: str = \"inbox\",
        limit: int = 50
    ) -> List[dict]:
        \"\"\"List messages from folder.\"\"\"
        ...
    
    async def send_email(
        self,
        to: str,
        subject: str,
        body: str
    ) -> dict:
        \"\"\"Send email message.\"\"\"
        ...
    
    async def get_message(self, message_id: str) -> dict:
        \"\"\"Get single message by ID.\"\"\"
        ...
```

### 3. Provider-Specific Adapter

**Implement interface for each provider:**

```python
# api/app/adapters/ms365/mail.py
from ..interfaces.mail import MailAdapter
from ._o365_auth import get_graph_client

class MS365MailAdapter:
    \"\"\"Microsoft 365 mail adapter.\"\"\"
    
    def __init__(self, credential_id: str):
        self.credential_id = credential_id
        self._client = None
    
    async def _get_client(self):
        if not self._client:
            self._client = await get_graph_client(self.credential_id)
        return self._client
    
    async def list_messages(
        self,
        folder: str = \"inbox\",
        limit: int = 50
    ) -> List[dict]:
        client = await self._get_client()
        response = await client.get(
            f\"/me/mailFolders/{folder}/messages\",
            params={
                \"$top\": limit,
                \"$orderby\": \"receivedDateTime desc\"
            }
        )
        # Normalize to common format
        return [self._normalize_message(msg) for msg in response[\"value\"]]
    
    def _normalize_message(self, msg: dict) -> dict:
        \"\"\"Convert MS365 format to common format.\"\"\"
        return {
            \"id\": msg[\"id\"],
            \"subject\": msg[\"subject\"],
            \"from\": msg[\"from\"][\"emailAddress\"][\"address\"],
            \"received_at\": msg[\"receivedDateTime\"],
            \"body\": msg[\"body\"][\"content\"],
        }
    
    async def send_email(self, to: str, subject: str, body: str) -> dict:
        client = await self._get_client()
        response = await client.post(\"/me/sendMail\", json={
            \"message\": {
                \"subject\": subject,
                \"body\": {\"contentType\": \"HTML\", \"content\": body},
                \"toRecipients\": [{\"emailAddress\": {\"address\": to}}]
            }
        })
        return {\"status\": \"sent\", \"message_id\": response.get(\"id\")}
```

### 4. Adapter Factory

**Centralize adapter creation:**

```python
# api/app/adapters/factories.py
from .ms365.mail import MS365MailAdapter
from .googlews.mail import GoogleMailAdapter
from ..services.database import db_service

async def create_mail_adapter(credential_id: str):
    \"\"\"Create appropriate mail adapter based on credential type.\"\"\"
    credential = await db_service.get_credential(credential_id)
    
    if credential[\"provider\"] == \"ms365\":
        return MS365MailAdapter(credential_id)
    elif credential[\"provider\"] == \"google\":
        return GoogleMailAdapter(credential_id)
    else:
        raise ValueError(f\"Unknown provider: {credential['provider']}\")
```

### 5. Pure Process Layer

**Business logic with no provider knowledge:**

```python
# api/app/processes/email_processor.py
from ..adapters.interfaces.mail import MailAdapter

async def process_email(message_id: str, mail_adapter: MailAdapter):
    \"\"\"
    Process email message.
    
    Note: This function works with ANY mail adapter (MS365, Google, etc.).
    No knowledge of credentials or provider-specific APIs.
    \"\"\"
    # Fetch message (works with any adapter)
    message = await mail_adapter.get_message(message_id)
    
    # Business logic
    if \"urgent\" in message[\"subject\"].lower():
        priority = \"high\"
    else:
        priority = \"normal\"
    
    # Extract information
    result = {
        \"priority\": priority,
        \"sender\": message[\"from\"],
        \"summary\": message[\"subject\"],
        \"received\": message[\"received_at\"],
    }
    
    # Trigger follow-up if needed
    if priority == \"high\":
        await mail_adapter.send_email(
            to=\"manager@company.com\",
            subject=f\"Urgent: {message['subject']}\",
            body=\"Requires immediate attention.\"
        )
    
    return result
```

---

## Testing Strategy

### Mock Adapters

**Easy to test processes with fake adapters:**

```python
# tests/test_email_processor.py
import pytest
from app.processes.email_processor import process_email

class MockMailAdapter:
    \"\"\"Test double for mail adapter.\"\"\"
    
    async def get_message(self, message_id: str):
        return {
            \"id\": message_id,
            \"subject\": \"URGENT: Server down\",
            \"from\": \"ops@company.com\",
            \"received_at\": \"2026-03-06T10:00:00Z\",
            \"body\": \"Production server is down\"
        }
    
    async def send_email(self, to: str, subject: str, body: str):
        self.sent_emails = [(to, subject, body)]
        return {\"status\": \"sent\"}

@pytest.mark.asyncio
async def test_urgent_email_triggers_notification():
    mock_adapter = MockMailAdapter()
    
    result = await process_email(\"msg-123\", mock_adapter)
    
    assert result[\"priority\"] == \"high\"
    assert len(mock_adapter.sent_emails) == 1
    assert mock_adapter.sent_emails[0][0] == \"manager@company.com\"
```

---

## Refactoring from Single-Service

### Before (tangled):
```python
async def process_email(message_id: str, credential_id: str):
    # Mixed concerns: auth + business logic
    token = await get_ms365_token(credential_id)
    client = GraphAPIClient(token)
    message = await client.get_message(message_id)
    
    if \"urgent\" in message[\"subject\"]:
        # Can only send via MS365
        await client.send_email(...)
```

### After (hexagonal):
```python
async def process_email(message_id: str, mail_adapter: MailAdapter):
    # Pure business logic
    message = await mail_adapter.get_message(message_id)
    
    if \"urgent\" in message[\"subject\"]:
        # Works with any provider
        await mail_adapter.send_email(...)
```

**Steps to refactor:**
1. Extract MS365-specific code into adapter
2. Define MailAdapter interface
3. Update process to receive adapter
4. Move credential logic to endpoint layer
5. Test with mock adapter

---

## Trade-offs

### Advantages ✅
- **Provider flexibility** - Swap providers without changing business logic
- **Testability** - Mock adapters easily
- **Clarity** - Business logic separated from integration details
- **Extensibility** - Add providers by implementing interface
- **Reusability** - Same process works with any provider

### Disadvantages ❌
- **Complexity** - More files and layers
- **Overhead** - Overkill for single-provider apps
- **Learning curve** - Team needs to understand pattern
- **Boilerplate** - Interfaces and factories add code

---

## When NOT to Use

**Skip hexagonal if:**
- Only ONE provider ever (use direct integration)
- MVP/prototype phase (premature)
- Simple CRUD app with no external integrations
- Team unfamiliar with pattern (training overhead)
- Project timeline < 3 months

**Start simple, refactor to hexagonal when:**
- Adding second provider
- Business logic becomes hard to test
- External API changes frequently
- Need to support multiple providers simultaneously

---

## Source References

**Extracted from:**
- AI Workflow: `.github/copilot-instructions.md` (lines 140-165, Process + Adapters pattern)
- AI Workflow: `api/app/processes/` folder (process implementations)
- AI Workflow: `api/app/adapters/` folder (MS365, Google adapters)
- AI Workflow: `api/app/adapters/factories.py` (adapter creation)
- AI Workflow: `.docs/Architecture/architecture-reference.md` (Complete pattern doc)

**Related Patterns:**
- 📎 [Single-Service Architecture](single-service.md) - Starting point before hexagonal
- 📎 [Multi-Service Architecture](multi-service.md) - Can combine with hexagonal
- 📎 [Testing Patterns](../testing/pytest-patterns.md) - Testing with mocks

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 6, 2026  
**Source Project:** Enterprise application v0.5.5
