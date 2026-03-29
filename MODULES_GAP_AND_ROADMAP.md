# Modules Gap Analysis & API Roadmap

This document maps your **20 admin modules** and **Student CRM/Portal** to existing APIs and lists what is **new or extended** for full coverage. Backend is designed to scale (Redis, rate limits, pagination, indexes) and is deployed on Render.

---

## 1. Dashboard ✅

| Feature | Status | API / Notes |
|--------|--------|-------------|
| School admin dashboard | Done | `GET /dashboard/school-admin` |
| HR dashboard | Done | `GET /dashboard/hr` |
| Accountant dashboard | Done | `GET /dashboard/accountant` |
| Superadmin dashboard | Done | `GET /superadmin/dashboard/overview` |

**Gap:** Student-portal dashboard → see **§20 Student CRM**.

---

## 2. Admissions 🆕

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Online admission form | **New** | `POST /school/admissions/applications` – submit application |
| Application tracking | **New** | `GET /school/admissions/applications`, `GET /school/admissions/applications/:id` |
| Document upload | **New** | `POST /school/admissions/applications/:id/documents` |
| Admission approval | **New** | `PATCH /school/admissions/applications/:id/status` (APPROVED/REJECTED) |
| Waiting list management | **New** | `GET/PATCH /school/admissions/waiting-list` |
| Student registration number generation | **New** | Generated on approval; `GET /school/admissions/next-reg-no` (internal) |
| Admission fee payment | **New** | `POST /school/admissions/applications/:id/payment` or link to fees |
| Student onboarding | **New** | On approval: create Student + optional User; `POST /school/admissions/applications/:id/onboard` |

**DB:** New models `AdmissionApplication`, `AdmissionDocument`, `AdmissionPayment`, `WaitingListEntry`.

---

## 3. Student Management ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| All student details | Done | `GET /school/students`, `GET /school/students/:id`, CRUD, documents, move-class, status |
| Export / import | Done | `GET /school/students/export`, `POST /school/students/import` |

**Extension:** Add fields in Student if needed (medical, transport, hostel, etc.) and expose via same APIs.

---

## 4. Teacher & Staff Management ✅

| Feature | Status | API / Notes |
|--------|--------|-------------|
| List/get staff | Done | `GET /school/staff`, `GET /school/staff/:id` |
| Create/update/delete | Done | `POST/PUT/DELETE /school/staff/:id` |
| Documents | Done | `GET/POST/DELETE /school/staff/:id/documents` |
| HR leave & attendance | Done | HR module + `GET /school/attendance/records` (type=staff) |

---

## 5. Academic Management ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Class management | Done | `GET/POST/PUT/DELETE /school/classes` |
| Section management | Done | `GET/POST/PUT/DELETE /school/sections` |
| Subject management | Done | `GET/POST/PUT/DELETE /school/subjects` |
| Curriculum planning | **New** | `GET/POST/PUT/DELETE /school/curriculum` (e.g. by class/subject) |
| Syllabus tracking | **New** | `GET/POST/PUT/DELETE /school/syllabus`, link to class/subject/term |
| Lesson plan management | **New** | `GET/POST/PUT/DELETE /school/lesson-plans` |
| Study materials upload | **New** | `GET/POST/DELETE /school/study-materials` (chapter/topic, file URL) |

**DB:** `Curriculum`, `Syllabus`, `LessonPlan`, `StudyMaterial`.

---

## 6. Attendance Management ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Student attendance | Done | `GET/POST /school/attendance/*`, bulk-mark |
| Teacher attendance | Done | Same with `type=staff` |
| Bulk attendance | Done | `POST /school/attendance/bulk-mark` |
| Biometric / face | Done | `GET /school/face-checkins`, approve/reject |
| Attendance reports | Done | `GET /school/reports/attendance`, export |

---

## 7. Fee Management ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Fee structure setup | Done | `GET/POST/PUT/DELETE /school/fees/structures` |
| Installment system | **Extend** | Add `installments` to FeeStructure or new model; API for installments |
| Fee categories | Done | Fee structures + discount rules |
| Online payment gateway | Integrate | Backend records payment; gateway is frontend/third-party |
| Fee receipts | Done | `GET /school/payments/:id/receipt` |
| Late fee calculation | **Extend** | Config in fee structure or settings; apply in invoice generation |
| Fee reminders | **New** | `GET/POST /school/fees/reminders` or use notification templates |
| Fee reports | Done | Collection, pending-dues, student-ledger |

**DB:** Optional `FeeReminder`, `InvoiceInstallment`.

---

