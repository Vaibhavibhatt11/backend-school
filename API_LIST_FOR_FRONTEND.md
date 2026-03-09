# API List for Frontend Integration

**Base URL:** `{BASE_URL}/api/v1`  
**Auth:** Send JWT in `Authorization: Bearer <token>` (except Auth and Health).  
**Content-Type:** `application/json` for request bodies.  
**Rate limit:** APIs are rate-limited per IP (e.g. 300 req/min). On exceedance the response is **429 Too Many Requests** with `error.code: "TOO_MANY_REQUESTS"`. Health, ready, and login endpoints are excluded.

---

## General

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/health` | No | Health check |
| GET | `/ready` | No | Readiness (DB, Redis) |

---

## 1. Auth (No JWT required for login/refresh/forgot/reset)

**Base path:** `/api/v1/auth`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login (email, password). Returns accessToken, refreshToken, user. |
| POST | `/auth/refresh` | Refresh token (body: refreshToken). Returns new accessToken. |
| POST | `/auth/logout` | Logout (body: refreshToken optional). |
| GET | `/auth/me` | **Requires JWT.** Current user profile + role, schoolId. |
| POST | `/auth/forgot-password` | Forgot password (body: email). |
| POST | `/auth/verify-otp` | Verify OTP (body: email, otp). |
| POST | `/auth/reset-password` | Reset password (body: resetToken, newPassword). |
| POST | `/auth/change-password` | **Requires JWT.** Change password (body: currentPassword, newPassword). |

---

## 2. Dashboard

**Base path:** `/api/v1/dashboard`  
**Roles:** Any authenticated user (role-specific data).

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard/school-admin` | School admin dashboard (students, staff, invoices, collection, etc.). Query: `schoolId` (required for SUPERADMIN). |
| GET | `/dashboard/hr` | HR dashboard (staff, today attendance, leave requests). |
| GET | `/dashboard/accountant` | Accountant dashboard (fees summary, invoices, payments). |

---

## 3. Superadmin

**Base path:** `/api/v1/superadmin`  
**Roles:** `SUPERADMIN` only.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/superadmin/dashboard/overview` | Superadmin dashboard overview. |
| GET | `/superadmin/schools` | List schools. |
| POST | `/superadmin/schools` | Create school. |
| GET | `/superadmin/schools/:id` | Get school by id. |
| PUT | `/superadmin/schools/:id` | Update school. |
| PATCH | `/superadmin/schools/:id/status` | Update school status. |
| DELETE | `/superadmin/schools/:id` | Delete school. |
| GET | `/superadmin/subscriptions` | List school subscriptions. |
| PATCH | `/superadmin/subscriptions/:schoolId/plan` | Update subscription plan. |
| PATCH | `/superadmin/subscriptions/:schoolId/auto-renew` | Update auto-renew. |
| GET | `/superadmin/plans` | List subscription plans. |
| PUT | `/superadmin/plans/:planCode` | Update plan. |
| GET | `/superadmin/configuration` | Get platform configuration. |
| PUT | `/superadmin/configuration` | Update platform configuration. |
| GET | `/superadmin/support/tickets` | List support tickets. |
| GET | `/superadmin/support/tickets/:id` | Get ticket by id. |
| POST | `/superadmin/support/tickets/:id/replies` | Add reply to ticket. |
| PATCH | `/superadmin/support/tickets/:id/status` | Update ticket status. |
| GET | `/superadmin/analytics/overview` | Analytics overview. |
| GET | `/superadmin/accountants` | List accountants. |
| POST | `/superadmin/accountants` | Create accountant. |
| GET | `/superadmin/accountants/:id` | Get accountant by id. |
| PUT | `/superadmin/accountants/:id` | Update accountant. |
| PATCH | `/superadmin/accountants/:id/status` | Update accountant status. |
| DELETE | `/superadmin/accountants/:id` | Delete accountant. |
| GET | `/superadmin/staff` | List staff (superadmin scope). |
| POST | `/superadmin/staff` | Create staff member. |
| GET | `/superadmin/staff/:id` | Get staff member by id. |
| PUT | `/superadmin/staff/:id` | Update staff member. |
| PATCH | `/superadmin/staff/:id/status` | Update staff status. |
| DELETE | `/superadmin/staff/:id` | Delete staff member. |
| POST | `/superadmin/invitations` | Create invitation. |
| GET | `/superadmin/invitations` | List invitations. |
| POST | `/superadmin/invitations/:id/resend` | Resend invitation. |
| DELETE | `/superadmin/invitations/:id` | Cancel invitation. |
| GET | `/superadmin/security/settings` | Get security settings. |
| PUT | `/superadmin/security/settings` | Update security settings. |
| GET | `/superadmin/security/sessions` | List security sessions. |
| DELETE | `/superadmin/security/sessions/:id` | Revoke session. |
| POST | `/superadmin/security/sessions/revoke-all` | Revoke all sessions. |
| POST | `/superadmin/security/keys/rotate` | Rotate security keys. |
| GET | `/superadmin/security/audit-logs` | Security audit logs. |
| GET | `/superadmin/notifications` | List notifications. |
| PATCH | `/superadmin/notifications/:id/read` | Mark notification read. |
| DELETE | `/superadmin/notifications/:id` | Delete notification. |
| POST | `/superadmin/firebase/upload` | Upload Firebase service account (multipart: file). |

---

## 4. School (School Admin / HR / Accountant)

**Base path:** `/api/v1/school`  
**Roles:** `SUPERADMIN`, `SCHOOLADMIN`, `HR`, `ACCOUNTANT`.  
**Note:** For SUPERADMIN, pass `schoolId` in query or body where required.

### 4.1 School profile & RBAC
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/profile` | Get current school profile. |
| PUT | `/school/profile` | Update school profile (name, email, phone, timezone, currencyCode). |
| GET | `/school/permissions` | List all permission codes (for RBAC matrix). |
| GET | `/school/admin-users` | List admin users. Query: role, page, limit, schoolId. |
| POST | `/school/admin-users` | Create admin user (fullName, email, password, role). |
| PUT | `/school/admin-users/:id` | Update admin user (fullName, role, isActive). |
| GET | `/school/permissions/matrix` | Get permission matrix. |
| PUT | `/school/permissions/matrix` | Update permission matrix. |
| GET | `/school/roles` | List roles. |
| POST | `/school/roles` | Create role. |
| PUT | `/school/roles/:id` | Update role. |
| DELETE | `/school/roles/:id` | Delete role (custom roles only). |
| GET | `/school/settings` | Get school settings. |
| PUT | `/school/settings` | Update school settings. |

