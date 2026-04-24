const { spawn } = require("child_process");
const path = require("path");

const BASE_URL = process.env.SMOKE_BASE_URL || "http://localhost:5000/api/v1";
const ROOT_DIR = path.resolve(__dirname, "..");

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const failures = [];

function createError(message, details) {
  const error = new Error(message);
  error.details = details;
  return error;
}

async function waitForServer(timeoutMs = 60_000) {
  const startedAt = Date.now();
  while (Date.now() - startedAt < timeoutMs) {
    try {
      const res = await fetch(`${BASE_URL}/ready`);
      if (res.ok) return;
    } catch {
      // retry
    }
    await sleep(500);
  }
  throw createError("Server did not become ready in time");
}

async function api(pathname, options = {}) {
  const {
    method = "GET",
    token,
    body,
    expected = [200],
    name = `${method} ${pathname}`,
    required = false,
  } = options;

  const headers = { Accept: "application/json" };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body !== undefined) headers["Content-Type"] = "application/json";

  console.log(`RUN   ${name}`);
  const response = await fetch(`${BASE_URL}${pathname}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  const raw = await response.text();
  let parsed;
  try {
    parsed = raw ? JSON.parse(raw) : null;
  } catch {
    parsed = raw;
  }

  if (!expected.includes(response.status)) {
    const details = {
      status: response.status,
      body: parsed,
    };
    failures.push({ name, method, pathname, ...details });
    console.log(`FAIL  ${name} -> ${response.status}`);
    if (required) {
      throw createError(`Failed: ${name}`, details);
    }
    return null;
  }

  console.log(`PASS  ${name} -> ${response.status}`);
  return parsed;
}

async function runAdminWorkflow(adminToken) {
  const admin = {};
  const today = new Date().toISOString().slice(0, 10);
  await api("/dashboard/school-admin", { token: adminToken, name: "Admin dashboard", expected: [200] });
  await api("/dashboard/accountant", { token: adminToken, name: "Admin accountant dashboard", expected: [200] });
  await api("/school/profile/me", { token: adminToken, name: "Admin profile me", expected: [200] });
  await api("/school/profile", { token: adminToken, name: "School profile", expected: [200] });
  await api("/school/settings", { token: adminToken, name: "School settings", expected: [200] });
  await api("/school/approvals/pending-summary", { token: adminToken, name: "Approvals pending summary", expected: [200] });
  await api("/school/notifications", { token: adminToken, name: "School notifications", expected: [200] });

  await api("/school/students?page=1&limit=5", { token: adminToken, name: "List students", expected: [200] });
  const studentList = await api("/school/students?page=1&limit=1", { token: adminToken, name: "List one student", expected: [200] });
  const studentId = studentList?.data?.items?.[0]?.id;
  if (studentId) {
    admin.studentId = studentId;
    await api(`/school/students/${studentId}`, { token: adminToken, name: "Get student by id", expected: [200] });
    await api(`/school/students/${studentId}/documents?page=1&limit=5`, {
      token: adminToken,
      name: "Student documents",
      expected: [200],
    });
  }

  await api("/school/staff?page=1&limit=5", { token: adminToken, name: "List staff", expected: [200] });
  const staffList = await api("/school/staff?page=1&limit=1", { token: adminToken, name: "List one staff", expected: [200] });
  const staffId = staffList?.data?.items?.[0]?.id;
  if (staffId) {
    admin.staffId = staffId;
    await api(`/school/staff/${staffId}`, { token: adminToken, name: "Get staff by id", expected: [200] });
    await api(`/school/staff/${staffId}/documents?page=1&limit=5`, {
      token: adminToken,
      name: "Staff documents",
      expected: [200],
    });
  }

  const classList = await api("/school/classes?page=1&limit=5", {
    token: adminToken,
    name: "List classes",
    expected: [200],
  });
  const classId = classList?.data?.items?.[0]?.id;

  await api("/school/subjects?page=1&limit=5", { token: adminToken, name: "List subjects", expected: [200] });
  await api("/school/attendance/overview", { token: adminToken, name: "Attendance overview", expected: [200] });
  await api("/school/attendance/trend?days=7", { token: adminToken, name: "Attendance trend", expected: [200] });
  await api(`/school/attendance/records?type=student&page=1&limit=10&date=${today}`, {
    token: adminToken,
    name: "Attendance records",
    expected: [200],
  });
  await api("/school/timetable", { token: adminToken, name: "Timetable", expected: [200] });
  if (classId) {
    await api(`/school/timetable/class/${classId}`, { token: adminToken, name: "Timetable by class", expected: [200] });
  }
  if (staffId) {
    await api(`/school/timetable/teacher/${staffId}`, {
      token: adminToken,
      name: "Timetable by teacher",
      expected: [200],
    });
  }
  await api("/school/timetable/conflicts", { token: adminToken, name: "Timetable conflicts", expected: [200] });
  await api("/school/timetable/periods", { token: adminToken, name: "Timetable periods", expected: [200] });

  await api("/school/fees/summary", { token: adminToken, name: "Fees summary", expected: [200] });
  await api("/school/fees/snapshot", { token: adminToken, name: "Fees snapshot", expected: [200] });
  await api("/school/fees/structures?page=1&limit=10", { token: adminToken, name: "Fee structures", expected: [200] });
  await api("/school/fees/discount-rules?page=1&limit=10", { token: adminToken, name: "Fee discount rules", expected: [200] });
  await api("/school/fees/due-list?page=1&limit=10", { token: adminToken, name: "Fees due list", expected: [200] });
  await api("/school/fees/reports/collection", { token: adminToken, name: "Fees collection report", expected: [200] });
  await api("/school/fees/reports/pending-dues", {
    token: adminToken,
    name: "Fees pending report",
    expected: [200],
  });
  if (studentId) {
    await api(`/school/fees/reports/student-ledger/${studentId}`, {
      token: adminToken,
      name: "Student ledger",
      expected: [200],
    });
  }

  const invoicesRes = await api("/school/invoices?page=1&limit=5", { token: adminToken, name: "List invoices", expected: [200] });
  const invoiceId = invoicesRes?.data?.items?.[0]?.id;
  if (invoiceId) {
    admin.invoiceId = invoiceId;
    await api(`/school/invoices/${invoiceId}`, { token: adminToken, name: "Invoice by id", expected: [200] });
  }
  await api("/school/payments?page=1&limit=5", { token: adminToken, name: "List payments", expected: [200] });

  const announcements = await api("/school/announcements?page=1&limit=5", {
    token: adminToken,
    name: "List announcements",
    expected: [200],
  });
  const createdAnnouncement = await api("/school/announcements", {
    method: "POST",
    token: adminToken,
    name: "Create announcement",
    expected: [200, 201],
    body: {
      title: `Audit announcement ${Date.now()}`,
      content: "Automated detailed audit message",
      audience: "PARENT,STUDENT",
      status: "DRAFT",
    },
  });
  const newAnnouncementId =
    createdAnnouncement?.data?.announcement?.id ||
    createdAnnouncement?.data?.id ||
    announcements?.data?.items?.[0]?.id;
  if (newAnnouncementId) {
    await api(`/school/announcements/${newAnnouncementId}/send`, {
      method: "POST",
      token: adminToken,
      name: "Send announcement",
      expected: [200],
    });
    await api(`/school/announcements/${newAnnouncementId}`, {
      method: "DELETE",
      token: adminToken,
      name: "Delete announcement",
      expected: [200],
    });
  }

  await api("/school/audit-logs?page=1&limit=10", { token: adminToken, name: "Audit logs", expected: [200] });
  await api("/school/reports/students", { token: adminToken, name: "Students report", expected: [200] });
  await api(`/school/reports/attendance?type=student&dateFrom=${today}&dateTo=${today}`, {
    token: adminToken,
    name: "Attendance report",
    expected: [200],
  });
  await api("/school/reports/fees", { token: adminToken, name: "Fees report", expected: [200] });
  await api("/school/reports/exam-performance", {
    token: adminToken,
    name: "Exam performance report",
    expected: [200],
  });

  await api("/school/library/books?page=1&limit=10", { token: adminToken, name: "Library books", expected: [200] });
  await api("/school/library/borrows?page=1&limit=10", { token: adminToken, name: "Library borrows", expected: [200] });
  await api("/school/inventory/items?page=1&limit=10", { token: adminToken, name: "Inventory items", expected: [200] });
  await api("/school/inventory/transactions?page=1&limit=10", {
    token: adminToken,
    name: "Inventory transactions",
    expected: [200],
  });
  await api("/school/events?page=1&limit=10", { token: adminToken, name: "Events", expected: [200] });
  await api("/school/admissions/applications?page=1&limit=10", {
    token: adminToken,
    name: "Admissions list",
    expected: [200],
  });
  await api("/school/backups/exports?page=1&limit=10", {
    token: adminToken,
    name: "Backup exports",
    expected: [200],
  });
  await api("/school/offline-sync/records?page=1&limit=10", {
    token: adminToken,
    name: "Offline sync records",
    expected: [200],
  });
}

async function runStaffWorkflow(staffToken) {
  await api("/staff/dashboard", { token: staffToken, name: "Staff dashboard", expected: [200] });
  await api("/staff/profile", { token: staffToken, name: "Staff profile", expected: [200] });
  await api("/staff/reports", { token: staffToken, name: "Staff reports", expected: [200] });
  await api("/staff/communication", { token: staffToken, name: "Staff communication", expected: [200] });
  await api("/staff/communication/messages", {
    method: "POST",
    token: staffToken,
    name: "Staff send message",
    expected: [201],
    body: { to: "Parent - Demo Parent", message: "Detailed workflow staff message" },
  });
  await api("/staff/communication/meeting-notes", {
    method: "POST",
    token: staffToken,
    name: "Staff save meeting note",
    expected: [201],
    body: { title: "Detailed workflow note", note: "PTM meeting note from detailed audit." },
  });
  await api("/staff/settings", { token: staffToken, name: "Staff settings", expected: [200] });
  await api("/staff/settings", {
    method: "PUT",
    token: staffToken,
    name: "Staff update settings",
    expected: [200],
    body: { notificationsEnabled: true, privacyMode: false, compactView: true },
  });
  await api("/staff/ai/assist", {
    method: "POST",
    token: staffToken,
    name: "Staff AI assist",
    expected: [200, 502, 503],
    body: { prompt: "Create 2 concise homework ideas for grade 10 science.", contextType: "homework" },
  });
}

async function runParentWorkflow(parentToken) {
  const children = await api("/parent/children", { token: parentToken, name: "Parent children", expected: [200] });
  const childId = children?.data?.children?.[0]?.id;
  if (!childId) {
    throw createError("No linked child found for parent role");
  }
  const q = `?childId=${childId}`;

  await api(`/parent/home${q}`, { token: parentToken, name: "Parent home", expected: [200] });
  await api(`/parent/announcements${q}`, { token: parentToken, name: "Parent announcements", expected: [200] });
  await api(`/parent/notifications${q}`, { token: parentToken, name: "Parent notifications", expected: [200] });
  await api(`/parent/notifications/mark-all-read${q}`, {
    method: "POST",
    token: parentToken,
    name: "Parent mark notifications read",
    expected: [200],
  });
  await api(`/parent/attendance${q}`, { token: parentToken, name: "Parent attendance", expected: [200] });
  await api(`/parent/timetable${q}`, { token: parentToken, name: "Parent timetable", expected: [200] });
  await api(`/parent/exam-timetable${q}`, { token: parentToken, name: "Parent exam timetable", expected: [200] });
  await api(`/parent/event-timetable${q}`, { token: parentToken, name: "Parent event timetable", expected: [200] });
  await api(`/parent/progress-reports${q}`, { token: parentToken, name: "Parent progress reports", expected: [200] });
  await api(`/parent/live-classes${q}`, { token: parentToken, name: "Parent live classes", expected: [200] });
  await api(`/parent/profile-hub${q}`, { token: parentToken, name: "Parent profile hub", expected: [200] });
  await api(`/parent/library${q}`, { token: parentToken, name: "Parent library", expected: [200] });
  await api(`/parent/documents${q}`, { token: parentToken, name: "Parent documents", expected: [200] });
  await api(`/parent/achievements${q}`, { token: parentToken, name: "Parent achievements", expected: [200] });
  await api(`/parent/settings${q}`, { token: parentToken, name: "Parent settings", expected: [200] });
  await api(`/parent/settings${q}`, {
    method: "PUT",
    token: parentToken,
    name: "Parent update settings",
    expected: [200],
    body: { pushNotificationsEnabled: true, faceIdEnabled: false, darkModeOption: "system" },
  });
  await api(`/parent/fees${q}`, { token: parentToken, name: "Parent fees", expected: [200] });
  await api(`/parent/finance-hub${q}`, { token: parentToken, name: "Parent finance hub", expected: [200] });
  const fees = await api(`/parent/fees${q}`, { token: parentToken, name: "Parent fees recheck", expected: [200] });
  const invoiceId = fees?.data?.invoices?.[0]?.id || fees?.data?.overdueInvoices?.[0]?.id;
  if (invoiceId) {
    await api(`/parent/invoices/${invoiceId}${q}`, {
      token: parentToken,
      name: "Parent invoice detail",
      expected: [200],
    });
    await api(`/parent/invoices/${invoiceId}/pay-balance${q}`, {
      method: "POST",
      token: parentToken,
      name: "Parent pay invoice balance",
      expected: [200, 201],
      body: { amount: 1, method: "ONLINE", notes: "Detailed audit payment" },
    });
  }
  await api(`/parent/fees/quick-pay-all${q}`, {
    method: "POST",
    token: parentToken,
    name: "Parent quick pay all",
    expected: [200, 201],
    body: { method: "ONLINE" },
  });
  await api(`/parent/events${q}`, { token: parentToken, name: "Parent events hub", expected: [200] });
  await api(`/parent/meetings${q}`, { token: parentToken, name: "Parent meetings", expected: [200] });
  await api(`/parent/messages${q}`, { token: parentToken, name: "Parent messages", expected: [200] });
  await api(`/parent/messages${q}`, {
    method: "POST",
    token: parentToken,
    name: "Parent create message",
    expected: [201],
    body: { teacher: "Riya Teacher", subject: "Homework", message: "Need clarification on assignment." },
  });
  await api(`/parent/leave-requests${q}`, {
    method: "POST",
    token: parentToken,
    name: "Parent create leave request",
    expected: [201],
    body: {
      fromDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
      toDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
      reason: "Detailed audit leave request",
    },
  });
  await api(`/parent/meetings/request${q}`, {
    method: "POST",
    token: parentToken,
    name: "Parent create meeting request",
    expected: [201],
    body: {
      teacher: "Riya Teacher",
      preferredDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      timeSlot: "10:00 AM - 10:30 AM",
      purpose: "Discuss academic progress",
    },
  });
}

async function run() {
  let serverProcess = null;
  let startedByScript = false;

  try {
    try {
      await waitForServer(2_000);
      console.log("Using existing running server");
    } catch {
      startedByScript = true;
      serverProcess = spawn("node", ["src/server.js"], {
        cwd: ROOT_DIR,
        stdio: "inherit",
      });
      await waitForServer();
      console.log("Started local server");
    }

    const adminLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "admin@school.edu", password: "Admin123!" },
      expected: [200],
      name: "Login admin",
      required: true,
    });
    const staffLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "teacher@school.edu", password: "Admin123!" },
      expected: [200],
      name: "Login staff",
      required: true,
    });
    const parentLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "parent@school.edu", password: "Parent123!" },
      expected: [200],
      name: "Login parent",
      required: true,
    });

    const adminToken = adminLogin?.data?.accessToken;
    const staffToken = staffLogin?.data?.accessToken;
    const parentToken = parentLogin?.data?.accessToken;

    if (!adminToken || !staffToken || !parentToken) {
      throw createError("Missing one or more role access tokens");
    }

    console.log("\n=== ADMIN WORKFLOW ===");
    await runAdminWorkflow(adminToken);
    console.log("\n=== STAFF WORKFLOW ===");
    await runStaffWorkflow(staffToken);
    console.log("\n=== PARENT WORKFLOW ===");
    await runParentWorkflow(parentToken);

    if (failures.length > 0) {
      console.error(`\nDETAILED E2E AUDIT COMPLETED WITH ${failures.length} FAILURE(S):`);
      for (const fail of failures) {
        console.error(`- ${fail.name} [${fail.status}]`);
      }
      process.exitCode = 1;
      return;
    }
    console.log("\nDETAILED E2E AUDIT PASSED: admin + staff + parent workflows are healthy.");
  } finally {
    if (startedByScript && serverProcess && !serverProcess.killed) {
      serverProcess.kill("SIGTERM");
    }
  }
}

run().catch((error) => {
  console.error("\nDETAILED E2E AUDIT FAILED");
  console.error(error.message);
  if (error.details) {
    console.error(JSON.stringify(error.details, null, 2));
  }
  process.exit(1);
});
