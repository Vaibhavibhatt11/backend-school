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

    const staffLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "teacher@school.edu", password: "Admin123!" },
      expected: [200],
      name: "POST /auth/login staff",
    });
    const staffToken = staffLogin?.data?.accessToken;
    if (!staffToken) {
      throw createError("Staff token missing from login response", staffLogin);
    }

    await api("/staff/dashboard", {
      token: staffToken,
      expected: [200],
      name: "GET /staff/dashboard",
    });
    await api("/staff/profile", {
      token: staffToken,
      expected: [200],
      name: "GET /staff/profile",
    });
    await api("/staff/reports", {
      token: staffToken,
      expected: [200],
      name: "GET /staff/reports",
    });
    await api("/staff/communication", {
      token: staffToken,
      expected: [200],
      name: "GET /staff/communication",
    });
    await api("/staff/communication/messages", {
      method: "POST",
      token: staffToken,
      body: { to: "Parent - Demo Parent", message: "Smoke test message" },
      expected: [201],
      name: "POST /staff/communication/messages",
    });
    await api("/staff/communication/meeting-notes", {
      method: "POST",
      token: staffToken,
      body: { title: "Smoke PTM note", note: "Meeting note from smoke test." },
      expected: [201],
      name: "POST /staff/communication/meeting-notes",
    });
    await api("/staff/settings", {
      token: staffToken,
      expected: [200],
      name: "GET /staff/settings",
    });
    await api("/staff/settings", {
      method: "PUT",
      token: staffToken,
      body: { notificationsEnabled: true, privacyMode: false, compactView: true },
      expected: [200],
      name: "PUT /staff/settings",
    });
    await api("/staff/ai/assist", {
      method: "POST",
      token: staffToken,
      body: { prompt: "Give 2 short tips for class engagement.", contextType: "general" },
      expected: [200, 502, 503],
      name: "POST /staff/ai/assist",
    });

    console.log("\nALL CHECKS PASSED: staff smoke run completed.");
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
