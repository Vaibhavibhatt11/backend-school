# School ERP — Admin module: complete frontend API handoff

**Single document for frontend integration.** All paths are relative to the API base URL.

---

## 1. Base URL and versioning

| Environment | Base URL |
|-------------|----------|
| Production (Render) | `https://backend-school-app.onrender.com/api/v1` |
| Local | `http://localhost:5000/api/v1` |

**Important:** Every request path below is appended to this base (e.g. `POST {BASE}/auth/login`).

---

## 2. Global response shape

### 2.1 Success

```json
{
  "success": true,
  "data": {}
}
```

`data` may be an object, array, or nested structure depending on the endpoint.

### 2.2 Error

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message"
  }
}
```

Common codes: `VALIDATION_ERROR`, `UNAUTHORIZED`, `REQUEST_ERROR`, `DUPLICATE_VALUE`, `INTERNAL_SERVER_ERROR`, `INVALID_JSON_BODY`.

### 2.3 Pagination (list endpoints)

Many list APIs return:

```json
{
  "success": true,
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 137,
      "totalPages": 7
    }
  }
}
```

- Default `page` is often `1`, default `limit` often `20`.
- **Maximum `limit` is 100** unless an endpoint documents otherwise.

---

## 3. Authentication

### 3.1 Header

All protected routes:

```http
Authorization: Bearer <accessToken>
Content-Type: application/json
```

### 3.2 Login

**`POST /auth/login`**

Request:

```json
{
  "email": "admin@school.edu",
  "password": "Admin123!"
}
```

Response **200**:

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "clx...",
      "fullName": "School Admin",
      "email": "admin@school.edu",
      "role": "SCHOOLADMIN",
      "schoolId": "clx...",
      "branchId": null,
      "isActive": true
    }
  }
}
```

### 3.3 Refresh

**`POST /auth/refresh`**

Request:

```json
{
  "refreshToken": "<refreshToken from login>"
}
```

Response **200** (shape matches login tokens; use new `accessToken`):

```json
{
  "success": true,
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

### 3.4 Current user (JWT)

**`GET /auth/me`**

Response **200**:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clx...",
      "fullName": "School Admin",
      "email": "admin@school.edu",
      "role": "SCHOOLADMIN",
      "schoolId": "clx...",
      "branchId": null,
      "isActive": true
    }
  }
}
```

### 3.5 Logged-in admin profile (school-scoped)

**`GET /school/profile/me`**

Same roles as `/school/*`. Returns the user tied to the current school context.

Response **200**:

```json
{
  "success": true,
  "data": {
    "profile": {
      "id": "clx...",
      "fullName": "School Admin",
      "email": "admin@school.edu",
      "role": "SCHOOLADMIN",
      "schoolId": "clx...",
      "branchId": null,
      "isActive": true
    }
  }
}
```

### 3.6 Logout (optional)

**`POST /auth/logout`**

Body may include `{ "refreshToken": "..." }` to revoke refresh token.

---

## 4. Role access (admin-relevant)

| Area | Path prefix | Allowed roles |
|------|-------------|----------------|
| Dashboard | `/dashboard/*` | Any authenticated user (use school-admin token in practice) |
| School operations | `/school/*` | `SUPERADMIN`, `SCHOOLADMIN`, `HR`, `ACCOUNTANT` |
| Students (CRUD) | `/school/students/*` | `SUPERADMIN`, `SCHOOLADMIN`, `HR`, `ACCOUNTANT` |
| HR module | `/hr/*` | `SUPERADMIN`, `SCHOOLADMIN`, `HR` |
| Accountant module | `/accountant/*` | `SUPERADMIN`, `SCHOOLADMIN`, `ACCOUNTANT` |
| Superadmin | `/superadmin/*` | `SUPERADMIN` only |

### 4.1 `SUPERADMIN` and `schoolId`

For school-scoped endpoints, **`SUPERADMIN` may need `?schoolId=<id>`** in query (or body where supported) to choose a tenant. Other roles use `req.user.schoolId` automatically and **cannot** access another school’s `schoolId`.

---

## 5. Demo users (after `npm run prisma:seed`)

| Role | Email | Password |
|------|-------|----------|
| Super Admin | `super@school.edu` | `Admin123!` |
| School Admin | `admin@school.edu` | `Admin123!` |
| Accountant | `acc@school.edu` | `Admin123!` |
| HR | `hr@school.edu` | `Admin123!` |
| Teacher (linked staff) | `teacher@school.edu` | `Teacher123!` |

