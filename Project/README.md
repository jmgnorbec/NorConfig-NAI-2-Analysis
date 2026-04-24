# Documentation

Comprehensive documentation for AI Workflow Automation platform.

---

## Folder Organization

```
docs/
├── Architecture/          # System design, patterns, decisions
├── Communication/         # External communication (LinkedIn, posts)
├── ContextEngineering/    # AI agent instruction optimization
├── HowToGuides/          # Step-by-step procedural guides
├── Implementation/        # Feature implementation plans
├── Troubleshooting/      # Debug procedures
└── Archive/              # Superseded documentation
```

---

## How-To Guides (Procedural)

Step-by-step guides for common operational tasks. All guides are in [`HowToGuides/`](HowToGuides/).

| Guide | File | Purpose |
|-------|------|---------|
| **Deploy to Hostinger** | [`deploy-to-hostinger.md`](HowToGuides/deploy-to-hostinger.md) | VPS deployment using GitHub Container Registry and Docker |
| **Integrate n8n Email Workflow** | [`integrate-n8n-email-workflow.md`](HowToGuides/integrate-n8n-email-workflow.md) | Connect n8n to Flovify API for email processing |
| **Verify OAuth Connection** | [`verify-oauth-connection.md`](HowToGuides/verify-oauth-connection.md) | Check MS365/Google OAuth connection status in database |
| **Test Webhook Subscription** | [`test-webhook-subscription.md`](HowToGuides/test-webhook-subscription.md) | Create and verify MS365 webhook subscriptions |
| **Debug Credential Sync** | [`debug-credential-sync.md`](HowToGuides/debug-credential-sync.md) | Troubleshoot "Sync to Local" button failures |
| **Sync Host Credentials to Local** | [`sync-host-credentials-to-local.md`](HowToGuides/sync-host-credentials-to-local.md) | Sync production OAuth credentials to local development |

---

## Architecture

System design, patterns, and architectural decisions.

### Key Documents

| File | Purpose |
|------|---------|
| [`architecture-reference.md`](Architecture/architecture-reference.md) | **PRIMARY** - Hexagonal architecture (Process + Adapters pattern) |
| [`README.md`](Architecture/README.md) | Architecture folder index |

**See**: [`Architecture/README.md`](Architecture/README.md) for complete architecture documentation index.

---

## Context Engineering

AI agent instruction optimization and template infrastructure.

### Key Documents

| File | Purpose |
|------|---------|
| [`_template/`](ContextEngineering/_template/) | **PORTABLE TEMPLATE** - Copy to new projects |
| [`context-engineering.md`](ContextEngineering/context-engineering.md) | Canonical principles (161 lines) |
| [`context-engineering-audit-prompts.md`](ContextEngineering/context-engineering-audit-prompts.md) | 3-phase audit framework |
| [`README.md`](ContextEngineering/README.md) | Complete context engineering guide |

**5-Phase Process**: Brief → Install → Define → Generate → Execute → Maintain

**See**: [`ContextEngineering/README.md`](ContextEngineering/README.md) for complete context engineering documentation.

---

## Communication

External communication artifacts (LinkedIn, social media, portfolio).

### Key Documents

| Folder | Purpose |
|--------|---------|
| [`ProjectDescription/`](Communication/ProjectDescription/) | LinkedIn project section (prompts + output) |
| [`prompt_log.md`](Communication/prompt_log.md) | Development prompt history (1,248 lines) |

**See**: [`Communication/README.md`](Communication/README.md) for workflows and content organization.

---

## Implementation

Feature implementation plans and execution summaries.

### Current Plans

| File | Status | Purpose |
|------|--------|---------|
| [`googlews_implementation_plan.md`](Implementation/googlews_implementation_plan.md) | Active | Google Workspace adapter implementation |

**Note**: Completed implementation plans are archived to [`Archive/Implementation/`](Archive/Implementation/).

---

## Troubleshooting

Debug procedures and troubleshooting guides.

Superseded documentation, completed plans, and historical context.

**Policy**: `Archive/` contains documentation that is no longer active but preserved for reference.

**Index**: [`Archive/ARCHIVE_INDEX.md`](Archive/ARCHIVE_INDEX.md) - Complete archive catalog

**Categories**:
- Architecture (superseded designs)
- Implementation (completed plans)
- Operations (obsolete procedures)
- Context Engineering (old templates)

**See**: [`Archive/ARCHIVE_INDEX.md`](Archive/ARCHIVE_INDEX.md) for complete archive index.

---

## Quick Navigation

### I want to...

| Task | Document |
|------|----------|
| **Deploy to production** | [`HowToGuides/deploy-to-hostinger.md`](HowToGuides/deploy-to-hostinger.md) |
| **Understand architecture** | [`Architecture/architecture-reference.md`](Architecture/architecture-reference.md) |
| **Set up OAuth credentials** | [`auth/AUTH_CONFIGURATION.md`](../auth/AUTH_CONFIGURATION.md) |
| **Integrate with n8n** | [`HowToGuides/integrate-n8n-email-workflow.md`](HowToGuides/integrate-n8n-email-workflow.md) |
| **Sync credentials to local** | [`HowToGuides/sync-host-credentials-to-local.md`](HowToGuides/sync-host-credentials-to-local.md) |
| **Create new project with context engineering** | [`ContextEngineering/_template/`](ContextEngineering/_template/) |
| **Debug OAuth issues** | [`HowToGuides/verify-oauth-connection.md`](HowToGuides/verify-oauth-connection.md) |
| **Find archived docs** | [`Archive/ARCHIVE_INDEX.md`](Archive/ARCHIVE_INDEX.md) |

---

## Related Documentation

- **Service READMEs**: [`auth/README.md`](../auth/README.md), [`api/README.md`](../api/README.md), [`webui/README.md`](../webui/README.md)
- **AI Agent Instructions**: [`.github/copilot-instructions.md`](../.github/copilot-instructions.md)
- **API Design**: [`api/api_design.md`](../api/api_design.md)
- **WebUI Architecture**: [`webui/ARCHITECTURE.md`](../webui/ARCHITECTURE.md)

---

*Last updated: 2026-02-03 | Total folders: 6 (+ Archive) | How-To Guides: 6*
