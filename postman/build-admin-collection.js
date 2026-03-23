/**
 * School admin panel — routes under /api/v1/school/*, /api/v1/school/students/*, /api/v1/dashboard/*.
 * Roles: SUPERADMIN, SCHOOLADMIN, HR, ACCOUNTANT (see each folder).
 * Run: node postman/build-admin-collection.js
 */
const fs = require("fs");
const path = require("path");

const BASE = "{{base_url}}";
const bearerAuth = {
  type: "bearer",
  bearer: [{ key: "token", value: "{{auth_token}}", type: "string" }],
};

function req(name, method, p, body = null, noAuth = false) {
  const pathStr = p.startsWith("/") ? p.slice(1) : p;
  const raw = `${BASE}/${pathStr}`;
  const request = {
    method,
    header: body ? [{ key: "Content-Type", value: "application/json" }] : [],
    url: raw,
  };
  if (!noAuth) request.auth = bearerAuth;
  if (body) {
    request.body = {
      mode: "raw",
      raw: typeof body === "string" ? body : JSON.stringify(body, null, 2),
      options: { raw: { language: "json" } },
    };
  }
  return { name, request };
}

function folder(name, items) {
  return { name, item: items };
}

function eventLogin() {
  return [
    {
      listen: "test",
      script: {
        type: "text/javascript",
        exec: [
          "pm.test('Status 2xx', function () { pm.response.to.be.success; });",
          "const j = pm.response.json();",
          "if (j && j.data && j.data.accessToken) { pm.collectionVariables.set('auth_token', j.data.accessToken); pm.collectionVariables.set('accessToken', j.data.accessToken); }",
          "if (j && j.data && j.data.refreshToken) pm.collectionVariables.set('refreshToken', j.data.refreshToken);",
        ],
      },
    },
  ];
}

function toPostmanItem(it) {
  if (it.item) {
    return { name: it.name, item: it.item.map(toPostmanItem) };
  }
  const r = it.request;
  const urlRaw = typeof r.url === "string" ? r.url : r.url?.raw || `${BASE}/`;
  const reqObj = {
    method: r.method,
    header: r.header || [],
    url: urlRaw,
    auth: r.auth || undefined,
    body: r.body || undefined,
  };
  const out = { name: it.name, request: reqObj };
  if (it.event) out.event = it.event;
  return out;
}

