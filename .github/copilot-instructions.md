# Development Principles & Preferences

## Documentation Philosophy

### Core Principles

**Concise and highly effective**
- Every document, section, and sentence must earn its place
- Question the value of each piece of documentation: "Do we really need this?"
- Prefer simplicity over completeness when both achieve the goal
- In small projects, less may be better than comprehensive

**Avoid duplication**
- Never duplicate information across documents
- Each document has a distinct, clear purpose
- In small projects with related docs side-by-side, cross-reference instead of repeating
- Code should not appear in both specifications and codebase

**Documents should age well**
- Avoid content that becomes stale quickly (specific code, exact commands, library versions in specs)
- Focus on concepts and patterns that remain valid through refactoring
- Specifications should survive code evolution without requiring updates

### Specification vs Implementation

**Specifications describe WHAT and WHY, not HOW**
- ✅ "Extract unique color values from dataset to populate color list"
- ❌ `const colors = [...new Set(data.map(row => row.color))];`

**Design recommendations belong in specifications**
- ✅ "Use session-level caching for dataset to avoid repeated API calls"
- ✅ "Match row using color, paint, and gage combination"
- ✅ "Construct column key by concatenating profile and finish values"

**Implementation details do NOT belong in specifications**
- ❌ Literal code examples showing exact syntax
- ❌ Specific library usage (e.g., "use Axios.get()")
- ❌ State management implementation code
- ❌ Exact variable names and function signatures

**Rationale:**
- Code may change (refactoring, different libraries, better approaches) while still following the same design pattern
- Literal code creates duplication between specs and codebase
- Specs with code become outdated and misleading when implementation evolves
- Conceptual guidance stays valid regardless of implementation details

### Document Separation of Concerns

**Each document has a specific role:**
- **Architecture docs:** WHY decisions were made, trade-offs, rationale
- **API specs:** Endpoint contracts, data models, technical details (CORS, networking)
- **UI specs:** WHAT the UI does, user interactions, behavior patterns, visual design
- **Development plan:** Implementation phases, timeline, deliverables
- **Code:** The actual HOW

**Anti-patterns:**
- API spec telling frontend HOW to implement logic (belongs in UI spec)
- UI spec containing literal implementation code (belongs in code)
- Multiple docs covering the same information from different angles
- "Frontend Usage" sections in API specs for tiny projects

### Project Size Awareness

**Small internal tools (<10K lines) need:**
- Lean documentation focused on key decisions and patterns
- Cross-references between related docs instead of duplication
- Conceptual guidance, not implementation tutorials
- Question every documentation section's necessity

**Avoid:**
- Over-engineering documentation for simple projects
- Treating a 2-endpoint API like a complex distributed system
- Creating implementation guides when specs + plan are sufficient
- Following "best practices" blindly without considering project scale

---

## Code Principles

### General Philosophy

**Simplicity and clarity**
- Write code that matches the specification's conceptual guidance
- Prefer readable code over clever code
- Code should be self-documenting where possible

**Separation from documentation**
- Code evolves independently from specifications
- Specifications provide design patterns, code implements them
- Refactor freely as long as design intent is preserved

**Small project pragmatism**
- Don't over-engineer for theoretical future requirements
- Solve the immediate problem well
- Internal tools can prioritize simplicity over enterprise patterns

---

## Architecture Principles

### Decision-Making

**Optimize for the actual problem**
- Small datasets (<50KB) favor client-side processing
- Internal tools don't need enterprise-grade security on day 1
- Simple architectures are easier to implement and maintain
- Question conventional patterns when they don't fit the scale

**Example from MaxPanelLength project:**
- Chose full dataset to frontend instead of query API
- Rationale: <50KB data, enables smart filtering, instant results, simpler backend
- Trade-off: Client loads more data upfront, but UX is better and architecture is simpler

**Docker & Deployment**
- Private networks for inter-container communication
- Don't expose services unnecessarily
- Security through simplicity and isolation

---

## Collaboration Principles

**Question everything constructively**
- "Do we really need this?" is a valid question
- "Is this the right place for this information?" keeps docs organized
- "Will this stay relevant when code changes?" ensures longevity

**Iterative refinement**
- Documentation evolves through discussion
- Better to remove unnecessary content than accumulate bloat
- Specifications should get simpler and clearer over time, not larger

**Practical efficiency over theoretical completeness**
- Documentation should serve developers, not burden them
- Time spent on docs should have clear ROI
- For small projects, getting to working code faster may be better than perfect documentation

---

## Project-Specific Context

**MaxPanelLength Application:**
- Internal tool for Norex panel specifications lookup
- Python FastAPI + React + Docker
- Two plants (STH, SRY), ~50-100 rows of data each
- "Toy but pro" aesthetic - playful yet professional
- Users: Internal staff, trusted environment

**Development approach:**
- Complete planning before implementation
- 5-phase development (6-10 days total)
- Backend serves data, frontend handles all filtering and calculation
- MVP focuses on core functionality, defer enhancements

---

## Key Takeaways

1. **Specifications guide implementation, they don't duplicate it**
2. **Conceptual > Literal** in all documentation
3. **Question the value** of each doc section
4. **Avoid duplication** religiously
5. **Small projects need lean docs** that focus on key decisions
6. **Code changes, patterns endure** - write specs accordingly
7. **Each document has one clear purpose** - keep it focused
8. **Practical efficiency** over theoretical completeness

---

*These principles emerged from iterative discussion about MaxPanelLength project documentation structure and content. They reflect a pragmatic approach to documentation that balances thoroughness with maintainability, especially for small to medium-sized projects.*
