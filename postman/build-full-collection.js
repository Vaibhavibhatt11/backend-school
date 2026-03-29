/**
 * Builds School-ERP-Full.postman_collection.json (routes embedded in this script).
 * Run: node build-full-collection.js
 */
const fs = require('fs');
const path = require('path');

const BASE = '{{base_url}}';
const bearerAuth = {
  type: 'bearer',
  bearer: [{ key: 'token', value: '{{auth_token}}', type: 'string' }]
};

function req(name, method, path, body = null, noAuth = false) {
  const pathStr = path.startsWith('/') ? path.slice(1) : path;
  const raw = BASE + '/' + pathStr;
  const request = {
    method,
    header: body ? [{ key: 'Content-Type', value: 'application/json' }] : [],
    url: raw,
  };
  if (!noAuth) request.auth = bearerAuth;
  if (body) request.body = { mode: 'raw', raw: typeof body === 'string' ? body : JSON.stringify(body, null, 2), options: { raw: { language: 'json' } } };
  return { name, request };
}

function folder(name, items) {
  return { name, item: items };
}

function eventTest(setToken) {
  if (!setToken) return undefined;
  return [{
    listen: 'test',
    script: {
      type: 'text/javascript',
      exec: [
        "pm.test('Status 2xx', function () { pm.response.to.be.success; });",
        "const j = pm.response.json();",
        "if (j && j.data && j.data.accessToken) { pm.collectionVariables.set('auth_token', j.data.accessToken); pm.collectionVariables.set('accessToken', j.data.accessToken); }",
        "if (j && j.data && j.data.refreshToken) pm.collectionVariables.set('refreshToken', j.data.refreshToken);"
      ]
    }
  }];
}

