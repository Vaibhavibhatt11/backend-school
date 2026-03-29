# School Ecosystem — Backend, API & Database Plan

Based on **School_Ecosystem.pdf** (extracted spec in `school_ecosystem_extracted.txt`).

---

## 1. Current Folder Status

| Item | Status |
|------|--------|
| **Backend** | ❌ Not present — to be created |
| **APIs** | ❌ All pending (see list below) |
| **Database** | ❌ Not present — schema to be implemented |
| **Existing code** | Only `school_ecosystem_extracted.txt`; frontend/src files show as deleted in git |

**Conclusion:** Everything is pending. This plan defines what to build.

---

## 2. Recommended Tech Stack (from spec)

| Layer | Recommendation |
|-------|----------------|
| **Backend** | Node (NestJS or Express) or Laravel/Django |
| **Database** | PostgreSQL |
| **Storage** | S3-compatible (AWS S3, Cloudflare R2) for documents/images |
| **Auth** | JWT + refresh tokens (or session-based) |
| **Push** | Firebase Cloud Messaging (FCM) |
| **Logs/Monitoring** | Sentry + server logs |
| **Deployment** | Docker + CI/CD |

---

## 3. Database — Entities & Tables

Design tables around these entities (all **school-scoped** where applicable):

### Core & multi-tenant
- `schools` — name, logo, address, phone, email, timezone, language, academic_year_format, branding
- `academic_years` — school_id, name, start_date, end_date, is_active (only one active per school)

### Auth & RBAC
- `users` — email, phone, password_hash, school_id, status, last_login, etc.
- `roles` — name, description, school_id (or global for super_admin)
- `permissions` — code (e.g. `attendance.mark`, `fees.view`), module, description
- `role_permissions` — role_id, permission_id
- `user_roles` — user_id, role_id, school_id

### People
- `students` — admission_no, first_name, last_name, dob, gender, class_id, section_id, roll_no, address, status (Active/Inactive/Passed Out/Transferred), emergency_contact, school_id, academic_year_id
- `parents` — name, phone, email, school_id (parent as user linked via user_id)
- `student_parents` — student_id, parent_id, relation (Father/Mother/Guardian)
- `staff` — employee_id, user_id, name, phone, email, role, joining_date, school_id, designation (optional salary fields)
- `classes` — name, school_id, academic_year_id (e.g. Grade 1–12)
- `sections` — class_id, name (A, B, C), class_teacher_id, capacity (optional)
- `subjects` — name, code, school_id, compulsory/elective, academic_year_id
- `teacher_subjects` — staff_id, subject_id, class_id/section_id

### Academic & operations
- `attendance_records` — student_id or staff_id, date, status (Present/Absent/Late), section_id/class_id, marked_by, edited_at, edit_reason
- `timetable_periods` — school_id, start_time, end_time, order (period 1, 2, …)
- `timetables` — school_id, version, is_published, effective_from
- `timetable_entries` — timetable_id, section_id, subject_id, staff_id, period_id, day_of_week, room (optional)
- `fee_structures` — school_id, class_id, academic_year_id, fee_type (tuition, transport, exam), amount, due_date_rules
- `invoices` — student_id, invoice_no (unique), total, paid_amount, status, due_date, fee_structure refs
- `payments` — invoice_id, amount, mode (cash/UPI/card/bank), reference, paid_at, received_by
- `exams` — school_id, name, type (Unit Test/Midterm/Final), academic_year_id, start_date, end_date
- `exam_schedules` — exam_id, subject_id, class_id/section_id, date, time
- `marks` — exam_schedule_id or exam_id, student_id, subject_id, marks, grade (optional)
- `announcements` — school_id, title, body, target_type (all/class/role/individual), target_ids (JSON), created_by
- `notification_logs` — announcement_id, user_id, channel (in-app/push/email), status (sent/failed), sent_at
- `audit_logs` — user_id, action, entity_type, entity_id, old_value, new_value, ip, timestamp
- `documents` — entity_type (student/staff/school), entity_id, category (TC, birth_cert, receipt), file_url, uploaded_by, uploaded_at

### Optional / Phase 2
- `holidays` — school_id, date, name
- `faq_categories`, `faqs` — for chatbot
- `face_checkin_logs` — user_id, image_url, device_id, geo, status, timestamp
- `live_class_sessions` — school_id, title, join_link, scheduled_at, created_by, target_class/section

