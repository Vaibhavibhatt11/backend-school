# New APIs Added (PDF Gap – Strong Security)

All endpoints are under **`/api/v1`**, protected by **auth** and **role** middleware.  
School-scoping and **Zod** validation are applied where applicable.

---

## Security Measures

- **Auth:** JWT required on all new endpoints (except public auth routes).
- **School scope:** Handlers use `scopedSchoolId(req)` so SUPERADMIN can pass `schoolId`, others are limited to their school.
- **Validation:** Request body/query validated with **Zod** (type, length, format).
- **Audit:** Sensitive actions (profile update, admin user create/update, bulk invoices, attendance edit) write to `audit_logs`.
- **Permissions:** `GET /school/permissions` returns a fixed list of permission codes for RBAC UI.
- **Rate limiting:** Login already rate-limited; add global rate limit in front of `/api/v1` if needed.

---

## New Endpoints

### School profile
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/profile` | Current school profile (id, code, name, email, phone, timezone, currency). |
| PUT | `/school/profile` | Update school profile (name, email, phone, timezone, currencyCode). |

### RBAC / Admin users
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/permissions` | List all permission codes (for matrix UI). |
| GET | `/school/admin-users` | List admin users (school-scoped; optional `?role=`, `?page=`, `?limit=`). |
| POST | `/school/admin-users` | Create admin user (body: fullName, email, password min 8, role). |
| PUT | `/school/admin-users/:id` | Update admin user (fullName, role, isActive). |

### Parents
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/parents/:id` | Parent profile + linked students. |
| POST | `/school/parents` | Create parent (fullName, email/phone, isActive). |
| PUT | `/school/parents/:id` | Update parent. |

### Staff
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/staff/:id` | Staff profile (user, classes, subjects, documents). |

### Students (under `/school/students`)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/school/students/import` | Bulk import (body: `{ students: [{ admissionNo, firstName, lastName, className, ... }] }`, max 500). |
| GET | `/school/students/export` | Export list (same filters as list; `?format=csv` or json). |
| POST | `/school/students/:id/move-class` | Move student (body: className, section?, classId?). |

### Attendance
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/attendance/records` | List records (query: type=student|staff, date, classId, className, section, page, limit). |
| PUT | `/school/attendance/records/:id` | Edit record (body: status, remark?, reason?); query `?type=student|staff`. Audit logged. |
| GET | `/school/attendance/export` | Export (query: type, dateFrom, dateTo, classId, format=json|csv). |

### Timetable
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/timetable/teacher/:staffId` | Timetable for teacher. |
| GET | `/school/timetable/class/:classId` | Timetable for class. |
| GET | `/school/timetable/conflicts` | Detect teacher/class double-booking. |

### Fees
| Method | Path | Description |
|--------|------|-------------|
| POST | `/school/invoices/bulk-generate` | Bulk invoices (body: feeStructureId, dueDate, amountPerStudent, classId?). |
| GET | `/school/fees/due-list` | Overdue/partial list (optional classId, status, limit). |
| GET | `/school/fees/reports/collection` | Collection report (date or dateFrom/dateTo). |
| GET | `/school/fees/reports/pending-dues` | Pending dues report (optional classId). |
| GET | `/school/fees/reports/student-ledger/:studentId` | Student ledger (invoices + payments). |

### Exams
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/exams/:id/marks-status` | Marks entry status (expected vs entered, missing student ids). |

### Announcements
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/announcements/:id` | Announcement detail + delivery status (notification logs). |

### Reports
| Method | Path | Description |
|--------|------|-------------|
| GET | `/school/reports/students` | Student list report (className, section, status; optional format=csv). |
| GET | `/school/reports/attendance` | Attendance summary (type, dateFrom, dateTo, classId). |
| GET | `/school/reports/fees` | Fees summary (dateFrom, dateTo). |
| GET | `/school/reports/exam-performance` | Exam performance (optional examId, classId, subjectId). |

---

## Files Touched

- `src/constants/permissions.js` — new (permission codes).
- `src/modules/school/school.misc.handlers.js` — getSchoolProfile, updateSchoolProfile, getAnnouncementById.
- `src/modules/school/school.people.handlers.js` — getParentById, createParent, updateParent, getStaffById, listAdminUsers, createAdminUser, updateAdminUser, getPermissionsList.
- `src/modules/students/students.handlers.js` — importStudents, exportStudents, moveStudentClass.
- `src/modules/school/school.academic.core.handlers.js` — listAttendanceRecords, updateAttendanceRecord, exportAttendance.
- `src/modules/school/school.schedule.handlers.js` — getTimetableByTeacher, getTimetableByClass, getTimetableConflicts.
- `src/modules/school/school.finance.handlers.js` — bulkGenerateInvoices, getDueList, getCollectionReport, getPendingDuesReport, getStudentLedger.
- `src/modules/school/school.exams.handlers.js` — getExamMarksStatus.
- `src/modules/school/school.reports.handlers.js` — new (reportStudents, reportAttendance, reportFees, reportExamPerformance).
- `src/modules/school/school.routes.js` — all new routes.
- `src/modules/students/students.routes.js` — import, export, move-class.

All new APIs use the existing auth and `requireRole(["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"])` for `/school` and `/school/students`.
