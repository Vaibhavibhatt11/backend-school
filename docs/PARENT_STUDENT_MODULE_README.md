# Parent & Student module — frontend handoff

## Roles (this module only)

**Only two roles exist for these APIs — nothing else:**

| Role | Use with |
|------|----------|
| **`STUDENT`** | `/api/v1/student/*` only |
| **`PARENT`** | `/api/v1/parent/*` only |

- One role per user account for this app: **either** `STUDENT` **or** `PARENT` (not staff roles).
- Do **not** use `SCHOOLADMIN`, `SUPERADMIN`, `HR`, or `ACCOUNTANT` tokens on student/parent routes — they will get **403**.

## File to share

| File | Contents |
|------|----------|
| **`PARENT_STUDENT_MODULE_APIS.json`** | Base URL, auth, **allowedRoles** (`STUDENT` + `PARENT` only), **all Student + Parent routes**, query/body notes, `requiresChildId` for Parent, checklist. |

## Quick reference

| | Student | Parent |
|---|---------|--------|
| **Base path** | `https://backend-school-app.onrender.com/api/v1/student` | `https://backend-school-app.onrender.com/api/v1/parent` |
| **Role** | `STUDENT` only | `PARENT` only |
| **Auth** | `Authorization: Bearer <token>` | Same |

**Login:** `POST /api/v1/auth/login` — account role must be exactly **`STUDENT`** or exactly **`PARENT`**.

## Parent: `childId`

Most parent endpoints need **`?childId=<studentId>`** (the linked child’s id from **`GET /api/v1/parent/children`**).

Exceptions in this module:

- **`GET /parent/children`** — no `childId`
- **`GET /parent/invoices/:invoiceId`** — no `childId` in query (access checked via invoice → student → parent link)
- **`POST /parent/ai/ask`** / **`GET /parent/ai/career`** — no `childId`

## Full platform API list

For all modules (admin, HR, school, etc.), use **`FRONTEND_TEAM_API.json`** in the same folder.
