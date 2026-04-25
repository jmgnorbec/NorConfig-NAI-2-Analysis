# Architecture

## Overview

Microservices architecture with containerized backend API and frontend UI.

## Backend - REST API

**Technology Stack:**
- Python 3.11+
- FastAPI
- Uvicorn (ASGI server)
- Pydantic (data validation)
- pandas (CSV processing)

**API Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/plants` | List available plants |
| GET | `/api/plants/{plantId}/filters` | Get all available filter options for plant |
| POST | `/api/calculate` | Calculate maximum panel length |
| GET | `/docs` | Swagger UI documentation |
| GET | `/redoc` | ReDoc documentation |

**Request Model (POST /api/calculate):**
```json
{
  "plant": "STH",
  "color": "Blanc Régal/Regal White",
  "paint": "PVDF CLASSIC",
  "gage": 22,
  "profile": "Grooved",
  "finish": "Embossed"
}
```

**Response Model:**
```json
{
  "maxLength": "52.25",
  "unit": "ft",
  "available": true,
  "plant": "STH",
  "metadata": {
    "color": "Blanc Régal/Regal White",
    "paint": "PVDF CLASSIC",
    "gage": 22,
    "profile": "Grooved",
    "finish": "Embossed"
  }
}
```

**Data Loading:**
- CSV files loaded at startup into memory
- Indexed data structures for fast lookups
- Validation of input parameters against available options

**Port:** 8000

## Frontend - React UI

**Technology Stack:**
- React 18+
- Vite (build tool)
- Tailwind CSS (styling - ToitCalc Pro style)
- Axios (HTTP client)
- i18next (bilingual EN/FR support)

**Components:**
- `PlantSelector` - Toggle/select between STH and SRY
- `FilterPanel` - Cascading dropdowns for Color, Paint, Gage, Profile, Finish
- `ResultDisplay` - Large, prominent max length display
- `ErrorBoundary` - Handle NA/unavailable combinations

**Features:**
- Cascading filter logic (only show valid combinations)
- Real-time validation
- Bilingual labels and messages
- Responsive design

**Port:** 3000 (dev), 80 (production via Nginx)

## Docker Architecture

### Backend Container
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Frontend Container
```dockerfile
# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

### Docker Compose
```yaml
version: '3.8'
services:
  backend:
    build: ./src/backend
    ports:
      - "8000:8000"
    volumes:
      - ./MaxLength-STH.csv:/app/data/MaxLength-STH.csv
      - ./MaxLength-SRY.csv:/app/data/MaxLength-SRY.csv
    environment:
      - CORS_ORIGINS=http://localhost:3000
  
  frontend:
    build: ./src/frontend
    ports:
      - "3000:80"
    build: ./src/frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
    environment:
      - REACT_APP_API_URL=http://localhost:8000
```

## Data Flow

1. User selects plant → Frontend fetches available filters from `/api/plants/{plantId}/filters`
2. User selects parameters → Dropdowns cascade based on valid combinations
3. User submits → Frontend POSTs to `/api/calculate`
4. Backend looks up value in CSV data → Returns max length or NA
5. Frontend displays result prominently

## Development vs Production

**Development:**
- Hot reload for both frontend and backend
- Backend on :8000, Frontend on :3000
- CORS enabled for localhost

**Production:**
- Nginx serves frontend on :80
- Nginx proxies `/api/*` to backend :8000
- Single domain, no CORS needed