---

## 4. API Requirements (from spec)

- **Base path:** `/api/v1/`
- **School-scoped:** Every record belongs to a school (header or context).
- **Role-protected:** RBAC middleware on all admin APIs.
- **Lists:** Paginated (`page`, `limit`, `sort`, filters).

### Standard patterns
- Auth: login, refresh, logout, forgot-password, reset-password
- CRUD per entity (list, get, create, update, delete where applicable)
- Bulk import/export endpoints
- File upload endpoints (documents, logo, etc.)

---

## 5. APIs by Module (Pending List)

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/login` | Admin login (rate-limited) |
| POST | `/api/v1/auth/refresh` | Refresh token |
| POST | `/api/v1/auth/logout` | Logout / invalidate session |
| POST | `/api/v1/auth/forgot-password` | Forgot password (send link/OTP) |
| POST | `/api/v1/auth/reset-password` | Reset password (token/OTP) |
| GET  | `/api/v1/auth/me` | Current user + roles + permissions |

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/dashboard/summary` | Total students, active, attendance today, pending dues count+amount, upcoming exams, new admissions (7/30 days), recent announcements (filters: academic_year, class/section) |

### School setup
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/PUT | `/api/v1/schools/:id` or `/api/v1/schools/current` | School profile (name, logo, address, phone, email, timezone, language, academic year format) |
| GET/POST/PUT/DELETE | `/api/v1/academic-years` | Academic years (create/edit, set active; only one active per school) |
| GET/POST/PUT/DELETE | `/api/v1/holidays` | Holidays calendar (optional) |

### Users & roles (RBAC)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/roles` | Roles list, create/edit role |
| GET/PUT | `/api/v1/roles/:id/permissions` | Permissions matrix for role |
| GET/POST | `/api/v1/permissions` | List permissions (for matrix) |
| GET/POST/PUT/DELETE | `/api/v1/admin-users` | Admin users list, create admin, assign role |

### Students
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/students` | List (filters: class, section, status); paginated |
| GET | `/api/v1/students/:id` | Student profile (info, parents, class history, fee status, attendance summary, documents) |
| POST/PUT | `/api/v1/students` | Add/Edit student |
| POST | `/api/v1/students/import` | Bulk import (CSV/Excel) |
| GET | `/api/v1/students/export` | Export filtered students |
| POST | `/api/v1/students/:id/move-class` | Move between class/section (with history) |

### Parents
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/parents` | Parent list; paginated |
| GET | `/api/v1/parents/:id` | Parent profile + linked students |
| POST/PUT | `/api/v1/parents` | Add/Edit parent |
| POST | `/api/v1/parents/invite` | Invite parent (OTP or invite link) |

### Staff
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/staff` | Staff list (filter by role); paginated |
| GET | `/api/v1/staff/:id` | Staff profile (designation, classes/subjects, documents) |
| POST/PUT | `/api/v1/staff` | Add/Edit staff |

### Classes & sections
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/classes` | Classes list (e.g. Grade 1–12) |
| GET/POST/PUT/DELETE | `/api/v1/classes/:id/sections` | Sections under class; class teacher, capacity |
| PUT | `/api/v1/sections/:id/class-teacher` | Assign class teacher |

### Subjects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/subjects` | Subject list; create (name, code, class mapping, compulsory/elective) |
| GET/PUT | `/api/v1/subjects/:id/teachers` | Teacher mapping to subject |

