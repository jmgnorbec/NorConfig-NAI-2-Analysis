# Pattern Library

**Purpose:** Reusable architectural, deployment, testing, frontend, and database patterns extracted from real-world projects.

## Pattern Categories

| Category | Purpose | Common Patterns |
|----------|---------|-----------------|
| [architecture](architecture/) | System design patterns | Single-service, multi-service, hexagonal |
| [deployment](deployment/) | Docker, CI/CD, hosting | Docker patterns, GitHub Actions, VPS |
| [testing](testing/) | Test strategies | Testing pyramid, pytest, Playwright |
| [frontend](frontend/) | React, UI patterns | Component patterns, TanStack Query, BFF |
| [database](database/) | DB setup, migrations | SQLite, PostgreSQL, manual migrations |

## How to Use Patterns

Patterns are **reference documentation** organized by complexity:

**Simple Patterns** - MVP, single developer, SQLite
**Medium Patterns** - Small team, PostgreSQL, basic CI/CD  
**Complex Patterns** - Production, microservices, multi-environment

### Usage Decision Matrix

| Project Stage | Recommended Patterns |
|---------------|---------------------|
| **Week 1 - MVP** | Single-service architecture, SQLite, basic React |
| **Month 1 - Beta** | PostgreSQL, Docker basics, testing pyramid |
| **Month 3 - Growth** | Process+Adapters (if external APIs), GitHub Actions |
| **Month 6+ - Production** | Multi-service (if needed), VPS deployment, monitoring |

## Pattern Format

Each pattern is split into two files following **recursive layering principle**:

### Overview Files (~200-350 lines)
**Purpose**: Quick decision-making and minimal implementation  
**Format**: `{pattern}-overview.md`  
**Read time**: 2-3 minutes  
**Contains**:
- When to use (vs alternatives)
- Essential configuration (minimal settings)
- Minimal working example (copy-paste ready)
- Common operations (core patterns)
- Top 5 gotchas
- Quick troubleshooting
- 📎 Anchor to reference file

### Reference Files (~300-600 lines)
**Purpose**: Comprehensive implementation details  
**Format**: `{pattern}-reference.md`  
**Read time**: 20-30 minutes  
**Contains**:
- Complete configuration options
- All examples and edge cases
- Advanced features
- Performance optimization
- Comprehensive troubleshooting
- Full pattern documentation

**Example**: 
- `sqlite-overview.md` (~280 lines) - Quick start, decide if SQLite fits your needs
- `sqlite-reference.md` (~350 lines) - Complete SQLite implementation with all PRAGMAs, patterns, troubleshooting

### Loading Strategy
- **Load overview first** - When choosing patterns or getting started (always read this)
- **Load reference if needed** - When implementing advanced features or troubleshooting specific issues

## Source Projects

Patterns are extracted from real-world production projects:
- **Simple patterns** - Single-service architecture, SQLite database, React frontend (MVP/startup scale)
- **Complex patterns** - Multi-service hexagonal architecture, production-grade deployments (enterprise scale)

## Pattern Lifecycle

1. **Extract** - Identify pattern in source project
2. **Document** - Create pattern doc with examples
3. **Validate** - Test in template usage
4. **Maintain** - Update as patterns evolve

## For AI Agents

**Context loading strategy** for patterns (recursive layering):

1. **Read overview first** (~3 min) - Always start here
   - Understand when to use vs alternatives
   - Check evolution triggers (when to adopt)
   - See minimal working examples
   - Learn top 5 gotchas

2. **Load reference if needed** (~20-30 min) - Only when implementing
   - Advanced configuration details
   - Edge cases and troubleshooting
   - Migration strategies
   - Real-world examples

3. **Use anchor pattern** for just-in-time loading:

```markdown
📎 **Reference**: [hexagonal-architecture-overview.md](architecture/hexagonal-architecture-overview.md)
**When to load**: Adding external API integrations, multi-provider support
**Key content**: Process + Adapters pattern, normalized interfaces, connected adapters
```

**Don't load all patterns automatically** - they're reference material to apply when specific needs arise.

---

**Pattern Count:** 24 patterns (3 architecture + 6 deployment + 5 testing + 5 frontend + 5 database)  
**Last Updated:** March 7, 2026
