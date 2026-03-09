# School Ecosystem PDF vs Backend — Gap Analysis & Plan

Comparison of **School_Ecosystem.pdf** requirements with your current **backend** (Express + Prisma + PostgreSQL).  
API base: `/api/v1`.

---

## 1. Summary

| Category | PDF (Spec) | Backend (Done) | Pending |
|----------|------------|----------------|--------|
| **APIs** | ~100–120 endpoints | ~95+ implemented | **~25–30** |
| **Database** | ~25 core + optional entities | **50+ models** in Prisma | **0** (schema exceeds PDF) |

**Conclusion:** Database is **complete** (and richer than PDF). Most APIs are **done**; remaining gaps are mainly **students import/export**, **parents CRUD profile**, **attendance edit/export**, **timetable views**, **fee reports**, **exam schedules/marks-status**, **announcement detail**, **report endpoints**, **school profile**, and **optional** (unified dashboard, grade mapping, leave-reasons).

---

## 2. Database — PDF vs Backend

### PDF entities (from spec)

- schools, academic_years, users, roles, permissions, user_roles  
- students, parents, student_parents, staff, classes, sections  
- subjects, teacher_subjects (ClassSubject)  
- attendance_records, timetable_periods, timetables, timetable_entries  
- fee_structures, invoices, payments  
- exams, marks (ExamResult)  
- announcements, notification_logs, audit_logs, documents  
- Optional: holidays, faqs, face_checkin_logs, live_class_sessions  

### Backend (Prisma schema)

All of the above are present, plus:

- Branch, RefreshToken, PasswordResetOtp  
- SubscriptionPlan, SchoolSubscription, PlatformConfiguration, SecuritySetting  
- Invitation, SuperadminNotification, FirebaseCredential  
- SchoolRole, PermissionMatrix, HrSetting, HrRolePolicy  
- StaffAttendance, LeaveRequest, LeaveRequestComment  
- StudentDocument, StaffDocument, FeeDiscountRule, PaymentRefund  
- SupportTicket, TicketMessage  
- ReportJob, ReportCardTemplate, NotificationTemplate, DocumentCategory  
- BackupExportJob, LibraryBook, LibraryBorrow  
- InventoryItem, InventoryTransaction, OfflineSyncRecord  
- AcademicYear, SchoolTerm, Section (separate from ClassRoom.section)  
- TimetablePeriod (no separate Timetable version model; slots used)  

**Verdict:** **No database work required** for PDF compliance. Schema is school-scoped, has RBAC, and covers optional areas (library, inventory, HR leave, support, backups).

---

## 3. API Gap — By Module

### 3.1 Auth

| PDF | Backend | Status |
|-----|---------|--------|
| POST login | POST /auth/login | Done |
| POST refresh | POST /auth/refresh | Done |
| POST logout | POST /auth/logout | Done |
| POST forgot-password | POST /auth/forgot-password | Done |
| POST reset-password | POST /auth/reset-password | Done |
| GET me | GET /auth/me | Done |

**Pending:** 0

---

### 3.2 Dashboard

| PDF | Backend | Status |
|-----|---------|--------|
| GET dashboard/summary (single, filters: academic_year, class/section) | GET /dashboard/school-admin, /hr, /accountant | Partial (3 role dashboards; no single “summary”) |

**Pending:** 1 (optional) — **GET /dashboard/summary** with filters if you want one unified widget endpoint.

---

### 3.3 School setup

| PDF | Backend | Status |
|-----|---------|--------|
| GET/PUT school profile (current school: name, logo, timezone, etc.) | Superadmin: full schools CRUD. No “current school” for school admin. | Gap |
| GET/POST/PUT/DELETE academic-years | /school/academic-years + activate | Done |
| GET/POST/PUT/DELETE holidays | /school/holidays | Done |

**Pending:** 1 — **GET /school/profile** and **PUT /school/profile** (or GET/PUT `/schools/current`) for logged-in school.

---

### 3.4 Users & roles (RBAC)

| PDF | Backend | Status |
|-----|---------|--------|
| GET/POST/PUT/DELETE roles | /school/roles | Done |
| GET/PUT roles/:id/permissions | /school/permissions/matrix (single matrix) | Partial |
| GET permissions (list codes) | — | Gap |
| GET/POST/PUT/DELETE admin-users | — | Gap (invitations exist; no “admin users” list per school) |

**Pending:** 2–3 — **GET /school/permissions** (list permission codes), **GET/POST/PUT/DELETE /school/admin-users** (list/create/update/delete admin users, assign role). Optional: **PUT /school/roles/:id/permissions** if you want per-role permissions.

---

### 3.5 Students

