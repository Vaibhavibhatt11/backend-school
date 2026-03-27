const { spawn } = require("child_process");
const path = require("path");
const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();
const BASE_URL = process.env.SMOKE_BASE_URL || "http://localhost:5000/api/v1";
const ROOT_DIR = path.resolve(__dirname, "..");

const STUDENT_EMAIL = "student@school.edu";
const STUDENT_PASSWORD = "Student123!";
const PARENT_EMAIL = "parent@school.edu";
const PARENT_PASSWORD = "Parent123!";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function fail(message, details) {
  const err = new Error(message);
  err.details = details;
  throw err;
}

async function waitForServer(timeoutMs = 25000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const res = await fetch(`${BASE_URL}/health`);
      if (res.ok) return;
    } catch {}
    await sleep(500);
  }
  fail("Server did not become healthy");
}

async function req(pathname, { method = "GET", token, body, expected = [200], label } = {}) {
  const headers = { Accept: "application/json" };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body != null) headers["Content-Type"] = "application/json";

  const res = await fetch(`${BASE_URL}${pathname}`, {
    method,
    headers,
    body: body != null ? JSON.stringify(body) : undefined,
  });

  const raw = await res.text();
  let data = null;
  try {
    data = raw ? JSON.parse(raw) : null;
  } catch {
    data = raw;
  }

  if (!expected.includes(res.status)) {
    fail(`FAIL ${label || `${method} ${pathname}`}`, { status: res.status, body: data });
  }
  console.log(`PASS ${label || `${method} ${pathname}`} -> ${res.status}`);
  return { status: res.status, data };
}

async function ensureParentFixture() {
  const student = await prisma.student.findFirst({
    where: { user: { email: STUDENT_EMAIL } },
    include: { user: true },
  });
  if (!student) fail("Student fixture not found. Run prisma seed first.");

  const passwordHash = await bcrypt.hash(PARENT_PASSWORD, 10);
  await prisma.user.upsert({
    where: { email: PARENT_EMAIL },
    update: { passwordHash, role: "PARENT", schoolId: student.schoolId, isActive: true, fullName: "Parent Smoke User" },
    create: {
      fullName: "Parent Smoke User",
      email: PARENT_EMAIL,
      passwordHash,
      role: "PARENT",
      schoolId: student.schoolId,
      isActive: true,
    },
  });

  let parent = await prisma.parent.findFirst({
    where: { schoolId: student.schoolId, email: PARENT_EMAIL },
  });
  if (!parent) {
    parent = await prisma.parent.create({
      data: {
        schoolId: student.schoolId,
        fullName: "Parent Smoke User",
        email: PARENT_EMAIL,
        phone: "9999999999",
        isActive: true,
      },
    });
  } else {
    parent = await prisma.parent.update({
      where: { id: parent.id },
      data: { fullName: "Parent Smoke User", isActive: true },
    });
  }

  await prisma.studentParent.upsert({
    where: { studentId_parentId: { studentId: student.id, parentId: parent.id } },
    update: { relationType: "GUARDIAN", isPrimary: true },
    create: {
      studentId: student.id,
      parentId: parent.id,
      relationType: "GUARDIAN",
      isPrimary: true,
    },
  });

  return { studentId: student.id };
}

async function login(email, password, label) {
  const out = await req("/auth/login", {
    method: "POST",
    body: { email, password },
    expected: [200],
    label,
  });
  return out.data.data.accessToken;
}