const items = [
  folder("00 Health (public)", [
    req("GET /health", "GET", "/health", null, true),
    req("GET /ready", "GET", "/ready", null, true),
  ]),
  folder("01 Auth", [
    (() => {
      const r = req(
        "POST /auth/login (school admin)",
        "POST",
        "/auth/login",
        { email: "{{adminEmail}}", password: "{{adminPassword}}" },
        true
      );
      r.event = eventLogin();
      return r;
    })(),
    req("POST /auth/refresh", "POST", "/auth/refresh", { refreshToken: "{{refreshToken}}" }, true),
    req("GET /auth/me", "GET", "/auth/me"),
    req("POST /auth/logout", "POST", "/auth/logout", { refreshToken: "{{refreshToken}}" }),
  ]),
  folder("02 Dashboard", [
    req("GET /dashboard/school-admin", "GET", "/dashboard/school-admin?schoolId={{schoolId}}"),
    req("GET /dashboard/hr", "GET", "/dashboard/hr?schoolId={{schoolId}}"),
    req("GET /dashboard/accountant", "GET", "/dashboard/accountant?schoolId={{schoolId}}"),
  ]),
  folder("03 School profile & permissions", [
    req("GET /school/profile", "GET", "/school/profile"),
    req("PUT /school/profile", "PUT", "/school/profile", { name: "Demo School" }),
    req("GET /school/permissions", "GET", "/school/permissions"),
    req("GET /school/admin-users", "GET", "/school/admin-users"),
    req("POST /school/admin-users", "POST", "/school/admin-users", {}),
    req("PUT /school/admin-users/:id", "PUT", "/school/admin-users/{{userId}}", {}),
  ]),
  folder("04 Parents & staff", [
    req("GET /school/parents", "GET", "/school/parents?page=1&limit=20"),
    req("GET /school/parents/:id", "GET", "/school/parents/{{parentId}}"),
    req("POST /school/parents", "POST", "/school/parents", {}),
    req("PUT /school/parents/:id", "PUT", "/school/parents/{{parentId}}", {}),
    req("POST /school/parents/invite", "POST", "/school/parents/invite", {}),
    req("POST /school/parents/:id/resend-otp", "POST", "/school/parents/{{parentId}}/resend-otp", {}),
    req("GET /school/staff", "GET", "/school/staff"),
    req("GET /school/staff/:id", "GET", "/school/staff/{{staffId}}"),
    req("POST /school/staff", "POST", "/school/staff", {}),
    req("PUT /school/staff/:id", "PUT", "/school/staff/{{staffId}}", {}),
    req("DELETE /school/staff/:id", "DELETE", "/school/staff/{{staffId}}"),
    req("GET /school/staff/:id/documents", "GET", "/school/staff/{{staffId}}/documents"),
    req("POST /school/staff/:id/documents", "POST", "/school/staff/{{staffId}}/documents", {}),
    req("DELETE /school/staff/:id/documents/:docId", "DELETE", "/school/staff/{{staffId}}/documents/{{docId}}"),
  ]),
  folder("05 Students (CRUD)", [
    req("GET /school/students", "GET", "/school/students?page=1&limit=20"),
    req("GET /school/students/export", "GET", "/school/students/export"),
    req("POST /school/students", "POST", "/school/students", {}),
    req("POST /school/students/import", "POST", "/school/students/import", {}),
    req("GET /school/students/:id", "GET", "/school/students/{{studentId}}"),
    req("PUT /school/students/:id", "PUT", "/school/students/{{studentId}}", {}),
    req("DELETE /school/students/:id", "DELETE", "/school/students/{{studentId}}"),
    req("PATCH /school/students/:id/status", "PATCH", "/school/students/{{studentId}}/status", { status: "ACTIVE" }),
    req("POST /school/students/:id/move-class", "POST", "/school/students/{{studentId}}/move-class", {}),
    req("POST /school/students/:id/documents", "POST", "/school/students/{{studentId}}/documents", {}),
    req("DELETE /school/students/:id/documents/:docId", "DELETE", "/school/students/{{studentId}}/documents/{{docId}}"),
  ]),
  folder("06 Classes, sections, academic calendar", [
    req("GET /school/classes", "GET", "/school/classes"),
    req("POST /school/classes", "POST", "/school/classes", {}),
    req("PUT /school/classes/:id", "PUT", "/school/classes/{{classId}}", {}),
    req("DELETE /school/classes/:id", "DELETE", "/school/classes/{{classId}}"),
    req("GET /school/sections", "GET", "/school/sections"),
    req("POST /school/sections", "POST", "/school/sections", {}),
    req("PUT /school/sections/:id", "PUT", "/school/sections/{{sectionId}}", {}),
    req("DELETE /school/sections/:id", "DELETE", "/school/sections/{{sectionId}}"),
    req("GET /school/academic-years", "GET", "/school/academic-years"),
    req("POST /school/academic-years", "POST", "/school/academic-years", {}),
    req("PUT /school/academic-years/:id", "PUT", "/school/academic-years/{{academicYearId}}", {}),
    req("PATCH /school/academic-years/:id/activate", "PATCH", "/school/academic-years/{{academicYearId}}/activate", {}),
    req("DELETE /school/academic-years/:id", "DELETE", "/school/academic-years/{{academicYearId}}"),
    req("GET /school/terms", "GET", "/school/terms"),
    req("POST /school/terms", "POST", "/school/terms", {}),
    req("PUT /school/terms/:id", "PUT", "/school/terms/{{termId}}", {}),
    req("DELETE /school/terms/:id", "DELETE", "/school/terms/{{termId}}"),
    req("GET /school/holidays", "GET", "/school/holidays"),
    req("POST /school/holidays", "POST", "/school/holidays", {}),
    req("PUT /school/holidays/:id", "PUT", "/school/holidays/{{holidayId}}", {}),
    req("DELETE /school/holidays/:id", "DELETE", "/school/holidays/{{holidayId}}"),
    req("GET /school/permissions/matrix", "GET", "/school/permissions/matrix"),
    req("PUT /school/permissions/matrix", "PUT", "/school/permissions/matrix", {}),
  ]),
  folder("07 Subjects & attendance", [
    req("GET /school/subjects", "GET", "/school/subjects"),
    req("POST /school/subjects", "POST", "/school/subjects", {}),
    req("PUT /school/subjects/:id", "PUT", "/school/subjects/{{subjectId}}", {}),
    req("DELETE /school/subjects/:id", "DELETE", "/school/subjects/{{subjectId}}"),
    req("GET /school/attendance/overview", "GET", "/school/attendance/overview"),
    req("GET /school/attendance/records", "GET", "/school/attendance/records"),
    req("PUT /school/attendance/records/:id", "PUT", "/school/attendance/records/{{attendanceRecordId}}", {}),
    req("GET /school/attendance/export", "GET", "/school/attendance/export"),
    req("POST /school/attendance/mark", "POST", "/school/attendance/mark", {}),
    req("POST /school/attendance/bulk-mark", "POST", "/school/attendance/bulk-mark", {}),
  ]),
  folder("08 Timetable & live classes", [
    req("GET /school/timetable", "GET", "/school/timetable"),
    req("GET /school/timetable/teacher/:staffId", "GET", "/school/timetable/teacher/{{staffId}}"),
    req("GET /school/timetable/class/:classId", "GET", "/school/timetable/class/{{classId}}"),
    req("GET /school/timetable/conflicts", "GET", "/school/timetable/conflicts"),
    req("POST /school/timetable/slots", "POST", "/school/timetable/slots", {}),
    req("PUT /school/timetable/slots/:id", "PUT", "/school/timetable/slots/{{slotId}}", {}),
    req("DELETE /school/timetable/slots/:id", "DELETE", "/school/timetable/slots/{{slotId}}"),
    req("POST /school/timetable/publish", "POST", "/school/timetable/publish", {}),
    req("GET /school/timetable/periods", "GET", "/school/timetable/periods"),
    req("POST /school/timetable/periods", "POST", "/school/timetable/periods", {}),
    req("PUT /school/timetable/periods/:id", "PUT", "/school/timetable/periods/{{periodId}}", {}),
    req("DELETE /school/timetable/periods/:id", "DELETE", "/school/timetable/periods/{{periodId}}"),
    req("GET /school/live-classes/sessions", "GET", "/school/live-classes/sessions"),
    req("POST /school/live-classes/sessions", "POST", "/school/live-classes/sessions", {}),
    req("PUT /school/live-classes/sessions/:id", "PUT", "/school/live-classes/sessions/{{sessionId}}", {}),
    req("POST /school/live-classes/sessions/:id/end", "POST", "/school/live-classes/sessions/{{sessionId}}/end", {}),
  ]),
  folder("09 Fees, invoices, payments", [
    req("GET /school/fees/summary", "GET", "/school/fees/summary"),
    req("GET /school/fees/structures", "GET", "/school/fees/structures"),
    req("POST /school/fees/structures", "POST", "/school/fees/structures", {}),
    req("PUT /school/fees/structures/:id", "PUT", "/school/fees/structures/{{feeStructureId}}", {}),
    req("DELETE /school/fees/structures/:id", "DELETE", "/school/fees/structures/{{feeStructureId}}"),
    req("GET /school/fees/discount-rules", "GET", "/school/fees/discount-rules"),
    req("POST /school/fees/discount-rules", "POST", "/school/fees/discount-rules", {}),
    req("PUT /school/fees/discount-rules/:id", "PUT", "/school/fees/discount-rules/{{ruleId}}", {}),
    req("DELETE /school/fees/discount-rules/:id", "DELETE", "/school/fees/discount-rules/{{ruleId}}"),
    req("GET /school/invoices", "GET", "/school/invoices"),
    req("POST /school/invoices", "POST", "/school/invoices", {}),
    req("POST /school/invoices/bulk-generate", "POST", "/school/invoices/bulk-generate", {}),
    req("GET /school/invoices/:id", "GET", "/school/invoices/{{invoiceId}}"),
    req("PATCH /school/invoices/:id/status", "PATCH", "/school/invoices/{{invoiceId}}/status", {}),
    req("GET /school/payments", "GET", "/school/payments"),
    req("POST /school/payments", "POST", "/school/payments", {}),
    req("GET /school/payments/:id/receipt", "GET", "/school/payments/{{paymentId}}/receipt"),
    req("GET /school/payments/:id/refunds", "GET", "/school/payments/{{paymentId}}/refunds"),
    req("POST /school/payments/:id/refunds", "POST", "/school/payments/{{paymentId}}/refunds", {}),
    req("GET /school/fees/due-list", "GET", "/school/fees/due-list"),
    req("GET /school/fees/reports/collection", "GET", "/school/fees/reports/collection"),
    req("GET /school/fees/reports/pending-dues", "GET", "/school/fees/reports/pending-dues"),
    req("GET /school/fees/reports/student-ledger/:studentId", "GET", "/school/fees/reports/student-ledger/{{studentId}}"),
  ]),
  folder("10 Announcements & audit", [
    req("GET /school/announcements", "GET", "/school/announcements"),
    req("GET /school/announcements/:id", "GET", "/school/announcements/{{announcementId}}"),
    req("POST /school/announcements", "POST", "/school/announcements", {}),
    req("PUT /school/announcements/:id", "PUT", "/school/announcements/{{announcementId}}", {}),
    req("DELETE /school/announcements/:id", "DELETE", "/school/announcements/{{announcementId}}"),
    req("POST /school/announcements/:id/send", "POST", "/school/announcements/{{announcementId}}/send", {}),
    req("GET /school/audit-logs", "GET", "/school/audit-logs"),
  ]),
  folder("11 Reports & report cards", [
    req("GET /school/reports/jobs", "GET", "/school/reports/jobs"),
    req("POST /school/reports/generate", "POST", "/school/reports/generate", {}),
    req("GET /school/report-cards/templates", "GET", "/school/report-cards/templates"),
    req("POST /school/report-cards/templates", "POST", "/school/report-cards/templates", {}),
    req("PUT /school/report-cards/templates/:id", "PUT", "/school/report-cards/templates/{{templateId}}", {}),
    req("DELETE /school/report-cards/templates/:id", "DELETE", "/school/report-cards/templates/{{templateId}}"),
    req("GET /school/reports/students", "GET", "/school/reports/students"),
    req("GET /school/reports/attendance", "GET", "/school/reports/attendance"),
    req("GET /school/reports/fees", "GET", "/school/reports/fees"),
    req("GET /school/reports/exam-performance", "GET", "/school/reports/exam-performance"),
  ]),
  folder("12 Settings & roles", [
    req("GET /school/settings", "GET", "/school/settings"),
    req("PUT /school/settings", "PUT", "/school/settings", {}),
    req("GET /school/roles", "GET", "/school/roles"),
    req("POST /school/roles", "POST", "/school/roles", {}),
    req("PUT /school/roles/:id", "PUT", "/school/roles/{{roleId}}", {}),
    req("DELETE /school/roles/:id", "DELETE", "/school/roles/{{roleId}}"),
  ]),
  folder("13 Face check-in & school FAQ content", [
    req("GET /school/face-checkins", "GET", "/school/face-checkins"),
    req("PATCH /school/face-checkins/:id/approve", "PATCH", "/school/face-checkins/{{faceLogId}}/approve", {}),
    req("PATCH /school/face-checkins/:id/reject", "PATCH", "/school/face-checkins/{{faceLogId}}/reject", {}),
    req("GET /school/ai/faqs", "GET", "/school/ai/faqs"),
    req("POST /school/ai/faqs", "POST", "/school/ai/faqs", {}),
    req("PUT /school/ai/faqs/:id", "PUT", "/school/ai/faqs/{{faqId}}", {}),
    req("DELETE /school/ai/faqs/:id", "DELETE", "/school/ai/faqs/{{faqId}}"),
  ]),
  folder("14 Notifications & documents", [
    req("GET /school/notifications/templates", "GET", "/school/notifications/templates"),
    req("POST /school/notifications/templates", "POST", "/school/notifications/templates", {}),
    req("PUT /school/notifications/templates/:id", "PUT", "/school/notifications/templates/{{templateId}}", {}),
    req("DELETE /school/notifications/templates/:id", "DELETE", "/school/notifications/templates/{{templateId}}"),
    req("GET /school/notifications/logs", "GET", "/school/notifications/logs"),
    req("GET /school/document-categories", "GET", "/school/document-categories"),
    req("POST /school/document-categories", "POST", "/school/document-categories", {}),
    req("PUT /school/document-categories/:id", "PUT", "/school/document-categories/{{docCatId}}", {}),
    req("DELETE /school/document-categories/:id", "DELETE", "/school/document-categories/{{docCatId}}"),
    req("GET /school/backups/exports", "GET", "/school/backups/exports"),
    req("POST /school/backups/exports", "POST", "/school/backups/exports", {}),
  ]),
  folder("15 Library & inventory", [
    req("GET /school/library/books", "GET", "/school/library/books"),
    req("POST /school/library/books", "POST", "/school/library/books", {}),
    req("PUT /school/library/books/:id", "PUT", "/school/library/books/{{bookId}}", {}),
    req("DELETE /school/library/books/:id", "DELETE", "/school/library/books/{{bookId}}"),
    req("GET /school/library/borrows", "GET", "/school/library/borrows"),
    req("POST /school/library/borrows", "POST", "/school/library/borrows", {}),
    req("PATCH /school/library/borrows/:id/return", "PATCH", "/school/library/borrows/{{borrowId}}/return", {}),
    req("GET /school/inventory/items", "GET", "/school/inventory/items"),
    req("POST /school/inventory/items", "POST", "/school/inventory/items", {}),
    req("PUT /school/inventory/items/:id", "PUT", "/school/inventory/items/{{invItemId}}", {}),
    req("DELETE /school/inventory/items/:id", "DELETE", "/school/inventory/items/{{invItemId}}"),
    req("GET /school/inventory/transactions", "GET", "/school/inventory/transactions"),
    req("POST /school/inventory/transactions", "POST", "/school/inventory/transactions", {}),
  ]),
  folder("16 Offline sync", [
    req("GET /school/offline-sync/records", "GET", "/school/offline-sync/records"),
    req("POST /school/offline-sync/records", "POST", "/school/offline-sync/records", {}),
    req("PATCH /school/offline-sync/records/:id", "PATCH", "/school/offline-sync/records/{{syncId}}", {}),
  ]),
  folder("17 Exams", [
    req("GET /school/exams", "GET", "/school/exams"),
    req("POST /school/exams", "POST", "/school/exams", {}),
    req("GET /school/exams/:id/marks-status", "GET", "/school/exams/{{examId}}/marks-status"),
    req("PUT /school/exams/:id", "PUT", "/school/exams/{{examId}}", {}),
    req("DELETE /school/exams/:id", "DELETE", "/school/exams/{{examId}}"),
    req("POST /school/exams/:id/marks", "POST", "/school/exams/{{examId}}/marks", {}),
    req("POST /school/exams/:id/publish", "POST", "/school/exams/{{examId}}/publish", {}),
  ]),
  folder("18 Admissions", [
    req("GET /school/admissions/applications", "GET", "/school/admissions/applications"),
    req("GET /school/admissions/applications/:id", "GET", "/school/admissions/applications/{{applicationId}}"),
    req("POST /school/admissions/applications", "POST", "/school/admissions/applications", {}),
    req("PATCH /school/admissions/applications/:id/status", "PATCH", "/school/admissions/applications/{{applicationId}}/status", {}),
    req("POST /school/admissions/applications/:id/documents", "POST", "/school/admissions/applications/{{applicationId}}/documents", {}),
    req("POST /school/admissions/applications/:id/onboard", "POST", "/school/admissions/applications/{{applicationId}}/onboard", {}),
  ]),
  folder("19 Transport", [
    req("GET /school/transport/routes", "GET", "/school/transport/routes"),
    req("POST /school/transport/routes", "POST", "/school/transport/routes", {}),
    req("PUT /school/transport/routes/:id", "PUT", "/school/transport/routes/{{routeId}}", {}),
    req("DELETE /school/transport/routes/:id", "DELETE", "/school/transport/routes/{{routeId}}"),
    req("GET /school/transport/drivers", "GET", "/school/transport/drivers"),
    req("POST /school/transport/drivers", "POST", "/school/transport/drivers", {}),
    req("GET /school/transport/allocations", "GET", "/school/transport/allocations"),
    req("POST /school/transport/allocations", "POST", "/school/transport/allocations", {}),
    req("PUT /school/transport/allocations/:id", "PUT", "/school/transport/allocations/{{allocId}}", {}),
    req("DELETE /school/transport/allocations/:id", "DELETE", "/school/transport/allocations/{{allocId}}"),
  ]),
  folder("20 Hostel", [
    req("GET /school/hostel/rooms", "GET", "/school/hostel/rooms"),
    req("POST /school/hostel/rooms", "POST", "/school/hostel/rooms", {}),
    req("PUT /school/hostel/rooms/:id", "PUT", "/school/hostel/rooms/{{roomId}}", {}),
    req("DELETE /school/hostel/rooms/:id", "DELETE", "/school/hostel/rooms/{{roomId}}"),
    req("GET /school/hostel/allocations", "GET", "/school/hostel/allocations"),
    req("POST /school/hostel/allocations", "POST", "/school/hostel/allocations", {}),
    req("GET /school/hostel/attendance", "GET", "/school/hostel/attendance"),
    req("POST /school/hostel/attendance", "POST", "/school/hostel/attendance", {}),
    req("GET /school/hostel/visitors", "GET", "/school/hostel/visitors"),
    req("POST /school/hostel/visitors", "POST", "/school/hostel/visitors", {}),
  ]),
  folder("21 Events, homework, study materials", [
    req("GET /school/events", "GET", "/school/events"),
    req("GET /school/events/:id", "GET", "/school/events/{{eventId}}"),
    req("POST /school/events", "POST", "/school/events", {}),
    req("PUT /school/events/:id", "PUT", "/school/events/{{eventId}}", {}),
    req("DELETE /school/events/:id", "DELETE", "/school/events/{{eventId}}"),
    req("GET /school/events/:id/registrations", "GET", "/school/events/{{eventId}}/registrations"),
    req("POST /school/events/:id/registrations", "POST", "/school/events/{{eventId}}/registrations", {}),
    req("POST /school/events/:id/gallery", "POST", "/school/events/{{eventId}}/gallery", {}),
    req("DELETE /school/events/:id/gallery/:imageId", "DELETE", "/school/events/{{eventId}}/gallery/{{imageId}}"),
    req("GET /school/homework", "GET", "/school/homework"),
    req("GET /school/homework/:id", "GET", "/school/homework/{{homeworkId}}"),
    req("POST /school/homework", "POST", "/school/homework", {}),
    req("PUT /school/homework/:id", "PUT", "/school/homework/{{homeworkId}}", {}),
    req("DELETE /school/homework/:id", "DELETE", "/school/homework/{{homeworkId}}"),
    req("POST /school/homework/:id/submit", "POST", "/school/homework/{{homeworkId}}/submit", {}),
    req("GET /school/study-materials", "GET", "/school/study-materials"),
    req("POST /school/study-materials", "POST", "/school/study-materials", {}),
    req("PUT /school/study-materials/:id", "PUT", "/school/study-materials/{{materialId}}", {}),
    req("DELETE /school/study-materials/:id", "DELETE", "/school/study-materials/{{materialId}}"),
    req("GET /school/achievements", "GET", "/school/achievements"),
    req("POST /school/achievements", "POST", "/school/achievements", {}),
    req("DELETE /school/achievements/:id", "DELETE", "/school/achievements/{{achievementId}}"),
  ]),
];

