# Frontend Patterns

**Purpose:** React, UI component libraries, and state management patterns for modern web applications.

---

## Pattern Structure

This directory uses a **two-file pattern** for comprehensive topics:

| File Type | Lines | Purpose | Read Time |
|-----------|-------|---------|-----------|
| **Overview** (`*-overview.md`) | 200-300 | Quick decision-making, essential config, common gotchas | 2-3 min |
| **Reference** (`*-reference.md`) | 700-1,200 | Complete implementation details, advanced patterns, all examples | 20+ min |

**Loading strategy for AI agents:**
- Load **overview** first for decisions (which pattern to use, basic setup)
- Load **reference** when implementing (complete examples, edge cases, production patterns)

---

## Available Patterns

### 1. React Component Patterns

**What it covers:** Functional components, hooks, state management, composition, controlled components

| File | Purpose |
|------|---------|
| [react-overview.md](react-overview.md) | Essential patterns (presentational vs container, custom hooks, context) |
| [react-reference.md](react-reference.md) | Advanced patterns (render props, HOCs, performance optimization, testing) |

**Quick decision:** Use for all React 18+ applications with functional components and hooks.

### 2. TanStack Query (React Query)

**What it covers:** Data fetching, caching, background updates, optimistic updates, mutations

| File | Purpose |
|------|---------|
| [tanstack-query-overview.md](tanstack-query-overview.md) | Basic queries, mutations, cache invalidation, common gotchas |
| [tanstack-query-reference.md](tanstack-query-reference.md) | Infinite queries, pagination, parallel queries, SSR, advanced caching |

**Quick decision:** Use when building API-driven React apps that need client-side caching and automatic refetching.

### 3. Feature-Folder Structure

**What it covers:** Organizing React code by business feature instead of technical layer

| File | Purpose |
|------|---------|
| [feature-folder-overview.md](feature-folder-overview.md) | Basic structure, exports pattern, feature boundaries |
| [feature-folder-reference.md](feature-folder-reference.md) | Advanced organization, cross-feature communication, migration strategies |

**Quick decision:** Use when app has 3+ distinct features (habits + calendar + settings). Skip for tiny apps (< 3 features).

### 4. Material UI (MUI)

**What it covers:** Component library, theming, styling, responsive design with Material Design

| File | Purpose |
|------|---------|
| [mui-overview.md](mui-overview.md) | Theme setup, common components (Button, Card, Dialog, Grid), styling with `sx` prop |
| [mui-reference.md](mui-reference.md) | Advanced theming (dark mode, custom colors), complex components (DataGrid, Autocomplete), performance |

**Quick decision:** Use for rapid enterprise UI development with Material Design. Bundle size: ~400KB. Don't use for highly custom designs.

### 5. Backend-for-Frontend (BFF)

**What it covers:** Node.js proxy layer between React frontend and backend microservices

| File | Purpose |
|------|---------|
| [bff-overview.md](bff-overview.md) | Express setup, JWT cookies, route proxying, authentication middleware |
| [bff-reference.md](bff-reference.md) | Request aggregation, error handling, production config, NGINX integration, Docker setup |

**Quick decision:** Use when SPA consumes multiple backend services and needs secure authentication (httpOnly cookies vs localStorage). Don't use for simple monolithic backends.

---

## Decision Matrix

**Which patterns to use based on project stage:**

| Project Stage | Patterns | Rationale |
|---------------|----------|-----------|
| **Week 1 MVP** | React basics, useState + useEffect | Keep it simple, no libraries needed yet |
| **Month 1 Beta** | React + TanStack Query + Feature folders | Add data fetching, organize growing codebase |
| **Month 3 Production** | All patterns + MUI or custom design system + BFF | Full stack, secure auth, scalable architecture |

**Quick decision guidance:**

- **Just starting React?** → Read [react-overview.md](react-overview.md)
- **Need to fetch API data?** → Read [tanstack-query-overview.md](tanstack-query-overview.md)
- **App growing (3+ features)?** → Read [feature-folder-overview.md](feature-folder-overview.md)
- **Need rapid UI development?** → Read [mui-overview.md](mui-overview.md)
- **Multiple backend services + auth?** → Read [bff-overview.md](bff-overview.md)

---

## Loading Strategy for AI Agents

```markdown
1. **Making decisions** (which pattern to use):
   - Load overview files for quick comparison
   - Check "When to Use" sections
   - Review decision matrix above

2. **Implementing features**:
   - Load overview for minimal working example
   - If need advanced features → load reference
   - If stuck → check "Top 5 Gotchas" in overview

3. **Troubleshooting**:
   - Check "Quick Troubleshooting" table in overview
   - If not resolved → load reference for detailed debugging
```

---

## Related Documentation

📎 **Architecture context**: [../../Architecture/architecture-reference.md](../../Architecture/architecture-reference.md)  
📎 **Testing frontend**: [../testing/](../testing/)  
📎 **Deployment patterns**: [../deployment/](../deployment/)

---

**Last Updated:** 2026-03-07  
**Pattern Count:** 5 patterns (10 files: 5 overviews + 5 references)
import { Button } from '@mui/material'
<Button variant="contained" color="primary">Save</Button>
```

**Benefits:** Pre-built components, accessibility, consistency

## State Management

**Simple state:** useState (local component state)  
**Server state:** TanStack Query (API data)  
**Global state:** Context API or Zustand (if needed)

**Avoid:** Redux for simple apps

---

**Pattern files will be created in Phase 3**

**Template Version:** 1.0.0  
**Last Updated:** March 6, 2026
