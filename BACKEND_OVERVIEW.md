# Backend folder — current overview

Quick reference for the `backend` folder structure, database, and APIs.

---

## 1. Tech stack

| Item | Choice |
|------|--------|
| Runtime | Node 20.x |
| Framework | Express 5 |
| ORM | Prisma |
| Database | PostgreSQL |
| Auth | JWT + refresh tokens (bcrypt, jsonwebtoken) |
| Rate limit | express-rate-limit (+ optional Redis via rate-limit-redis) |
| Docs | Swagger UI at `/api/docs` (when `SWAGGER_ENABLED=true` or non-production) |
| File upload | Multer (e.g. Firebase creds in superadmin) |

---

## 2. Folder structure

```
backend/
├── prisma/
│   ├── schema.prisma    # Full DB schema (~750 lines)
│   └── seed.js          # Seed: plans, platform config, security, demo school, users
├── src/
│   ├── app.js           # Express app, CORS, helmet, /api/v1 routes, Swagger, error handler
│   ├── server.js        # Entry: load env, start server
│   ├── config/
│   │   ├── env.js       # Env validation
│   │   └── redis.js     # Redis client (optional)
│   ├── docs/
│   │   └── openapi.js   # OpenAPI spec for Swagger
│   ├── lib/
│   │   └── prisma.js    # Prisma client singleton
│   ├── middlewares/
│   │   ├── auth.js           # JWT auth, attach req.user
│   │   ├── authRateLimit.js  # Login rate limiter
│   │   ├── errorHandler.js
│   │   ├── notFound.js
│   │   └── requireRole.js   # Role-based access (SUPERADMIN, SCHOOLADMIN, HR, ACCOUNTANT)
│   ├── modules/
│   │   ├── auth/           # auth.routes.js, auth.handlers.js
│   │   ├── dashboard/      # dashboard.routes.js, dashboard.handlers.js
│   │   ├── superadmin/     # superadmin.routes.js, superadmin.handlers.js
│   │   ├── school/         # school.routes.js + many *handlers.js (people, academic, schedule, finance, misc, exams, advanced)
│   │   ├── students/       # students.routes.js, students.handlers.js
│   │   ├── hr/             # hr.routes.js, hr.handlers.js
│   │   └── accountant/     # accountant.routes.js, accountant.handlers.js
│   ├── routes/
│   │   └── index.js        # Mounts all modules under /api/v1
│   ├── services/
│   │   ├── health.js       # Readiness (DB, Redis)
│   │   └── mailer.js
│   └── utils/
│       ├── httpErrors.js
│       └── schoolScope.js
├── scripts/              # e.g. full-api-smoke, k6 load
├── postman/              # Postman collections (if any)
├── package.json
├── docker-compose.yml
├── Dockerfile
├── nodemon.json
├── .env, .env.example
└── README.md
```

---

## 3. Database (Prisma)

- **Provider:** PostgreSQL (`DATABASE_URL` in `.env`).
- **Seed:** `npm run prisma:seed` — creates subscription plans, platform config, security settings, demo school, demo users (super@school.edu, admin@school.edu, acc@school.edu, hr@school.edu; password `Admin123!`).

### Main entities (from schema)

- **Platform / multi-tenant:** `School`, `Branch`, `User`, `RefreshToken`, `PasswordResetOtp`, `SubscriptionPlan`, `SchoolSubscription`, `PlatformConfiguration`, `SecuritySetting`, `Invitation`, `SuperadminNotification`, `FirebaseCredential`, `SchoolRole`, `PermissionMatrix`.
- **HR:** `HrSetting`, `HrRolePolicy`, `Staff`, `StaffAttendance`, `LeaveRequest`, `LeaveRequestComment`, `StaffDocument`.
- **Academic:** `ClassRoom`, `Subject`, `ClassSubject`, `AcademicYear`, `SchoolTerm`, `Section`, `Holiday`, `TimetablePeriod`.
- **Students:** `Student`, `Parent`, `StudentParent`, `StudentDocument`, `StudentAttendance`.
- **Finance:** `FeeStructure`, `FeeDiscountRule`, `Invoice`, `Payment`, `PaymentRefund`.
- **Communication:** `Announcement`, `NotificationTemplate`, `NotificationLog`.
- **Exams:** `Exam`, `ExamResult`.
- **Other:** `SupportTicket`, `TicketMessage`, `AiFaq`, `FaceCheckinLog`, `LiveClassSession`, `ReportJob`, `ReportCardTemplate`, `DocumentCategory`, `BackupExportJob`, `LibraryBook`, `LibraryBorrow`, `InventoryItem`, `InventoryTransaction`, `OfflineSyncRecord`, `AuditLog`.