| PDF | Backend | Status |
|-----|---------|--------|
| GET students (list, filters, paginated) | GET /school/students | Done |
| GET students/:id | GET /school/students/:id | Done |
| POST/PUT students | POST/PUT /school/students | Done |
| POST students/import (CSV/Excel) | — | Pending |
| GET students/export | — | Pending |
| POST students/:id/move-class | — | Pending |

**Pending:** 3 — **POST /school/students/import**, **GET /school/students/export**, **POST /school/students/:id/move-class**.

---

### 3.6 Parents

| PDF | Backend | Status |
|-----|---------|--------|
| GET parents (list) | GET /school/parents | Done |
| GET parents/:id | — | Pending |
| POST/PUT parents | — | Pending (invite only) |
| POST parents/invite | POST /school/parents/invite | Done |

**Pending:** 3 — **GET /school/parents/:id**, **POST /school/parents**, **PUT /school/parents/:id**.

---

### 3.7 Staff

| PDF | Backend | Status |
|-----|---------|--------|
| GET staff (list) | GET /school/staff | Done |
| GET staff/:id | — | Pending (HR has it; school module does not) |
| POST/PUT staff | POST/PUT /school/staff | Done |

**Pending:** 1 — **GET /school/staff/:id** (staff profile with designation, classes/subjects, documents).

---

### 3.8 Classes & sections

| PDF | Backend | Status |
|-----|---------|--------|
| Classes CRUD | /school/classes | Done |
| Sections under class / CRUD | /school/sections | Done |
| PUT sections/:id/class-teacher | Can be part of PUT /sections/:id | Partial (if updateSection sets classTeacherId) |

**Pending:** 0 (or 1 if you want explicit **PATCH /school/sections/:id/class-teacher**).

---

### 3.9 Subjects

| PDF | Backend | Status |
|-----|---------|--------|
| Subjects CRUD | /school/subjects | Done |
| GET/PUT subjects/:id/teachers | Teacher via ClassSubject | Partial |

**Pending:** 1 — **GET /school/subjects/:id/teachers**, **PUT /school/subjects/:id/teachers** (or combined).

---

### 3.10 Attendance

| PDF | Backend | Status |
|-----|---------|--------|
| GET attendance/overview | GET /school/attendance/overview | Done |
| GET attendance/records (by date, class, section) | — | Pending |
| POST attendance/mark | POST /school/attendance/mark, bulk-mark | Done |
| PUT attendance/records/:id (edit + reason, lock rules) | — | Pending |
| GET attendance/export | — | Pending |
| Leave/absence reason options | — | Optional |

**Pending:** 3 — **GET /school/attendance/records**, **PUT /school/attendance/records/:id**, **GET /school/attendance/export**. Optional: leave-reasons CRUD.

---

### 3.11 Timetable

| PDF | Backend | Status |
|-----|---------|--------|
| GET/POST/PUT timetable/periods | /school/timetable/periods | Done |
| GET timetables (versions: draft/published) | Single getTimetable | Partial |
| GET/POST/PUT timetable entries | /school/timetable, /timetable/slots CRUD | Done |
| GET timetables/conflicts | — | Pending |
| POST timetables/:id/publish | POST /school/timetable/publish | Done |
| GET timetable/teacher/:staffId | — | Pending |
| GET timetable/class/:sectionId | — | Pending |

**Pending:** 3 — **GET /school/timetable/conflicts**, **GET /school/timetable/teacher/:staffId**, **GET /school/timetable/class/:sectionId**.

---

### 3.12 Fees & billing

| PDF | Backend | Status |
|-----|---------|--------|
| Fee structures CRUD | /school/fees/structures | Done |
| Invoices list, get, create, patch status | /school/invoices | Done |
| POST invoices/generate-bulk (by class) | — | Pending |
| Payments, receipt | /school/payments | Done |
| GET fees/due-list | — | Pending |
| GET fees/reports/collection | — | Pending |
| GET fees/reports/pending-dues | — | Pending |
| GET fees/reports/student-ledger/:studentId | — | Pending |
| Refunds | /school/payments/:id/refunds | Done |

**Pending:** 5 — **POST /school/invoices/generate-bulk**, **GET /school/fees/due-list**, **GET /school/fees/reports/collection**, **GET /school/fees/reports/pending-dues**, **GET /school/fees/reports/student-ledger/:studentId**.

---

### 3.13 Exams & results

| PDF | Backend | Status |
|-----|---------|--------|
| Exams CRUD | /school/exams | Done |
| Exam schedules (date, time, subject, class) | Exam has examDate; no separate schedule list API | Partial |
| GET exams/:id/marks-status | — | Pending |
| Marks entry | POST /school/exams/:id/marks | Done |
| POST exams/:id/publish-results | POST /school/exams/:id/publish | Done |
| Grade mapping (A/B/C or %) | — | Optional (settings or GET /grades) |

