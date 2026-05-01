# BFF (Backend-for-Frontend) Pattern - Overview

**Pattern Type:** Frontend Architecture  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** SPAs with microservices, authentication complexity, API aggregation

---

## When to Use This Pattern

### ✅ Use BFF When

- **SPA consuming multiple backend microservices** (need to aggregate data)
- **Authentication complexity** (want JWT in httpOnly cookies, not localStorage)
- **Different frontend apps** (web/mobile need different data shapes)
- **Simplifying frontend** (hide internal service complexity)
- **CORS issues** (multiple backend services, complicated CORS setup)
- **Request aggregation** (reduce frontend round trips)

### ❌ Don't Use BFF When

- **Simple monolithic backend** (single API endpoint is fine)
- **No authentication complexity** (direct API calls work)
- **Small team** (BFF adds operational overhead)
- **Static site** (no dynamic backend needed)

### vs. Direct Backend Access

| Approach | Authentication | CORS | API Calls | Complexity |
|----------|---------------|------|-----------|------------|
| **Direct** | localStorage (XSS risk) | Per service | Multiple | Frontend handles all |
| **BFF** | httpOnly cookie (safe) | None | Single | BFF handles all |

**Key insight:** BFF trades operational complexity (one more service) for frontend simplicity and better security.

---

## Essential Configuration

### Project Structure

```
bff/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts              # Express server setup
│   ├── middleware/
│   │   └── jwt.ts            # Authentication middleware
│   └── routes/
│       ├── auth.ts           # Auth proxy (login, verify)
│       ├── admin.ts          # Admin proxy (user mgmt)
│       └── api.ts            # API proxy (business logic)
└── .env
```

### Core Dependencies

```bash
npm install express cookie-parser cors pino pino-http
npm install --save-dev @types/express @types/cookie-parser typescript
```

### Environment Variables

```bash
# .env
PORT=3001
NODE_ENV=development
LOG_LEVEL=info

# Backend services
AUTH_SERVICE_URL=http://auth:8000
API_SERVICE_URL=http://api:8000

# Cookie settings
COOKIE_DOMAIN=localhost
COOKIE_SECURE=false          # true in production
COOKIE_HTTP_ONLY=true
```

**Critical:** Always set `COOKIE_HTTP_ONLY=true` to prevent XSS attacks.

---

## Minimal Working Example

### 1. Express Server Setup

**`src/index.ts`:**
```typescript
import express from 'express';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import pino from 'pino';

const app = express();
const logger = pino({ level: 'info' });

// Middleware
app.use(express.json());
app.use(cookieParser());
app.use(cors({ 
  origin: true,  // Allow all origins in dev
  credentials: true  // CRITICAL: Allow cookies
}));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Mount routes
import authRouter from './routes/auth.js';
import apiRouter from './routes/api.js';

app.use('/bff/auth', authRouter);
app.use('/bff/api', apiRouter);

const port = process.env.PORT || 3001;
app.listen(port, () => {
  logger.info(`BFF server listening on port ${port}`);
});
```

### 2. Authentication Proxy Route

**`src/routes/auth.ts`:**
```typescript
import express from 'express';
import fetch from 'node-fetch';

const router = express.Router();
const authServiceUrl = process.env.AUTH_SERVICE_URL;

// Login endpoint
router.post('/login', async (req, res) => {
  try {
    // Forward request to auth service
    const response = await fetch(`${authServiceUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body)
    });

    const data = await response.json();

    if (response.ok && data.jwt) {
      // Store JWT in httpOnly cookie
      res.cookie('auth_token', data.jwt, {
        httpOnly: true,    // Prevents JavaScript access (XSS protection)
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        maxAge: 7 * 24 * 60 * 60 * 1000  // 7 days
      });

      // Return success WITHOUT token (it's in cookie now)
      return res.json({ success: true, user: data.user });
    }

    return res.status(response.status).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Login failed' });
  }
});

// Logout endpoint
router.post('/logout', (req, res) => {
  res.clearCookie('auth_token');
  res.json({ success: true });
});

export default router;
```

### 3. JWT Middleware

**`src/middleware/jwt.ts`:**
```typescript
import { Request, Response, NextFunction } from 'express';

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.cookies.auth_token;

  if (!token) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  // Attach token to request for downstream use
  req.jwt = token;
  next();
}
```

### 4. Protected API Proxy Route

**`src/routes/api.ts`:**
```typescript
import express from 'express';
import fetch from 'node-fetch';
import { requireAuth } from '../middleware/jwt.js';

const router = express.Router();
const apiServiceUrl = process.env.API_SERVICE_URL;

// Apply authentication to all routes
router.use(requireAuth);

