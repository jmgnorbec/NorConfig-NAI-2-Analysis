# Backend-for-Frontend (BFF) Pattern

**Pattern Type:** Frontend Architecture  
**Complexity:** Intermediate  
**Best For:** SPAs with microservices, authentication/authorization complexity, API aggregation

---

## Overview

The Backend-for-Frontend (BFF) pattern creates a dedicated server-side proxy that sits between your frontend application and backend microservices. Each frontend (web, mobile, etc.) can have its own BFF tailored to its specific needs.

### When to Use

**✅ Use BFF when:**
- SPA consuming backend microservices architecture
- Need to aggregate data from multiple services
- Want to centralize authentication handling (JWT cookies)
- Mobile/web apps have different data requirements
- Need to simplify frontend API surface (hide internal service complexity)
- Want to offload authentication logic from frontend
- Need server-side session management

**❌ Don't use BFF when:**
- Simple monolithic backend with single API
- No authentication complexity
- Direct backend API suitable for frontend needs
- Development team is small (BFF adds operational overhead)

---

## Architecture

### Without BFF (Direct Backend Access)
```
┌──────────────┐
│   Browser    │
│   (React)    │
└──────┬───────┘
       │ HTTP/HTTPS (CORS issues, multiple endpoints)
       │
    ┌──┴─────────────────────────────────────┐
    │                                         │
    ▼                                         ▼
┌────────────┐                      ┌────────────────┐
│   Auth     │                      │   API Service  │
│  Service   │                      │  (Business)    │
│ (Port 8000)│                      │  (Port 8001)   │
└────────────┘                      └────────────────┘
```

**Problems:**
- Frontend manages multiple API endpoints
- CORS configuration required for each service
- JWT token stored in browser (localStorage = XSS vulnerable)
- Frontend handles authentication complexity
- No request aggregation (multiple round trips)

### With BFF (Proxy Pattern)
```
┌──────────────┐
│   Browser    │
│   (React)    │
└──────┬───────┘
       │ HTTP (same-origin via Nginx)
       │ Cookie-based auth (httpOnly, secure)
       │
       ▼
┌──────────────────┐
│    BFF Server    │  ← Single point of contact for frontend
│   (Express.js)   │
│   (Port 3001)    │
└──────┬───────────┘
       │ Internal network (no CORS)
       │ Service-to-service auth (tokens)
       │
    ┌──┴─────────────────────────────────────┐
    │                                         │
    ▼                                         ▼
┌────────────┐                      ┌────────────────┐
│   Auth     │                      │   API Service  │
│  Service   │                      │  (Business)    │
└────────────┘                      └────────────────┘
```

**Benefits:**
- Single API endpoint for frontend (`/bff/*`)
- JWT in httpOnly cookie (safe from XSS)
- BFF handles authentication, frontend only manages UI
- Request aggregation (1 BFF call = multiple service calls)
- Simplified frontend code (no service discovery)
- Role-based access control centralized in BFF

---

## Project Structure

```
bff/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts              # Express server setup
│   ├── middleware/
│   │   └── jwt.ts            # Authentication middleware
│   └── routes/
│       ├── health.ts         # Health check endpoint
│       ├── auth.ts           # Auth proxy (login, register, verify)
│       ├── admin.ts          # Admin proxy (user management)
│       ├── api.ts            # API proxy (business logic)
│       └── workflow.ts       # Workflow proxy (n8n, etc.)
└── .env.example              # Environment configuration
```

---

## Implementation Patterns

### 1. Express Server Setup

**`src/index.ts`** - Main server configuration

