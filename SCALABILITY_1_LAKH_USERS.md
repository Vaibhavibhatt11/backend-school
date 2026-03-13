# Scalability: Supporting ~1 Lakh (100,000) Users

This document describes what is in place and what to configure so the APIs can handle **~1 lakh users** (concurrent and total).

---

## 1. What’s Already Implemented

### 1.1 Global API rate limiting
- **Middleware:** `src/middlewares/apiRateLimit.js`
- **Behaviour:** Limits requests per IP per time window (default **300 req/min per IP**).
- **Config (env):**
  - `API_RATE_LIMIT_WINDOW_MS` (default `60000` = 1 min)
  - `API_RATE_LIMIT_MAX_PER_IP` (default `300`)
  - `API_RATE_LIMIT_USE_REDIS` = `"true"` → use Redis store (required for multiple API instances).
- **Skipped:** `/health`, `/ready`, `/auth/login` (login has its own limiter).
- **For 1L users:** Use **Redis** (`REDIS_URL` + `API_RATE_LIMIT_USE_REDIS=true`) so all API instances share the same counters.

### 1.2 Pagination caps
- **List APIs:** Max **100 items per page** (via `parsePagination` in `schoolScope.js`).
- **Export / report APIs:** Max **2000 rows** per request (`MAX_EXPORT_LIMIT` in `schoolScope.js`).
- Prevents single requests from loading too much data and keeps response times stable.

### 1.3 Database indexes (Prisma)
- **User:** `@@index([schoolId])`, `@@index([schoolId, role])` for admin-user and school-scoped lists.
- **Invoice:** `@@index([schoolId, dueDate])` for due-list and collection reports.
- Existing indexes on Student, Staff, Attendance, etc. are used for filters and pagination.
- **Action:** Run `npx prisma migrate dev` (or `deploy`) after pulling so new indexes are applied.

### 1.4 Compression & timeouts
- **Compression:** `compression()` middleware is enabled for JSON responses.
- **Server timeouts:** `SERVER_KEEP_ALIVE_TIMEOUT_MS`, `SERVER_HEADERS_TIMEOUT_MS`, `SERVER_REQUEST_TIMEOUT_MS` in env (used in `server.js`).

### 1.5 Login rate limiting
- Login already has its own rate limiter (failed attempts per IP).
- Use Redis for login limiter too when running multiple instances: `LOGIN_RATE_LIMIT_USE_REDIS=true`.

---

## 2. Required Configuration for ~1 Lakh Users

### 2.1 Database (PostgreSQL)

- **Connection pool:** Set in `DATABASE_URL`:
  - Example: `?connection_limit=30&pool_timeout=20`
  - For 1L users and multiple API instances, use **PgBouncer** (or your cloud pooler) in front of Postgres and point `DATABASE_URL` to PgBouncer with a reasonable pool size (e.g. 50–100 per app instance).
- **Resources:** Ensure enough CPU/RAM and connection capacity for your peak load (e.g. 5k–10k concurrent users).
- **Backups & replication:** Use automated backups and read replicas for reporting if needed.

### 2.2 Redis (required for 1L users / 100k concurrent)

- **Used for:**
  - Global API rate limit store (`API_RATE_LIMIT_USE_REDIS=true`).
  - Login rate limit store (`LOGIN_RATE_LIMIT_USE_REDIS=true`).
  - **Response cache** for hot read endpoints (dashboard, profile, permissions, `/auth/me`) when `CACHE_ENABLED=true`.
- **Why:** With multiple API instances, in-memory rate limits are per-instance; Redis gives one limit per IP across all instances. Caching reduces DB load under 100k concurrent users.
- Set `REDIS_URL` (e.g. `redis://localhost:6379` or managed Redis). Cache uses the same Redis; optional env: `CACHE_TTL_DASHBOARD_SEC`, `CACHE_TTL_PROFILE_SEC`, `CACHE_TTL_ME_SEC`, `CACHE_TTL_PERMISSIONS_SEC`, `CACHE_KEY_PREFIX`.

### 2.3 Environment variables (production)

```env
# Rate limiting (per IP) – adjust if you have higher traffic per IP
API_RATE_LIMIT_WINDOW_MS=60000
API_RATE_LIMIT_MAX_PER_IP=300
API_RATE_LIMIT_USE_REDIS=true

# Redis (required for multi-instance rate limiting)
REDIS_URL=redis://your-redis-host:6379
LOGIN_RATE_LIMIT_USE_REDIS=true

# Cache (hot reads; requires Redis)
CACHE_ENABLED=true
CACHE_TTL_DASHBOARD_SEC=90
CACHE_TTL_PROFILE_SEC=300
CACHE_TTL_ME_SEC=120
CACHE_TTL_PERMISSIONS_SEC=3600

# DB pool (if not using PgBouncer, set in DATABASE_URL)
# DATABASE_URL="...?connection_limit=30&pool_timeout=20"
```

### 2.4 Horizontal scaling (multiple API instances)