Enums include: `Role`, `SchoolStatus`, `StudentStatus`, `AttendanceStatus`, `InvoiceStatus`, `PaymentMethod`, `AnnouncementStatus`, `TicketPriority`, `TicketStatus`, `LeaveRequestStatus`, `InvitationStatus`, `SubscriptionPaymentStatus`, `SubscriptionStatus`.

---

## 4. API base and routing

- **Base path:** `/api/v1`.
- **Health:** `GET /api/v1/health`, `GET /api/v1/ready`.
- **Auth:** All auth routes are **public**; rest are protected by `auth` and/or `requireRole`.

| Mount path | Auth | Roles | Module |
|------------|------|-------|--------|
| `/api/v1/auth` | — | — | Auth (login, refresh, logout, me, forgot, verify-otp, reset, change-password) |
| `/api/v1/dashboard` | ✓ | — | Dashboard (school-admin, hr, accountant) |
| `/api/v1/superadmin` | ✓ | SUPERADMIN | Superadmin (schools, subscriptions, plans, config, support, analytics, accountants, staff, invitations, security, notifications, Firebase upload) |
| `/api/v1/school/students` | ✓ | SUPERADMIN, SCHOOLADMIN, HR, ACCOUNTANT | Students CRUD + status + documents |
| `/api/v1/school` | ✓ | SUPERADMIN, SCHOOLADMIN, HR, ACCOUNTANT | School (parents, staff, classes, sections, academic-years, terms, holidays, permissions, subjects, attendance, timetable, fees, invoices, payments, announcements, reports, audit-logs, settings, roles, face-checkins, AI FAQs, notification templates/logs, document categories, backups, library, inventory, offline-sync, live-classes, exams) |
| `/api/v1/hr` | ✓ | SUPERADMIN, SCHOOLADMIN, HR | HR (dashboard, staff, leave-requests, attendance performance, settings, roles) |
| `/api/v1/accountant` | ✓ | SUPERADMIN, SCHOOLADMIN, ACCOUNTANT | Accountant (dashboard, fee structures, invoices, payments, student balances, reports) |

---

## 5. Auth APIs (`/api/v1/auth`)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/login` | Login (rate-limited) |
| POST | `/refresh` | Refresh token |
| POST | `/logout` | Logout |
| GET | `/me` | Current user (requires auth) |
| POST | `/forgot-password` | Forgot password |
| POST | `/verify-otp` | Verify OTP |
| POST | `/reset-password` | Reset password |
| POST | `/change-password` | Change password (requires auth) |

---

## 6. Dashboard APIs (`/api/v1/dashboard`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/school-admin` | School admin dashboard |
| GET | `/hr` | HR dashboard |
| GET | `/accountant` | Accountant dashboard |

---

## 7. Superadmin APIs (`/api/v1/superadmin`)

- **Dashboard:** `GET /dashboard/overview`
- **Schools:** `GET/POST /schools`, `GET/PUT/PATCH/DELETE /schools/:id`, `PATCH /schools/:id/status`
- **Subscriptions:** `GET /subscriptions`, `PATCH /subscriptions/:schoolId/plan`, `PATCH /subscriptions/:schoolId/auto-renew`
- **Plans:** `GET /plans`, `PUT /plans/:planCode`
- **Configuration:** `GET/PUT /configuration`
- **Support:** `GET /support/tickets`, `GET /support/tickets/:id`, `POST /support/tickets/:id/replies`, `PATCH /support/tickets/:id/status`
- **Analytics:** `GET /analytics/overview`
- **Accountants:** CRUD + status (`/accountants`, `/accountants/:id`, etc.)
- **Staff:** CRUD + status (`/staff`, `/staff/:id`, etc.)
- **Invitations:** `POST /invitations`, `GET /invitations`, `POST /invitations/:id/resend`, `DELETE /invitations/:id`
- **Security:** `GET/PUT /security/settings`, `GET /security/sessions`, `DELETE /security/sessions/:id`, `POST /security/sessions/revoke-all`, `POST /security/keys/rotate`, `GET /security/audit-logs`
- **Notifications:** `GET /notifications`, `PATCH /notifications/:id/read`, `DELETE /notifications/:id`
- **Firebase:** `POST /firebase/upload` (multer)