Use **`admin@school.edu`** for full admin UI against `/school/*`.

---

## 6. Dashboard APIs

### 6.1 School admin dashboard (primary home payload)

**`GET /dashboard/school-admin`**

Query: `schoolId` optional (`SUPERADMIN`).

Response **200** (example values; yours follow live DB):

```json
{
  "success": true,
  "data": {
    "scope": { "schoolId": "clx-demo-school" },
    "students": 1248,
    "staff": 80,
    "classes": 24,
    "subjects": 18,
    "announcements": 12,
    "pendingInvoices": 45,
    "totals": {
      "invoiceAmount": 1250000,
      "paidAmount": 816000,
      "outstandingAmount": 434000,
      "monthCollection": 142800
    },
    "ui": {
      "studentsTotal": 1248,
      "teacherPresence": 97.5,
      "teacherPresent": 78,
      "teacherTotal": 80,
      "pendingApprovals": 12,
      "attendanceTrend": [
        {
          "date": "2026-03-22",
          "presentPct": 88.5,
          "summary": { "PRESENT": 1100, "ABSENT": 80, "LATE": 40, "LEAVE": 28 }
        }
      ],
      "feeToday": 14280,
      "feePending": 434000,
      "feeVsLastWeekPct": 12.4
    }
  }
}
```

### 6.2 HR dashboard

**`GET /dashboard/hr`**

```json
{
  "success": true,
  "data": {
    "scope": { "schoolId": "clx-demo-school" },
    "staffTotal": 80,
    "attendanceToday": {
      "present": 72,
      "late": 6,
      "absent": 1,
      "leave": 1
    }
  }
}
```

### 6.3 Accountant dashboard

**`GET /dashboard/accountant`**

```json
{
  "success": true,
  "data": {
    "scope": { "schoolId": "clx-demo-school" },
    "totals": {
      "invoiceAmount": 1250000,
      "invoicePaidAmount": 816000,
      "paymentAmount": 820000,
      "outstandingAmount": 434000,
      "dueInvoices": 45,
      "monthCollection": 142800,
      "studentsWithOutstandingBalance": 38
    }
  }
}
```

---

## 7. Admin “hub” APIs (high priority for UI)

### 7.1 Pending approvals summary

**`GET /school/approvals/pending-summary`**

```json
{
  "success": true,
  "data": {
    "totalPending": 12,
    "buckets": {
      "admissions": 5,
      "leaveRequests": 3,
      "faceCheckins": 4
    },
    "topItems": [
      {
        "id": "clx...",
        "type": "ADMISSION",
        "title": "APP-00001 - Marcus Thompson",
        "submittedAt": "2026-03-28T10:15:00.000Z"
      },
      {
        "id": "clx...",
        "type": "LEAVE",
        "title": "Class Teacher",
        "submittedAt": "2026-03-27T14:00:00.000Z"
      }
    ]
  }
}
```

### 7.2 Notifications feed (delivery / activity log)

**`GET /school/notifications?page=1&limit=20`**