### Attendance
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/attendance/overview` | Daily/monthly overview (filters) |
| GET | `/api/v1/attendance/records` | List records (by date, section, class) |
| POST | `/api/v1/attendance/mark` | Teacher: submit daily attendance (class/section) |
| PUT | `/api/v1/attendance/records/:id` | Admin edit (with reason); respect lock-after-X-days |
| GET | `/api/v1/attendance/export` | Export attendance reports |
| GET/POST/PUT | `/api/v1/attendance/leave-reasons` | Leave/absence reason options (optional) |

### Timetable
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT | `/api/v1/timetable/periods` | Period/time setup (school timing, period durations) |
| GET | `/api/v1/timetables` | List versions (draft vs published) |
| GET/POST/PUT | `/api/v1/timetables/:id` | Timetable builder (get/update entries) |
| GET | `/api/v1/timetables/:id/entries` | Grid entries (for drag-drop) |
| POST | `/api/v1/timetables/:id/entries` | Bulk update entries |
| GET | `/api/v1/timetables/conflicts` | Conflict checker (teacher double-book, room) |
| POST | `/api/v1/timetables/:id/publish` | Publish (trigger push); versioning |
| GET | `/api/v1/timetables/teacher/:staffId` | Teacher timetable view |
| GET | `/api/v1/timetables/class/:sectionId` | Class timetable view |

### Fees & billing
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/fee-structures` | Fee structure (per class/year); fee types; discounts/scholarship |
| GET | `/api/v1/invoices` | List invoices (filters: student, class, status, date) |
| GET | `/api/v1/invoices/:id` | Invoice detail + payment history |
| POST | `/api/v1/invoices/generate-bulk` | Bulk generate by class |
| POST | `/api/v1/payments` | Mark payment (cash/UPI/card/bank); receipt generation |
| GET | `/api/v1/fees/due-list` | Overdue, partial payments |
| GET | `/api/v1/fees/reports/collection` | Daily collection report |
| GET | `/api/v1/fees/reports/pending-dues` | Pending dues report |
| GET | `/api/v1/fees/reports/student-ledger/:studentId` | Student ledger statement |
| POST | `/api/v1/refunds` | Refunds (optional V1) |

### Exams & results
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/exams` | Exam types, create exam (name, type, dates) |
| GET/POST/PUT/DELETE | `/api/v1/exams/:id/schedules` | Exam schedule (date, time, subject, class) |
| GET | `/api/v1/exams/:id/marks-status` | Marks entry status dashboard |
| GET/POST/PUT | `/api/v1/marks` | Marks entry (lock after publish unless reopened) |
| POST | `/api/v1/exams/:id/publish-results` | Result publishing controls |
| GET | `/api/v1/grades` or settings | Grade mapping (A/B/C or %) |

### Announcements & notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/announcements` | List (filters) |
| GET | `/api/v1/announcements/:id` | Detail + delivery status |
| POST/PUT/DELETE | `/api/v1/announcements` | Create/update; target (all/class/role/individual); delivery (in-app, push, email/SMS optional) |
| GET | `/api/v1/announcements/templates` | Template support (fee due reminder, holiday notice) |
| GET | `/api/v1/notification-logs` | Delivery status: sent/failed; message history |

### Reports & exports
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/reports/students` | Student list (classwise); export PDF/Excel |
| GET | `/api/v1/reports/attendance` | Attendance (classwise/monthly); export |
| GET | `/api/v1/reports/fees` | Collection, dues, refunds; export |
| GET | `/api/v1/reports/exam-performance` | Exam performance summary |
| GET | `/api/v1/reports/teacher-workload` | Teacher workload timetable summary (optional) |
| All | Date range filters + permissions required |

### Settings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/PUT | `/api/v1/settings/branding` | App branding: logo, name, theme color |
| GET/PUT | `/api/v1/settings/attendance` | Lock period, allowed edits |
| GET/PUT | `/api/v1/settings/fees` | Partial payment, late fees |
| GET/PUT | `/api/v1/settings/notifications` | FCM keys, templates |
| GET/PUT | `/api/v1/settings/document-categories` | Document categories |
| POST | `/api/v1/settings/backup` or `/export` | Data backup/export (optional) |

### Audit logs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/audit-logs` | Logs (who, action, entity_type, entity_id, timestamp, IP); filters |

### Chatbot FAQ (optional)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/faq-categories` | FAQ categories |
| GET/POST/PUT/DELETE | `/api/v1/faqs` | FAQ CRUD; categories + keywords; canned replies |

### Face check-in logs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/face-checkin-logs` | Check-in attempts, status, image storage policy; approve/reject (if manual review) |

### Live class sessions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/live-sessions` | Create session, schedule, join link; audience (class/section) |

### File upload (shared)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/upload` | Generic file upload (type/size restriction); returns URL for documents/logo |

---

## 6. Approximate API Count (Pending)

| Module | Approx. endpoints |
|--------|--------------------|
| Auth | 6 |
| Dashboard | 1 |
| School setup | 5–8 |
| RBAC | 8–10 |
| Students | 6–8 |
| Parents | 4–5 |
| Staff | 3–4 |
| Classes & sections | 6–8 |
| Subjects | 4–6 |
| Attendance | 6–8 |
| Timetable | 10–12 |
| Fees & billing | 12–15 |
| Exams & results | 8–10 |
| Announcements | 5–7 |
| Reports | 5–7 |
| Settings | 6–8 |
| Audit logs | 1 |
| FAQ / Face check-in / Live sessions | 5–10 |
| Upload | 1 |
| **Total** | **~100–120** |