---

## 8. School APIs (`/api/v1/school`) — summary

Covers: **parents** (list, invite, resend OTP), **staff** (CRUD, documents), **classes** (CRUD), **sections** (CRUD), **academic-years** (CRUD, activate), **terms** (CRUD), **holidays** (CRUD), **permissions** (matrix get/update), **subjects** (CRUD), **attendance** (overview, mark, bulk-mark), **timetable** (get, slots CRUD, publish, periods CRUD), **fees** (summary, structures CRUD, discount-rules CRUD), **invoices** (list, create, get, patch status), **payments** (list, create, receipt, refunds), **announcements** (CRUD, send), **reports** (jobs, generate), **audit-logs**, **report-cards/templates** (CRUD), **settings** (get/update), **roles** (CRUD), **face-checkins** (list, approve, reject), **ai/faqs** (CRUD), **notifications** (templates CRUD, logs), **document-categories** (CRUD), **backups/exports** (list, create), **library** (books CRUD, borrows list/create, return), **inventory** (items CRUD, transactions list/create), **offline-sync/records** (list, create, update), **live-classes/sessions** (list, create, update, end), **exams** (CRUD, marks, publish).

Exact paths are in `src/modules/school/school.routes.js`.

---

## 9. Students APIs (`/api/v1/school/students`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | List students |
| POST | `/` | Create student |
| GET | `/:id` | Get student by id |
| PUT | `/:id` | Update student |
| DELETE | `/:id` | Delete student |
| PATCH | `/:id/status` | Update status |
| POST | `/:id/documents` | Add document |
| DELETE | `/:id/documents/:docId` | Delete document |

---

## 10. HR APIs (`/api/v1/hr`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/dashboard/overview` | HR dashboard |
| GET | `/staff`, `GET /staff/:id` | List staff, get by id |
| GET | `/leave-requests`, `GET /leave-requests/:id` | List leave requests, get by id |
| PATCH | `/leave-requests/:id/status` | Update leave status |
| POST | `/leave-requests/:id/comment` | Add comment |
| GET | `/attendance/performance`, `GET /attendance/performance/:staffId` | Attendance performance |
| GET/PUT | `/settings` | HR settings |
| GET/PUT | `/roles/:id` | Role update |

---

## 11. Accountant APIs (`/api/v1/accountant`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/dashboard/overview` | Accountant dashboard |
| GET/POST/PUT/DELETE | `/fees/structures`, `.../structures/:id` | Fee structures |
| GET/POST | `/invoices`, `GET/PATCH /invoices/:id` | Invoices |
| GET/POST | `/payments`, `GET /payments/:id`, `GET /payments/:id/receipt` | Payments |
| GET | `/students/balances` | Student balances |
| GET | `/reports/jobs`, `POST /reports/generate` | Report jobs |

---

## 12. Scripts (package.json)

- `npm run dev` — nodemon
- `npm run start` — node
- `prisma:generate`, `prisma:migrate`, `prisma:deploy`, `prisma:studio`, `prisma:seed`
- `smoke:full` — full API smoke test
- `load:k6:auth` — k6 auth load (`scripts/k6-auth-load.js`; requires k6 installed)

---

## 13. Summary

- **Database:** PostgreSQL with a full Prisma schema aligned to the School Ecosystem (schools, users, RBAC, students, parents, staff, classes, sections, attendance, timetable, fees, invoices, payments, exams, announcements, audit, library, inventory, etc.).
- **APIs:** Auth, dashboard (school-admin/hr/accountant), superadmin, school (large set), students, HR, and accountant routes are implemented and mounted under `/api/v1`.
- **Security:** JWT auth, optional Redis rate limit, role-based access (SUPERADMIN, SCHOOLADMIN, HR, ACCOUNTANT), school-scoping where applicable.
- **Docs:** Swagger at `/api/docs` when enabled.

For a **gap list** vs the full School Ecosystem PDF, see the project root plan: `BACKEND_API_AND_DATABASE_PLAN.md`.
