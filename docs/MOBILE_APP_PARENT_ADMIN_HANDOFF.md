# Mobile app (Flutter) — Parent & Admin API handoff

This document answers the integration checklist for **Parent** and **School Admin** flows. **Staff (TEACHER) screens are out of scope** for this milestone; those routes exist on the server but are not listed below as required for this release.

All paths below are prefixed with **`/api/v1`** unless noted.

---

## 1. Base URL & versioning

| Environment | URL pattern | Notes |
|---------------|-------------|--------|
| **Production** | `https://<your-host>/api/v1` | Set `<your-host>` from deployment (e.g. Render custom domain). |
| **Staging / QA** | Same pattern on staging host | Not fixed in repo; use your team’s staging base. Backend exposes `PUBLIC_BASE_URL` in `.env` for links/emails only — **clients should configure the API base URL in the app**. |
| **Local** | `http://localhost:<PORT>/api/v1` | Default `PORT` from `.env` is `5000` (`backend/.env.example`). |

- **Version**: API is **`v1`** (mounted at `/api/v1` in `src/app.js`).
- **Health**: `GET /api/v1/health` — use for connectivity checks.

---

## 2. Machine-readable API spec

| Artifact | Location | Notes |
|----------|----------|--------|
| **OpenAPI JSON** | `GET /api/docs.json` | Available when `SWAGGER_ENABLED=true` (default in non-production; can be enabled in prod). Interactive UI: `GET /api/docs`. |
| **OpenAPI generator** | `backend/src/docs/openapi.js` | Builds spec from route files under `src/modules`. |
| **Postman** | `backend/postman/School-ERP-Admin.postman_collection.json`, `School-ERP-Parent.postman_collection.json`, `FRONTEND_COLLECTIONS.json` | Import + set `baseUrl` variable to `https://host/api/v1`. |
| **API catalog (JSON)** | `backend/docs/API_CATALOG.json`, `PARENT_MODULE_APIS.json`, `APP_MODULE_APIS.json` | Machine-readable lists used for frontend tooling. |

**Minimum for mobile (this milestone):** Parent collection + Admin/school routes from the admin collection; confirm `baseUrl` includes `/api/v1`.

---

## 3. Auth contract

### 3.1 Login

- **`POST /api/v1/auth/login`**
- **Body (JSON):** `{ "email": string, "password": string }` (email normalized to lowercase on server).

**200 response:**

```json
{
  "success": true,
  "data": {
    "accessToken": "<jwt>",
    "refreshToken": "<jwt>",
    "user": {
      "id": "...",
      "fullName": "...",
      "email": "...",
      "role": "PARENT | SCHOOLADMIN | ...",
      "schoolId": "... | null",
      "branchId": "... | null",
      "isActive": true
    }
  }
}
```

### 3.2 Token expiry (defaults)

From `backend/.env.example` / `src/config/env.js`:

| Token | Env | Default |
|-------|-----|---------|
| Access | `ACCESS_TOKEN_EXPIRES_IN` | **`15m`** |
| Refresh | `REFRESH_TOKEN_EXPIRES_IN` | **`7d`** |

Decode JWT `exp` for exact expiry per deployment.

### 3.3 Refresh

- **`POST /api/v1/auth/refresh`**
- **Body:** `{ "refreshToken": "<refresh jwt>" }`
- **200:** Same shape as login (`data.accessToken`, `data.refreshToken`, `data.user`). Old refresh row is revoked; a new refresh token is issued.

### 3.4 Logout

- **`POST /api/v1/auth/logout`**
- **Body:** `{ "refreshToken": "<optional>" }` — if omitted or empty, returns success without revoking (idempotent “logged out” message).
- **200:** `{ "success": true, "data": { "message": "Logged out" } }`

### 3.5 Current user (recommended for routing)

- **`GET /api/v1/auth/me`**
- **Header:** `Authorization: Bearer <accessToken>`
- **200:** `{ "success": true, "data": { "user": { ... same fields as toSafeUser } } }`
- Cached briefly server-side (Redis when enabled).

### 3.6 JWT claims (access token)

Payload includes (HS256):

