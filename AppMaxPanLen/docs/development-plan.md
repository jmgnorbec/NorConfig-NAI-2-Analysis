# Development Plan

## Phase 1: Backend Foundation (1 day)
**Goal:** Simple data-serving API

**Key Tasks:**
- Setup FastAPI project with Uvicorn, Swagger/ReDoc
- CSV parsing with pandas
- Pydantic data models for responses
- Implement endpoints:
  - `GET /api/plants` - plant list
  - `GET /api/plants/{plantId}/data` - complete dataset
- Basic error handling (404 for invalid plant)
- Simple tests (pytest) for CSV loading and endpoint responses

**Deliverable:** API serving complete plant datasets via Swagger UI

**Note:** Simpler than originally planned - no validation logic, no calculate endpoint

---

## Phase 2: Frontend Foundation (2-3 days)
**Goal:** React UI with ToitCalc-inspired styling

**Key Tasks:**
- Vite + React + Tailwind CSS setup
- Build core components per [ui-specifications.md](ui-specifications.md)
- Implement visual design (dark header, cards, blue accents)
- API integration for data loading
- Responsive layout

**Deliverable:** Working UI displaying results from API

---

## Phase 3: Business Logic (1-2 days)
**Goal:** Smart filtering and calculation logic

**Key Tasks:**
- Implement data loading and caching per [ui-specifications.md](ui-specifications.md)
- Dynamic filtering: extract and filter options based on current selections
- Result calculation from cached dataset (profile + finish mapping)
- State management rules (plant change, color change, characteristic change)
- Handle NA values in display

**Deliverable:** Fully functional filtering with intelligent option display and instant results

---

## Phase 4: Docker & Deployment (1 day)
**Goal:** Containerized deployment on single host

**Key Tasks:**
- Backend Dockerfile (Python + volume mounts for CSVs)
- Frontend Dockerfile (multi-stage: Node build + Nginx)
- docker-compose.yml:
  - Define both services
  - Private Docker network for inter-container communication
  - Volume mapping for CSV files
  - Environment variables (API URL for dev/prod)
- Nginx configuration:
  - Serve frontend static files
  - Proxy `/api/*` to backend via Docker network
- Build/start/stop scripts

**Deliverable:** Working Docker Compose deployment with secure internal networking

**Note:** Backend not exposed to host in production, only accessible via Nginx proxy

---

## Phase 5: Testing & Polish (1-2 days)
**Goal:** Production-ready application

**Key Tasks:**
- Complete backend pytest suite
- E2E tests (Playwright/Cypress) for critical flows
- Loading states and transitions
- Error boundaries
- Deployment documentation

**Deliverable:** Tested, polished MVP ready for production

---

## Timeline

**Total: 6-10 days**
- Phase 1: 1 day
- Phase 2: 2-3 days
- Phase 3: 1-2 days
- Phase 4: 1 day
- Phase 5: 1-2 days

---

## Success Criteria

- ✅ All parameter selections work correctly
- ✅ Only valid combinations shown (smart filtering)
- ✅ Accurate max length results (including NA)
- ✅ Smart state preservation on plant/color changes
- ✅ Instant results (no API call for calculation)
- ✅ Clean UI matching design specifications
- ✅ Backend and E2E tests passing
- ✅ Docker deployment successful
