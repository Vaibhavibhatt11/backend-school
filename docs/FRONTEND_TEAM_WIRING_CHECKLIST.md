# Frontend team — Parent + School Admin API wiring (no demo data)

Share **Section A** with the backend team. Use **Section B** on your side to implement screens against real APIs only (remove fake chat rows / hardcoded sample KPIs).

---

## Section A — Message for backend team (copy/paste)

**Subject:** Mobile – remove client demo data; contracts & data we need

Hi team,

We’re aligning the Flutter app so Parent + School Admin screens are fully driven by APIs (no fake chat rows or hardcoded “sample” content).

Please confirm or deliver the following:

1. **`GET /dashboard/school-admin`** and **`GET /school/approvals/pending-summary`** return **200** for migrated DBs (no 500s), so we don’t rely on client-side fallbacks for core KPIs.

2. **`GET /school/fees/summary`** — stable contract (e.g. `schemaVersion`, `totals`, `categories`) as documented; mobile reads that shape only.  
   Reference: `docs/schemas/get-school-fees-summary.response.schema.json` and `docs/MOBILE_APP_PARENT_ADMIN_HANDOFF.md`.

3. **AI – Parent**
   - **`POST /parent/ai/ask`** — response must include the assistant text in a clear field (we read **`answer`**; if you use another key, document it).
   - **`GET /parent/ai/career`** — please return suggested quick prompts for the home chips, e.g. under **`suggestions`** or **`prompts`** (array of strings, or objects with `label` / `text`). If this list is empty, the app will show no chips (no hardcoded strings on our side).

4. **Lists & pagination** — Parent notifications (`page`, `limit`) and all list endpoints return consistent `{ success, data }` with documented list + pagination fields.

5. **Optional (later):** Admin reports filters (e.g. class list) — if you expose **`GET /school/...`** (classes, branches), we can bind filters to the backend instead of static labels.

6. **OpenAPI / Postman** — keep `/api/docs.json` or collections updated so field names stay in sync.

Thanks.

**Short version (Slack):** Mobile no longer ships demo AI threads; we need career/AI to return quick prompts, ask to return **`answer`**, and dashboard + approvals + fees summary stable **200** + documented JSON so we don’t use fallbacks.

**Note:** UI copy like “Ask a question below…” is only an empty-state hint, not school data. Placeholder avatars (e.g. via.placeholder.com) are still images unless profile image URLs come from APIs.

---

## Section B — Frontend wiring checklist (what to implement now)

### Auth & routing

- Store **`accessToken`** / **`refreshToken`** from **`POST /auth/login`** (or refresh).
- Route Parent vs Admin using **`data.user.role`** or **`GET /auth/me`** → `PARENT` vs `SCHOOLADMIN` (and related admin roles).  
- Send **`Authorization: Bearer <accessToken>`** on all secured calls.

### School Admin — no demo KPIs

| Endpoint | What to bind | Notes |
|----------|----------------|------|
| `GET /api/v1/dashboard/school-admin` | Full dashboard / KPI cards | Expect `{ success: true, data: { ... } }`. On non-200, show error state — **do not** show fake numbers. |
| `GET /api/v1/school/approvals/pending-summary` | Pending approvals summary | Same. |
| `GET /api/v1/school/fees/summary` | Fees overview + category breakdown | Parse **`data.schemaVersion`**, **`data.totals`**, **`data.categories`** only (see JSON Schema in repo). |

### Parent — AI (current backend shape)

| Endpoint | Field to use | Today’s behaviour |
|----------|----------------|-------------------|
| `POST /api/v1/parent/ai/ask` | **`data.answer`** | Backend already returns a string `answer` (stub until real model). **Do not** invent fake chat history; render the returned answer. |
| `GET /api/v1/parent/ai/career` | **`data.suggestions`** | Today: **empty array `[]`**. When backend fills it, treat as quick-prompt chips — **if empty, show no chips** (no hardcoded prompt strings). |

If backend later adds **`prompts`** alongside **`suggestions`**, prefer documented field from OpenAPI/Postman.

### Parent — notifications & lists

- **`GET /api/v1/parent/notifications`** (current implementation): response is  
  `{ success: true, data: { notifications: [ { section, items: [...] } ] } } }` — **sectioned**, not offset pagination.  
- **`page` / `limit`**: backend team may extend this; until then, **do not** assume `data.items` + `data.pagination` for this route unless docs say so.
- Other list endpoints: follow **`docs/MOBILE_APP_PARENT_ADMIN_HANDOFF.md`** and **`/api/docs.json`** for exact shapes.

### Errors

- Standard shape: `{ success: false, error: { code, message } }` — map to toasts / inline errors; don’t silently fall back to demo content.

### Optional later

- Admin filter dropdowns: when **`GET /school/classes`** (and branches if added) are documented, bind labels/ids from API instead of static lists.

### QA

- After DB migrations deployed, smoke-test **dashboard**, **approvals**, **fees summary** return **200** on staging.
- Confirm OpenAPI/Postman **`baseUrl`** includes **`/api/v1`**.

---

## Section C — Short Slack for frontend devs (copy/paste)

Parent + Admin: wire screens to live APIs only — **no fake threads, no sample KPIs**. Admin: **`/dashboard/school-admin`**, **`/school/approvals/pending-summary`**, **`/school/fees/summary`** (`schemaVersion` + `totals` + `categories`). Parent AI: read **`data.answer`** from **`POST /parent/ai/ask`**; career chips from **`GET /parent/ai/career`** → **`data.suggestions`** (empty = no chips). Notifications: sectioned **`data.notifications`** until pagination is documented. Errors from API only. Details: `backend/docs/FRONTEND_TEAM_WIRING_CHECKLIST.md`.
