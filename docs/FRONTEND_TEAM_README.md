# Frontend team — API handoff

## Single file to share

| File | Purpose |
|------|---------|
| **`FRONTEND_TEAM_API.json`** | **Base URL**, API prefix, auth notes, and **all HTTP routes** (method + path + module + roles). |

**Production base URL:** `https://backend-school-app.onrender.com`  
**API prefix:** `/api/v1`  
**Full API root:** `https://backend-school-app.onrender.com/api/v1`

## Regenerate after route changes

From the `backend` folder:

```bash
npm run docs:frontend-json
```

This runs `scripts/generate-frontend-api-json.js` and overwrites `docs/FRONTEND_TEAM_API.json`.

## Interactive docs

If Swagger is enabled on the deployed server:  
`https://backend-school-app.onrender.com/api/docs`  
OpenAPI JSON: `https://backend-school-app.onrender.com/api/docs.json`

## Client usage

1. `POST /api/v1/auth/login` → store `access` (and `refresh` if provided).
2. Send `Authorization: Bearer <access_token>` on protected calls.
3. Use `POST /api/v1/auth/refresh` when the access token expires.

---

*Generated listing is derived from `*.routes.js`; for exact request/response bodies, use Swagger or handler source.*
