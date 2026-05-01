# Implementation Planning & Tracking Guide

**Purpose:** Project-agnostic guidance for implementation planning, progress tracking, and commit management.

**Location:** This guide lives in `.docs/Implementation.md` (template repository)  
**Project files:** Implementation plans and tracking go in `docs/Implementation/` (project-specific)

---

## Overview

Implementation tracking uses three document types:

| Document | Purpose | Cadence | Location |
|----------|---------|---------|----------|
| `history.md` | Narrative: decisions, rationale, next steps | Phase boundaries, milestones | `docs/Implementation/` |
| `commit-log.md` | Flat rolling change log | Every file edit | `docs/Implementation/` |
| `[feature].md` | Feature implementation plan | Per feature/initiative | `docs/Implementation/` |

**Key principle:** `history.md` and `commit-log.md` use matching `## Session YYYY-MM-DD` headers to cross-reference.

---

## History File (`history.md`)

### Purpose

Narrative log capturing:
- **Decisions made** and their rationale
- **Context switches** and handoffs
- **Blockers encountered** and resolution paths
- **Next steps** for future sessions
- **Retrospectives** after major milestones

### When to Update

Update `history.md` at:
- Phase boundaries (transition between planning → implementation → validation)
- Major milestones (feature complete, tests passing, deployed)
- Context switches (pausing work, switching features)
- Before long pauses (end of day/week if significant progress)
- After "ready to commit" (via `reflect.prompt.md` retrospective)

### Structure

```markdown
# [Project Name] — History

> **Purpose**: Narrative log of decisions, rationale, and work context. One file per project.  
> **Update when**: Phase boundaries, major milestones, context switches, before long pauses.  
> **Cross-reference**: Use matching `## Session YYYY-MM-DD` headers with `commit-log.md`.

---

## Session YYYY-MM-DD

**Phase:** [Planning|Implementation|Testing|Deployed]  
**Focus:** [Current work focus]

### What Was Done

[Narrative description of progress]

### Decisions Made

1. **[Decision]**: [Rationale]
2. **[Decision]**: [Rationale]

### Blockers / Challenges

- [Challenge encountered and how resolved]

### Next Steps

1. [Next action]
2. [Next action]

### Retrospective

[Added by reflect.prompt.md after "ready to commit"]
- **What worked well**: [Observations]
- **What could improve**: [Observations]
- **Lessons learned**: [Insights]
```

---

## Commit Log File (`commit-log.md`)

### Purpose

Flat, rolling change log where every file edit gets one line. Commit markers delimit batches for semantic commit message generation.

### Trigger Phrases

| Phrase | Action |
|--------|--------|
| `"prepare commit message"` | Find last `--- COMMIT MARKER ---`, read everything after it, synthesize semantic commit message |
| `"ready to commit"` | Append `--- COMMIT MARKER YYYY-MM-DD HH:MM ---` to log (before running git commands) |

### Structure

```markdown
# [Project Name] — Commit Log

> **Purpose**: Flat rolling change log. Every file edit gets one line. Commit markers delimit batches.  
> **Trigger phrases**:  
> — `"prepare commit message"` → find last marker, synthesize commit from entries after it  
> — `"ready to commit"` → append `--- COMMIT MARKER YYYY-MM-DD HH:MM ---`

---

## Session YYYY-MM-DD

### [Work Context / Feature Name]

- Created `path/file.ext` ([brief description])
- Updated `path/file.ext` ([what changed])
- Deleted `path/file.ext` ([why removed])

**Key changes:**
- [Summary point]
- [Summary point]

--- COMMIT MARKER YYYY-MM-DD HH:MM ---

### [Next Work Context]

- Updated `path/file.ext` ([what changed])
- Added tests in `tests/test_feature.py`

--- COMMIT MARKER YYYY-MM-DD HH:MM ---
```

### Usage Pattern

1. **During work**: Add one line per file edit under current session
2. **Before commit**: Say "ready to commit" → marker appended
3. **Git commit**: Say "prepare commit message" → get synthesized message
4. **After commit**: Continue adding entries for next batch

---

## Feature Plans (`[feature].md`)

### When to Create

Create implementation plans for:
- ✅ Multi-day work requiring coordination
- ✅ Breaking changes needing careful rollout
- ✅ Complex features with multiple dependencies
- ✅ Architecture changes affecting multiple components

Skip for:
- ❌ Simple bug fixes (< 1 day)
- ❌ Minor enhancements
- ❌ Routine maintenance

### Plan Template

```markdown
# [Feature Name] - Implementation Plan