**Pending:** 1–2 — **GET /school/exams/:id/marks-status**. Optional: exam schedules CRUD if you add ExamSchedule model, and **GET/PUT /school/grades** (or in settings).

---

### 3.14 Announcements & notifications

| PDF | Backend | Status |
|-----|---------|--------|
| List, create, update, delete, send | /school/announcements | Done |
| GET announcements/:id (detail + delivery status) | — | Pending |
| Templates | /school/notifications/templates, logs | Done |
| GET notification-logs | /school/notifications/logs | Done |

**Pending:** 1 — **GET /school/announcements/:id** (with delivery status).

---

### 3.15 Reports & exports

| PDF | Backend | Status |
|-----|---------|--------|
| GET reports/jobs, POST reports/generate | /school/reports/jobs, generate | Done |
| GET reports/students (classwise, export) | — | Pending |
| GET reports/attendance (classwise/monthly, export) | — | Pending |
| GET reports/fees (collection, dues, export) | — | Pending |
| GET reports/exam-performance | — | Pending |
| GET reports/teacher-workload | — | Optional |

**Pending:** 4 — **GET /school/reports/students**, **GET /school/reports/attendance**, **GET /school/reports/fees**, **GET /school/reports/exam-performance**. Optional: teacher-workload.

---

### 3.16 Settings

| PDF | Backend | Status |
|-----|---------|--------|
| GET/PUT settings (branding, attendance, fees, notifications, document-categories) | GET/PUT /school/settings (single) | Partial |
| Backup/export | /school/backups/exports | Done |
| Document categories CRUD | /school/document-categories | Done |

**Pending:** 0–1 — Optional: split **GET/PUT /school/settings** into **/school/settings/branding**, **/school/settings/attendance**, **/school/settings/fees**, **/school/settings/notifications** if PDF structure is strict.

---

### 3.17 Audit logs

| PDF | Backend | Status |
|-----|---------|--------|
| GET audit-logs (filters) | GET /school/audit-logs | Done |

**Pending:** 0

---

### 3.18 Chatbot FAQ, Face check-in, Live classes, Upload

| PDF | Backend | Status |
|-----|---------|--------|
| FAQ CRUD | /school/ai/faqs | Done |
| Face check-in list, approve/reject | /school/face-checkins | Done |
| Live class sessions | /school/live-classes/sessions | Done |
| File upload | Student/staff docs, Firebase upload | Done |

**Pending:** 0

---

## 4. Pending API count (PDF vs backend)

| Module | Pending endpoints |
|--------|--------------------|
| Dashboard | 1 (optional unified summary) |
| School setup | 1 (current school profile) |
| RBAC | 2–3 (permissions list, admin-users) |
| Students | 3 (import, export, move-class) |
| Parents | 3 (get by id, create, update) |
| Staff | 1 (get by id in school) |
| Subjects | 1 (teachers get/put) |
| Attendance | 3 (+ optional leave-reasons) |
| Timetable | 3 (conflicts, teacher view, class view) |
| Fees | 5 (bulk invoices, due-list, 3 reports) |
| Exams | 1–2 (marks-status, optional grade mapping) |
| Announcements | 1 (get by id with delivery status) |
| Reports | 4 (+ optional teacher-workload) |
| Settings | 0–1 (optional split) |
| **Total** | **~28–32** |

---

## 5. Implementation plan (prioritized)

### Phase A — High priority (PDF must-haves)

1. **School profile (current)**  
   - **GET /api/v1/school/profile** — current school details (from `req.user.schoolId`).  
   - **PUT /api/v1/school/profile** — update name, logo, timezone, etc. (school admin only).

2. **Students**  
   - **POST /api/v1/school/students/import** — CSV/Excel bulk import (template, validation, duplicates).  
   - **GET /api/v1/school/students/export** — export filtered list (CSV/Excel, same filters as list).  
   - **POST /api/v1/school/students/:id/move-class** — move to another class/section (with history if needed).

3. **Parents**  
   - **GET /api/v1/school/parents/:id** — parent profile + linked students.  
   - **POST /api/v1/school/parents** — create parent.  
   - **PUT /api/v1/school/parents/:id** — update parent.

4. **Staff**  
   - **GET /api/v1/school/staff/:id** — staff profile (designation, classes/subjects, documents). Reuse or delegate to existing HR handler if same response shape.

5. **Attendance**  
   - **GET /api/v1/school/attendance/records** — list by date, class, section (paginated).  
   - **PUT /api/v1/school/attendance/records/:id** — edit status with reason; enforce “lock after X days” and audit.  
   - **GET /api/v1/school/attendance/export** — export (e.g. CSV/Excel) for date range/class.