- App is **stateless** (JWT in header; no in-memory session store).
- Run **multiple Node processes** behind a **load balancer** (e.g. Nginx, AWS ALB, Cloud Load Balancing).
- Use **Redis** for both API and login rate limit so limits are shared across instances.
- Health: `GET /api/v1/health` and `GET /api/v1/ready` for load balancer checks.

---

## 3. Optional Improvements for Very High Load

### 3.1 Caching (implemented for 100k concurrent)
- **Module:** `src/lib/cache.js` (get/set/del; no-op when Redis missing or `CACHE_ENABLED=false`).
- **Cached endpoints:**  
  - Dashboards: school-admin, HR, accountant (TTL `CACHE_TTL_DASHBOARD_SEC`, default 90s).  
  - `GET /school/profile` (TTL `CACHE_TTL_PROFILE_SEC`, default 300s); invalidated on `PUT /school/profile`.  
  - `GET /school/permissions` (TTL `CACHE_TTL_PERMISSIONS_SEC`, default 3600s).  
  - `GET /auth/me` (TTL `CACHE_TTL_ME_SEC`, default 120s).
- Set `CACHE_ENABLED=true` and `REDIS_URL` for cache to be active.

### 3.2 Background jobs (bulk & reports)
- **Bulk import (students):** For very large files (e.g. 10k+ rows), consider queuing a job and processing in a worker; API returns job id and frontend polls status.
- **Report generation:** `POST /reports/generate` already creates a `ReportJob` with status `QUEUED`; implement a **worker** that processes the queue, generates the file, and updates `fileUrl` and status. This keeps API response time low and avoids timeouts for 1L users.

### 3.3 Database read replicas
- Use a **read replica** for heavy read-only endpoints (e.g. list students, list invoices, reports) if write volume is high. Prisma supports multiple datasources (e.g. read URL) in schema; can be introduced when needed.

### 3.4 CDN & static assets
- Serve static assets (e.g. uploaded documents, logos) via **CDN** and store files in **object storage** (S3/R2); keep API focused on JSON and metadata.

---

## 4. 100k Users *at One Time* (Concurrent)

For **~1 lakh concurrent users**, ensure:

1. **PgBouncer** (or cloud pooler) in front of PostgreSQL so connection count stays bounded (e.g. 100–200 total); set `DATABASE_URL` to PgBouncer. Each API instance should use a **low** `connection_limit` (e.g. 10–20) so N instances × limit stays within PgBouncer’s pool.
2. **Redis** for rate limiting and **response cache** (`REDIS_URL`, `API_RATE_LIMIT_USE_REDIS=true`, `CACHE_ENABLED=true`). Cache absorbs repeated dashboard/profile/permissions/me traffic and reduces DB load.
3. **Multiple API instances** behind a load balancer; app is stateless (JWT + Redis for limits/cache).
4. **Tune rate limits** if needed: e.g. higher `API_RATE_LIMIT_MAX_PER_IP` if each “user” is one IP with many tabs; keep login limits strict.

---

## 5. Checklist for 1 Lakh Users

| Item | Status / action |
|------|------------------|
| Global API rate limit (per IP) | Done (enable Redis in prod) |
| Login rate limit | Done (enable Redis in prod) |
| Pagination max (list 100, export 2000) | Done |
| DB indexes (User, Invoice, etc.) | Done (run migrations) |
| DATABASE_URL connection pool / PgBouncer | Configure in prod |
| REDIS_URL + API_RATE_LIMIT_USE_REDIS | Set in prod |
| Multiple API instances + load balancer | Deploy as needed |
| Compression | Done |
| Server timeouts | Done (env) |
| Background worker for report jobs | Optional (recommended for heavy reports) |
| Dashboard / profile / permissions / me caching | Done (Redis + CACHE_ENABLED) |
| Read replica | Optional |

---

## 6. Running migrations after index changes

New indexes were added on `User` and `Invoice`. Apply them with:

```bash
npx prisma migrate dev --name add_scalability_indexes
# or in production:
npx prisma migrate deploy
```

Then regenerate the client if needed:

```bash
npx prisma generate
```

---

With the above in place (especially **Redis**, **connection pooling / PgBouncer**, and **horizontal scaling**), the APIs are in a position to handle **~1 lakh users**; tune rate limits and pool sizes based on real traffic and load tests.

---

## 7. New modules (Admissions, Transport, Hostel, Events, Homework, Student portal)

All new school and student-portal APIs use the same scalability patterns:

- **Pagination:** List endpoints use `page` and `limit` (capped at 100 via `parsePagination` in `schoolScope.js`).
- **School-scoped:** Queries are filtered by `schoolId`; SUPERADMIN passes `schoolId` in query/body.
- **Indexes:** New Prisma models include `@@index([schoolId, ...])` where needed for list/filter performance.
- **Stateless:** Student portal uses JWT; no server-side session store.

For **millions of concurrent users**, continue to use Redis (rate limit + cache), PgBouncer/connection pool, multiple API instances, and consider read replicas for report/analytics and background workers for bulk operations (e.g. admission onboarding, report generation).