const items = [
  folder('00 Health', [
    req('GET /health', 'GET', '/health', null, true),
    req('GET /ready', 'GET', '/ready', null, true)
  ]),
  folder('01 Auth', [
    (() => { const r = req('POST /auth/login', 'POST', '/auth/login', { email: 'admin@school.edu', password: 'Admin123!' }, true); r.event = eventTest(true); return r; })(),
    (() => { const r = req('POST /auth/refresh', 'POST', '/auth/refresh', { refreshToken: '{{refreshToken}}' }, true); r.event = eventTest(true); return r; })(),
    req('POST /auth/logout', 'POST', '/auth/logout', {}),
    req('GET /auth/me', 'GET', '/auth/me'),
    req('POST /auth/forgot-password', 'POST', '/auth/forgot-password', { email: '{{forgotEmail}}' }, true),
    req('POST /auth/verify-otp', 'POST', '/auth/verify-otp', { email: '{{forgotEmail}}', otp: '{{otp}}' }, true),
    req('POST /auth/reset-password', 'POST', '/auth/reset-password', { resetToken: '{{resetToken}}', newPassword: '{{resetNewPassword}}' }, true),
    req('POST /auth/change-password', 'POST', '/auth/change-password', { currentPassword: '{{changeCurrentPassword}}', newPassword: '{{changeNewPassword}}' })
  ]),
  folder('02 Dashboard', [
    req('GET /dashboard/school-admin', 'GET', '/dashboard/school-admin'),
    req('GET /dashboard/hr', 'GET', '/dashboard/hr'),
    req('GET /dashboard/accountant', 'GET', '/dashboard/accountant')
  ]),
  folder('03 Superadmin', [
    folder('Dashboard', [req('GET /superadmin/dashboard/overview', 'GET', '/superadmin/dashboard/overview')]),
    folder('Schools', [
      req('GET /superadmin/schools', 'GET', '/superadmin/schools'),
      req('POST /superadmin/schools', 'POST', '/superadmin/schools', { name: 'School Name', email: 'school@example.com', phone: '', address: '' }),
      req('GET /superadmin/schools/:id', 'GET', '/superadmin/schools/{{schoolId}}'),
      req('PUT /superadmin/schools/:id', 'PUT', '/superadmin/schools/{{schoolId}}', { name: '', email: '', phone: '', address: '' }),
      req('PATCH /superadmin/schools/:id/status', 'PATCH', '/superadmin/schools/{{schoolId}}/status', { status: 'ACTIVE' }),
      req('DELETE /superadmin/schools/:id', 'DELETE', '/superadmin/schools/{{schoolId}}')
    ]),
    folder('Subscriptions', [
      req('GET /superadmin/subscriptions', 'GET', '/superadmin/subscriptions'),
      req('PATCH /superadmin/subscriptions/:schoolId/plan', 'PATCH', '/superadmin/subscriptions/{{schoolId}}/plan', { planCode: '' }),
      req('PATCH /superadmin/subscriptions/:schoolId/auto-renew', 'PATCH', '/superadmin/subscriptions/{{schoolId}}/auto-renew', { autoRenew: true })
    ]),
    folder('Plans', [
      req('GET /superadmin/plans', 'GET', '/superadmin/plans'),
      req('PUT /superadmin/plans/:planCode', 'PUT', '/superadmin/plans/{{planCode}}', {})
    ]),
    folder('Configuration', [
      req('GET /superadmin/configuration', 'GET', '/superadmin/configuration'),
      req('PUT /superadmin/configuration', 'PUT', '/superadmin/configuration', {})
    ]),
    folder('Support', [
      req('GET /superadmin/support/tickets', 'GET', '/superadmin/support/tickets'),
      req('GET /superadmin/support/tickets/:id', 'GET', '/superadmin/support/tickets/{{ticketId}}'),
      req('POST /superadmin/support/tickets/:id/replies', 'POST', '/superadmin/support/tickets/{{ticketId}}/replies', { message: '' }),
      req('PATCH /superadmin/support/tickets/:id/status', 'PATCH', '/superadmin/support/tickets/{{ticketId}}/status', { status: '' })
    ]),
    folder('Analytics', [req('GET /superadmin/analytics/overview', 'GET', '/superadmin/analytics/overview')]),
    folder('Accountants', [
      req('GET /superadmin/accountants', 'GET', '/superadmin/accountants'),
      req('POST /superadmin/accountants', 'POST', '/superadmin/accountants', { fullName: '', email: '', password: '' }),
      req('GET /superadmin/accountants/:id', 'GET', '/superadmin/accountants/{{accountantId}}'),
      req('PUT /superadmin/accountants/:id', 'PUT', '/superadmin/accountants/{{accountantId}}', {}),
      req('PATCH /superadmin/accountants/:id/status', 'PATCH', '/superadmin/accountants/{{accountantId}}/status', { status: 'ACTIVE' }),
      req('DELETE /superadmin/accountants/:id', 'DELETE', '/superadmin/accountants/{{accountantId}}')
    ]),
    folder('Staff', [
      req('GET /superadmin/staff', 'GET', '/superadmin/staff'),
      req('POST /superadmin/staff', 'POST', '/superadmin/staff', {}),
      req('GET /superadmin/staff/:id', 'GET', '/superadmin/staff/{{staffId}}'),
      req('PUT /superadmin/staff/:id', 'PUT', '/superadmin/staff/{{staffId}}', {}),
      req('PATCH /superadmin/staff/:id/status', 'PATCH', '/superadmin/staff/{{staffId}}/status', { status: 'ACTIVE' }),
      req('DELETE /superadmin/staff/:id', 'DELETE', '/superadmin/staff/{{staffId}}')
    ]),
    folder('Invitations', [
      req('GET /superadmin/invitations', 'GET', '/superadmin/invitations'),
      req('POST /superadmin/invitations', 'POST', '/superadmin/invitations', { email: '', role: '', schoolId: '' }),
      req('POST /superadmin/invitations/:id/resend', 'POST', '/superadmin/invitations/{{invitationId}}/resend'),
      req('DELETE /superadmin/invitations/:id', 'DELETE', '/superadmin/invitations/{{invitationId}}')
    ]),
    folder('Security', [
      req('GET /superadmin/security/settings', 'GET', '/superadmin/security/settings'),
      req('PUT /superadmin/security/settings', 'PUT', '/superadmin/security/settings', {}),
      req('GET /superadmin/security/sessions', 'GET', '/superadmin/security/sessions'),
      req('DELETE /superadmin/security/sessions/:id', 'DELETE', '/superadmin/security/sessions/{{sessionId}}'),
      req('POST /superadmin/security/sessions/revoke-all', 'POST', '/superadmin/security/sessions/revoke-all'),
      req('POST /superadmin/security/keys/rotate', 'POST', '/superadmin/security/keys/rotate'),
      req('GET /superadmin/security/audit-logs', 'GET', '/superadmin/security/audit-logs')
    ]),
    folder('Notifications', [
      req('GET /superadmin/notifications', 'GET', '/superadmin/notifications'),
      req('PATCH /superadmin/notifications/:id/read', 'PATCH', '/superadmin/notifications/{{notificationId}}/read'),
      req('DELETE /superadmin/notifications/:id', 'DELETE', '/superadmin/notifications/{{notificationId}}')
    ]),
    folder('Firebase', [req('POST /superadmin/firebase/upload', 'POST', '/superadmin/firebase/upload')]) // multipart - user sets file
  ]),
  folder('04 School', [
    folder('4.1 Profile & RBAC', [
      req('GET /school/profile', 'GET', '/school/profile'),
      req('PUT /school/profile', 'PUT', '/school/profile', { name: '', email: '', phone: '', timezone: '', currencyCode: '' }),
      req('GET /school/permissions', 'GET', '/school/permissions'),
      req('GET /school/admin-users', 'GET', '/school/admin-users'),
      req('POST /school/admin-users', 'POST', '/school/admin-users', { fullName: '', email: '', password: '', role: '' }),
      req('PUT /school/admin-users/:id', 'PUT', '/school/admin-users/{{adminUserId}}', { fullName: '', role: '', isActive: true }),
      req('GET /school/permissions/matrix', 'GET', '/school/permissions/matrix'),
      req('PUT /school/permissions/matrix', 'PUT', '/school/permissions/matrix', {}),
      req('GET /school/roles', 'GET', '/school/roles'),
      req('POST /school/roles', 'POST', '/school/roles', {}),
      req('PUT /school/roles/:id', 'PUT', '/school/roles/{{roleId}}', {}),
      req('DELETE /school/roles/:id', 'DELETE', '/school/roles/{{roleId}}'),
      req('GET /school/settings', 'GET', '/school/settings'),
      req('PUT /school/settings', 'PUT', '/school/settings', {})
    ]),
    folder('4.2 Parents', [
      req('GET /school/parents', 'GET', '/school/parents'),
      req('GET /school/parents/:id', 'GET', '/school/parents/{{parentId}}'),
      req('POST /school/parents', 'POST', '/school/parents', {}),
      req('PUT /school/parents/:id', 'PUT', '/school/parents/{{parentId}}', {}),
      req('POST /school/parents/invite', 'POST', '/school/parents/invite', { fullName: '', email: '', studentId: '', relationType: '' }),
      req('POST /school/parents/:id/resend-otp', 'POST', '/school/parents/{{parentId}}/resend-otp')
    ]),
    folder('4.3 Staff', [
      req('GET /school/staff', 'GET', '/school/staff'),
      req('GET /school/staff/:id', 'GET', '/school/staff/{{staffId}}'),
      req('POST /school/staff', 'POST', '/school/staff', {}),
      req('PUT /school/staff/:id', 'PUT', '/school/staff/{{staffId}}', {}),
      req('DELETE /school/staff/:id', 'DELETE', '/school/staff/{{staffId}}'),
      req('GET /school/staff/:id/documents', 'GET', '/school/staff/{{staffId}}/documents'),
      req('POST /school/staff/:id/documents', 'POST', '/school/staff/{{staffId}}/documents', { name: '', url: '', type: '' }),
      req('DELETE /school/staff/:id/documents/:docId', 'DELETE', '/school/staff/{{staffId}}/documents/{{docId}}')
    ]),
    folder('4.4 Classes & Sections', [
      req('GET /school/classes', 'GET', '/school/classes'),
      req('POST /school/classes', 'POST', '/school/classes', { name: '' }),
      req('PUT /school/classes/:id', 'PUT', '/school/classes/{{classId}}', {}),
      req('DELETE /school/classes/:id', 'DELETE', '/school/classes/{{classId}}'),
      req('GET /school/sections', 'GET', '/school/sections'),
      req('POST /school/sections', 'POST', '/school/sections', {}),
      req('PUT /school/sections/:id', 'PUT', '/school/sections/{{sectionId}}', {}),
      req('DELETE /school/sections/:id', 'DELETE', '/school/sections/{{sectionId}}')
    ]),
    folder('4.5 Academic Years, Terms, Holidays', [
      req('GET /school/academic-years', 'GET', '/school/academic-years'),
      req('POST /school/academic-years', 'POST', '/school/academic-years', {}),
      req('PUT /school/academic-years/:id', 'PUT', '/school/academic-years/{{academicYearId}}', {}),
      req('PATCH /school/academic-years/:id/activate', 'PATCH', '/school/academic-years/{{academicYearId}}/activate'),
      req('DELETE /school/academic-years/:id', 'DELETE', '/school/academic-years/{{academicYearId}}'),
      req('GET /school/terms', 'GET', '/school/terms'),
      req('POST /school/terms', 'POST', '/school/terms', {}),
      req('PUT /school/terms/:id', 'PUT', '/school/terms/{{termId}}', {}),
      req('DELETE /school/terms/:id', 'DELETE', '/school/terms/{{termId}}'),
      req('GET /school/holidays', 'GET', '/school/holidays'),
      req('POST /school/holidays', 'POST', '/school/holidays', {}),
      req('PUT /school/holidays/:id', 'PUT', '/school/holidays/{{holidayId}}', {}),
      req('DELETE /school/holidays/:id', 'DELETE', '/school/holidays/{{holidayId}}')
    ]),
    folder('4.6 Subjects', [
      req('GET /school/subjects', 'GET', '/school/subjects'),
      req('POST /school/subjects', 'POST', '/school/subjects', { name: '', code: '' }),
      req('PUT /school/subjects/:id', 'PUT', '/school/subjects/{{subjectId}}', {}),
      req('DELETE /school/subjects/:id', 'DELETE', '/school/subjects/{{subjectId}}')
    ]),
    folder('4.7 Attendance', [
      req('GET /school/attendance/overview', 'GET', '/school/attendance/overview'),
      req('GET /school/attendance/records', 'GET', '/school/attendance/records'),
      req('PUT /school/attendance/records/:id', 'PUT', '/school/attendance/records/{{recordId}}', { status: 'PRESENT', remark: '' }),
      req('GET /school/attendance/export', 'GET', '/school/attendance/export'),
      req('POST /school/attendance/mark', 'POST', '/school/attendance/mark', { type: 'student', studentId: '', date: '', status: 'PRESENT', remark: '' }),
      req('POST /school/attendance/bulk-mark', 'POST', '/school/attendance/bulk-mark', { type: 'student', date: '', records: [] })
    ]),
    folder('4.8 Timetable', [
      req('GET /school/timetable', 'GET', '/school/timetable'),
      req('GET /school/timetable/teacher/:staffId', 'GET', '/school/timetable/teacher/{{staffId}}'),
      req('GET /school/timetable/class/:classId', 'GET', '/school/timetable/class/{{classId}}'),
      req('GET /school/timetable/conflicts', 'GET', '/school/timetable/conflicts'),
      req('POST /school/timetable/slots', 'POST', '/school/timetable/slots', {}),
      req('PUT /school/timetable/slots/:id', 'PUT', '/school/timetable/slots/{{slotId}}', {}),
      req('DELETE /school/timetable/slots/:id', 'DELETE', '/school/timetable/slots/{{slotId}}'),
      req('POST /school/timetable/publish', 'POST', '/school/timetable/publish', {}),
      req('GET /school/timetable/periods', 'GET', '/school/timetable/periods'),
      req('POST /school/timetable/periods', 'POST', '/school/timetable/periods', {}),
      req('PUT /school/timetable/periods/:id', 'PUT', '/school/timetable/periods/{{periodId}}', {}),
      req('DELETE /school/timetable/periods/:id', 'DELETE', '/school/timetable/periods/{{periodId}}')
    ]),
    folder('4.9 Fees & Billing', [
      req('GET /school/fees/summary', 'GET', '/school/fees/summary'),
      req('GET /school/fees/structures', 'GET', '/school/fees/structures'),
      req('POST /school/fees/structures', 'POST', '/school/fees/structures', {}),
      req('PUT /school/fees/structures/:id', 'PUT', '/school/fees/structures/{{feeStructureId}}', {}),
      req('DELETE /school/fees/structures/:id', 'DELETE', '/school/fees/structures/{{feeStructureId}}'),
      req('GET /school/fees/discount-rules', 'GET', '/school/fees/discount-rules'),
      req('POST /school/fees/discount-rules', 'POST', '/school/fees/discount-rules', {}),
      req('PUT /school/fees/discount-rules/:id', 'PUT', '/school/fees/discount-rules/{{discountRuleId}}', {}),
      req('DELETE /school/fees/discount-rules/:id', 'DELETE', '/school/fees/discount-rules/{{discountRuleId}}'),
      req('GET /school/invoices', 'GET', '/school/invoices'),
      req('POST /school/invoices', 'POST', '/school/invoices', {}),
      req('POST /school/invoices/bulk-generate', 'POST', '/school/invoices/bulk-generate', { feeStructureId: '', dueDate: '', amountPerStudent: 0, classId: '' }),
      req('GET /school/invoices/:id', 'GET', '/school/invoices/{{invoiceId}}'),
      req('PATCH /school/invoices/:id/status', 'PATCH', '/school/invoices/{{invoiceId}}/status', { status: '' }),
      req('GET /school/payments', 'GET', '/school/payments'),
      req('POST /school/payments', 'POST', '/school/payments', {}),
      req('GET /school/payments/:id/receipt', 'GET', '/school/payments/{{paymentId}}/receipt'),
      req('GET /school/payments/:id/refunds', 'GET', '/school/payments/{{paymentId}}/refunds'),
      req('POST /school/payments/:id/refunds', 'POST', '/school/payments/{{paymentId}}/refunds', {}),
      req('GET /school/fees/due-list', 'GET', '/school/fees/due-list'),
      req('GET /school/fees/reports/collection', 'GET', '/school/fees/reports/collection'),
      req('GET /school/fees/reports/pending-dues', 'GET', '/school/fees/reports/pending-dues'),
      req('GET /school/fees/reports/student-ledger/:studentId', 'GET', '/school/fees/reports/student-ledger/{{studentId}}')
    ]),
    folder('4.10 Announcements & Notifications', [
      req('GET /school/announcements', 'GET', '/school/announcements'),
      req('GET /school/announcements/:id', 'GET', '/school/announcements/{{announcementId}}'),
      req('POST /school/announcements', 'POST', '/school/announcements', {}),
      req('PUT /school/announcements/:id', 'PUT', '/school/announcements/{{announcementId}}', {}),
      req('DELETE /school/announcements/:id', 'DELETE', '/school/announcements/{{announcementId}}'),
      req('POST /school/announcements/:id/send', 'POST', '/school/announcements/{{announcementId}}/send'),
      req('GET /school/notifications/templates', 'GET', '/school/notifications/templates'),
      req('POST /school/notifications/templates', 'POST', '/school/notifications/templates', {}),
      req('PUT /school/notifications/templates/:id', 'PUT', '/school/notifications/templates/{{templateId}}', {}),
      req('DELETE /school/notifications/templates/:id', 'DELETE', '/school/notifications/templates/{{templateId}}'),
      req('GET /school/notifications/logs', 'GET', '/school/notifications/logs')
    ]),
    folder('4.11 Reports, Audit, Settings', [
      req('GET /school/reports/jobs', 'GET', '/school/reports/jobs'),
      req('POST /school/reports/generate', 'POST', '/school/reports/generate', { type: '', params: {}, schoolId: '' }),
      req('GET /school/reports/students', 'GET', '/school/reports/students'),
      req('GET /school/reports/attendance', 'GET', '/school/reports/attendance'),
      req('GET /school/reports/fees', 'GET', '/school/reports/fees'),
      req('GET /school/reports/exam-performance', 'GET', '/school/reports/exam-performance'),
      req('GET /school/audit-logs', 'GET', '/school/audit-logs'),
      req('GET /school/report-cards/templates', 'GET', '/school/report-cards/templates'),
      req('POST /school/report-cards/templates', 'POST', '/school/report-cards/templates', {}),
      req('PUT /school/report-cards/templates/:id', 'PUT', '/school/report-cards/templates/{{templateId}}', {}),
      req('DELETE /school/report-cards/templates/:id', 'DELETE', '/school/report-cards/templates/{{templateId}}')
    ]),
    folder('4.12 Face Check-in & AI FAQ', [
      req('GET /school/face-checkins', 'GET', '/school/face-checkins'),
      req('PATCH /school/face-checkins/:id/approve', 'PATCH', '/school/face-checkins/{{faceCheckinId}}/approve', { reason: '' }),
      req('PATCH /school/face-checkins/:id/reject', 'PATCH', '/school/face-checkins/{{faceCheckinId}}/reject', { reason: '' }),
      req('GET /school/ai/faqs', 'GET', '/school/ai/faqs'),
      req('POST /school/ai/faqs', 'POST', '/school/ai/faqs', {}),
      req('PUT /school/ai/faqs/:id', 'PUT', '/school/ai/faqs/{{faqId}}', {}),
      req('DELETE /school/ai/faqs/:id', 'DELETE', '/school/ai/faqs/{{faqId}}')
    ]),
    folder('4.13 Documents, Backups, Library, Inventory', [
      req('GET /school/document-categories', 'GET', '/school/document-categories'),
      req('POST /school/document-categories', 'POST', '/school/document-categories', {}),
      req('PUT /school/document-categories/:id', 'PUT', '/school/document-categories/{{categoryId}}', {}),
      req('DELETE /school/document-categories/:id', 'DELETE', '/school/document-categories/{{categoryId}}'),
      req('GET /school/backups/exports', 'GET', '/school/backups/exports'),
      req('POST /school/backups/exports', 'POST', '/school/backups/exports', {}),
      req('GET /school/library/books', 'GET', '/school/library/books'),
      req('POST /school/library/books', 'POST', '/school/library/books', {}),
      req('PUT /school/library/books/:id', 'PUT', '/school/library/books/{{bookId}}', {}),
      req('DELETE /school/library/books/:id', 'DELETE', '/school/library/books/{{bookId}}'),
      req('GET /school/library/borrows', 'GET', '/school/library/borrows'),
      req('POST /school/library/borrows', 'POST', '/school/library/borrows', {}),
      req('PATCH /school/library/borrows/:id/return', 'PATCH', '/school/library/borrows/{{borrowId}}/return'),
      req('GET /school/inventory/items', 'GET', '/school/inventory/items'),
      req('POST /school/inventory/items', 'POST', '/school/inventory/items', {}),
      req('PUT /school/inventory/items/:id', 'PUT', '/school/inventory/items/{{itemId}}', {}),
      req('DELETE /school/inventory/items/:id', 'DELETE', '/school/inventory/items/{{itemId}}'),
      req('GET /school/inventory/transactions', 'GET', '/school/inventory/transactions'),
      req('POST /school/inventory/transactions', 'POST', '/school/inventory/transactions', {})
    ]),
    folder('4.14 Offline Sync, Live Classes, Exams', [
      req('GET /school/offline-sync/records', 'GET', '/school/offline-sync/records'),
      req('POST /school/offline-sync/records', 'POST', '/school/offline-sync/records', {}),
      req('PATCH /school/offline-sync/records/:id', 'PATCH', '/school/offline-sync/records/{{recordId}}', {}),
      req('GET /school/live-classes/sessions', 'GET', '/school/live-classes/sessions'),
      req('POST /school/live-classes/sessions', 'POST', '/school/live-classes/sessions', {}),
      req('PUT /school/live-classes/sessions/:id', 'PUT', '/school/live-classes/sessions/{{sessionId}}', {}),
      req('POST /school/live-classes/sessions/:id/end', 'POST', '/school/live-classes/sessions/{{sessionId}}/end'),
      req('GET /school/exams', 'GET', '/school/exams'),
      req('POST /school/exams', 'POST', '/school/exams', {}),
      req('GET /school/exams/:id/marks-status', 'GET', '/school/exams/{{examId}}/marks-status'),
      req('PUT /school/exams/:id', 'PUT', '/school/exams/{{examId}}', {}),
      req('DELETE /school/exams/:id', 'DELETE', '/school/exams/{{examId}}'),
      req('POST /school/exams/:id/marks', 'POST', '/school/exams/{{examId}}/marks', { results: [{ studentId: '', marks: 0, grade: '', remarks: '' }] }),
      req('POST /school/exams/:id/publish', 'POST', '/school/exams/{{examId}}/publish')
    ])
  ]),
  folder('05 Students', [
    req('GET /school/students', 'GET', '/school/students'),
    req('GET /school/students/export', 'GET', '/school/students/export'),
    req('POST /school/students', 'POST', '/school/students', {}),
    req('POST /school/students/import', 'POST', '/school/students/import', { students: [] }),
    req('GET /school/students/:id', 'GET', '/school/students/{{studentId}}'),
    req('PUT /school/students/:id', 'PUT', '/school/students/{{studentId}}', {}),
    req('DELETE /school/students/:id', 'DELETE', '/school/students/{{studentId}}'),
    req('PATCH /school/students/:id/status', 'PATCH', '/school/students/{{studentId}}/status', { status: 'ACTIVE' }),
    req('POST /school/students/:id/move-class', 'POST', '/school/students/{{studentId}}/move-class', { className: '', section: '', classId: '' }),
    req('POST /school/students/:id/documents', 'POST', '/school/students/{{studentId}}/documents', {}),
    req('DELETE /school/students/:id/documents/:docId', 'DELETE', '/school/students/{{studentId}}/documents/{{docId}}')
  ]),
  folder('06 HR', [
    req('GET /hr/dashboard/overview', 'GET', '/hr/dashboard/overview'),
    req('GET /hr/staff', 'GET', '/hr/staff'),
    req('GET /hr/staff/:id', 'GET', '/hr/staff/{{staffId}}'),
    req('GET /hr/leave-requests', 'GET', '/hr/leave-requests'),
    req('GET /hr/leave-requests/:id', 'GET', '/hr/leave-requests/{{leaveRequestId}}'),
    req('PATCH /hr/leave-requests/:id/status', 'PATCH', '/hr/leave-requests/{{leaveRequestId}}/status', { status: 'APPROVED' }),
    req('POST /hr/leave-requests/:id/comment', 'POST', '/hr/leave-requests/{{leaveRequestId}}/comment', { comment: '' }),
    req('GET /hr/attendance/performance', 'GET', '/hr/attendance/performance'),
    req('GET /hr/attendance/performance/:staffId', 'GET', '/hr/attendance/performance/{{staffId}}'),
    req('GET /hr/settings', 'GET', '/hr/settings'),
    req('PUT /hr/settings', 'PUT', '/hr/settings', {}),
    req('GET /hr/roles', 'GET', '/hr/roles'),
    req('PUT /hr/roles/:id', 'PUT', '/hr/roles/{{roleId}}', {})
  ]),
  folder('07 Accountant', [
    req('GET /accountant/dashboard/overview', 'GET', '/accountant/dashboard/overview'),
    req('GET /accountant/fees/structures', 'GET', '/accountant/fees/structures'),
    req('POST /accountant/fees/structures', 'POST', '/accountant/fees/structures', {}),
    req('PUT /accountant/fees/structures/:id', 'PUT', '/accountant/fees/structures/{{feeStructureId}}', {}),
    req('DELETE /accountant/fees/structures/:id', 'DELETE', '/accountant/fees/structures/{{feeStructureId}}'),
    req('GET /accountant/invoices', 'GET', '/accountant/invoices'),
    req('POST /accountant/invoices', 'POST', '/accountant/invoices', {}),
    req('POST /accountant/invoices/bulk-generate', 'POST', '/accountant/invoices/bulk-generate', { feeStructureId: '', dueDate: '', amountPerStudent: 0, classId: '' }),
    req('GET /accountant/invoices/:id', 'GET', '/accountant/invoices/{{invoiceId}}'),
    req('PATCH /accountant/invoices/:id/status', 'PATCH', '/accountant/invoices/{{invoiceId}}/status', { status: '' }),
    req('GET /accountant/payments', 'GET', '/accountant/payments'),
    req('POST /accountant/payments', 'POST', '/accountant/payments', {}),
    req('GET /accountant/payments/:id', 'GET', '/accountant/payments/{{paymentId}}'),
    req('GET /accountant/payments/:id/receipt', 'GET', '/accountant/payments/{{paymentId}}/receipt'),
    req('GET /accountant/students/balances', 'GET', '/accountant/students/balances'),
    req('GET /accountant/reports/jobs', 'GET', '/accountant/reports/jobs'),
    req('POST /accountant/reports/generate', 'POST', '/accountant/reports/generate', { type: '', params: {} })
  ]),
  folder('08 Student app (STUDENT role JWT)', [
    req('GET /student/dashboard', 'GET', '/student/dashboard'),
    req('GET /student/profile', 'GET', '/student/profile'),
    req('PUT /student/profile', 'PUT', '/student/profile', {}),
    req('GET /student/timetable', 'GET', '/student/timetable'),
    req('GET /student/attendance', 'GET', '/student/attendance'),
    req('GET /student/homework', 'GET', '/student/homework'),
    req('GET /student/homework/:id', 'GET', '/student/homework/{{homeworkId}}'),
    req('POST /student/homework/:id/submit', 'POST', '/student/homework/{{homeworkId}}/submit', {}),
    req('GET /student/study-materials', 'GET', '/student/study-materials'),
    req('GET /student/exams', 'GET', '/student/exams'),
    req('GET /student/exams/:id/result', 'GET', '/student/exams/{{examId}}/result'),
    req('GET /student/exam-timetable', 'GET', '/student/exam-timetable'),
    req('GET /student/fees', 'GET', '/student/fees'),
    req('GET /student/fees/receipts', 'GET', '/student/fees/receipts'),
    req('GET /student/payments/:id/receipt', 'GET', '/student/payments/{{paymentId}}/receipt'),
    req('GET /student/announcements', 'GET', '/student/announcements'),
    req('GET /student/events', 'GET', '/student/events'),
    req('POST /student/events/:id/register', 'POST', '/student/events/{{eventId}}/register', {}),
    req('GET /student/transport', 'GET', '/student/transport'),
    req('GET /student/library', 'GET', '/student/library'),
    req('GET /student/library/books', 'GET', '/student/library/books'),
    req('GET /student/achievements', 'GET', '/student/achievements'),
    req('GET /student/notifications', 'GET', '/student/notifications'),
    req('GET /student/circulars', 'GET', '/student/circulars'),
    req('GET /student/health', 'GET', '/student/health'),
    req('GET /student/settings', 'GET', '/student/settings'),
    req('PUT /student/settings', 'PUT', '/student/settings', {}),
    req('GET /student/leave-requests', 'GET', '/student/leave-requests'),
    req('POST /student/leave-requests', 'POST', '/student/leave-requests', {}),
    req('GET /student/subject-teachers', 'GET', '/student/subject-teachers'),
    req('POST /student/meetings/request', 'POST', '/student/meetings/request', {}),
    req('GET /student/report-cards', 'GET', '/student/report-cards'),
    req('GET /student/documents', 'GET', '/student/documents')
  ])
];

