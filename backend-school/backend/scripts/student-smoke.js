const { spawn } = require("child_process");
const path = require("path");

const BASE_URL = process.env.SMOKE_BASE_URL || "http://localhost:5000/api/v1";
const ROOT_DIR = path.resolve(__dirname, "..");

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
    throw createError(`Failed: ${name}`, {
      status: response.status,
      body: parsed,
    });
  }

  console.log(`PASS  ${name} -> ${response.status}`);
  return parsed;
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

    const studentLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "student@school.edu", password: "Student123!" },
      expected: [200],
      name: "POST /auth/login student",
    });
    const studentToken = studentLogin?.data?.accessToken;
    if (!studentToken) {
      throw createError("Student token missing from login response", studentLogin);
    }

    await api("/student/dashboard", {
      token: studentToken,
      expected: [200],
      name: "GET /student/dashboard",
    });
    await api("/student/profile", {
      token: studentToken,
      expected: [200],
      name: "GET /student/profile",
    });
    await api("/student/timetable", {
      token: studentToken,
      expected: [200],
      name: "GET /student/timetable",
    });
    await api("/student/attendance", {
      token: studentToken,
      expected: [200],
      name: "GET /student/attendance",
    });
    await api("/student/homework", {
      token: studentToken,
      expected: [200],
      name: "GET /student/homework",
    });
    await api("/student/study-materials", {
      token: studentToken,
      expected: [200],
      name: "GET /student/study-materials",
    });
    await api("/student/exams", {
      token: studentToken,
      expected: [200],
      name: "GET /student/exams",
    });
    await api("/student/exam-timetable", {
      token: studentToken,
      expected: [200],
      name: "GET /student/exam-timetable",
    });
    await api("/student/fees", {
      token: studentToken,
      expected: [200],
      name: "GET /student/fees",
    });
    await api("/student/fees/receipts", {
      token: studentToken,
      expected: [200],
      name: "GET /student/fees/receipts",
    });
    await api("/student/announcements", {
      token: studentToken,
      expected: [200],
      name: "GET /student/announcements",
    });
    await api("/student/events", {
      token: studentToken,
      expected: [200],
      name: "GET /student/events",
    });
    await api("/student/library", {
      token: studentToken,
      expected: [200],
      name: "GET /student/library",
    });
    await api("/student/library/books", {
      token: studentToken,
      expected: [200],
      name: "GET /student/library/books",
    });
    await api("/student/achievements", {
      token: studentToken,
      expected: [200],
      name: "GET /student/achievements",
    });
    await api("/student/notifications", {
      token: studentToken,
      expected: [200],
      name: "GET /student/notifications",
    });
    await api("/student/circulars", {
      token: studentToken,
      expected: [200],
      name: "GET /student/circulars",
    });
    await api("/student/health", {
      token: studentToken,
      expected: [200],
      name: "GET /student/health",
    });
    await api("/student/settings", {
      token: studentToken,
      expected: [200],
      name: "GET /student/settings",
    });
    await api("/student/settings", {
      method: "PUT",
      token: studentToken,
      body: { notificationsEnabled: true, privacyMode: false },
      expected: [200],
      name: "PUT /student/settings",
    });
    await api("/student/leave-requests", {
      token: studentToken,
      expected: [200],
      name: "GET /student/leave-requests",
    });
    await api("/student/subject-teachers", {
      token: studentToken,
      expected: [200],
      name: "GET /student/subject-teachers",
    });
    await api("/student/report-cards", {
      token: studentToken,
      expected: [200],
      name: "GET /student/report-cards",
    });
    await api("/student/documents", {
      token: studentToken,
      expected: [200],
      name: "GET /student/documents",
    });

    await api("/student/meetings/request", {
      method: "POST",
      token: studentToken,
      body: {
        preferredDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        purpose: "Need clarification on science assignment",
      },
      expected: [200, 201],
      name: "POST /student/meetings/request",
    });
    await api("/student/leave-requests", {
      method: "POST",
      token: studentToken,
      body: {
        fromDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
        toDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
        reason: "Smoke test leave request",
      },
      expected: [200, 201],
      name: "POST /student/leave-requests",
    });

    console.log("\nALL CHECKS PASSED: student smoke run completed.");
  } finally {
    if (startedByScript && serverProcess && !serverProcess.killed) {
      serverProcess.kill("SIGTERM");
    }
  }
}

run().catch((error) => {
  console.error("\nSMOKE RUN FAILED");
  console.error(error.message);
  if (error.details) {
    console.error(JSON.stringify(error.details, null, 2));
  }
  process.exit(1);
});