```typescript
import express from 'express';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import pino from 'pino';
import pinoHttp from 'pino-http';

// Import route modules
import healthRouter from './routes/health.js';
import authRouter from './routes/auth.js';
import adminRouter from './routes/admin.js';
import apiRouter from './routes/api.js';

const app = express();
const port = process.env.PORT || 3001;

// Logger setup - pino for structured logging
const logger = pino({
  level: process.env.LOG_LEVEL || 'warn',
  transport: process.env.NODE_ENV !== 'production' ? {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
    },
  } : undefined,
});

// Middleware stack
app.use(pinoHttp({ logger }));       // Request logging
app.use(express.json());              // Parse JSON bodies
app.use(cookieParser());              // Parse cookies

// CORS - Allow frontend origin with credentials
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:5173', // Vite dev server
  credentials: true, // Allow cookies
}));

// Routes - All routes under /bff/* prefix
app.use('/bff/health', healthRouter);
app.use('/bff/auth', authRouter);
app.use('/bff/admin', adminRouter);
app.use('/bff/api', apiRouter);

// Global error handler
app.use((err: Error, req: express.Request, res: express.Response, _next: express.NextFunction) => {
  logger.error({ err, req: req.url }, 'Unhandled error');
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'production' ? 'An error occurred' : err.message,
  });
});

// Start server
const server = app.listen(port, () => {
  console.log(`🌐 BFF Server listening on port ${port}`);
  console.log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`✓ API base: ${process.env.API_BASE_URL || 'http://api:8000'}`);
  console.log(`✓ Auth base: ${process.env.AUTH_BASE_URL || 'http://auth:8000'}`);
});

server.on('error', (error) => {
  logger.error({ error }, 'Server error');
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => process.exit(0));
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => process.exit(0));
});

export default app;
```

**Key concepts:**
- **Middleware stack**: Request logging → JSON parsing → Cookie parsing → CORS
- **Route prefix**: All BFF routes under `/bff/*` namespace
- **Global error handler**: Catches unhandled errors, logs, returns JSON
- **Graceful shutdown**: Handle SIGTERM/SIGINT for clean shutdown

---

### 2. JWT Authentication Middleware

**`src/middleware/jwt.ts`** - JWT verification and cookie management

```typescript
import jwt from 'jsonwebtoken';
import type { Request, Response, NextFunction } from 'express';

const JWT_SECRET = process.env.JWT_SECRET || 'change-this-secret-in-production';
const JWT_COOKIE_NAME = process.env.JWT_COOKIE_NAME || 'flovify_token';

if (JWT_SECRET === 'change-this-secret-in-production') {
  console.warn('⚠️  WARNING: Using default JWT_SECRET. Set a secure secret matching Auth Service!');
}

export interface JwtPayload {
  userId: string;
  email: string;
  role: 'user' | 'admin' | 'super-user';
  iat?: number;
  exp?: number;
}

/**
 * Verify JWT token
 */
export function verifyToken(token: string): JwtPayload {
  try {
    return jwt.verify(token, JWT_SECRET) as JwtPayload;
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
}

/**
 * Set JWT cookie in response
 * httpOnly: Prevents JavaScript access (XSS protection)
 * secure: HTTPS only in production
 * sameSite: Prevents CSRF
 */
export function setAuthCookie(res: Response, token: string): void {
  res.cookie(JWT_COOKIE_NAME, token, {
    httpOnly: true,                          // Cannot be accessed by JavaScript
    secure: process.env.NODE_ENV === 'production', // HTTPS only in production
    sameSite: 'strict',                      // CSRF protection
    maxAge: 7 * 24 * 60 * 60 * 1000,        // 7 days in milliseconds
    path: '/',
  });
}

/**
 * Clear JWT cookie
 */
export function clearAuthCookie(res: Response): void {
  res.clearCookie(JWT_COOKIE_NAME, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    path: '/',
  });
}

/**
 * Express middleware to require authentication
 */
export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const token = req.cookies[JWT_COOKIE_NAME];
  
  if (!token) {
    res.status(401).json({ error: 'Authentication required' });
    return;
  }
  
  try {
    const payload = verifyToken(token);
    req.user = payload; // Attach user to request
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}

/**
 * Express middleware for optional authentication
 * Continues even if token is invalid
 */
export function optionalAuth(req: Request, _res: Response, next: NextFunction): void {
  const token = req.cookies[JWT_COOKIE_NAME];
  
  if (token) {
    try {
      const payload = verifyToken(token);
      req.user = payload;
    } catch {
      // Invalid token, but continue without auth
    }
  }
  
  next();
}

// Extend Express Request type to include user
declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}
```

**Key concepts:**
- **JWT_SECRET**: Must match Auth Service secret
- **httpOnly cookie**: Prevents XSS attacks (JavaScript cannot access)
- **secure flag**: HTTPS only in production
- **sameSite: strict**: Prevents CSRF attacks
- **requireAuth middleware**: Blocks requests without valid token
- **optionalAuth middleware**: Allows requests, attaches user if token valid
- **TypeScript extension**: Add `user` property to Express Request