### 4.2 Parents
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/parents` | List parents. Query: page, limit, search, schoolId. |
| GET | `/school/parents/:id` | Get parent by id (with linked students). |
| POST | `/school/parents` | Create parent. |
| PUT | `/school/parents/:id` | Update parent. |
| POST | `/school/parents/invite` | Invite parent (fullName, email/phone, studentId, relationType). |
| POST | `/school/parents/:id/resend-otp` | Resend OTP to parent. |

### 4.3 Staff
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/staff` | List staff. Query: page, limit, search, department, isActive, schoolId. |
| GET | `/school/staff/:id` | Get staff by id (profile, classes, subjects, documents). |
| POST | `/school/staff` | Create staff. |
| PUT | `/school/staff/:id` | Update staff. |
| DELETE | `/school/staff/:id` | Delete staff. |
| GET | `/school/staff/:id/documents` | List staff documents. |
| POST | `/school/staff/:id/documents` | Add staff document. |
| DELETE | `/school/staff/:id/documents/:docId` | Delete staff document. |

### 4.4 Classes & sections
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/classes` | List classes. |
| POST | `/school/classes` | Create class. |
| PUT | `/school/classes/:id` | Update class. |
| DELETE | `/school/classes/:id` | Delete class. |
| GET | `/school/sections` | List sections. |
| POST | `/school/sections` | Create section. |
| PUT | `/school/sections/:id` | Update section. |
| DELETE | `/school/sections/:id` | Delete section. |

### 4.5 Academic years, terms, holidays
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/academic-years` | List academic years. |
| POST | `/school/academic-years` | Create academic year. |
| PUT | `/school/academic-years/:id` | Update academic year. |
| PATCH | `/school/academic-years/:id/activate` | Set as active academic year. |
| DELETE | `/school/academic-years/:id` | Delete academic year. |
| GET | `/school/terms` | List terms. |
| POST | `/school/terms` | Create term. |
| PUT | `/school/terms/:id` | Update term. |
| DELETE | `/school/terms/:id` | Delete term. |
| GET | `/school/holidays` | List holidays. |
| POST | `/school/holidays` | Create holiday. |
| PUT | `/school/holidays/:id` | Update holiday. |
| DELETE | `/school/holidays/:id` | Delete holiday. |