## 8. Examination System ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Exam schedule | Done | `GET/POST/PUT/DELETE /school/exams` |
| Question paper upload | **New** | `POST /school/exams/:id/question-paper` (store URL) |
| Marks entry | Done | `POST /school/exams/:id/marks` |
| Grading system | Done | Grade in ExamResult; optional grade matrix API |
| Report cards | Done | `GET/POST/PUT/DELETE /school/report-cards/templates` |
| Exam analytics | Done | `GET /school/reports/exam-performance` |
| Result publishing | Done | `POST /school/exams/:id/publish` |

**DB:** Add `questionPaperUrl` to Exam if needed.

---

## 9. Timetable Management ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Class timetable | Done | `GET /school/timetable`, `GET /school/timetable/class/:classId` |
| Teacher timetable | Done | `GET /school/timetable/teacher/:staffId` |
| Room allocation | **Extend** | Add `roomId`/room to TimetableSlot model and API |
| Substitute teacher | **New** | `PATCH /school/timetable/slots/:id/substitute` or slot override |

**DB:** Room model + slot.roomId; optional SubstituteSlot/Override.

---

## 10. Library Management ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Book catalog | Done | `GET/POST/PUT/DELETE /school/library/books` |
| Book categories | **Extend** | Add category to LibraryBook or new LibraryCategory |
| Issue/return | Done | `GET/POST /school/library/borrows`, `PATCH .../return` |
| Student library card | **Extend** | Card number on Student or LibraryMember; issue card API |
| Late fine management | **New** | Fine rule + fine amount on return; `GET /school/library/fines` |

**DB:** LibraryCategory, fine fields on LibraryBorrow.

---

## 11. Transport Management 🆕

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Bus routes | **New** | `GET/POST/PUT/DELETE /school/transport/routes` |
| Driver details | **New** | `GET/POST/PUT/DELETE /school/transport/drivers` |
| Student bus allocation | **New** | `GET/POST/PUT /school/transport/allocations` (studentId, routeId, stop) |
| Transport fees | **New** | `GET/POST/PUT /school/transport/fees` or link to fee structure |

**DB:** `TransportRoute`, `TransportDriver`, `TransportAllocation`, `TransportFee`.

---

## 12. Hostel Management 🆕

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Room allocation | **New** | `GET/POST/PUT/DELETE /school/hostel/rooms`, `GET/POST /school/hostel/allocations` |
| Hostel attendance | **New** | `GET/POST /school/hostel/attendance` |
| Visitor logs | **New** | `GET/POST /school/hostel/visitors` |
| Hostel fee management | **New** | Link to fee structure or `GET/POST /school/hostel/fees` |

**DB:** `HostelRoom`, `HostelAllocation`, `HostelAttendance`, `HostelVisitor`, `HostelFee`.

---

## 13. Inventory & Assets ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Asset tracking | Done | `GET/POST/PUT/DELETE /school/inventory/items`, transactions |
| Equipment inventory | Done | Same |
| Purchase orders | **New** | `GET/POST/PUT /school/inventory/purchase-orders` |
| Vendor management | **New** | `GET/POST/PUT/DELETE /school/inventory/vendors` |

**DB:** `PurchaseOrder`, `Vendor`.

---

## 14. Communication Center ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Announcements | Done | `GET/POST/PUT/DELETE /school/announcements`, send |
| Notification templates | Done | `GET/POST/PUT/DELETE /school/notifications/templates` |
| Notification logs | Done | `GET /school/notifications/logs` |
| SMS/WhatsApp/Email | Config | Platform config (smsUrl, whatsAppToken); send via templates |
| Staff chat | **New** | Optional: `GET/POST /school/chat/channels`, messages (or use third-party) |
| Parent communication | Done | Announcements by audience; parent invite |

**DB:** Optional ChatChannel, ChatMessage if in-app chat.

---

## 15. Events & Activities 🆕

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Event calendar | **New** | `GET/POST/PUT/DELETE /school/events` (date, title, type) |
| Event registration | **New** | `GET/POST /school/events/:id/registrations` |
| Competition management | **New** | Events with type=COMPETITION; or `GET/POST /school/events/competitions` |
| Photo gallery | **New** | `GET/POST/DELETE /school/events/:id/gallery` (URLs) |

**DB:** `Event`, `EventRegistration`, `EventGalleryImage`.

---

## 16. Reports & Analytics ✅

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Attendance reports | Done | `GET /school/reports/attendance`, export |
| Fee reports | Done | Collection, pending-dues, student-ledger |
| Academic/Exam reports | Done | `GET /school/reports/exam-performance`, students report |
| Staff reports | Done | HR attendance performance, leave |
| Report jobs | Done | `GET /school/reports/jobs`, `POST /school/reports/generate` |
| Transport reports | **New** | When transport exists: `GET /school/reports/transport` |

---