---

### 3. Auth Proxy Routes

**`src/routes/auth.ts`** - Proxy authentication requests to Auth Service

```typescript
import express from 'express';
import { requireAuth, setAuthCookie, clearAuthCookie } from '../middleware/jwt.js';

const router = express.Router();

const AUTH_SERVICE_URL = process.env.AUTH_BASE_URL || 'http://auth:8000';

/**
 * POST /bff/auth/register
 * Register a new user
 */
router.post('/register', async (req, res) => {
  try {
    const response = await fetch(`${AUTH_SERVICE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    // Set JWT cookie on successful registration
    if (data.token) {
      setAuthCookie(res, data.token);
    }
    
    res.status(201).json(data);
    
  } catch (error) {
    req.log.error({ error }, 'Failed to proxy register to Auth Service');
    res.status(500).json({ error: 'Failed to connect to authentication service' });
  }
});

/**
 * POST /bff/auth/login
 * User login with email + OTP code
 */
router.post('/login', async (req, res) => {
  try {
    const response = await fetch(`${AUTH_SERVICE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    // Set JWT cookie on successful login
    if (data.token) {
      setAuthCookie(res, data.token);
      req.log.info({ email: req.body.email }, 'User logged in successfully');
    }
    
    res.json(data);
    
  } catch (error) {
    req.log.error({ error }, 'Failed to proxy login to Auth Service');
    res.status(500).json({ error: 'Failed to connect to authentication service' });
  }
});

/**
 * POST /bff/auth/logout
 * User logout - clear JWT cookie
 */
router.post('/logout', requireAuth, async (req, res) => {
  try {
    clearAuthCookie(res);
    req.log.info({ user: req.user?.email }, 'User logged out');
    res.json({ message: 'Logged out successfully' });
    
  } catch (error) {
    req.log.error({ error }, 'Failed to logout');
    res.status(500).json({ error: 'Failed to logout' });
  }
});

/**
 * GET /bff/auth/verify
 * Verify JWT token and return user info
 */
router.get('/verify', requireAuth, async (req, res) => {
  try {
    // requireAuth middleware already verified token and attached req.user
    res.json({
      authenticated: true,
      user: req.user,
    });
    
  } catch (error) {
    req.log.error({ error }, 'Failed to verify token');
    res.status(401).json({ error: 'Authentication failed' });
  }
});

export default router;
```

**Key concepts:**
- **POST /bff/auth/login**: Forward login request, set JWT cookie on success
- **POST /bff/auth/logout**: Clear JWT cookie (no backend call needed)
- **GET /bff/auth/verify**: Verify authentication status without calling backend
- **Error handling**: Catch network errors, return 500 with generic message
- **Logging**: Log authentication events for security audit

---

### 4. Admin Proxy with Role Verification

**`src/routes/admin.ts`** - Admin routes with role-based access control

```typescript
import express from 'express';
import { requireAuth } from '../middleware/jwt.js';

const router = express.Router();

const AUTH_SERVICE_URL = process.env.AUTH_BASE_URL || 'http://auth:8000';

/**
 * Middleware to verify admin role
 * 
 * Role hierarchy:
 * - user: Standard user with basic access
 * - super-user: Elevated user with business workflow privileges (NOT admin console)
 * - admin: Full administrative access including admin console
 */
function requireAdmin(req: express.Request, res: express.Response, next: express.NextFunction): void {
  if (!req.user) {
    res.status(401).json({ error: 'Authentication required' });
    return;
  }
  
  const role = req.user.role;
  
  // Only 'admin' role can access admin console
  if (role !== 'admin') {
    res.status(403).json({ error: 'Admin access required' });
    return;
  }
  
  next();
}

// Apply authentication and admin role check to all admin routes
router.use(requireAuth);
router.use(requireAdmin);

/**
 * GET /bff/admin/users
 * List all users (admin only)
 */
router.get('/users', async (req, res) => {
  try {
    const token = req.cookies[process.env.JWT_COOKIE_NAME || 'flovify_token'];
    
    // Build query params for pagination
    const queryParams = new URLSearchParams();
    if (req.query.page) queryParams.append('page', req.query.page as string);
    if (req.query.limit) queryParams.append('limit', req.query.limit as string);
    if (req.query.search) queryParams.append('search', req.query.search as string);
    
    const url = `${AUTH_SERVICE_URL}/auth/admin/users${queryParams.toString() ? '?' + queryParams.toString() : ''}`;
    
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`, // Forward JWT to backend
      },
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    req.log.info({ admin: req.user?.email, userCount: data.users?.length }, 'Admin listed users');
    res.json(data);
    
  } catch (error) {
    req.log.error({ error }, 'Failed to proxy admin/users to Auth Service');
    res.status(500).json({ error: 'Failed to connect to authentication service' });
  }
});