### 4.6 Subjects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/subjects` | List subjects. |
| POST | `/school/subjects` | Create subject. |
| PUT | `/school/subjects/:id` | Update subject. |
| DELETE | `/school/subjects/:id` | Delete subject. |

### 4.7 Attendance
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/attendance/overview` | Attendance overview for a date. Query: date, schoolId. |
| GET | `/school/attendance/records` | List attendance records. Query: type=student\|staff, date, classId, className, section, page, limit. |
| PUT | `/school/attendance/records/:id` | Edit attendance record. Query: type=student\|staff. Body: status, remark?, reason?. |
| GET | `/school/attendance/export` | Export attendance. Query: type, dateFrom, dateTo, classId, format=json\|csv. |
| POST | `/school/attendance/mark` | Mark single attendance (type, studentId or staffId, date, status, remark). |
| POST | `/school/attendance/bulk-mark` | Bulk mark (type, date, records: [{ studentId or staffId, status, remark }]). |

### 4.8 Timetable
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/timetable` | Get timetable (slots). Query: classId, dateFrom, dateTo, schoolId. |
| GET | `/school/timetable/teacher/:staffId` | Timetable for teacher. |
| GET | `/school/timetable/class/:classId` | Timetable for class. |
| GET | `/school/timetable/conflicts` | Get timetable conflicts (double-booked teacher/class). |
| POST | `/school/timetable/slots` | Create timetable slot. |
| PUT | `/school/timetable/slots/:id` | Update timetable slot. |
| DELETE | `/school/timetable/slots/:id` | Delete timetable slot. |
| POST | `/school/timetable/publish` | Publish timetable. Body: classId?, dateFrom?, dateTo?. |
| GET | `/school/timetable/periods` | List timetable periods. |
| POST | `/school/timetable/periods` | Create period. |
| PUT | `/school/timetable/periods/:id` | Update period. |
| DELETE | `/school/timetable/periods/:id` | Delete period. |

### 4.9 Fees & billing
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/fees/summary` | Fees summary (totals, outstanding, collection). |
| GET | `/school/fees/structures` | List fee structures. |
| POST | `/school/fees/structures` | Create fee structure. |
| PUT | `/school/fees/structures/:id` | Update fee structure. |
| DELETE | `/school/fees/structures/:id` | Delete fee structure. |
| GET | `/school/fees/discount-rules` | List fee discount rules. |
| POST | `/school/fees/discount-rules` | Create discount rule. |
| PUT | `/school/fees/discount-rules/:id` | Update discount rule. |
| DELETE | `/school/fees/discount-rules/:id` | Delete discount rule. |
| GET | `/school/invoices` | List invoices. Query: page, limit, status, studentId, search, schoolId. |
| POST | `/school/invoices` | Create invoice. |
| POST | `/school/invoices/bulk-generate` | Bulk generate invoices. Body: feeStructureId, dueDate, amountPerStudent, classId?. |
| GET | `/school/invoices/:id` | Get invoice by id (with payments). |
| PATCH | `/school/invoices/:id/status` | Update invoice status. |
| GET | `/school/payments` | List payments. Query: studentId, invoiceId, page, limit. |
| POST | `/school/payments` | Record payment. |
| GET | `/school/payments/:id/receipt` | Get payment receipt. |
| GET | `/school/payments/:id/refunds` | List refunds for payment. |
| POST | `/school/payments/:id/refunds` | Create refund. |
| GET | `/school/fees/due-list` | Due list (overdue/partial). Query: classId?, status?, limit?. |
| GET | `/school/fees/reports/collection` | Collection report. Query: date?, dateFrom?, dateTo?, schoolId. |
| GET | `/school/fees/reports/pending-dues` | Pending dues report. Query: classId?. |
| GET | `/school/fees/reports/student-ledger/:studentId` | Student fee ledger. |

### 4.10 Announcements & notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/announcements` | List announcements. Query: page, limit, status, search, schoolId. |
| GET | `/school/announcements/:id` | Get announcement by id (with delivery status). |
| POST | `/school/announcements` | Create announcement. |
| PUT | `/school/announcements/:id` | Update announcement. |
| DELETE | `/school/announcements/:id` | Delete announcement. |
| POST | `/school/announcements/:id/send` | Send announcement. |
| GET | `/school/notifications/templates` | List notification templates. |
| POST | `/school/notifications/templates` | Create template. |
| PUT | `/school/notifications/templates/:id` | Update template. |
| DELETE | `/school/notifications/templates/:id` | Delete template. |
| GET | `/school/notifications/logs` | List notification logs. |

