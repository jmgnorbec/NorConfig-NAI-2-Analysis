# Documentation Index

> **🔑 CRITICAL DISTINCTION**  
> **`.docs/` (this directory)** = Project-agnostic templates, patterns, and guidance  
> **`docs/`** = Your actual project-specific documentation  
> 
> This is the **template repository**. Your project documentation lives in `docs/`.

**Purpose:** Central hub for template documentation and guidance for creating project-specific docs.

## Quick Navigation

**Template & Guidance Directories** (in `.docs/`):

| Section | Purpose | When to Read |
|---------|---------|------------|
| [Architecture.md](Architecture.md) | Architecture documentation guide | Creating project architecture docs |
| [ArchitectureGrowthPath.md](ArchitectureGrowthPath.md) | Evolution from MVP to production | Planning architecture transitions |
| [patterns](patterns/) | Reusable patterns library | Adopting new patterns, scaling up |
| [HowToGuides](HowToGuides/) | Step-by-step procedures | Operations, deployment, testing |
| [Implementation.md](Implementation.md) | Implementation planning & tracking guide | Adding features, tracking work |
| [ContextEngineering.md](ContextEngineering.md) | AI instruction optimization guide | Initial setup, context audits |
| [standards](standards/) | Standards (diagrams, code, etc.) | Maintaining consistency |
| [Archive.md](Archive.md) | Archive management guide | Managing completed/obsolete docs |

## Documentation Lifecycle

**For Your Project** (create in `docs/`):

```
1. Requirements → docs/Architecture/brief.md
2. Design → docs/Architecture/architecture-reference.md
3. Implementation Plans → docs/Implementation/*.md
4. How-To Guides → docs/HowToGuides/*.md
5. Completed Work → docs/Archive/* (with ARCHIVE_INDEX.md entry)
```

**Use Templates From** (`.docs/`):
- `.docs/Architecture.md` - Guide for creating architecture docs
- `.docs/Implementation.md` - Guide for implementation planning & tracking
- `.docs/patterns/` - Copy patterns to your project

## For AI Agents

Use the **anchor pattern** when referencing docs:

**Template/Guidance References** (`.docs/`):
```markdown
📎 **Reference**: `.docs/Architecture.md`
**When to load**: Creating architecture documentation
**Key content**: Templates for brief, architecture-reference, ADRs
```

**Project Documentation References** (`docs/`):
```markdown
📎 **Reference**: `docs/Architecture/architecture-reference.md`
**When to load**: Understanding actual project architecture
**Key content**: Project-specific design decisions, layer boundaries
```

**Critical distinction for agents:**
- Load `.docs/` files for **guidance on how to create documentation**
- Load `docs/` files for **actual project-specific information**

## For Developers

**When starting a new project:**

1. Read `.docs/Architecture.md` - Learn how to create architecture docs
2. Run Phase 0 Context Engineering to generate:
   - `docs/Architecture/brief.md` - Your project goals and requirements
   - `docs/Architecture/architecture-reference.md` - Your system design
3. Copy patterns from `.docs/patterns/` as needed
4. Create `docs/HowToGuides/` for your operational procedures

**Remember:**
- `.docs/` = Read-only templates and guidance
- `docs/` = Your editable project documentation

## Archive Policy

**For Project Documentation** (`docs/Archive/`):

Move documentation to `docs/Archive/` when:
- Implementation plans are completed
- Specs are superseded by newer versions
- Historical context but no longer actively referenced

Always update `docs/Archive/ARCHIVE_INDEX.md` when archiving.

---

## Summary

| Directory | Purpose | Editable? |
|-----------|---------|----------|
| **`.docs/`** | Templates, patterns, standards, guidance | No (reference only) |
| **`docs/`** | Your actual project documentation | Yes (your project docs) |

---

**Template Version:** 1.0.0  
**Last Updated:** 2026-04-17