/**
 * POST /bff/admin/users
 * Create a new user (admin only)
 */
router.post('/users', async (req, res) => {
  try {
    const token = req.cookies[process.env.JWT_COOKIE_NAME || 'flovify_token'];
    
    const response = await fetch(`${AUTH_SERVICE_URL}/auth/admin/users`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    req.log.info({ admin: req.user?.email, newUser: data.email }, 'Admin created user');
    res.status(201).json(data);
    
  } catch (error) {
    req.log.error({ error }, 'Failed to proxy admin/users POST to Auth Service');
    res.status(500).json({ error: 'Failed to connect to authentication service' });
  }
});

/**
 * PATCH /bff/admin/users/:user_id
 * Update user (admin only)
 */
router.patch('/users/:user_id', async (req, res) => {
  try {
    const token = req.cookies[process.env.JWT_COOKIE_NAME || 'flovify_token'];
    const { user_id } = req.params;
    
    const response = await fetch(`${AUTH_SERVICE_URL}/auth/admin/users/${user_id}`, {
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    req.log.info({ admin: req.user?.email, userId: user_id }, 'Admin updated user');
    res.json(data);
    
  } catch (error) {
    req.log.error({ error }, 'Failed to proxy admin/users PATCH to Auth Service');
    res.status(500).json({ error: 'Failed to connect to authentication service' });
  }
});

export default router;
```

**Key concepts:**
- **requireAdmin middleware**: Check role after authentication
- **Role hierarchy**: user < super-user < admin
- **JWT forwarding**: Send original JWT to backend (Authorization header)
- **Query params**: Preserve pagination, filtering from frontend
- **Audit logging**: Log admin actions for security review

---

### 5. API Proxy with Catch-All Pattern

**`src/routes/api.ts`** - Proxy business logic requests to API Service

```typescript
import express from 'express';

const router = express.Router();

const API_SERVICE_URL = process.env.API_BASE_URL || 'http://api:8000';
const API_SERVICE_TOKEN = process.env.API_SERVICE_TOKEN; // Optional service-to-service auth

/**
 * GET /bff/api/ms365/emails/:credential_id
 * Proxy to API Service: MS365 emails endpoint
 */
router.get('/ms365/emails/:credential_id', async (req, res) => {
  try {
    const { credential_id } = req.params;
    const { limit, mailbox, unread_only } = req.query;
    
    // Build query params
    const queryParams = new URLSearchParams();
    if (limit) queryParams.append('limit', limit as string);
    if (mailbox) queryParams.append('mailbox', mailbox as string);
    if (unread_only) queryParams.append('unread_only', unread_only as string);
    const queryString = queryParams.toString() ? `?${queryParams.toString()}` : '';
    
    const response = await fetch(
      `${API_SERVICE_URL}/api/ms365/emails/${credential_id}${queryString}`,
      { method: 'GET' }
    );
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    res.json(data);
    
  } catch (error) {
    req.log.error({ error }, 'Failed to proxy ms365 emails to API Service');
    res.status(500).json({ error: 'Failed to connect to API service' });
  }
});

/**
 * Catch-all proxy for all other API routes
 * /bff/api/* -> /api/*
 * Supports GET, POST, PUT, DELETE, PATCH
 */
router.all('/*', async (req, res) => {
  try {
    // Extract the path after /bff/api/
    const path = req.path.startsWith('/') ? req.path.substring(1) : req.path;
    const queryString = req.url.split('?')[1] ? `?${req.url.split('?')[1]}` : '';
    
    // Build headers - include service token if configured
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    
    if (API_SERVICE_TOKEN) {
      headers['X-Service-Token'] = API_SERVICE_TOKEN;
    }
    
    const response = await fetch(
      `${API_SERVICE_URL}/api/${path}${queryString}`,
      {
        method: req.method,
        headers,
        body: req.method !== 'GET' && req.method !== 'HEAD' ? JSON.stringify(req.body) : undefined,
      }
    );
    
    const data = await response.json();
    
    if (!response.ok) {
      res.status(response.status).json(data);
      return;
    }
    
    res.json(data);
    
  } catch (error) {
    req.log.error({ error, path: req.path }, 'Failed to proxy request to API Service');
    res.status(500).json({ error: 'Failed to connect to API service' });
  }
});

export default router;
```

**Key concepts:**
- **Specific routes first**: Define custom routes before catch-all
- **Catch-all pattern**: `router.all('/*')` proxies any unmatched route
- **Service-to-service token**: Optional auth between BFF and API Service
- **Preserve query params**: Forward pagination, filters to backend
- **HTTP method preservation**: Support GET, POST, PUT, DELETE, PATCH

---

### 6. Service Aggregation

**BFF aggregates multiple backend services into a single endpoint**

**`src/routes/dashboard.ts`** - Example: Aggregate user + usage stats

```typescript
import express from 'express';
import { requireAuth } from '../middleware/jwt.js';

const router = express.Router();

const AUTH_SERVICE_URL = process.env.AUTH_BASE_URL || 'http://auth:8000';
const API_SERVICE_URL = process.env.API_BASE_URL || 'http://api:8000';

/**
 * GET /bff/dashboard
 * Aggregates user profile + API usage stats + quota info
 * 
 * Without BFF: Frontend makes 3 separate requests
 * With BFF: Frontend makes 1 request, BFF aggregates
 */
router.get('/', requireAuth, async (req, res) => {
  try {
    const token = req.cookies[process.env.JWT_COOKIE_NAME || 'flovify_token'];
    const userId = req.user?.userId;
    
    // Parallel requests to multiple services
    const [userProfile, usageStats, quotaInfo] = await Promise.all([
      // 1. Get user profile from Auth Service
      fetch(`${AUTH_SERVICE_URL}/auth/users/${userId}`, {
        headers: { 'Authorization': `Bearer ${token}` },
      }).then(r => r.json()),
      
      // 2. Get usage stats from API Service
      fetch(`${API_SERVICE_URL}/api/usage/stats?user_id=${userId}`, {
        headers: { 'Authorization': `Bearer ${token}` },
      }).then(r => r.json()),
      
      // 3. Get quota info from API Service
      fetch(`${API_SERVICE_URL}/api/usage/quota?user_id=${userId}`, {
        headers: { 'Authorization': `Bearer ${token}` },
      }).then(r => r.json()),
    ]);
    
    // Aggregate response
    res.json({
      user: {
        email: userProfile.email,
        name: userProfile.name,
        role: userProfile.role,
      },
      usage: {
        apiCalls: usageStats.total_calls,
        tokensUsed: usageStats.total_tokens,
      },
      quota: {
        apiCallsLimit: quotaInfo.api_calls_limit,
        tokensLimit: quotaInfo.tokens_limit,
        percentUsed: (usageStats.total_calls / quotaInfo.api_calls_limit) * 100,
      },
    });
    
  } catch (error) {
    req.log.error({ error }, 'Failed to aggregate dashboard data');
    res.status(500).json({ error: 'Failed to load dashboard data' });
  }
});

export default router;
```

**Key concepts:**
- **Parallel requests**: `Promise.all()` for concurrent backend calls
- **Data transformation**: Reshape backend responses for frontend needs
- **Reduced latency**: 1 frontend request instead of 3
- **Error handling**: Fail gracefully if one service is down

---

## Environment Configuration

**`.env.example`** - Required environment variables

```bash
# BFF Server
PORT=3001
NODE_ENV=development
LOG_LEVEL=warn                          # debug | info | warn | error

# CORS - Frontend origin
CORS_ORIGIN=http://localhost:5173       # Vite dev server (dev) | https://app.example.com (prod)

# JWT Configuration (must match Auth Service)
JWT_SECRET=your-secret-key-here-at-least-32-chars
JWT_COOKIE_NAME=flovify_token

# Backend Service URLs
AUTH_BASE_URL=http://auth:8000          # Auth Service (Docker: http://auth:8000)
API_BASE_URL=http://api:8000            # API Service (Docker: http://api:8000)

# Optional: Service-to-service authentication
API_SERVICE_TOKEN=                      # X-Service-Token for API Service auth
```

**Important:**
- **JWT_SECRET must match Auth Service**: BFF verifies tokens created by Auth Service
- **CORS_ORIGIN**: Set to frontend URL (dev: localhost:5173, prod: https://app.example.com)
- **Service URLs**: Use Docker service names (http://auth:8000) in containers, localhost in dev

---

## Deployment

### Docker Configuration

**`Dockerfile`** - Multi-stage build for BFF

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY . .

# Build TypeScript
RUN npm run build

# Stage 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Copy from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3001

CMD ["node", "dist/index.js"]
```

**`docker-compose.yml`** - BFF in Docker Compose stack

```yaml
version: '3.8'

services:
  bff:
    build:
      context: ./bff
      dockerfile: Dockerfile
    container_name: bff
    ports:
      - "3001:3001"
    environment:
      NODE_ENV: production
      PORT: 3001
      LOG_LEVEL: warn
      CORS_ORIGIN: https://app.example.com
      JWT_SECRET: ${JWT_SECRET}
      JWT_COOKIE_NAME: flovify_token
      AUTH_BASE_URL: http://auth:8000
      API_BASE_URL: http://api:8000
    depends_on:
      - auth
      - api
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3001/bff/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

networks:
  app-network:
    driver: bridge
```

---

## Error Handling

### BFF Error Handling Best Practices

```typescript
// 1. Catch network errors (service unavailable)
try {
  const response = await fetch(`${API_SERVICE_URL}/api/endpoint`);
  const data = await response.json();
  
  if (!response.ok) {
    // Forward backend error to frontend
    res.status(response.status).json(data);
    return;
  }
  
  res.json(data);
  
} catch (error) {
  // Network error or JSON parse error
  req.log.error({ error }, 'Failed to connect to API service');
  res.status(500).json({ error: 'Failed to connect to API service' });
}

// 2. Global error handler (unhandled errors)
app.use((err: Error, req: express.Request, res: express.Response, _next: express.NextFunction) => {
  req.log.error({ err, url: req.url }, 'Unhandled error');
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'production' ? 'An error occurred' : err.message,
  });
});

// 3. Service unavailable retry with timeout
async function fetchWithRetry(url: string, options: RequestInit, retries = 3): Promise<Response> {
  for (let i = 0; i < retries; i++) {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 5000); // 5s timeout
      
      const response = await fetch(url, { ...options, signal: controller.signal });
      clearTimeout(timeout);
      return response;
      
    } catch (error) {
      if (i === retries - 1) throw error; // Last retry failed
      await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1s before retry
    }
  }
  throw new Error('All retries failed');
}
```

---

## Security Considerations

### 1. JWT Cookie Security

```typescript
// ✅ SECURE: httpOnly, secure, sameSite
res.cookie(JWT_COOKIE_NAME, token, {
  httpOnly: true,        // Cannot be accessed by JavaScript (XSS protection)
  secure: true,          // HTTPS only (production)
  sameSite: 'strict',    // CSRF protection
  maxAge: 7 * 24 * 60 * 60 * 1000,
});

// ❌ INSECURE: localStorage in frontend
localStorage.setItem('token', token); // Vulnerable to XSS!
```

### 2. CORS Configuration

```typescript
// ✅ SECURE: Specific origin with credentials
app.use(cors({
  origin: 'https://app.example.com', // Specific frontend URL
  credentials: true,                  // Allow cookies
}));

// ❌ INSECURE: Allow all origins
app.use(cors({
  origin: '*',          // Any origin can access
  credentials: true,    // ERROR: Cannot use credentials with wildcard origin
}));
```

### 3. Input Validation

```typescript
// ✅ Validate user input before proxying
import { body, validationResult } from 'express-validator';

router.post('/users',
  requireAuth,
  requireAdmin,
  [
    body('email').isEmail().withMessage('Invalid email'),
    body('role').isIn(['user', 'super-user', 'admin']).withMessage('Invalid role'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    // ... proxy to backend
  }
);
```

### 4. Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// Apply rate limiting to auth routes
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,                    // 5 requests per window
  message: 'Too many login attempts, please try again later',
});

app.use('/bff/auth/login', authLimiter);
```

---

## Testing

### Unit Tests

**`tests/middleware/jwt.test.ts`** - Test JWT middleware

```typescript
import { describe, it, expect, vi } from 'vitest';
import { verifyToken, requireAuth } from '../../src/middleware/jwt';

describe('JWT Middleware', () => {
  it('should verify valid token', () => {
    const mockToken = 'valid.jwt.token';
    const payload = verifyToken(mockToken);
    
    expect(payload).toHaveProperty('userId');
    expect(payload).toHaveProperty('email');
    expect(payload).toHaveProperty('role');
  });
  
  it('should reject invalid token', () => {
    const mockToken = 'invalid.token';
    
    expect(() => verifyToken(mockToken)).toThrow('Invalid or expired token');
  });
  
  it('requireAuth should block unauthenticated requests', () => {
    const req = { cookies: {} } as any;
    const res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    } as any;
    const next = vi.fn();
    
    requireAuth(req, res, next);
    
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: 'Authentication required' });
    expect(next).not.toHaveBeenCalled();
  });
});
```

### Integration Tests

**`tests/routes/auth.test.ts`** - Test auth proxy routes

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import app from '../../src/index';

describe('Auth Routes', () => {
  it('POST /bff/auth/login should return JWT cookie on success', async () => {
    const response = await request(app)
      .post('/bff/auth/login')
      .send({ email: 'user@example.com', code: '123456' });
    
    expect(response.status).toBe(200);
    expect(response.headers['set-cookie']).toBeDefined();
    expect(response.headers['set-cookie'][0]).toContain('flovify_token');
  });
  
  it('GET /bff/auth/verify should require authentication', async () => {
    const response = await request(app)
      .get('/bff/auth/verify');
    
    expect(response.status).toBe(401);
    expect(response.body.error).toBe('Authentication required');
  });
});
```

