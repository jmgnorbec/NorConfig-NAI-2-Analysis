# API Specification

## Design Principle

**Simple data-serving API:** Backend serves complete plant datasets to frontend. Frontend handles all filtering, validation, and calculation logic. This approach enables smart UI filtering (showing only valid combinations) while keeping backend simple.

**Data size:** ~50-100 rows per plant, <50KB transfer - small enough for efficient client-side processing.

## Base URL

**Development:** 
- From host: `http://localhost:8000`
- From frontend container: `http://localhost:8000` (CORS enabled)

**Production:** 
- From host: Not accessible (backend not exposed)
- From frontend container: `http://backend:8000` (via Docker network)
- User access: Via Nginx proxy at `http://{server}/api/*`

---

## Endpoints

### 1. List Plants

**Endpoint:** `GET /api/plants`

**Description:** Returns list of available plants

**Response (200 OK):**
```json
{
  "plants": [
    { "id": "STH", "name": "St-Hyacinthe" },
    { "id": "SRY", "name": "Strathroy" }
  ]
}
```

---

### 2. Get Plant Data

**Endpoint:** `GET /api/plants/{plantId}/data`

**Description:** Returns complete dataset for specified plant including all combinations and max lengths

**Path Parameters:**
- `plantId` (string): Plant identifier (STH or SRY)

**Response (200 OK):**
```json
{
  "plant": "STH",
  "data": [
    {
      "color": "Blanc Régal/Regal White",
      "paint": "PVDF CLASSIC",
      "gage": 22,
      "maxLengths": {
        "GroovedEmbossed": "52.25",
        "GroovedSmooth": "52.25",
        "SilklineEmbossed": "52.25",
        "SilklineSmooth": "52.25",
        "MicroribbedEmbossed": "52.25",
        "MicroribbedSmooth": "52.25",
        "Embossed": "24'",
        "Smooth": "24"
      }
    },
    {
      "color": "Blanc Régal/Regal White",
      "paint": "PVDF CLASSIC",
      "gage": 24,
      "maxLengths": {
        "GroovedEmbossed": "52.25",
        "GroovedSmooth": "52.25",
        "SilklineEmbossed": "52.25",
        "SilklineSmooth": "52.25",
        "MicroribbedEmbossed": "52.25",
        "MicroribbedSmooth": "52.25",
        "Embossed": "NA",
        "Smooth": "NA"
      }
    }
  ]
}
```

**Note:** Frontend extracts filter options and performs all filtering/calculation from this dataset.

**Response (404 Not Found):**
```json
{
  "error": "Plant not found",
  "detail": "Plant '{plantId}' does not exist"
}
```

---

### 3. API Documentation

**Swagger UI:** `GET /docs`  
**ReDoc:** `GET /redoc`

---

## Data Models

### PlantList
```python
{
  "plants": List[Plant]
}
```

### Plant
```python
{
  "id": str,      # "STH" or "SRY"
  "name": str     # Full plant name
}
```

### PlantData
```python
{
  "plant": str,
  "data": List[DataRow]
}
```

### DataRow
```python
{
  "color": str,
  "paint": str,
  "gage": int,
  "maxLengths": {
    "GroovedEmbossed": str,
    "GroovedSmooth": str,
    "SilklineEmbossed": str,
    "SilklineSmooth": str,
    "MicroribbedEmbossed": str,
    "MicroribbedSmooth": str,
    "Embossed": str,
    "Smooth": str
  }
}
```

**Note:** SRY dataset may include additional fields (surface, SRI) which frontend can ignore for MVP.

### ErrorResponse
```python
{
  "error": str,
  "detail": str
}
```

---

## Status Codes

| Code | Description |
|------|-------------|
| 200 | Success - data returned |
| 404 | Not Found - plant doesn't exist |
| 500 | Internal Server Error |

---

## Performance Notes

- **Dataset size:** ~50-100 rows per plant
- **Transfer size:** <50KB uncompressed
- **Caching:** Frontend should cache plant data for session duration
- **No pagination needed:** Dataset is small enough to transfer in single request

---

## CORS Configuration

**Development:**
- Allowed origins: `http://localhost:3000`
- Allowed methods: GET, POST, OPTIONS
- Allowed headers: Content-Type
- **Reason:** Frontend and backend on different ports during dev

**Production:**
- Not needed (Nginx proxy on same origin)
- Both services communicate via private Docker network
- Backend not exposed to external requests

---

## Rate Limiting

None (internal tool, trusted users)

---

## Authentication

None (MVP - internal network only)