---

## 7. Implementation Plan (Phased)

### Phase 1 — Foundation (Weeks 1–2)
1. **Project setup**  
   - Backend repo (e.g. NestJS or Express), ESLint, env config, Docker for Postgres.
2. **Database**  
   - PostgreSQL + migrations (e.g. TypeORM/Prisma/Knex).  
   - Create: `schools`, `academic_years`, `users`, `roles`, `permissions`, `role_permissions`, `user_roles`.
3. **Auth**  
   - Login, refresh, logout, forgot/reset; JWT + refresh; rate limit; password policy.  
   - Implement all **Auth** APIs.
4. **RBAC**  
   - Middleware: resolve user → roles → permissions; school context.  
   - Seed default roles/permissions.  
   - Implement **Users & roles** APIs (roles, permissions, admin-users).
5. **School context**  
   - Middleware: attach `school_id` from token/header to every request.

### Phase 2 — Core entities (Weeks 3–4)
1. **School setup**  
   - Tables: holidays (optional).  
   - **School setup** APIs (school profile, academic years, holidays).
2. **People**  
   - Tables: students, parents, student_parents, staff, classes, sections, subjects, teacher_subjects.  
   - **Students**, **Parents**, **Staff**, **Classes & sections**, **Subjects** APIs (CRUD + import/export for students).
3. **Documents**  
   - Table: documents; S3 (or compatible) upload.  
   - **Upload** API and link to student/staff/school.

### Phase 3 — Operations (Weeks 5–6)
1. **Attendance**  
   - Table: attendance_records; lock rules.  
   - **Attendance** APIs (overview, mark, edit, export).
2. **Timetable**  
   - Tables: timetable_periods, timetables, timetable_entries.  
   - **Timetable** APIs (periods, builder, entries, conflicts, publish, teacher/class views).
3. **Dashboard**  
   - **Dashboard** API (aggregates from students, attendance, fees, exams, announcements).

### Phase 4 — Fees & exams (Weeks 7–8)
1. **Fees**  
   - Tables: fee_structures, invoices, payments.  
   - **Fees & billing** APIs (structure, invoices, bulk generate, payments, due list, reports).
2. **Exams**  
   - Tables: exams, exam_schedules, marks.  
   - **Exams & results** APIs (exams, schedules, marks, publish, grade mapping).

### Phase 5 — Communication & reporting (Weeks 9–10)
1. **Announcements**  
   - Tables: announcements, notification_logs.  
   - **Announcements & notifications** APIs; FCM integration for push.
2. **Reports**  
   - **Reports & exports** APIs (students, attendance, fees, exam performance); PDF/Excel export.
3. **Settings**  
   - **Settings** APIs (branding, attendance, fees, notifications, document categories).
4. **Audit**  
   - Table: audit_logs; middleware to log create/update/delete and key actions.  
   - **Audit logs** API.

### Phase 6 — Optional / Phase 2 (Later)
- Chatbot FAQ (tables + APIs).  
- Face check-in logs (table + API).  
- Live class sessions (table + API + optional Jitsi link generation).  
- Refunds, 2FA, backup/export.

---

## 8. Non-Functional (from spec)

- **Performance:** List screens &lt; 2s; use server-side caching for dashboard aggregates.  
- **Security:** RBAC enforced server-side; input validation; SQL injection protection; secure file uploads (type/size).  
- **Scalability:** Multi-school support via `school_id` on all tenant tables.  
- **Reliability:** Retry push notification delivery; store failures in `notification_logs`.

---

## 9. Next Steps

1. Choose stack: **NestJS** (recommended) or Express + Postgres.  
2. Create backend repo in `c:\Users\DC\admin` (e.g. `backend/` or `server/`).  
3. Initialize DB migrations and implement **Phase 1** (auth + RBAC + school context).  
4. Proceed through phases 2–5, then add Phase 6 items as needed.

If you tell me your preferred stack (Node/NestJS vs Express, and ORM choice), I can outline the exact folder structure and first set of files (e.g. auth module, RBAC middleware, first migration) next.