---

## Frontend Integration

### API Client With BFF

**`src/lib/api.js`** - Frontend API client for BFF

```javascript
const API_BASE = '/bff'; // BFF routes under /bff/* (proxied by Nginx)

/**
 * Centralized request utility
 */
async function request(endpoint, options = {}) {
  const url = `${API_BASE}${endpoint}`;
  
  const response = await fetch(url, {
    ...options,
    credentials: 'include', // Include cookies (JWT)
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
  
  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.error || 'Request failed');
  }
  
  return data;
}

// Auth API
export const authApi = {
  login: (email, code) => request('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, code }),
  }),
  
  logout: () => request('/auth/logout', { method: 'POST' }),
  
  verify: () => request('/auth/verify'),
};

// Admin API
export const adminApi = {
  listUsers: (page = 1, limit = 20) => request(`/admin/users?page=${page}&limit=${limit}`),
  
  createUser: (userData) => request('/admin/users', {
    method: 'POST',
    body: JSON.stringify(userData),
  }),
};

// Business API
export const api = {
  getEmails: (credentialId, options) => {
    const params = new URLSearchParams(options);
    return request(`/api/ms365/emails/${credentialId}?${params}`);
  },
};
```

**Key concepts:**
- **credentials: 'include'**: Send cookies with every request (required for JWT cookie)
- **API_BASE = '/bff'**: All requests go through BFF (Nginx proxies to BFF server)
- **Single endpoint**: Frontend only knows about BFF, not backend services

