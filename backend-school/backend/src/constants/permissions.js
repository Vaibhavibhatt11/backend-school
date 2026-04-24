/**
 * Permission codes for RBAC (School Ecosystem PDF).
 * Used by GET /school/permissions and permission matrix UI.
 */
const PERMISSION_CODES = [
  { code: "students.view", module: "students", description: "View students" },
  { code: "students.create", module: "students", description: "Add student" },
  { code: "students.update", module: "students", description: "Edit student" },
  { code: "students.delete", module: "students", description: "Delete student" },
  { code: "students.import", module: "students", description: "Import students (CSV/Excel)" },
  { code: "students.export", module: "students", description: "Export students" },
  { code: "attendance.mark", module: "attendance", description: "Mark attendance" },
  { code: "attendance.edit", module: "attendance", description: "Edit attendance (including backdated)" },
  { code: "attendance.view", module: "attendance", description: "View attendance" },
  { code: "attendance.export", module: "attendance", description: "Export attendance" },
  { code: "fees.view", module: "fees", description: "View fees and invoices" },
  { code: "fees.create", module: "fees", description: "Create invoice" },
  { code: "fees.payments.manage", module: "fees", description: "Mark payment, refund" },
  { code: "fees.export", module: "fees", description: "Export fee reports" },
  { code: "timetable.view", module: "timetable", description: "View timetable" },
  { code: "timetable.edit", module: "timetable", description: "Edit timetable" },
  { code: "timetable.publish", module: "timetable", description: "Publish timetable" },
  { code: "announcement.send", module: "announcements", description: "Send announcement" },
  { code: "announcement.create", module: "announcements", description: "Create announcement" },
  { code: "announcement.view", module: "announcements", description: "View announcements" },
  { code: "exams.view", module: "exams", description: "View exams and results" },
  { code: "exams.edit", module: "exams", description: "Enter marks, edit exam" },
  { code: "exams.publish", module: "exams", description: "Publish results" },
  { code: "reports.view", module: "reports", description: "View reports" },
  { code: "reports.export", module: "reports", description: "Export reports" },
  { code: "staff.view", module: "staff", description: "View staff" },
  { code: "staff.manage", module: "staff", description: "Add/edit staff" },
  { code: "roles.manage", module: "roles", description: "Manage roles and permissions" },
  { code: "school.profile", module: "school", description: "Edit school profile" },
  { code: "audit.view", module: "audit", description: "View audit logs" },
];

module.exports = { PERMISSION_CODES };
