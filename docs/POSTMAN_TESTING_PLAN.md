# Postman — step-by-step API testing

Use this as a checklist you can copy. **Base URL** (production example):

```text
https://backend-school-app.onrender.com
```

**API prefix:**

```text
/api/v1
```

---

## Shortcut A — Import everything from OpenAPI (fastest)

If Swagger is enabled on the server:

1. Open **Postman** → **Import** → **Link**.
2. Paste:  
   `https://backend-school-app.onrender.com/api/docs.json`
3. Confirm import → you get a **Collection** with grouped requests (if the spec includes them).
4. Create an **Environment** (see below) and set `baseUrl` = `https://backend-school-app.onrender.com`  
   - If imported URLs are absolute, you may still need to add **Authorization** on the collection folder.

**Note:** If `/api/docs.json` returns 404, Swagger may be disabled in production — use **Shortcut B** or manual requests.

---

## Shortcut B — Environment + variables (recommended for manual testing)

### 1) Create an Environment

**Postman** → **Environments** → **Create Environment** → name e.g. `School ERP Prod`.

Add variables (Initial / Current):

| Variable | Example value |
|----------|----------------|
| `baseUrl` | `https://backend-school-app.onrender.com` |
| `apiPrefix` | `/api/v1` |
| `accessToken` | *(leave empty — filled after login)* |
| `refreshToken` | *(optional)* |

Save. Select this environment in the top-right dropdown.

### 2) Sanity checks (no auth)

Create a folder **01 Health** with:

**GET** `{{baseUrl}}{{apiPrefix}}/health`  
→ Expect **200** and JSON with `success: true`.

**GET** `{{baseUrl}}{{apiPrefix}}/ready`  
→ **200** = DB/redis OK; **503** = something down (still “working” as a route).

### 3) Login and save token

**POST** `{{baseUrl}}{{apiPrefix}}/auth/login`  
**Headers:** `Content-Type: application/json`  
**Body (raw JSON)** — use a real test user for the role you need:

```json
{
  "email": "YOUR_TEST_EMAIL",
  "password": "YOUR_TEST_PASSWORD"
}
```

**Tests** tab (optional — auto-save token):

```javascript
const json = pm.response.json();
if (json.data && json.data.access) {
  pm.environment.set("accessToken", json.data.access);
}
if (json.data && json.data.refresh) {
  pm.environment.set("refreshToken", json.data.refresh);
}
```

Send request → **200** → token variables should fill.

### 4) Authenticated requests

For any protected route:

**Authorization** tab → Type **Bearer Token** → Token `{{accessToken}}`  

Or **Header**:

```text
Authorization: Bearer {{accessToken}}
```

### 5) Test by role (important)

The backend **enforces roles**. One login **cannot** test every endpoint.

| What you test | Login as |
|----------------|----------|
| `/student/*` | User with role **STUDENT** |
| `/parent/*` | User with role **PARENT** (use `childId` query where required) |
| `/school/*`, `/school/students/*`, `/dashboard/*` (school) | **SCHOOLADMIN** (or allowed staff role) |
| `/hr/*` | **HR** / **SCHOOLADMIN** / **SUPERADMIN** (as per API) |
| `/accountant/*` | **ACCOUNTANT** / etc. |
| `/superadmin/*` | **SUPERADMIN** |

Repeat **Login** (step 3) with a different test account for each role, or duplicate the collection per role.

### 6) Parent-specific query

For most parent routes, add query param:

```text
?childId=<student_id_from_GET_parent_children>
```

Example:

```text
GET {{baseUrl}}{{apiPrefix}}/parent/home?childId=PASTE_CHILD_ID_HERE
```

---

## Shortcut C — Collection Runner (batch smoke test)

1. Put all requests you care about in **one collection** (or import OpenAPI collection).
2. Ensure **Login** runs **first** and saves `accessToken` (Tests script above).
3. **Collection** → **Run** → select environment → **Run School ERP Prod**.
4. Review **passed/failed** status codes (define expected 200/201 in Tests if needed).

---

## Shortcut D — Newman (CLI, copy-paste after export)

1. Export your Postman **Collection** + **Environment** as JSON.
2. Install: `npm i -g newman`
3. Run:

```bash
newman run YourCollection.json -e YourEnvironment.json
```

Useful for CI or quick regression.

---

## Built-in backend script (not Postman — optional)

If your repo defines a smoke script in `package.json` (e.g. `smoke:full`), run it from the `backend` folder after configuring `.env` and database:

```bash
npm run smoke:full
```

*(Skip this if the script file is not present — use Postman + OpenAPI import instead.)*

---

## Quick troubleshooting

| Issue | What to check |
|-------|----------------|
| **401** | Token missing/expired → login again or **POST** `/auth/refresh` with refresh token |
| **403** | Wrong **role** for this path → login with correct role |
| **404** | Wrong path — must include `/api/v1` |
| **CORS** | Browser only; Postman ignores CORS. If web app fails, fix server `CORS_ORIGIN` |
| **429** | Rate limit — wait or test locally |

---

## Minimum copy-paste checklist

```text
1. GET  {{baseUrl}}{{apiPrefix}}/health
2. POST {{baseUrl}}{{apiPrefix}}/auth/login   (body: email + password)
3. GET  {{baseUrl}}{{apiPrefix}}/auth/me      (Bearer {{accessToken}})
4. … your module paths …                      (same Bearer header)
```

Replace `{{baseUrl}}` / `{{apiPrefix}}` if you are not using Postman variables: use the full URL `https://backend-school-app.onrender.com/api/v1/...`.

---

## Files that list every path

- **All routes:** `docs/FRONTEND_TEAM_API.json`
- **Student + Parent only:** `docs/PARENT_STUDENT_MODULE_APIS.json`

Use them to tick off endpoints in Postman or to build a collection manually.