const collection = {
  info: {
    _postman_id: "school-erp-admin-" + Date.now(),
    name: "School ERP — Admin / School panel",
    schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    description:
      "Admin & school staff APIs: `/api/v1/school/*`, `/api/v1/school/students/*`, `/api/v1/dashboard/*`. " +
      "Set `base_url` to `https://YOUR-HOST/api/v1`. Run **01 Auth → POST /auth/login** first. " +
      "Use a user with role SCHOOLADMIN, SUPERADMIN, HR, or ACCOUNTANT as required by each route. " +
      "Many POST/PUT bodies are placeholders — adjust to match `zod` schemas in handlers.",
  },
  variable: [
    { key: "base_url", value: "https://backend-school-app.onrender.com/api/v1" },
    { key: "auth_token", value: "" },
    { key: "accessToken", value: "" },
    { key: "refreshToken", value: "" },
    { key: "adminEmail", value: "admin@school.edu" },
    { key: "adminPassword", value: "Admin123!" },
    { key: "schoolId", value: "" },
    { key: "studentId", value: "" },
    { key: "parentId", value: "" },
    { key: "staffId", value: "" },
    { key: "userId", value: "" },
    { key: "classId", value: "" },
    { key: "sectionId", value: "" },
    { key: "invoiceId", value: "" },
    { key: "paymentId", value: "" },
    { key: "announcementId", value: "" },
    { key: "examId", value: "" },
    { key: "eventId", value: "" },
    { key: "homeworkId", value: "" },
    { key: "applicationId", value: "" },
    { key: "bookId", value: "" },
    { key: "borrowId", value: "" },
    { key: "routeId", value: "" },
    { key: "allocId", value: "" },
    { key: "roomId", value: "" },
    { key: "faceLogId", value: "" },
    { key: "faqId", value: "" },
    { key: "templateId", value: "" },
    { key: "docCatId", value: "" },
    { key: "syncId", value: "" },
    { key: "feeStructureId", value: "" },
    { key: "ruleId", value: "" },
    { key: "slotId", value: "" },
    { key: "periodId", value: "" },
    { key: "sessionId", value: "" },
    { key: "materialId", value: "" },
    { key: "achievementId", value: "" },
    { key: "imageId", value: "" },
    { key: "roleId", value: "" },
    { key: "academicYearId", value: "" },
    { key: "termId", value: "" },
    { key: "holidayId", value: "" },
    { key: "subjectId", value: "" },
    { key: "attendanceRecordId", value: "" },
    { key: "invItemId", value: "" },
    { key: "docId", value: "" },
  ],
  item: items.map(toPostmanItem),
};

const outPath = path.join(__dirname, "School-ERP-Admin.postman_collection.json");
fs.writeFileSync(outPath, JSON.stringify(collection, null, 2), "utf8");
console.log("Written:", outPath);
