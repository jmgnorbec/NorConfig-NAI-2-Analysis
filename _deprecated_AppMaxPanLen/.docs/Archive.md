# Archive Management Guide

**Purpose:** Project-agnostic guidance for managing archived documentation in your project's `docs/Archive/` directory.

---

## When to Archive

Move documentation from `docs/` to `docs/Archive/` when:

| Scenario | Examples |
|----------|----------|
| **Completed work** | Implementation plans fully deployed, retrospectives finished |
| **Superseded content** | v1 specs replaced by v2, old architecture diagrams |
| **Reversed decisions** | ADRs that were later overturned, abandoned approaches |
| **Obsolete guides** | Procedures for retired tools, deprecated workflows |

**Keep if:** Still actively referenced, contains lessons learned, or provides context for current decisions.

---

## Archive Workflow

### 3-Step Process

1. **Move** file to `docs/Archive/[category]/`
   - Preserve directory structure: `docs/Implementation/feature-x.md` → `docs/Archive/Implementation/feature-x.md`

2. **Update index** in `docs/Archive/ARCHIVE_INDEX.md`
   - Record: filename, date, reason, outcome/replacement

3. **Fix links** pointing to archived doc
   - Update references in active docs
   - Consider if summary belongs in current docs

---

## Directory Structure

**Recommended:**
```
docs/Archive/
├── ARCHIVE_INDEX.md           # Searchable catalog
├── Implementation/            # Completed feature plans
├── Architecture/              # Superseded designs
├── HowToGuides/              # Obsolete procedures
└── ADRs/                     # Reversed decisions
```

**ARCHIVE_INDEX.md template:**
```markdown
# Archive Index

## Archived Documentation

### Implementation Plans
| File | Archived | Reason | Outcome |
|------|----------|--------|---------|
| feature-x.md | 2026-03-15 | Deployed | Live in production v2.1 |

### Architecture
| File | Archived | Reason | Current Version |
|------|----------|--------|-----------------|
| v1-design.md | 2026-02-20 | Superseded | v2-architecture-reference.md |
```

---

## For AI Agents

### Default Behavior

**DO NOT load archives automatically** - they represent historical context, not current truth.

### When to Load Archives

Load `docs/Archive/*` when:
- User explicitly requests historical context
- Researching why a past decision was made
- Understanding project evolution timeline
- Finding precedent for similar work
- Debugging issues related to deprecated features

### Anchor Pattern for Archives

```markdown
📎 **Archive Reference**: `docs/Archive/Implementation/feature-x.md`
**When to load**: Understanding why feature X changed in Q1 2026
**Archived:** 2026-03-15 (Deployed to production)
**Current version**: docs/Architecture/architecture-reference.md#feature-x
```

### Search Commands

**Find archived content:**
```bash
# Text search across archives
grep -r "search_term" docs/Archive/

# List by category
ls docs/Archive/Implementation/

# Find by date range
find docs/Archive/ -name "*.md" -newermt "2026-01-01" ! -newermt "2026-03-01"
```

---

## Best Practices

### Keep Archives Lean

- **Delete** drafts/WIP that never reached completion
- **Consolidate** multiple versions into final version + summary
- **Extract** still-relevant lessons into current docs before archiving

### Maintain Searchability

- **Always update** `ARCHIVE_INDEX.md` when archiving
- **Include context** in index: why archived, what replaced it
- **Preserve structure** so paths remain intuitive

### Reference vs. Keep Active

**Archive if:** Historical record only  
**Keep active if:** Still provides context for current decisions

Example: Keep foundational ADRs active even if old, archive tactical implementation plans after deployment.

---

## Common Mistakes

| Wrong | Right |
|-------|-------|
| Archive file without index entry | Always update `ARCHIVE_INDEX.md` |
| Leave broken links in active docs | Update references when archiving |
| Archive everything old | Keep docs that provide current context |
| No reason/outcome recorded | Document why archived + what replaced it |
| Mix archives with active docs | Clear separation: `docs/` vs `docs/Archive/` |

---

## Quick Reference

**Archive trigger:** Completed, superseded, reversed, or obsolete  
**Workflow:** Move → Index → Fix links  
**AI loading:** Only when explicitly needed for historical context  
**Structure:** Mirror original `docs/` structure in `docs/Archive/`  

---

**Guide Version:** 1.0.0  
**Last Updated:** 2026-04-17
