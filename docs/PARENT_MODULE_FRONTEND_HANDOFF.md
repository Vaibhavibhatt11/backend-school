# Parent Module – Frontend Handoff

## Base URL

- **Development:** `http://localhost:<PORT>/api/v1`  
  (Replace `<PORT>` with your backend port, e.g. `3000`.)
- **Production:** `https://backend-school-app.onrender.com/api/v1`

All parent APIs live under:

- **Full base for parent APIs:** `{BASE_URL}/parent/...`  
  Example: `https://backend-school-app.onrender.com/api/v1/parent/home`

---

## What to Share With Frontend

### 1. API spec (single source of truth)

**File:** `backend/docs/PARENT_MODULE_APIS.json`

- Endpoints for the parent-facing app (`/api/v1/parent/*`)
- Request/query/body details and response shapes
- Security notes (JWT + data isolation)

### 2. Auth

- **Login:** `POST {BASE_URL}/auth/login`  
  Body: `{ "email": "string", "password": "string" }`
- **Role:** user must have role `PARENT`
- **Header on every request:** `Authorization: Bearer <accessToken>`

### 3. Response format

- **Success:** `{ "success": true, "data": ... }`
- **Error:** `{ "success": false, "error": { "code": "string", "message": "string" } }`

---

## One-line summary you can send

> **Parent APIs:** Base URL is `https://backend-school-app.onrender.com/api/v1`. All endpoints are in `backend/docs/PARENT_MODULE_APIS.json`. Use header `Authorization: Bearer <accessToken>` (token from `POST /auth/login`). Share this JSON file with the frontend team for full request/response details.