Optional query: `status`, `schoolId`.

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "clx...",
        "schoolId": "clx...",
        "templateId": "clx...",
        "announcementId": "clx...",
        "targetType": "AUDIENCE",
        "targetRef": "PARENT,STUDENT",
        "channel": "PUSH",
        "status": "SENT",
        "error": null,
        "payload": { "title": "Fee Reminder" },
        "createdAt": "2026-03-28T08:00:00.000Z",
        "template": {
          "id": "clx...",
          "code": "FEE_REMINDER",
          "title": "Fee Reminder",
          "channel": "PUSH"
        },
        "announcement": {
          "id": "clx...",
          "title": "Fee Reminder",
          "audience": "PARENT,FEE",
          "status": "SENT"
        }
      }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 4, "totalPages": 1 }
  }
}
```

### 7.3 Fee snapshot (KPIs)

**`GET /school/fees/snapshot`**

```json
{
  "success": true,
  "data": {
    "todayCollected": 14280,
    "pendingAmount": 3450,
    "thisWeekCollected": 88000,
    "lastWeekCollected": 76000,
    "vsLastWeekPct": 15.79
  }
}
```

### 7.4 Attendance trend

**`GET /school/attendance/trend?days=7&type=student`**

- `days`: 1–31 (default 7)
- `type`: `student` | `staff` (default `student`)

```json
{
  "success": true,
  "data": {
    "type": "student",
    "days": [
      {
        "date": "2026-03-22",
        "summary": { "PRESENT": 1100, "ABSENT": 80, "LATE": 40, "LEAVE": 28 },
        "present": 1140,
        "total": 1248,
        "presentPct": 91.35
      }
    ]
  }
}
```

### 7.5 Attendance overview (single day)

**`GET /school/attendance/overview?date=2026-03-28`**

```json
{
  "success": true,
  "data": {
    "date": "2026-03-28T00:00:00.000Z",
    "students": {
      "total": 1248,
      "summary": { "PRESENT": 1100, "ABSENT": 80, "LATE": 40, "LEAVE": 28 }
    },
    "staff": {
      "total": 80,
      "summary": { "PRESENT": 72, "ABSENT": 1, "LATE": 6, "LEAVE": 1 }
    }
  }
}
```

### 7.6 School profile (institution)

**`GET /school/profile`**

```json
{
  "success": true,
  "data": {
    "profile": {
      "id": "clx...",
      "code": "DEMO-SCHOOL",
      "name": "Demo School",
      "email": "contact@demoschool.edu",
      "phone": "+1-555-0100",
      "status": "ACTIVE",
      "timezone": "America/New_York",
      "currencyCode": "USD",
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2026-03-01T00:00:00.000Z"
    }
  }
}
```

**`PUT /school/profile`** — body (at least one field):

```json
{
  "name": "Demo School",
  "email": "contact@demoschool.edu",
  "phone": "+1-555-0100",
  "timezone": "America/New_York",
  "currencyCode": "USD"
}
```

### 7.7 School settings

**`GET /school/settings`**

```json
{
  "success": true,
  "data": {
    "settings": {
      "schoolId": "clx...",
      "name": "Demo School",
      "email": "contact@demoschool.edu",
      "phone": "+1-555-0100",
      "timezone": "America/New_York",
      "currencyCode": "USD",
      "status": "ACTIVE"
    }
  }
}
```

**`PUT /school/settings`** or **`PATCH /school/settings`** (same validation):

```json
{
  "name": "Demo School",
  "email": "office@demoschool.edu",
  "phone": "+1-555-0100",
  "timezone": "America/New_York",
  "currencyCode": "USD"
}
```

---

## 8. Representative CRUD JSON (patterns)

### 8.1 Announcements

**`GET /school/announcements?page=1&limit=20&status=SENT`**

List item fields (typical): `id`, `schoolId`, `title`, `content`, `audience`, `status`, `scheduledAt`, `sentAt`, `createdById`, `createdAt`, `updatedAt`.

**`POST /school/announcements`**

```json
{
  "title": "Parent-Teacher Meeting",
  "content": "Meeting moved to the auditorium.",
  "audience": "PARENT,STUDENT",
  "status": "DRAFT",
  "scheduledAt": "2026-04-01T08:00:00.000Z"
}
```

**`POST /school/announcements/:id/send`** — marks sent (empty body OK).

### 8.2 Fees — payment

**`POST /school/payments`**

```json
{
  "studentId": "clx-student",
  "invoiceId": "clx-invoice",
  "amount": 500,
  "method": "CASH",
  "transactionRef": "TXN-123",
  "paidAt": "2026-03-28T12:00:00.000Z",
  "notes": "Partial payment"
}
```

`method` enum: `CASH`, `CARD`, `UPI`, `BANK_TRANSFER`, `ONLINE`.

### 8.3 Fees — invoice create

**`POST /school/invoices`**

```json
{
  "studentId": "clx-student",
  "feeStructureId": "clx-fee",
  "dueDate": "2026-04-15T00:00:00.000Z",
  "amountDue": 1200,
  "notes": "Term fee"
}
```

### 8.4 Attendance mark

**`POST /school/attendance/mark`**

```json
{
  "type": "student",
  "studentId": "clx-student",
  "date": "2026-03-28T00:00:00.000Z",
  "status": "PRESENT",
  "remark": "On time"
}
```

Staff variant:

```json
{
  "type": "staff",
  "staffId": "clx-staff",
  "date": "2026-03-28T00:00:00.000Z",
  "status": "LEAVE",
  "remark": "Medical"
}
```

`status`: `PRESENT` | `ABSENT` | `LATE` | `LEAVE`.

### 8.5 Admissions application

**`POST /school/admissions/applications`**

```json
{
  "firstName": "Elena",
  "lastName": "Rodriguez",
  "email": "elena.parent@example.com",
  "phone": "+1-555-3333",
  "appliedClass": "Class 10",
  "appliedSection": "B",
  "dob": "2010-05-12T00:00:00.000Z",
  "gender": "F"
}
```

**`PATCH /school/admissions/applications/:id/status`**

```json
{
  "status": "APPROVED"
}
```

Values: `UNDER_REVIEW`, `APPROVED`, `REJECTED`.

### 8.6 Face check-in decision

**`PATCH /school/face-checkins/:id/approve`**

```json
{
  "reason": "Matched staff ID"
}
```

**`PATCH /school/face-checkins/:id/reject`**

```json
{
  "reason": "Low confidence"
}
```

---

## 9. Complete route catalog (admin-facing)

All routes below use prefix **`{BASE}`** = your `/api/v1` URL.

### 9.1 System

| Method | Path | Notes |
|--------|------|--------|
| GET | `/health` | No auth |
| GET | `/ready` | No auth; DB check |

### 9.2 Auth (`/auth`)

| Method | Path |
|--------|------|
| POST | `/auth/login` |
| POST | `/auth/refresh` |
| POST | `/auth/logout` |
| GET | `/auth/me` |
| POST | `/auth/forgot-password` |
| POST | `/auth/verify-otp` |
| POST | `/auth/reset-password` |
| POST | `/auth/change-password` |

### 9.3 Dashboard (`/dashboard`) — Bearer required

| Method | Path |
|--------|------|
| GET | `/dashboard/school-admin` |
| GET | `/dashboard/hr` |
| GET | `/dashboard/accountant` |

### 9.4 Students mount (`/school/students`) — roles: SUPERADMIN, SCHOOLADMIN, HR, ACCOUNTANT

| Method | Path |
|--------|------|
| GET | `/school/students` |
| GET | `/school/students/export` |
| POST | `/school/students` |
| POST | `/school/students/import` |
| GET | `/school/students/:id` |
| PUT | `/school/students/:id` |
| DELETE | `/school/students/:id` |
| PATCH | `/school/students/:id/status` |
| POST | `/school/students/:id/move-class` |
| POST | `/school/students/:id/documents` |
| DELETE | `/school/students/:id/documents/:docId` |

### 9.5 School (`/school`) — same roles as above

**Profile & access**

| Method | Path |
|--------|------|
| GET | `/school/profile` |
| PUT | `/school/profile` |
| GET | `/school/profile/me` |
| GET | `/school/permissions` |
| GET | `/school/admin-users` |
| POST | `/school/admin-users` |
| PUT | `/school/admin-users/:id` |

**People**

| Method | Path |
|--------|------|
| GET | `/school/parents` |
| GET | `/school/parents/:id` |
| POST | `/school/parents` |
| PUT | `/school/parents/:id` |
| POST | `/school/parents/invite` |
| POST | `/school/parents/:id/resend-otp` |
| GET | `/school/staff` |
| GET | `/school/staff/:id` |
| POST | `/school/staff` |
| PUT | `/school/staff/:id` |
| DELETE | `/school/staff/:id` |
| GET | `/school/staff/:id/documents` |
| POST | `/school/staff/:id/documents` |
| DELETE | `/school/staff/:id/documents/:docId` |

**Academic structure**

| Method | Path |
|--------|------|
| GET/POST | `/school/classes` |
| PUT/DELETE | `/school/classes/:id` |
| GET/POST | `/school/sections` |
| PUT/DELETE | `/school/sections/:id` |
| GET/POST | `/school/academic-years` |
| PUT/PATCH/DELETE | `/school/academic-years/:id` … `/activate` |
| GET/POST | `/school/terms` |
| PUT/DELETE | `/school/terms/:id` |
| GET/POST | `/school/holidays` |
| PUT/DELETE | `/school/holidays/:id` |
| GET/PUT | `/school/permissions/matrix` |
| GET/POST | `/school/subjects` |
| PUT/DELETE | `/school/subjects/:id` |

**Attendance**

| Method | Path |
|--------|------|
| GET | `/school/attendance/overview` |
| GET | `/school/attendance/trend` |
| GET | `/school/attendance/records` |
| PUT | `/school/attendance/records/:id` |
| GET | `/school/attendance/export` |
| POST | `/school/attendance/mark` |
| POST | `/school/attendance/bulk-mark` |

**Timetable & live**

| Method | Path |
|--------|------|
| GET | `/school/timetable` |
| GET | `/school/timetable/teacher/:staffId` |
| GET | `/school/timetable/class/:classId` |
| GET | `/school/timetable/conflicts` |
| POST | `/school/timetable/slots` |
| PUT/DELETE | `/school/timetable/slots/:id` |
| POST | `/school/timetable/publish` |
| GET/POST | `/school/timetable/periods` |
| PUT/DELETE | `/school/timetable/periods/:id` |
| GET/POST | `/school/live-classes/sessions` |
| PUT | `/school/live-classes/sessions/:id` |
| POST | `/school/live-classes/sessions/:id/end` |

**Fees & finance**

| Method | Path |
|--------|------|
| GET | `/school/fees/summary` |
| GET | `/school/fees/snapshot` |
| GET/POST | `/school/fees/structures` |
| PUT/DELETE | `/school/fees/structures/:id` |
| GET/POST | `/school/fees/discount-rules` |
| PUT/DELETE | `/school/fees/discount-rules/:id` |
| GET/POST | `/school/invoices` |
| POST | `/school/invoices/bulk-generate` |
| GET | `/school/invoices/:id` |
| PATCH | `/school/invoices/:id/status` |
| GET/POST | `/school/payments` |
| GET | `/school/payments/:id/receipt` |
| GET/POST | `/school/payments/:id/refunds` |
| GET | `/school/fees/due-list` |
| GET | `/school/fees/reports/collection` |
| GET | `/school/fees/reports/pending-dues` |
| GET | `/school/fees/reports/student-ledger/:studentId` |

**Communication & compliance**

| Method | Path |
|--------|------|
| GET/POST | `/school/announcements` |
| GET | `/school/announcements/:id` |
| PUT/DELETE | `/school/announcements/:id` |
| POST | `/school/announcements/:id/send` |
| GET/POST | `/school/reports/jobs` |
| POST | `/school/reports/generate` |
| GET | `/school/audit-logs` |
| GET | `/school/approvals/pending-summary` |
| GET | `/school/notifications` |
| GET/POST | `/school/notifications/templates` |
| PUT/DELETE | `/school/notifications/templates/:id` |
| GET | `/school/notifications/logs` |

**Settings & roles**

| Method | Path |
|--------|------|
| GET | `/school/settings` |
| PUT/PATCH | `/school/settings` |
| GET/POST | `/school/roles` |
| PUT/DELETE | `/school/roles/:id` |

**Face & AI FAQ**

| Method | Path |
|--------|------|
| GET | `/school/face-checkins` |
| PATCH | `/school/face-checkins/:id/approve` |
| PATCH | `/school/face-checkins/:id/reject` |
| GET/POST | `/school/ai/faqs` |
| PUT/DELETE | `/school/ai/faqs/:id` |

**Documents, backup, library, inventory, offline**

| Method | Path |
|--------|------|
| GET/POST | `/school/document-categories` |
| PUT/DELETE | `/school/document-categories/:id` |
| GET/POST | `/school/backups/exports` |
| GET/POST | `/school/library/books` |
| PUT/DELETE | `/school/library/books/:id` |
| GET/POST | `/school/library/borrows` |
| PATCH | `/school/library/borrows/:id/return` |
| GET/POST | `/school/inventory/items` |
| PUT/DELETE | `/school/inventory/items/:id` |
| GET/POST | `/school/inventory/transactions` |
| GET/POST | `/school/offline-sync/records` |
| PATCH | `/school/offline-sync/records/:id` |

**Report cards**

| Method | Path |
|--------|------|
| GET/POST | `/school/report-cards/templates` |
| PUT/DELETE | `/school/report-cards/templates/:id` |

**Exams**

| Method | Path |
|--------|------|
| GET/POST | `/school/exams` |
| GET | `/school/exams/:id/marks-status` |
| PUT/DELETE | `/school/exams/:id` |
| POST | `/school/exams/:id/marks` |
| POST | `/school/exams/:id/publish` |

**Analytics reports**

| Method | Path |
|--------|------|
| GET | `/school/reports/students` |
| GET | `/school/reports/attendance` |
| GET | `/school/reports/fees` |
| GET | `/school/reports/exam-performance` |

**Admissions**

| Method | Path |
|--------|------|
| GET | `/school/admissions/applications` |
| GET | `/school/admissions/applications/:id` |
| POST | `/school/admissions/applications` |
| PATCH | `/school/admissions/applications/:id/status` |
| POST | `/school/admissions/applications/:id/documents` |
| POST | `/school/admissions/applications/:id/onboard` |

**Transport**

| Method | Path |
|--------|------|
| GET/POST | `/school/transport/routes` |
| PUT/DELETE | `/school/transport/routes/:id` |
| GET/POST | `/school/transport/drivers` |
| GET/POST | `/school/transport/allocations` |
| PUT/DELETE | `/school/transport/allocations/:id` |

**Hostel**

| Method | Path |
|--------|------|
| GET/POST | `/school/hostel/rooms` |
| PUT/DELETE | `/school/hostel/rooms/:id` |
| GET/POST | `/school/hostel/allocations` |
| GET/POST | `/school/hostel/attendance` |
| GET/POST | `/school/hostel/visitors` |

**Events**

| Method | Path |
|--------|------|
| GET/POST | `/school/events` |
| GET/PUT/DELETE | `/school/events/:id` |
| GET/POST | `/school/events/:id/registrations` |
| POST/DELETE | `/school/events/:id/gallery` … |

**Homework & materials**

| Method | Path |
|--------|------|
| GET/POST | `/school/homework` |
| GET/PUT/DELETE | `/school/homework/:id` |
| POST | `/school/homework/:id/submit` |
| GET/POST | `/school/study-materials` |
| PUT/DELETE | `/school/study-materials/:id` |
| GET/POST | `/school/achievements` |
| DELETE | `/school/achievements/:id` |

### 9.6 HR module (`/hr`) — SUPERADMIN, SCHOOLADMIN, HR

| Method | Path |
|--------|------|
| GET | `/hr/dashboard/overview` |
| GET | `/hr/staff` |
| GET | `/hr/staff/:id` |
| GET | `/hr/leave-requests` |
| GET | `/hr/leave-requests/:id` |
| PATCH | `/hr/leave-requests/:id/status` |
| POST | `/hr/leave-requests/:id/comment` |
| GET | `/hr/attendance/performance` |
| GET | `/hr/attendance/performance/:staffId` |
| GET/PUT | `/hr/settings` |
| GET | `/hr/roles` |
| PUT | `/hr/roles/:id` |

### 9.7 Accountant module (`/accountant`) — SUPERADMIN, SCHOOLADMIN, ACCOUNTANT

| Method | Path |
|--------|------|
| GET | `/accountant/dashboard/overview` |
| GET/POST | `/accountant/fees/structures` |
| PUT/DELETE | `/accountant/fees/structures/:id` |
| GET/POST | `/accountant/invoices` |
| POST | `/accountant/invoices/bulk-generate` |
| GET | `/accountant/invoices/:id` |
| PATCH | `/accountant/invoices/:id/status` |
| GET/POST | `/accountant/payments` |
| GET | `/accountant/payments/:id` |
| GET | `/accountant/payments/:id/receipt` |
| GET | `/accountant/students/balances` |
| GET/POST | `/accountant/reports/jobs` |
| POST | `/accountant/reports/generate` |

---

## 10. Live demo data

After deploy, ensure the database is migrated and seeded:

- `npx prisma migrate deploy`
- `npm run prisma:seed`

Then admin endpoints return **real rows** from PostgreSQL (not hardcoded API responses). Counts and IDs in JSON examples above are illustrative; actual values come from your environment.

---

## 11. Swagger (if enabled)

If `SWAGGER_ENABLED=true` (often **false** in production), interactive docs:

- `GET {origin}/api/docs`
- `GET {origin}/api/docs.json`

---

## 12. Postman

Repository includes generated collections under `postman/`. Use environment variable `base_url` = `https://backend-school-app.onrender.com/api/v1` (or local equivalent).

---

**End of handoff — share this file as the single admin API contract for the frontend team.**