---

## Common Patterns

### 1. Health Check Endpoint

```typescript
// src/routes/health.ts
import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'bff',
    timestamp: new Date().toISOString(),
  });
});

export default router;
```

### 2. Request Logging

```typescript
// Auto-logs all requests via pino-http
app.use(pinoHttp({ logger }));

// Manual logging in route handlers
router.get('/users', async (req, res) => {
  req.log.info({ admin: req.user?.email }, 'Admin accessed user list');
  
  try {
    // ... proxy logic
  } catch (error) {
    req.log.error({ error }, 'Failed to fetch users');
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

### 3. Response Transformation

```typescript
// Transform backend response for frontend needs
router.get('/dashboard', requireAuth, async (req, res) => {
  const backendData = await fetch(`${API_SERVICE_URL}/api/dashboard/${req.user?.userId}`)
    .then(r => r.json());
  
  // Frontend needs: { userName, stats: { apiCalls, tokensUsed } }
  // Backend returns: { user: { first_name, last_name }, api_stats: { calls, tokens } }
  
  const frontendData = {
    userName: `${backendData.user.first_name} ${backendData.user.last_name}`,
    stats: {
      apiCalls: backendData.api_stats.calls,
      tokensUsed: backendData.api_stats.tokens,
    },
  };
  
  res.json(frontendData);
});
```

---

## Best Practices

### ✅ Do

1. **Use httpOnly cookies for JWT** - Prevents XSS attacks
2. **Validate JWT in BFF** - Don't trust frontend tokens
3. **Log all admin actions** - Security audit trail
4. **Rate limit authentication routes** - Prevent brute force attacks
5. **Use service-to-service tokens** - Secure BFF → backend communication
6. **Aggregate parallel requests** - Reduce frontend latency
7. **Transform responses** - Adapt backend data to frontend needs
8. **Health check endpoint** - Monitor BFF availability
9. **Graceful shutdown** - Handle SIGTERM/SIGINT for clean restarts
10. **Environment configuration** - Externalize service URLs, secrets

### ❌ Don't

1. **Don't store JWT in localStorage** - Use httpOnly cookies instead
2. **Don't allow wildcard CORS with credentials** - Specify exact origin
3. **Don't proxy without validation** - Validate input before forwarding
4. **Don't expose internal service URLs** - Frontend only knows BFF
5. **Don't hardcode secrets** - Use environment variables
6. **Don't skip error handling** - Always catch network errors
7. **Don't trust frontend role claims** - Verify role in BFF middleware
8. **Don't forget request timeouts** - Prevent hanging requests
9. **Don't log sensitive data** - Avoid logging passwords, tokens
10. **Don't use BFF for static assets** - Use CDN or Nginx

---

## Troubleshooting

### Issue: CORS errors in browser

**Symptom:** `Access-Control-Allow-Origin` error in browser console

**Solution:**
```typescript
// Ensure CORS origin matches frontend URL
app.use(cors({
  origin: 'http://localhost:5173', // Must match frontend dev server
  credentials: true,
}));
```

### Issue: JWT cookie not sent from frontend

**Symptom:** `Authentication required` error despite successful login

**Solution:**
```javascript
// Frontend: Include credentials in fetch
fetch('/bff/auth/verify', {
  credentials: 'include', // Required to send cookies
});
```

### Issue: Service connection failures

**Symptom:** `Failed to connect to API service` errors

**Solution:**
```bash
# Check service URLs in .env
AUTH_BASE_URL=http://auth:8000   # Use Docker service name, not localhost
API_BASE_URL=http://api:8000