### 4.11 Reports, audit, settings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/reports/jobs` | List report jobs. Query: status, type, page, limit. |
| POST | `/school/reports/generate` | Request report generation. Body: type, params?, schoolId. |
| GET | `/school/reports/students` | Students report. Query: className, section, status, format=json\|csv, page, limit. |
| GET | `/school/reports/attendance` | Attendance report. Query: type, dateFrom, dateTo, classId. |
| GET | `/school/reports/fees` | Fees report. Query: dateFrom, dateTo. |
| GET | `/school/reports/exam-performance` | Exam performance report. Query: examId?, classId?, subjectId?. |
| GET | `/school/audit-logs` | List audit logs. Query: page, limit, action, entity, schoolId. |
| GET | `/school/report-cards/templates` | List report card templates. |
| POST | `/school/report-cards/templates` | Create report card template. |
| PUT | `/school/report-cards/templates/:id` | Update report card template. |
| DELETE | `/school/report-cards/templates/:id` | Delete report card template. |

### 4.12 Face check-in, AI FAQ
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/face-checkins` | List face check-in logs. Query: page, limit, status, personType. |
| PATCH | `/school/face-checkins/:id/approve` | Approve face check-in. Body: reason?. |
| PATCH | `/school/face-checkins/:id/reject` | Reject face check-in. Body: reason?. |
| GET | `/school/ai/faqs` | List AI FAQs. Query: page, limit, category, search. |
| POST | `/school/ai/faqs` | Create FAQ. |
| PUT | `/school/ai/faqs/:id` | Update FAQ. |
| DELETE | `/school/ai/faqs/:id` | Delete FAQ. |

### 4.13 Document categories, backups, library, inventory
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/document-categories` | List document categories. |
| POST | `/school/document-categories` | Create category. |
| PUT | `/school/document-categories/:id` | Update category. |
| DELETE | `/school/document-categories/:id` | Delete category. |
| GET | `/school/backups/exports` | List backup/export jobs. |
| POST | `/school/backups/exports` | Create backup export job. |
| GET | `/school/library/books` | List library books. |
| POST | `/school/library/books` | Create book. |
| PUT | `/school/library/books/:id` | Update book. |
| DELETE | `/school/library/books/:id` | Delete book. |
| GET | `/school/library/borrows` | List borrows. |
| POST | `/school/library/borrows` | Create borrow. |
| PATCH | `/school/library/borrows/:id/return` | Return book. |
| GET | `/school/inventory/items` | List inventory items. |
| POST | `/school/inventory/items` | Create item. |
| PUT | `/school/inventory/items/:id` | Update item. |
| DELETE | `/school/inventory/items/:id` | Delete item. |
| GET | `/school/inventory/transactions` | List inventory transactions. |
| POST | `/school/inventory/transactions` | Create transaction. |