6. **Fees**  
   - **POST /api/v1/school/invoices/generate-bulk** — bulk generate invoices by class/section/fee-structure.  
   - **GET /api/v1/school/fees/due-list** — overdue + partial (filters: class, section).  
   - **GET /api/v1/school/fees/reports/collection** — daily collection report.  
   - **GET /api/v1/school/fees/reports/pending-dues** — pending dues report.  
   - **GET /api/v1/school/fees/reports/student-ledger/:studentId** — student ledger.

7. **Timetable**  
   - **GET /api/v1/school/timetable/teacher/:staffId** — teacher’s timetable.  
   - **GET /api/v1/school/timetable/class/:sectionId** (or classId+section) — class timetable.  
   - **GET /api/v1/school/timetable/conflicts** — detect double-booked teacher / room.

8. **Exams**  
   - **GET /api/v1/school/exams/:id/marks-status** — marks entry status (e.g. entered vs missing per student/subject).

9. **Announcements**  
   - **GET /api/v1/school/announcements/:id** — detail + delivery status (from NotificationLog).

10. **Reports**  
    - **GET /api/v1/school/reports/students** — student list report (classwise), export option.  
    - **GET /api/v1/school/reports/attendance** — attendance report (classwise/monthly), export.  
    - **GET /api/v1/school/reports/fees** — fees summary (collection/dues), export.  
    - **GET /api/v1/school/reports/exam-performance** — exam performance summary.

11. **RBAC (admin users)**  
    - **GET /api/v1/school/admin-users** — list admin users for school (with roles).  
    - **POST /api/v1/school/admin-users** — create admin (or invite) and assign role.  
    - **PUT /api/v1/school/admin-users/:id** — update role/status.  
    - **GET /api/v1/school/permissions** — list permission codes (for matrix UI).

---

### Phase B — Nice to have

- **GET /api/v1/dashboard/summary** — single dashboard summary with filters (academic_year, class/section).  
- **GET/PUT /api/v1/school/subjects/:id/teachers** — teacher mapping for subject.  
- **GET /api/v1/school/reports/teacher-workload** — teacher workload from timetable.  
- **GET/PUT /api/v1/school/grades** (or in settings) — grade mapping (A/B/C or %).  
- Leave/absence **reasons** config (CRUD or config in settings).  
- **PATCH /api/v1/school/sections/:id/class-teacher** — explicit class-teacher assign.  
- Split **settings** into branding / attendance / fees / notifications if needed.

---

### Phase C — No backend gaps

- Database: use as-is.  
- Auth, dashboard (role-based), RBAC (roles + matrix), audit logs, FAQ, face check-in, live classes, document upload: already implemented.

---

## 6. Suggested order of work

| Order | Task | Est. |
|-------|------|------|
| 1 | School profile GET/PUT | 0.5 day |
| 2 | Parents: GET by id, POST, PUT | 0.5 day |
| 3 | Staff: GET /school/staff/:id | 0.25 day |
| 4 | Students: import (CSV/Excel) | 1 day |
| 5 | Students: export | 0.5 day |
| 6 | Students: move-class | 0.5 day |
| 7 | Attendance: records list, edit, export | 1 day |
| 8 | Timetable: teacher view, class view, conflicts | 0.5 day |
| 9 | Fees: bulk invoices, due-list, 3 reports | 1 day |
| 10 | Exams: marks-status | 0.25 day |
| 11 | Announcements: GET by id with delivery status | 0.25 day |
| 12 | Reports: students, attendance, fees, exam-performance | 1 day |
| 13 | Admin-users + GET permissions | 0.5 day |
| 14 | Optional: dashboard/summary, subjects/teachers, grades, etc. | 1 day |

**Rough total:** ~8–10 days for Phase A; +1–2 days for Phase B options.

---

## 7. One-page checklist

- [ ] **School:** GET/PUT current school profile  
- [ ] **Students:** import, export, move-class  
- [ ] **Parents:** GET :id, POST, PUT  
- [ ] **Staff:** GET /school/staff/:id  
- [ ] **Attendance:** list records, PUT record, export  
- [ ] **Timetable:** teacher view, class view, conflicts  
- [ ] **Fees:** bulk invoices, due-list, collection report, pending-dues report, student-ledger  
- [ ] **Exams:** GET exams/:id/marks-status  
- [ ] **Announcements:** GET :id with delivery status  
- [ ] **Reports:** students, attendance, fees, exam-performance  
- [ ] **RBAC:** admin-users CRUD, GET permissions  

Database: **no changes** required for PDF compliance.
