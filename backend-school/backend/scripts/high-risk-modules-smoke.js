const { spawn } = require("child_process");
const path = require("path");

const BASE_URL = process.env.SMOKE_BASE_URL || "http://localhost:5000/api/v1";
const ROOT_DIR = path.resolve(__dirname, "..");
const FORCE_START_LOCAL = process.env.FORCE_START_LOCAL === "1";
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

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
    } catch {}
    await sleep(500);
  }
  throw createError("Server did not become ready in time");
}

async function api(pathname, options = {}) {
  const { method = "GET", token, body, expected = [200], name = `${method} ${pathname}` } = options;
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
    throw createError(`Failed: ${name}`, { status: response.status, body: parsed });
  }
  console.log(`PASS  ${name} -> ${response.status}`);
  return parsed;
}

function ensure(condition, message, details) {
  if (!condition) throw createError(message, details);
}

async function run() {
  let serverProcess = null;
  let startedByScript = false;
  try {
    try {
      if (FORCE_START_LOCAL) {
        throw new Error("force local start");
      }
      await waitForServer(2_000);
      console.log("Using existing running server");
    } catch {
      startedByScript = true;
      serverProcess = spawn("node", ["src/server.js"], { cwd: ROOT_DIR, stdio: "inherit" });
      await waitForServer();
      console.log("Started local server");
    }

    const adminLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "admin@school.edu", password: "Admin123!" },
      expected: [200],
      name: "POST /auth/login admin",
    });
    const staffLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "teacher@school.edu", password: "Admin123!" },
      expected: [200],
      name: "POST /auth/login staff",
    });
    const adminToken = adminLogin.data.accessToken;
    const staffToken = staffLogin.data.accessToken;

    const createdEvent = await api("/school/events", {
      method: "POST",
      token: adminToken,
      expected: [201],
      name: "POST /school/events",
      body: {
        title: `Smoke Event ${Date.now()}`,
        description: "Smoke event for workflow validation",
        eventType: "ANNUAL_FUNCTION",
        startDate: new Date().toISOString(),
        endDate: new Date().toISOString(),
        location: "Main Campus",
        isPublished: true,
      },
    });
    const eventId = createdEvent?.data?.id;
    ensure(eventId, "Event creation did not return event id", createdEvent);
    await api(`/school/events/${eventId}`, { token: adminToken, expected: [200], name: "GET /school/events/:id" });

    const createdExam = await api("/school/exams", {
      method: "POST",
      token: adminToken,
      expected: [201],
      name: "POST /school/exams",
      body: {
        name: `Smoke Exam ${Date.now()}`,
        examDate: new Date().toISOString(),
        maxMarks: 100,
        status: "SCHEDULED",
        isPublished: false,
      },
    });
    const examId = createdExam?.data?.exam?.id;
    ensure(examId, "Exam creation did not return exam id", createdExam);
    await api(`/school/exams/${examId}/publish`, {
      method: "POST",
      token: adminToken,
      expected: [200],
      name: "POST /school/exams/:id/publish",
    });

    await api("/school/settings", {
      method: "PATCH",
      token: adminToken,
      expected: [200],
      name: "PATCH /school/settings timetableManagement",
      body: {
        timetableManagement: {
          roomAllocations: [{ id: `room-${Date.now()}`, roomName: "A-101", classLabel: "Class 8 A" }],
          substituteTeachers: [
            {
              id: `sub-${Date.now()}`,
              classLabel: "Class 8 A",
              originalTeacherName: "Rahul Verma",
              substituteTeacherName: "Anita Singh",
            },
          ],
        },
      },
    });
    const settingsTt = await api("/school/settings", {
      token: adminToken,
      expected: [200],
      name: "GET /school/settings (timetable verify)",
    });
    const tt = settingsTt?.data?.timetableManagement || {};
    ensure(Array.isArray(tt.roomAllocations) && tt.roomAllocations.length > 0, "Room allocation persistence failed", settingsTt);
    ensure(Array.isArray(tt.substituteTeachers) && tt.substituteTeachers.length > 0, "Substitute teacher persistence failed", settingsTt);

    await api("/school/settings", {
      method: "PATCH",
      token: adminToken,
      expected: [200],
      name: "PATCH /school/settings libraryManagement",
      body: {
        libraryManagement: {
          categories: [{ id: `cat-${Date.now()}`, category: "Reference" }],
          cards: [{ id: `card-${Date.now()}`, studentName: "Smoke Student", cardNo: "LIB-1001" }],
        },
      },
    });
    const settingsLib = await api("/school/settings", {
      token: adminToken,
      expected: [200],
      name: "GET /school/settings (library verify)",
    });
    const lib = settingsLib?.data?.libraryManagement || {};
    ensure(Array.isArray(lib.categories) && lib.categories.length > 0, "Library category persistence failed", settingsLib);

    await api("/staff/profile", {
      method: "PUT",
      token: staffToken,
      expected: [200],
      name: "PUT /staff/profile",
      body: { department: "Science", contact: "+91-9999999999" },
    });

    await api(`/school/exams/${examId}`, {
      method: "DELETE",
      token: adminToken,
      expected: [200],
      name: "DELETE /school/exams/:id",
    });
    await api(`/school/events/${eventId}`, {
      method: "DELETE",
      token: adminToken,
      expected: [200],
      name: "DELETE /school/events/:id",
    });

    console.log("\nALL CHECKS PASSED: high-risk module smoke run completed.");
  } finally {
    if (startedByScript && serverProcess && !serverProcess.killed) {
      serverProcess.kill("SIGTERM");
    }
  }
}

run().catch((error) => {
  console.error("\nHIGH-RISK SMOKE RUN FAILED");
  console.error(error.message);
  if (error.details) console.error(JSON.stringify(error.details, null, 2));
  process.exit(1);
});