- `sub` — user id  
- `email`  
- `role` — **`PARENT`**, **`SCHOOLADMIN`**, `SUPERADMIN`, `HR`, `ACCOUNTANT`, `TEACHER`, `STUDENT` (see Prisma `Role` enum)  
- `schoolId`, `branchId` (nullable)  
- `tokenType`: **`access`**  
- `iat`, `exp`

**Mobile routing:** Use **`data.user.role`** from login/refresh, or **`GET /auth/me`**, in addition to optional JWT decode — do not rely on the path alone.

### 3.7 Authorization header

Send **`Authorization: Bearer <accessToken>`** on all secured routes. Middleware also tolerates `x-access-token` / `auth-token` / `token` (see `src/middlewares/auth.js`).

---

## 4. Standard error format

Success:

```json
{ "success": true, "data": { ... } }
```

Error (typical):

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED | VALIDATION_ERROR | REQUEST_ERROR | DUPLICATE_VALUE | INTERNAL_SERVER_ERROR | ...",
    "message": "Human-readable message"
  }
}
```

| HTTP | When |
|------|------|
| **400** | Validation (`ZodError` → `VALIDATION_ERROR`), bad OTP, etc. |
| **401** | Missing/invalid token, bad credentials (`UNAUTHORIZED`) |
| **403** | Forbidden (e.g. school scope) — often `REQUEST_ERROR` with `statusCode` on custom errors |
| **404** | e.g. user not found on `/auth/me` |
| **409** | Prisma unique violation → `DUPLICATE_VALUE` |
| **500** | Unhandled / Prisma → `INTERNAL_SERVER_ERROR` (generic message; details logged server-side) |

Malformed JSON body may include `error.detail` (`INVALID_JSON_BODY`).

---

## 5. Parent APIs (PARENT role only)

Mounted at **`/api/v1/parent`** (`src/routes/index.js` + `requireRole(["PARENT"])`).

| Method & path | Notes |
|---------------|--------|
| `GET /parent/children` | Linked students for this parent. |
| `GET /parent/home` | Dashboard-style home; often uses default child. |
| `GET /parent/announcements` | |
| `GET /parent/notifications` | Pagination: `page`, `limit` (see handler). |
| `GET /parent/attendance` | Query: **`childId`** (optional; default child), **`month`** (optional). |
| `GET /parent/fees` | Query: **`childId`**. |
| `GET /parent/invoices/:invoiceId` | Path param `invoiceId`. |
| `GET /parent/timetable` | Query: **`childId`**, **`day`** (where applicable). |
| `GET /parent/progress-reports` | Query: **`childId`**, **`term`** optional. |
| `GET /parent/live-classes` | Query: **`childId`**. |
| `GET /parent/profile-hub` | Query: **`childId`**. |
| `GET /parent/library` | Query: **`childId`**; pagination/search in handler. |
| `GET /parent/documents` | Query: **`childId`**; pagination. |
| `POST /parent/ai/ask` | Body per handler (scoped to child). |
| `GET /parent/ai/career` | Query: **`childId`**. |
| `GET /parent/settings` | Parent preferences. |
| `PUT /parent/settings` | Updates settings. |

**Query params:** Most list/detail endpoints that are child-specific accept **`childId`** to select which linked student; if omitted, server resolves a **default child** where implemented (`resolveRequestedOrDefaultChild` in `parent.handlers.js`).

**Response schemas:** Shapes are consistent `{ success, data }` per endpoint; for a field-level list see **`backend/docs/PARENT_MODULE_APIS.json`** and generated JSON under `docs/` + OpenAPI when enabled.

---

## 6. Admin (school) APIs (SCHOOLADMIN + SUPERADMIN + HR + ACCOUNTANT)

Mounted under **`/api/v1/school`** with **`requireRole(["SUPERADMIN","SCHOOLADMIN","HR","ACCOUNTANT"])`**. Mobile “admin” for this milestone typically uses **`SCHOOLADMIN`** (or `SUPERADMIN` with `schoolId` query where required).

**Dashboard (separate mount):** `auth` only — **`/api/v1/dashboard`**

| Method & path | Purpose |
|---------------|---------|
| `GET /dashboard/school-admin` | School admin KPI dashboard. Query: optional **`schoolId`** for `SUPERADMIN` only. |

**School module:** base **`/api/v1/school`**

| Method & path | Purpose |
|---------------|---------|
| `GET /school/approvals/pending-summary` | Pending admissions / leave / face check-ins summary. Query: optional **`schoolId`** (superadmin). |
| `GET /school/notifications` | List notification logs. Query: **`page`**, **`limit`**, **`schoolId`**, **`status`**. |
| `GET /school/fees/snapshot` | Today / week fee snapshot vs last week. |
| `GET /school/fees/summary` | Totals + **per–fee-structure category breakdown** (stable contract). |
| `GET /school/attendance/trend` | Attendance trend. |
| `GET /school/attendance/overview` | Overview. |
| `GET /school/profile/me` | Logged-in admin user profile in school context. |
| `GET /school/profile` | School profile. |
| `GET /school/settings` | School settings. |
| `PUT /school/settings` / `PATCH /school/settings` | Update settings. |
| `GET /school/announcements` | List announcements (admin). |
| `GET /school/audit-logs` | Audit log list (pagination/filters per handler). |

**School scope:** Non–super-admin users must use their JWT **`schoolId`**; optional `schoolId` query param cannot point at another school.

---

## 7. Stable JSON schema — `GET /school/fees/summary`

**File:** `backend/docs/schemas/get-school-fees-summary.response.schema.json`

Response includes:

- **`data.schemaVersion`** — e.g. `"1.0.0"` (bump only on breaking changes)  
- **`data.totals`** — `amountDue`, `amountPaid`, `outstanding`, `collections`, `feeStructures` (count)  
- **`data.categories`** — array of `{ feeStructureId, name, amountDue, amountPaid, outstanding, invoiceCount }` (per fee structure; uncategorized invoices grouped under `name: "Uncategorized"`).

---

## 8. Route map (requested name → actual path)

| You asked for | Actual route on this server |
|---------------|-------------------------------|
| `GET /auth/me` | **`GET /api/v1/auth/me`** |
| `POST /auth/logout` | **`POST /api/v1/auth/logout`** |
| Parent routes | **`/api/v1/parent/...`** (as in §5) |
| Admin dashboard | **`GET /api/v1/dashboard/school-admin`** |
| School admin | **`/api/v1/school/...`** (as in §6) |

No separate microservice: single Express app.

---

## 9. Known issues & status (dashboard / approvals / fees)

| Issue | Status |
|-------|--------|
| `GET /dashboard/school-admin` | **500** if DB was missing **`AdmissionApplication`** / related tables. **Fix:** run **`prisma migrate deploy`** (includes migration `20260328120000_admission_application_tables` — admissions tables). |
| `GET /school/approvals/pending-summary` | Same root cause; **fixed** after migrations applied. |
| `GET /school/fees/summary` | Response extended with **`schemaVersion`** + **`categories`**; see JSON Schema in §7. |

**ETA:** After deploy includes latest migrations + release, core reads above should return **200** for valid tokens and school scope.

---

## 10. Out of scope (this phase)

- **Staff / TEACHER** mobile flows and dedicated teacher APIs are **not** part of this milestone checklist.  
- Routes under `/hr`, `/accountant`, `/superadmin`, `/student`, and teacher-only school endpoints remain available for other clients but are **not** required to be finalized for Parent/Admin mobile QA.

---

## 11. Short message (Slack / WhatsApp)

Hi — mobile milestone is **Parent + School Admin** only; Staff later. Please use **Base URL + `/api/v1`**, **`Authorization: Bearer`** access token, **role from `user.role` or `GET /auth/me`**. Machine-readable: **OpenAPI** at `/api/docs.json` (when Swagger enabled), **Postman** in `backend/postman/`. **Errors:** `{ success: false, error: { code, message } }`. **Stable fees summary:** `docs/schemas/get-school-fees-summary.response.schema.json`. **Dashboard / approvals 500s** were due to missing DB tables — **deploy latest Prisma migrations** (admissions). Staff APIs not needed this round.