### 4.14 Offline sync, live classes, exams
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/offline-sync/records` | List offline sync records. |
| POST | `/school/offline-sync/records` | Create sync record. |
| PATCH | `/school/offline-sync/records/:id` | Update sync record. |
| GET | `/school/live-classes/sessions` | List live class sessions. Query: status, classId, page, limit. |
| POST | `/school/live-classes/sessions` | Create live session. |
| PUT | `/school/live-classes/sessions/:id` | Update live session. |
| POST | `/school/live-classes/sessions/:id/end` | End live session. |
| GET | `/school/exams` | List exams. Query: classId, subjectId, isPublished, page, limit. |
| POST | `/school/exams` | Create exam. |
| GET | `/school/exams/:id/marks-status` | Get exam marks entry status (expected vs entered, missing). |
| PUT | `/school/exams/:id` | Update exam. |
| DELETE | `/school/exams/:id` | Delete exam. |
| POST | `/school/exams/:id/marks` | Save exam marks. Body: results: [{ studentId, marks, grade?, remarks? }]. |
| POST | `/school/exams/:id/publish` | Publish exam results. |

---

## 5. Students (under School)

**Base path:** `/api/v1/school/students`  
**Roles:** `SUPERADMIN`, `SCHOOLADMIN`, `HR`, `ACCOUNTANT`.  
**Note:** For SUPERADMIN, pass `schoolId` in query/body.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/school/students` | List students. Query: page, limit, search, status, className, section, schoolId. |
| GET | `/school/students/export` | Export students. Query: same as list + format=json\|csv. |
| POST | `/school/students` | Create student. |
| POST | `/school/students/import` | Bulk import. Body: students: [{ admissionNo, firstName, lastName, className, section?, ... }], max 500. |
| GET | `/school/students/:id` | Get student by id. |
| PUT | `/school/students/:id` | Update student. |
| DELETE | `/school/students/:id` | Delete student. |
| PATCH | `/school/students/:id/status` | Update student status. Body: status (ACTIVE\|INACTIVE). |
| POST | `/school/students/:id/move-class` | Move to another class. Body: className, section?, classId?. |
| POST | `/school/students/:id/documents` | Add student document. |
| DELETE | `/school/students/:id/documents/:docId` | Delete student document. |

---

## 6. HR

**Base path:** `/api/v1/hr`  
**Roles:** `SUPERADMIN`, `SCHOOLADMIN`, `HR`.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/hr/dashboard/overview` | HR dashboard. Query: schoolId. |
| GET | `/hr/staff` | List staff. |
| GET | `/hr/staff/:id` | Get staff by id. |
| GET | `/hr/leave-requests` | List leave requests. |
| GET | `/hr/leave-requests/:id` | Get leave request by id. |
| PATCH | `/hr/leave-requests/:id/status` | Update leave status (APPROVED\|REJECTED). |
| POST | `/hr/leave-requests/:id/comment` | Add comment to leave request. |
| GET | `/hr/attendance/performance` | Attendance performance summary. |
| GET | `/hr/attendance/performance/:staffId` | Attendance performance for one staff. |
| GET | `/hr/settings` | Get HR settings. |
| PUT | `/hr/settings` | Update HR settings. |
| GET | `/hr/roles` | List HR roles. |
| PUT | `/hr/roles/:id` | Update role. |

---

## 7. Accountant

**Base path:** `/api/v1/accountant`  
**Roles:** `SUPERADMIN`, `SCHOOLADMIN`, `ACCOUNTANT`.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/accountant/dashboard/overview` | Accountant dashboard. |
| GET | `/accountant/fees/structures` | List fee structures. |
| POST | `/accountant/fees/structures` | Create fee structure. |
| PUT | `/accountant/fees/structures/:id` | Update fee structure. |
| DELETE | `/accountant/fees/structures/:id` | Delete fee structure. |
| GET | `/accountant/invoices` | List invoices. |
| POST | `/accountant/invoices` | Create invoice. |
| GET | `/accountant/invoices/:id` | Get invoice by id. |
| PATCH | `/accountant/invoices/:id/status` | Update invoice status. |
| GET | `/accountant/payments` | List payments. |
| POST | `/accountant/payments` | Record payment. |
| GET | `/accountant/payments/:id` | Get payment by id. |
| GET | `/accountant/payments/:id/receipt` | Get payment receipt. |
| GET | `/accountant/students/balances` | List student balances. |
| GET | `/accountant/reports/jobs` | List report jobs. |
| POST | `/accountant/reports/generate` | Request report generation. |

---

## Response format

- **Success:** `{ success: true, data: { ... } }`
- **Error:** `{ success: false, error: "<message>", errorCode?: "<code>" }` with appropriate HTTP status (4xx/5xx).
- **List responses:** Usually `data: { items: [...], pagination: { page, limit, total, totalPages } }` or `data: { items, total, page, limit }`.

## Pagination

Use query params: `page` (default 1), `limit` (default 20, max often 100). Responses include `pagination` or equivalent.

## File uploads

- **Superadmin Firebase upload:** `POST /superadmin/firebase/upload` with `multipart/form-data`, field name `file`.
- **Student/Staff documents:** Typically pass `url` (and name, type) in JSON after uploading file to your storage; or add a separate upload endpoint if backend supports it.

---

*Document generated for frontend integration. Base URL and env (e.g. CORS) should be set per environment.*
