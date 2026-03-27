# Admin Module Frontend Handoff

This is the backend contract for the admin module so frontend can replace static/mock data with live APIs.

## Base URL

- Production: `https://backend-school-app.onrender.com/api/v1`
- Local: `http://localhost:5000/api/v1`

All admin endpoints are under `{BASE_URL}/dashboard/*` and `{BASE_URL}/school/*`.

## Auth

- Login: `POST /auth/login`
- Header on every admin request: `Authorization: Bearer <accessToken>`
- Allowed roles for school-admin endpoints: `SUPERADMIN`, `SCHOOLADMIN`, `HR`, `ACCOUNTANT` (as configured by route guards).

## New/Aligned Admin Endpoints

### 1) Admin dashboard payload (UI-friendly)

- `GET /dashboard/school-admin`
- Existing totals are still returned.
- New `data.ui` fields now include:
  - `studentsTotal`
  - `teacherPresence`
  - `teacherPresent`
  - `teacherTotal`
  - `pendingApprovals`
  - `attendanceTrend[]` (7 days)
  - `feeToday`
  - `feePending`
  - `feeVsLastWeekPct`

### 2) Attendance trend

- `GET /school/attendance/trend`
- Query:
  - `days` (optional, 1..31, default `7`)
  - `type` (optional, `student|staff`, default `student`)
  - `schoolId` (optional, scoped by role)
- Response:
  - `data.type`
  - `data.days[]` with `date`, `summary`, `present`, `total`, `presentPct`

### 3) Fee snapshot

- `GET /school/fees/snapshot`
- Query:
  - `schoolId` (optional)
- Response:
  - `todayCollected`
  - `pendingAmount`
  - `thisWeekCollected`
  - `lastWeekCollected`
  - `vsLastWeekPct`

### 4) Pending approvals summary

- `GET /school/approvals/pending-summary`
- Query:
  - `schoolId` (optional)
- Response:
  - `totalPending`
  - `buckets { admissions, leaveRequests, faceCheckins }`
  - `topItems[]` (latest mixed queue)

### 5) Notifications feed

- `GET /school/notifications`
- Query:
  - `page`, `limit` (max 100)
  - `status` (optional)
  - `schoolId` (optional)
- Response uses paginated shape:
  - `data.items[]`
  - `data.pagination`

### 6) Logged-in admin profile

- `GET /school/profile/me`
- Response:
  - `data.profile { id, fullName, email, role, schoolId, branchId, isActive }`

### 7) Settings update compatibility

- `PUT /school/settings` (existing)
- `PATCH /school/settings` (new alias to same validator/update logic)

## Existing Admin Endpoints (already available)

- Attendance:
  - `GET /school/attendance/overview`
  - `GET /school/attendance/records`
  - `POST /school/attendance/mark`
  - `POST /school/attendance/bulk-mark`
  - `PUT /school/attendance/records/:id`
- Fees:
  - `GET /school/fees/summary`
  - `GET /school/invoices`
  - `POST /school/invoices`
  - `GET /school/payments`
  - `POST /school/payments`
- Announcements:
  - `GET /school/announcements`
  - `POST /school/announcements`
  - `PUT /school/announcements/:id`
  - `POST /school/announcements/:id/send`
- Audit:
  - `GET /school/audit-logs`

## Validation Notes

- Attendance trend:
  - `days` is integer `1..31`
  - `type` is enum `student|staff`
- Notifications:
  - `limit` max `100`
- Settings:
  - At least one mutable field required.
  - `currencyCode` normalized to uppercase.
- Scope:
  - `schoolId` in query/body is validated and role-scoped through server utility.

## Real Data Seed Support

Seed now includes extra admin demo data for:

- staff attendance (including leave)
- pending leave request
- pending admission application
- pending face check-in
- notification logs for sent announcements

Run:

- `npm run prisma:seed`

After seeding, dashboard and admin endpoints return non-empty real data for demo accounts.
