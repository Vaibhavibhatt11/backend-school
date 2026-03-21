# Student Module – Frontend Handoff

## Base URL

- **Development:** `http://localhost:<PORT>/api/v1`  
  (Replace `<PORT>` with your backend port, e.g. `3000`.)
- **Production:** `https://backend-school-app.onrender.com/api/v1`

All student APIs live under this base:

- **Full base for student APIs:** `{BASE_URL}/student/...`  
  Example: `https://backend-school-app.onrender.com/api/v1/student/dashboard`

---

## What to Share With Frontend

### 1. API spec (single source of truth)

**File:** `backend/docs/STUDENT_MODULE_APIS.json`

- 35 endpoints with method, path, query, body, and response shape.
- Grouped by submodule (Dashboard, Profile, Homework, Fees, etc.).
- Auth, errors, pagination, and security notes.

They should use this file (or a generated client from it) for integration.

### 2. Auth

- **Login:** `POST {BASE_URL}/auth/login`  
  Body: `{ "email": "string", "password": "string" }`  
  Response: `{ "success": true, "data": { "accessToken", "refreshToken", "user" } }`
- **Student APIs:** Send the token on every request:  
  **Header:** `Authorization: Bearer <accessToken>`
- **Role:** User must have role **STUDENT** and a linked Student profile. Otherwise they get **403**.

### 3. Response format

- **Success:** `{ "success": true, "data": ... }`
- **Error:** `{ "success": false, "error": "message" }` with HTTP 4xx/5xx
- **Lists:** `data.items` + `data.pagination`: `{ page, limit, total, totalPages }`

### 4. Base URL they should use

Give them one base URL per environment, e.g.:

| Environment | Base URL |
|-------------|----------|
| Local      | `http://localhost:3000/api/v1` |
| Production | `https://backend-school-app.onrender.com/api/v1` |

All student paths are relative to this: e.g. `GET /student/dashboard` → `GET {BASE_URL}/student/dashboard`.

---

## One-line summary you can send

> **Student APIs:** Base URL is `https://backend-school-app.onrender.com/api/v1`. All 35 endpoints are in `backend/docs/STUDENT_MODULE_APIS.json`. Use header `Authorization: Bearer <accessToken>` (token from `POST /auth/login`). Success responses are `{ success: true, data: ... }`; errors are `{ success: false, error: "..." }`. Share that JSON file with the frontend team for full request/response details.