# Test service connectivity from BFF container
docker exec -it bff sh
wget -O- http://auth:8000/auth/health
```

### Issue: JWT verification fails

**Symptom:** `Invalid or expired token` errors

**Solution:**
```bash
# Ensure JWT_SECRET matches Auth Service
# BFF .env
JWT_SECRET=your-secret-key-at-least-32-chars

# Auth Service .env
JWT_SECRET=your-secret-key-at-least-32-chars  # Must be identical!
```

---

## References

### Source Code
- **Enterprise application BFF**: `d:\_dev\Enterprise application\webui\bff\`
  - `src/index.ts`: Express server setup, middleware stack
  - `src/middleware/jwt.ts`: JWT authentication middleware
  - `src/routes/auth.ts`: Authentication proxy routes
  - `src/routes/admin.ts`: Admin routes with role verification
  - `src/routes/api.ts`: API proxy with catch-all pattern

### Related Patterns
- 📎 [Feature Folder Structure](./feature-folder-structure.md) - Frontend code organization
- 📎 [React Patterns](./react-patterns.md) - Frontend component patterns
- 📎 [TanStack Query Patterns](./tanstack-query-patterns.md) - Data fetching in frontend

### External Resources
- [Express.js Documentation](https://expressjs.com/)
- [JSON Web Tokens (JWT)](https://jwt.io/)
- [pino Logging](https://getpino.io/)
- [Backend for Frontend Pattern](https://samnewman.io/patterns/architectural/bff/)

---

**Pattern Version:** 1.0.0  
**Last Updated:** 2026-01-28  
**Extracted From:** Enterprise application v0.2.11 (BFF service)
