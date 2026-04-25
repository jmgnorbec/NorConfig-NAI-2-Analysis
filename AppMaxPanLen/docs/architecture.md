# Architecture

## Overview

Microservices architecture with containerized backend API and frontend UI.

## MVP Principles

- **Static data**: CSV files represent material physics, rarely change
- **Full dataset to frontend**: Backend serves complete plant data; frontend handles all filtering and calculation
- **Client-side intelligence**: Frontend filters valid options based on actual data combinations for optimal UX
- **No BFF layer**: Frontend handles UI logic and state management directly; simplicity of MVP doesn't justify additional backend-for-frontend layer
- **Simple backend**: Serves data, no business logic or validation
- **Simple updates**: Replace CSV files and redeploy containers (no hot reload needed)
- **Internal tool**: No internationalization needed (display bilingual labels as-is)
- **Deployment**: Docker Compose for both dev and production (VM in VPN)

**Rationale for full dataset approach:**
- Dataset is small (~50-100 rows per plant, <50KB)
- Single API call provides all data needed for entire session
- Enables smart UI filtering (show only valid combinations)
- Frontend can calculate results instantly without API calls
- Simpler backend implementation (pure data serving)

## Backend - REST API

**Technology Stack:**
- **Python 3.11+** - Modern, type-safe Python
- **FastAPI** - High-performance, auto-generated API docs
- **Uvicorn** - Fast ASGI server
- **Pydantic** - Runtime data validation
- **pandas** - Efficient CSV parsing and data manipulation

**Responsibilities:**
- Parse and load CSV data at startup
- Serve complete plant datasets to frontend
- Minimal processing (read CSV, convert to JSON)

**API Design:** See [api-specification.md](api-specification.md) for complete endpoint details

**Key Endpoints:**
- `GET /api/plants` - List available plants
- `GET /api/plants/{plantId}/options` - Get filter options for plant
- `POST /api/calculate` - Valdata` - Get complete dataset for plant
## Frontend - React UI

**Technology Stack:**
- **React 18+** - Component-based UI
- **Vite** - Fast build tool with hot reload
- **Tailwind CSS** - Utility-first styling
- **Axios** - HTTP client for API calls

**Responsibilities:**
- Manage UI state (selections, filter options)
- Load and cache complete plant dataset
- Extract filter options from dataset
- Implement smart filtering logic (show only valid combinations)
- Calculate results locally from dataset
- Manage three-state controls and smart state preservation
**UI Design:** See [ui-specifications.md](ui-specifications.md) for complete design and interaction details

**Key Features:**
- ToitCalc-inspired "toy but pro" aesthetic
- One-click controls (no dropdowns for characteristics)
- Cascading filter behavior with smart state preservation
- Real-time result display via API

## Docker Architecture

**Strategy:** Multi-container deployment with Docker Compose on single host

**Backend Container:**
- Python 3.11 slim base image
- CSV files mounted as volumes for easy updates
- Exposes port 8000

**Frontend Container:**
- Multi-stage build: Node for build, Nginx for serving
- Nginx proxies `/api/*` to backend in production
- Exposes port 3000 (dev) or 80 (production)

**Container Networking:**
- Both containers run on same Docker instance
- Private Docker network for inter-container communication
- Frontend → Backend via internal network (e.g., `http://backend:8000`)
- Only frontend port exposed to host
- **Rationale:** Secure internal communication, backend not directly accessible from outside

**Volume Mounts:**
- `./MaxLength-STH.csv` → `/app/data/MaxLength-STH.csv`
- `./MaxLength-SRY.csv` → `/app/data/MaxLength-SRY.csv`

**Rationale:** CSV files as volumes allow data updates without rebuilding containers

## Data Flow

**1. Startup:**
- Backend loads CSV files, extracts filter options

**2. User Interaction:**
- Frontend fetches plant list and options from backend
- User selects plancomplete dataset for selected plant
- Caches data for session duration
- Filters available colors from dataset
- User selects color → frontend filters characteristics based on actual data rows
- User completes selection → frontend calculates result from local dataset

**3. Result Display:**
- Frontend looks up max length from cached dataset
- Displays numeric value or "NA" accordingly
- No backend validation needed (all combinations come from actual data)

**Key Decision:** Full dataset to frontend enables intelligent filtering and instant results; data size is small enough for efficient transfer and client-side processing
## Deployment Environments

**Development:**
- Both services run with hot reload
- Frontend on :3000, Backend on :8000 (both exposed to host)
- Frontend calls backend via localhost:8000
- CORS enabled for cross-origin requests

**Production:**
- Nginx serves frontend on :80 (exposed to host)
- Backend on :8000 (internal only, not exposed)
- Nginx proxies `/api/*` to `http://backend:8000` via Docker network
- Single domain eliminates CORS needs
- CSV data updates: replace files and restart containers

## Testing Strategy

### Backend Tests
**Unit Tests (pytest):**
- CSV parsing and data loading
- Filter options extraction logic
- Data structure validation
- Edge cases (missing values, malformed data)

**API Tests:**
- Endpoint response schemas (Pydantic validation)
- Plant list returns correctly
- Plant data endpoint returns valid structure
- Handle invalid plant IDs

**Coverage target:** Core logic and API endpoints

### End-to-End Tests
**Playwright/Cypress:**
- Complete user flow: select plant → select all parameters → verify result displayed
- Test NA result display
- Test all plants (STH, SRY)
- Verify cascading filter behavior
- Responsive layout validation

**Coverage:** Critical user paths only (MVP scope)

### Manual Testing
- Cross-browser compatibility (Chrome, Edge, Firefox)
- Sample data verification against original sources