**Status:** Planning | In Progress | Complete  
**Created:** YYYY-MM-DD  
**Last Updated:** YYYY-MM-DD

## Goal

[What this feature accomplishes in 1-2 sentences]

## Requirements

- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

---

## Implementation Progress Tracker

**Last Updated:** YYYY-MM-DD  
**Current Phase:** [Phase Number/Name]

### Phase 1: [Phase Name] (X-Y hours)
- [ ] **1.1** [Specific deliverable or task]
- [ ] **1.2** [Specific deliverable or task]

### Phase 2: [Phase Name] (X-Y hours)
- [ ] **2.1** [Specific deliverable or task]
- [ ] **2.2** [Specific deliverable or task]

**Summary:**
- **Total Items:** [Number] tasks
- **Estimated Time:** [Total] hours
- **Completion Target:** [Goal/milestone]

---

## Design

### Architecture Changes
[What needs to change in the system]

### Data Model
[Any database schema changes]

### API Changes
[New or modified endpoints]

## Testing Strategy

- Unit tests: [Coverage targets]
- Integration tests: [What to test]
- Manual testing: [Test cases]

## Rollout Plan

1. Deploy to staging
2. Run smoke tests
3. Deploy to production
4. Monitor metrics

## Archive Criteria

Move to `docs/Archive/Implementation/` when:
- [ ] All tasks complete
- [ ] Tests passing
- [ ] Deployed to production
- [ ] Documentation updated
```

### Progress Tracker Guidelines

**Simple features (1-3 days):**
- Use basic checklist format
- 5-10 tasks total
- No time estimates needed

**Complex features (3+ days):**
- Use numbered sub-tasks (1.1, 1.2, etc.)
- Include time estimates per phase
- Add summary statistics
- Include optional checkpoints for validation

---

## Integration with Development Workflow

### Development Iteration Cycle

**Phase 3: Create Plan**
- Create `docs/Implementation/[feature].md` if complex work
- Use `manage_todo_list` for tracking during active development

**Phase 4: Execute (Iterate)**
- Update `docs/Implementation/commit-log.md` continuously (every file edit)
- Update plan file progress tracker when completing phases
- Update `docs/Implementation/history.md` at phase boundaries
- **Propose commit** after completing each task/subtask

**Phase 5: Validate**
- Update `docs/Implementation/history.md` with validation results

**Phase 6: Conclude**
- Final update to `docs/Implementation/history.md` with outcome
- **Final commit** with "ready to commit" marker
- Archive plan to `docs/Archive/Implementation/` when complete

---

## Commit Message Format (LOW ENTROPY)

**Target:** 3-7 lines (10 lines soft limit)  
**Format:** `[type]([scope]): [description]`

**Types:** feat, fix, docs, refactor, test, chore, perf  
**Scope:** Component or area affected  
**Body:** Only if "why" isn't clear from diff

**Example:**
```
feat(api): add change request approval endpoint

- POST /v1/change-requests/{uid}/approve
- Requires estimator role validation
- Publishes cr.approved Kafka event
```

---

## Quick Reference

**Two required files per project:**
- `docs/Implementation/history.md` - Narrative, decisions, context
- `docs/Implementation/commit-log.md` - Flat change log, commit markers

**Feature plans:**
- `docs/Implementation/[feature].md` - Only for multi-day complex work

**Update triggers:**
- `commit-log.md`: Every file edit (one line)
- `history.md`: Phase boundaries, milestones, before pauses
- `[feature].md`: When completing phases or major tasks

**Commit workflow:**
1. Work → update commit-log.md continuously
2. Say "ready to commit" → marker appended
3. Say "prepare commit message" → get semantic commit message
4. Run git commands with provided message

---

**Guide Version:** 1.0.0  
**Last Updated:** 2026-04-17
