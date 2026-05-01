# Context Engineering Guide

**Purpose:** Project-agnostic framework for optimizing AI agent instructions and documentation for maximum effectiveness with minimal token waste.

---

## What is Context Engineering?

Systematic design of documentation so AI agents can find information quickly, understand architecture without loading everything, and make correct decisions with minimal context.

### Core Principles

| Principle | Meaning |
|-----------|---------|
| **Signal density > token count** | Every line must carry value |
| **Structure beats prose** | Tables, lists, diagrams over paragraphs |
| **Dynamic context** | Load what's needed, when needed (not everything upfront) |
| **Anchor pattern** | Tell agents WHEN to load docs |
| **Recursive layering** | Overview → reference at ALL levels |
| **Entropy management** | Combat verbosity, repetition, stale info |

---

## When to Use Context Engineering

### ✅ Use for:
- Multi-month projects with evolving documentation
- Team projects where AI agents are primary interface
- Complex architectures (microservices, hexagonal, multi-provider)
- Projects with >5,000 lines of documentation
- Production systems requiring consistent patterns

### ⚠️ Skip for:
- Solo MVPs (< 1 month)
- Simple single-service apps
- Proof-of-concept projects
- Projects with < 2,000 lines of docs

**Rule of thumb:** If your AI agents struggle to find patterns or make inconsistent decisions, adopt context engineering.

---

## The 5-Phase Process

```
PHASE 0     PHASE 1     PHASE 2      PHASE 3       PHASE 4      PHASE 5
BRIEF   --> INSTALL --> DEFINE   --> GENERATE  --> EXECUTE  --> MAINTAIN
(human)     (copy)      (transform)  (merge)       (develop)    (audit)
```

### Phase 0: Brief (1-2 hours)
Human writes project requirements in `docs/Architecture/brief.md`
- Problem statement, goals, constraints
- Critical use cases (3-5 architecturally significant scenarios)
- Tech stack and architecture pattern selection

### Phase 1: Install (5 min)
Copy context engineering template to `.docs/ContextEngineering/_template/`

### Phase 2: Define (30-60 min)
Transform brief into technical profile (`project-profile.md`)
- Extract architecture specifics, layer boundaries
- Define tech stack, key dependencies
- Document commands, version info

### Phase 3: Generate (15-30 min)
Merge profile + canonical standards → `.github/copilot-instructions.md`
- Auto-populate 80% of placeholders
- Generate project-specific guidance

### Phase 4: Execute (ongoing)
AI-assisted development with generated instructions

### Phase 5: Maintain (quarterly, 2-4 hours)
Audit and optimize context
- Detect context rot
- Archive stale docs
- Update instructions

---

## Key Patterns

### Anchor Pattern (Lazy Loading)

**Problem:** Loading all docs upfront wastes tokens and slows agents.

**Solution:** Tell agents WHEN to load docs, not loading everything by default.

```markdown
📎 **Reference**: `docs/Architecture/architecture-reference.md#section`
**When to load**: [trigger condition]
**Key content**: [what you'll find]
```

**Benefits:**
- Agents know doc exists
- Agents know when it's relevant
- Load only when needed
- Reduces context size by 70-80%

### Recursive Layering

Apply overview → reference pattern at ALL documentation levels:

**Pattern library files:**
- `pattern-overview.md` (~200-300 lines, 2-3 min read) - Decision-making
- `pattern-reference.md` (~5,000+ lines) - Complete implementation details

**Overview structure template:**
```markdown
## When to Use (vs Alternatives)        [40 lines]
## Essential Configuration               [40 lines]
## Minimal Working Example               [60 lines]
## Basic Operations                      [60 lines]
## Top 5 Gotchas                         [40 lines]
## Quick Troubleshooting                 [30 lines]
## 📎 Reference                          [30 lines]
```

**Large reference docs:** Use internal anchors for selective section reading.

**300+ line rule:** Any doc exceeding 300 lines should split into overview + reference.

---

## Context Rot Detection

Watch for warning signs and run Phase 5 audit:

### Early Rot (Weeks 1-4)
- Agents ask same questions repeatedly
- Inconsistent pattern application
- Agents cite outdated file paths
- Multiple sources of truth for same topic

### Advanced Rot (Month 2+)
- Verbose or uncertain agent responses
- Degraded code quality (mixing patterns)
- Hallucinated features or endpoints
- Context overflow warnings from AI tools

### Critical Rot (Month 3+)
- Agents unable to complete basic tasks
- Documentation contradicts codebase
- >5,000 lines of conflicting guidance
- Team bypassing AI agents entirely

**Fix:** Archive stale docs, regenerate instructions, run context audit immediately.

---

## Maintenance Schedule

### Weekly (during active development)
- Check for outdated file paths
- Update `CLAUDE.md`/`AGENTS.md` if new features added
- Verify anchor references still valid

### Monthly
- Review context rot indicators
- Compact verbose documentation
- Archive completed implementation plans

### Quarterly
- Run full context audit (Phase 5)
- Regenerate instructions if profile changed
- Update standards for new patterns discovered
- Review and update anchor references

### Annually
- Major context engineering review
- Update to latest template version
- Team retrospective on AI effectiveness

---

## Implementation Approaches

### Minimal Setup (< 2 hours)
1. Extract universal principles from canonical template
2. Add to `AGENTS.md` and `CLAUDE.md`
3. Use anchor pattern for deep docs
4. Keep docs under 2,000 lines total

**Best for:** Simple projects, quick starts

### Standard Setup (2-3 hours)
1. Run full 5-phase process
2. Generate instructions from project profile
3. Validate with agents
4. Set quarterly audit reminders

**Best for:** Most production projects

### Advanced Setup (4-6 hours)
1. Full 5-phase process
2. Customize standards for tech stack
3. Create project-specific prompts
4. Establish automated audit triggers

**Best for:** Complex, multi-team projects

---

## Quick Reference

**When to adopt:** >5,000 lines of docs, agents struggling with consistency  
**Core patterns:** Anchor pattern (lazy loading) + recursive layering (overview → reference)  
**Maintenance:** Weekly checks, monthly compaction, quarterly audits  
**Context rot fix:** Archive stale docs, regenerate instructions  
**Target metrics:** 70-80% context reduction via anchors, <300 lines per overview  

---

**Guide Version:** 1.0.0  
**Last Updated:** 2026-04-17