// Proxy API requests
router.all('/*', async (req, res) => {
  try {
    const path = req.path;
    const response = await fetch(`${apiServiceUrl}${path}`, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${req.jwt}`  // Forward JWT
      },
      body: req.method !== 'GET' ? JSON.stringify(req.body) : undefined
    });

    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Proxy request failed' });
  }
});

export default router;
```

---

## Basic Operations

### Frontend API Calls (with BFF)

```typescript
// Login
const response = await fetch('/bff/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  credentials: 'include',  // CRITICAL: Send cookies
  body: JSON.stringify({ email, password })
});

// Authenticated API call
const habits = await fetch('/bff/api/habits', {
  credentials: 'include'  // CRITICAL: Send auth cookie
});

// Logout
await fetch('/bff/auth/logout', {
  method: 'POST',
  credentials: 'include'
});
```

**Critical:** Always set `credentials: 'include'` in fetch calls to send cookies.

### Request Aggregation

```typescript
// Single BFF endpoint aggregates multiple service calls
router.get('/dashboard', requireAuth, async (req, res) => {
  const [user, habits, completions] = await Promise.all([
    fetch(`${authServiceUrl}/auth/me`, { headers: { Authorization: req.jwt } }),
    fetch(`${apiServiceUrl}/api/habits`, { headers: { Authorization: req.jwt } }),
    fetch(`${apiServiceUrl}/api/completions`, { headers: { Authorization: req.jwt } })
  ]);

  const [userData, habitsData, completionsData] = await Promise.all([
    user.json(), habits.json(), completions.json()
  ]);

  res.json({ user: userData, habits: habitsData, completions: completionsData });
});
```

---

## Top 5 Gotchas

### 1. Forgetting `credentials: 'include'` ⚠️

```typescript
// ❌ Wrong: Cookies NOT sent
fetch('/bff/auth/verify');

// ✅ Correct: Cookies sent
fetch('/bff/auth/verify', { credentials: 'include' });
```

**Impact:** Authentication fails silently, no JWT sent.

### 2. Cookie Domain Mismatch

```typescript
// ❌ Wrong: BFF on localhost:3001, frontend on 127.0.0.1:5173
res.cookie('auth_token', jwt, { domain: 'localhost' });

// ✅ Correct: Set domain to match frontend
res.cookie('auth_token', jwt, { 
  domain: process.env.COOKIE_DOMAIN  // 'localhost' for local dev
});
```

**Impact:** Browser rejects cookie, authentication never works.

### 3. CORS Configuration Missing `credentials: true`

```typescript
// ❌ Wrong: Cookies blocked by CORS
app.use(cors({ origin: true }));

// ✅ Correct: Allow credentials
app.use(cors({ 
  origin: true, 
  credentials: true  // CRITICAL
}));
```

**Impact:** Browser blocks cookie header in cross-origin requests.

### 4. Secure Cookie in Development

```typescript
// ❌ Wrong: secure=true breaks localhost (no HTTPS)
res.cookie('auth_token', jwt, { secure: true });

// ✅ Correct: secure only in production
res.cookie('auth_token', jwt, { 
  secure: process.env.NODE_ENV === 'production' 
});
```

**Impact:** Cookies not sent over HTTP in development.

### 5. Not Clearing Cookies on Logout

```typescript
// ❌ Wrong: JWT remains in cookie
router.post('/logout', (req, res) => {
  res.json({ success: true });
});

// ✅ Correct: Clear cookie explicitly
router.post('/logout', (req, res) => {
  res.clearCookie('auth_token');
  res.json({ success: true });
});
```

**Impact:** User appears logged out in UI but JWT still valid.

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| 401 on authenticated routes | Missing `credentials: 'include'` | Add to all fetch calls |
| Cookie not set after login | Domain mismatch | Check `COOKIE_DOMAIN` env var |
| CORS error on BFF calls | Missing `credentials: true` in CORS | Add to CORS config |
| Cookie not sent over localhost | `secure: true` in dev | Use `secure: NODE_ENV === 'production'` |
| Still authenticated after logout | Cookie not cleared | Call `res.clearCookie('auth_token')` |

---

## References

📎 **Reference**: [bff-reference.md](bff-reference.md)  
**When to load**: Implementing BFF server, handling authentication flows, request aggregation patterns, error handling, production deployment  
**Key content**: Complete Express setup, all middleware patterns, authentication flows, request aggregation, NGINX integration, Docker setup, production configuration, testing strategies, security hardening (~1,200 lines)

📎 **Related patterns**:
- [react-patterns.md](react-patterns.md) - Frontend integration
- [docker-patterns.md](../deployment/docker-patterns.md) - BFF containerization
- [traefik-patterns.md](../deployment/traefik-patterns.md) - Reverse proxy setup

---

**Pattern Type:** Frontend Architecture  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