// Convert to Postman format: each item is either a folder (item[]) or a request (request with url as string for Postman)
function toPostmanItem(it) {
  if (it.item) {
    return { name: it.name, item: it.item.map(toPostmanItem) };
  }
  const r = it.request;
  const urlRaw = typeof r.url === 'string' ? r.url : (r.url && r.url.raw) ? r.url.raw : BASE + '/';
  const reqObj = {
    method: r.method,
    header: r.header || [],
    url: urlRaw,
    auth: r.auth || undefined,
    body: r.body || undefined
  };
  const out = { name: it.name, request: reqObj };
  if (it.event) out.event = it.event;
  return out;
}

const collection = {
  info: {
    _postman_id: 'school-erp-full-' + Date.now(),
    name: 'School ERP - Full API Collection',
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    description: 'School ERP API collection. Set collection variable `base_url` (or import an environment). Run **01 Auth > POST /auth/login** first to set `auth_token`. For **08 Student app**, use a user with role STUDENT in the login body.'
  },
  variable: [
    { key: 'base_url', value: 'https://backend-school-app.onrender.com/api/v1' },
    { key: 'auth_token', value: '' },
    { key: 'accessToken', value: '' },
    { key: 'refreshToken', value: '' },
    { key: 'forgotEmail', value: 'admin@school.edu' },
    { key: 'otp', value: '654321' },
    { key: 'resetToken', value: '' },
    { key: 'resetNewPassword', value: 'Admin123!' },
    { key: 'schoolId', value: '' },
    { key: 'studentId', value: '' },
    { key: 'staffId', value: '' },
    { key: 'classId', value: '' },
    { key: 'subjectId', value: '' },
    { key: 'invoiceId', value: '' },
    { key: 'paymentId', value: '' },
    { key: 'adminUserId', value: '' },
    { key: 'roleId', value: '' },
    { key: 'parentId', value: '' },
    { key: 'sectionId', value: '' },
    { key: 'academicYearId', value: '' },
    { key: 'termId', value: '' },
    { key: 'holidayId', value: '' },
    { key: 'recordId', value: '' },
    { key: 'slotId', value: '' },
    { key: 'periodId', value: '' },
    { key: 'feeStructureId', value: '' },
    { key: 'discountRuleId', value: '' },
    { key: 'announcementId', value: '' },
    { key: 'templateId', value: '' },
    { key: 'faceCheckinId', value: '' },
    { key: 'faqId', value: '' },
    { key: 'categoryId', value: '' },
    { key: 'bookId', value: '' },
    { key: 'borrowId', value: '' },
    { key: 'itemId', value: '' },
    { key: 'sessionId', value: '' },
    { key: 'examId', value: '' },
    { key: 'leaveRequestId', value: '' },
    { key: 'ticketId', value: '' },
    { key: 'accountantId', value: '' },
    { key: 'invitationId', value: '' },
    { key: 'notificationId', value: '' },
    { key: 'homeworkId', value: '' },
    { key: 'eventId', value: '' },
    { key: 'docId', value: '' }
  ],
  item: items.map(toPostmanItem)
};



const outPath = path.join(__dirname, 'School-ERP-Full.postman_collection.json');
fs.writeFileSync(outPath, JSON.stringify(collection, null, 2), 'utf8');
console.log('Written:', outPath);
