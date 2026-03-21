# Scaling & Reliability (1M+ Users, Quick Response)

## Database

### Indexes (student API and high-traffic paths)

- **StudentAttendance**: `[studentId, date]` – student attendance list by student + date range.
- **ExamResult**: `[studentId, createdAt]` – report cards and exam results by student.
- **Homework**: `[schoolId, classId, isPublished]` – homework list by school/class.
- **Existing**: Invoice `[schoolId, studentId, createdAt]`, Payment `[schoolId, studentId, paidAt]`, Event `[schoolId, startDate]`, EventRegistration `[schoolId, eventId]`, etc.

### Connection pooling

- **Prisma**: Single `PrismaClient` per process (singleton in `src/lib/prisma.js`). Do not create a new client per request.
- **Production**: Add `?connection_limit=N` to `DATABASE_URL` (e.g. `20`–`50` per app instance). Total DB connections ≈ (instances × connection_limit); keep below PostgreSQL `max_connections`.
- **PostgreSQL**: Tune `max_connections`, `shared_buffers`, `work_mem` per your host. Use a managed DB (e.g. Render, RDS) with connection pooling (PgBouncer) if you run many app instances.

### Migrations

- After changing schema, run: `npx prisma migrate dev` (dev) or `npx prisma migrate deploy` (prod).
- New indexes are applied via migrations; they are online-friendly but may take time on large tables.

---

## Caching (quick response)

- **Redis**: Set `CACHE_ENABLED=true` and Redis URL. Student dashboard, profile, timetable, and exams use `getOrSet` with TTL (default 60–120s).
- **TTL**: `CACHE_TTL_STUDENT_DASHBOARD_SEC`, `CACHE_TTL_STUDENT_OTHER_SEC` (optional). Shorter TTL = fresher data, more DB load.
- **Invalidation**: Profile cache is cleared on `PUT /student/profile`. List caches rely on TTL.

---

## API reliability

- **Auth**: All `/student/*` routes use `requireAuth` (401 if no JWT) and `resolveStudent` (403 if not STUDENT). No cross-student data leakage.
- **Validation**: Params and body validated/sanitized (see `student.security.js`). Invalid input returns 400.
- **Errors**: Try/catch in handlers; errors passed to `next(e)` for central error handler (4xx/5xx JSON).
- **Pagination**: List endpoints use `parsePagination` (max limit 100). Prevents oversized responses and timeouts.

---

## Handling 1M concurrent users

1. **Horizontal scaling**: Run multiple app instances behind a load balancer. Stateless API; only DB and Redis are shared.
2. **Database**: Use a robust PostgreSQL (e.g. managed with replicas). Prefer read replicas for read-heavy student APIs if needed; Prisma can be pointed at replica for reads (custom).
3. **Redis**: Use a managed Redis (e.g. Redis Cloud, ElastiCache). Caching reduces DB load for dashboard/profile/timetable/exams.
4. **Connection limit**: Keep `connection_limit` per instance modest (e.g. 20–50). With 100 instances, 50 each = 5000 connections; use PgBouncer or a DB that supports high connections.
5. **Rate limiting**: Use `express-rate-limit` (or rate-limit-redis for cluster) on login and sensitive routes so one client cannot exhaust resources.
6. **Health checks**: Expose `/health` or `/ready` that checks DB (and optionally Redis). Load balancer should use it for instance health.
7. **CDN**: Serve static assets and, if any, public docs via CDN to reduce app load.

---

## Quick checklist

- [ ] Migrations applied: `npx prisma migrate deploy`
- [ ] `DATABASE_URL` includes `?connection_limit=N` in production
- [ ] Single Prisma client (no `new PrismaClient()` per request)
- [ ] Redis configured and `CACHE_ENABLED=true` for cacheable student APIs
- [ ] Rate limiting enabled on auth and/or global
- [ ] Health endpoint checks DB (and Redis if used)
- [ ] Multiple app instances behind load balancer for high concurrency