async function run() {
  let server = null;
  let startedByScript = false;
  try {
    const fixture = await ensureParentFixture();

    try {
      await waitForServer(2000);
      console.log("Using existing server");
    } catch {
      server = spawn("node", ["src/server.js"], { cwd: ROOT_DIR, stdio: "ignore" });
      startedByScript = true;
      await waitForServer(25000);
      console.log("Started local server");
    }

    const studentToken = await login(STUDENT_EMAIL, STUDENT_PASSWORD, "login student");
    const parentToken = await login(PARENT_EMAIL, PARENT_PASSWORD, "login parent");

    // Unified app module
    await req("/app/children", { token: studentToken, expected: [200] });
    await req("/app/dashboard", { token: studentToken, expected: [200] });
    await req(`/app/dashboard?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req("/app/attendance", { token: studentToken, expected: [200] });
    await req("/app/fees", { token: studentToken, expected: [200] });
    await req("/app/announcements", { token: studentToken, expected: [200] });

    // Student module
    await req("/student/dashboard", { token: studentToken, expected: [200] });
    await req("/student/profile", { token: studentToken, expected: [200] });
    await req("/student/timetable", { token: studentToken, expected: [200] });
    await req("/student/attendance", { token: studentToken, expected: [200] });
    await req("/student/homework", { token: studentToken, expected: [200] });
    await req("/student/study-materials", { token: studentToken, expected: [200] });
    await req("/student/exams", { token: studentToken, expected: [200] });
    await req("/student/exam-timetable", { token: studentToken, expected: [200] });
    await req("/student/fees", { token: studentToken, expected: [200] });
    await req("/student/fees/receipts", { token: studentToken, expected: [200] });
    await req("/student/announcements", { token: studentToken, expected: [200] });
    await req("/student/events", { token: studentToken, expected: [200] });
    await req("/student/transport", { token: studentToken, expected: [200] });
    await req("/student/library", { token: studentToken, expected: [200] });
    await req("/student/library/books", { token: studentToken, expected: [200] });
    await req("/student/achievements", { token: studentToken, expected: [200] });
    await req("/student/notifications", { token: studentToken, expected: [200] });
    await req("/student/circulars", { token: studentToken, expected: [200] });
    await req("/student/health", { token: studentToken, expected: [200] });
    await req("/student/settings", { token: studentToken, expected: [200] });
    await req("/student/leave-requests", { token: studentToken, expected: [200] });
    await req("/student/subject-teachers", { token: studentToken, expected: [200] });
    await req("/student/report-cards", { token: studentToken, expected: [200] });
    await req("/student/documents", { token: studentToken, expected: [200] });
    await req("/student/ai/career", { token: studentToken, expected: [200] });
    await req("/student/ai/ask", {
      method: "POST",
      token: studentToken,
      body: { question: "What should I study today?" },
      expected: [200],
    });

    // Detail/mutation endpoints (route + validation + auth smoke)
    await req("/student/homework/invalid/result", { token: studentToken, expected: [404] });
    await req("/student/exams/invalid/result", { token: studentToken, expected: [400] });
    await req("/student/payments/invalid/receipt", { token: studentToken, expected: [400] });
    await req("/student/homework/invalid/submit", {
      method: "POST",
      token: studentToken,
      body: { status: "SUBMITTED" },
      expected: [400],
    });
    await req("/student/events/invalid/register", {
      method: "POST",
      token: studentToken,
      expected: [400],
    });
    await req("/student/profile", {
      method: "PUT",
      token: studentToken,
      body: { guardianPhone: "9999999999" },
      expected: [200],
    });
    await req("/student/settings", {
      method: "PUT",
      token: studentToken,
      body: { language: "en" },
      expected: [200],
    });
    await req("/student/leave-requests", {
      method: "POST",
      token: studentToken,
      body: {
        fromDate: new Date().toISOString(),
        toDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        reason: "Smoke request",
      },
      expected: [201],
    });
    await req("/student/meetings/request", {
      method: "POST",
      token: studentToken,
      body: { purpose: "Discuss progress" },
      expected: [201],
    });

    // Parent module
    await req("/parent/children", { token: parentToken, expected: [200] });
    await req(`/parent/home?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/announcements?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/notifications?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/attendance?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/fees?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/timetable?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/progress-reports?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/live-classes?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/profile-hub?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/library?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/documents?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/settings?childId=${fixture.studentId}`, { token: parentToken, expected: [200] });
    await req(`/parent/settings?childId=${fixture.studentId}`, {
      method: "PUT",
      token: parentToken,
      body: { preferences: { language: "en" } },
      expected: [200],
    });
    await req("/parent/ai/ask", {
      method: "POST",
      token: parentToken,
      body: { question: "How can I support my child?" },
      expected: [200],
    });
    await req("/parent/ai/career", { token: parentToken, expected: [200] });
    await req("/parent/invoices/invalid", { token: parentToken, expected: [400] });

    console.log("\nALL STUDENT + PARENT + APP SMOKE TESTS PASSED");
  } catch (e) {
    console.error("\nSMOKE FAILED");
    console.error(e.message);
    if (e.details) console.error(JSON.stringify(e.details, null, 2));
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
    if (startedByScript && server) {
      server.kill("SIGTERM");
    }
  }
}

run();

