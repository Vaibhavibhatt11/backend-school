# Parent Module Frontend Handoff

This guide is for integrating the parent app against production backend without guesswork.

## Base URL

- Production: `https://backend-school-hqkl.onrender.com/api/v1`
- Local: `http://localhost:5000/api/v1`

All parent endpoints are under: `{BASE_URL}/parent/*`

## Authentication

- Parent and student use the same login endpoint:
  - `POST /auth/login`
- Send access token on every parent request:
  - `Authorization: Bearer <accessToken>`

### Login Request

`POST /auth/login`

```json
{
  "email": "parent@school.edu",
  "password": "Parent123!"
}
```

### Login Success Shape

```json
{
  "success": true,
  "data": {
    "accessToken": "jwt",
    "refreshToken": "jwt",
    "user": {}
  }
}
```

## Parent API Contract

Top-level response pattern:

- Success: `{ "success": true, "data": ... }`
- Error: `{ "success": false, "error": { "code": "...", "message": "..." } }`

`childId` is now optional on most endpoints.  
If omitted, backend uses the first child linked to that parent.

## Endpoint Map (Frontend Ready)

### 1) Children

- `GET /parent/children`
  - Query: none
  - Returns: `data.children[]`
  - Item fields: `id`, `name`, `grade`, `active`

### 2) Home Dashboard

- `GET /parent/home`
  - Query:
    - `childId` (optional, recommended)
    - `month` (optional, `YYYY-MM`)
  - Returns fields:
    - `childName`, `childGrade`, `attendance`, `feesDue`, `feesDueDate`
    - `upcomingClass`, `classStartIn`
    - `recentNotices[]`, `subjectScores{}`

### 3) Communication

- `GET /parent/announcements`
  - Query:
    - `childId` (optional, recommended)
    - `type` (optional: `all|urgent|teacher`)
  - Returns: `data.announcements[]`

- `GET /parent/notifications`
  - Query: `childId` (optional, recommended)
  - Returns: `data.notifications[]` grouped by section
  - Group shape: `{ section, items[] }`

### 4) Attendance / Academics

- `GET /parent/attendance`
  - Query:
    - `childId` (optional, recommended)
    - `month` (optional, `YYYY-MM`)
  - Returns:
    - `calendarDays[]`
    - `attendanceStats` (`present`, `absent`, `late`)

- `GET /parent/timetable`
  - Query:
    - `childId` (optional, recommended)
    - `day` (optional, `YYYY-MM-DD` or day number `1..31`)
  - Returns: `data.items[]`

- `GET /parent/progress-reports`
  - Query:
    - `childId` (optional, recommended)
    - `term` (optional)
  - Returns:
    - `studentName`, `studentClass`, `academicYear`, `selectedTerm`
    - `gpa`, `subjectScores`, `attendance`, `feeHistory[]`

- `GET /parent/live-classes`
  - Query: `childId` (optional, recommended)
  - Returns:
    - `liveClass` (nullable)
    - `upcomingClasses[]`

### 5) Fees

- `GET /parent/fees`
  - Query: `childId` (optional, recommended)
  - Returns:
    - `totalOutstanding`
    - `invoices[]`
    - `overdueInvoices[]`

- `GET /parent/invoices/:invoiceId`
  - Query: none
  - Path param: `invoiceId`
  - Returns:
    - `invoice`
    - `paymentHistory[]`

### 6) Profile / Library / Documents

- `GET /parent/profile-hub`
  - Query: `childId` (optional, recommended)
  - Returns:
    - `studentName`, `studentClass`, `dob`, `bloodGroup`
    - `fatherName`, `motherName`, `medicalInfo`
    - `academicYear`, `currentTermPercentage`, `classAvg`
    - `subjectScores`, `documents`

- `GET /parent/library`
  - Query:
    - `childId` (optional, recommended)
    - `page` (optional)
    - `limit` (optional)
    - `search` (optional)
  - Returns:
    - `search`, `recommendedBooks[]`, `activeLoans[]`
    - `pagination { page, limit, total, totalPages }`

- `GET /parent/documents`
  - Query:
    - `childId` (optional, recommended)
    - `page` (optional)
    - `limit` (optional)
  - Returns:
    - `documents[]`
    - `pagination { currentPage, totalPages }`

### 7) Settings

- `GET /parent/settings`
  - Query: `childId` (optional, recommended)
  - Returns:
    - `preferences`
    - `pushNotificationsEnabled`
    - `faceIdEnabled`
    - `selectedLanguage`
    - `darkModeOption`

- `PUT /parent/settings`
  - Query: `childId` (optional, recommended)
  - Body: settings object or `{ "preferences": {...} }`
  - Returns: saved settings record in `data`

### 8) AI

- `POST /parent/ai/ask`
  - Body:
    - `{ "question": "..." }` or `{ "prompt": "..." }`
  - Returns:
    - `data.answer`

- `GET /parent/ai/career`
  - Returns:
    - `data.suggestions[]`

## Suggested Frontend Flow

1. Login parent user via `POST /auth/login`.
2. Call `GET /parent/children`.
3. Store selected `childId` in app state.
4. Pass `childId` on all child-specific calls (recommended for consistency).
5. Use token refresh flow when 401 is returned.

## Common Integration Mistakes

- Wrong base URL (`/api/v1` missing).
- Double path concatenation (`.../parent/children/parent/children`).
- Missing `Authorization` header.
- Using non-parent user token for parent routes.

## Quick Postman Check

- Import: `postman/School-ERP-Parent.postman_collection.json`
- Set env `base_url = https://backend-school-hqkl.onrender.com/api/v1`
- Run:
  1. `POST /auth/login (PARENT user)`
  2. `GET /parent/children`
  3. Any other `/parent/*` request