## 17. AI Assistant ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| AI FAQs | Done | `GET/POST/PUT/DELETE /school/ai/faqs` |
| AI for automation | **Extend** | Same FAQs + future endpoints for predictions |
| AI student/teacher analytics | **New** | `GET /school/ai/analytics/student/:id`, teacher (aggregate from existing data) |
| AI academic prediction | **New** | `POST /school/ai/predict` (payload: studentId, type) – can call external AI |

---

## 18. Security & Permissions ✅ (extend)

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Role-based access | Done | `GET /school/roles`, permissions, matrix |
| User permissions | Done | `GET /school/permissions`, matrix |
| Login tracking | **New** | `GET /auth/sessions` or `GET /school/security/login-logs` |
| Two-factor authentication | **Extend** | Superadmin SecuritySetting (enforce2FA); TOTP endpoints in auth |
| Device management | **New** | `GET/DELETE /school/security/devices` (from RefreshToken/sessions) |

**DB:** Use existing RefreshToken; optional Device table.

---

## 19. Settings ✅

| Feature | Status | API / Notes |
|--------|--------|-------------|
| School settings | Done | `GET/PUT /school/settings` |
| School profile | Done | `GET/PUT /school/profile` |
| Superadmin config | Done | `GET/PUT /superadmin/configuration` |
| HR settings | Done | `GET/PUT /hr/settings` |
| Security (superadmin) | Done | `GET/PUT /superadmin/security/settings` |

---

## 20. Student CRM / Student Portal 🆕

Student-facing APIs (role **STUDENT** or **PARENT**). Base path: `/api/v1/student` (or `/api/v1/portal/student`).

| Feature | Status | API / Notes |
|--------|--------|-------------|
| Dashboard | **New** | `GET /student/dashboard` (attendance summary, upcoming exams, dues) |
| Profile | **New** | `GET /student/profile`, `PUT /student/profile` (limited fields) |
| Timetable | **New** | `GET /student/timetable` (from class) |
| Attendance | **New** | `GET /student/attendance` (own records + monthly report) |
| Homework | **New** | `GET /student/homework`, `GET /student/homework/:id`, `POST /student/homework/:id/submit` |
| Study materials | **New** | `GET /student/study-materials` (by class/subject) |
| Exams | **New** | `GET /student/exams`, `GET /student/exams/:id/result` |
| AI Study Assistant | **New** | `POST /student/ai/ask` (proxy to AI; rate-limited) |
| AI Career Advisor | **New** | `GET /student/ai/career` or same ask with type=career |
| Fees | **New** | `GET /student/fees/invoices`, `GET /student/fees/receipts`, pending dues |
| Communication | **New** | `GET /student/announcements`, `GET /student/notifications` |
| Events | **New** | `GET /student/events`, `POST /student/events/:id/register` |
| Health | **New** | `GET /student/health` (medical info if stored), or placeholder |
| Transport | **New** | `GET /student/transport` (allocation + route) |
| Library | **New** | `GET /student/library/borrows`, `GET /student/library/books` |
| Achievements | **New** | `GET /student/achievements` (certificates, badges) |
| Settings | **New** | `GET/PUT /student/settings` (notifications, language) |

**DB:** Homework/Assignment, Submission; StudyMaterial; Achievement/Certificate; StudentSettings.

---

## Scalability (Millions / High Concurrency)

- **Already in place:** Redis rate limiting, optional response cache (dashboard, profile, /auth/me), pagination caps (100 per page, 2000 export), DB indexes on hot queries.
- **Doc:** `SCALABILITY_1_LAKH_USERS.md` – use Redis, PgBouncer/connection pool, and cache for 100k+ users.
- **For millions:** Same patterns; add read replicas for reports, consider event-driven/queue for heavy jobs (report generation, bulk notifications). New APIs will use the same pagination, caching, and index guidelines.

---

## Implementation Order (Suggested)

1. **Admissions** – DB + APIs (applications, tracking, approval, onboarding).
2. **Student portal** – Routes under `/student/*` using existing Student/Class/Attendance/Exam/Invoice data.
3. **Homework & Study materials** – DB + school APIs + student portal APIs.
4. **Transport & Hostel** – DB + school APIs; then student transport view.
5. **Events & Achievements** – DB + school APIs + student event registration and achievements.
6. **Curriculum, Syllabus, Lesson plans** – DB + school APIs.
7. **Fee reminders, late fee, installments** – Extend fee handlers.
8. **Library categories & late fine** – Extend library.
9. **Timetable room & substitute** – Extend timetable.
10. **AI analytics & prediction** – New endpoints (can aggregate existing data or call external AI).
11. **Login tracking & devices** – Use RefreshToken/sessions; optional Device table.

---

*Next: Prisma schema additions and new route/handler files for Admissions, Student portal, Transport, Hostel, Events, and Homework.*
