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

    const adminLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "admin@school.edu", password: "Admin123!" },
      expected: [200],
      name: "POST /auth/login admin",
    });
    const parentLogin = await api("/auth/login", {
      method: "POST",
      body: { email: "parent@school.edu", password: "Parent123!" },
      expected: [200],
      name: "POST /auth/login parent",
    });

    const adminToken = adminLogin.data.accessToken;
    const parentToken = parentLogin.data.accessToken;

    await api("/dashboard/school-admin", {
      token: adminToken,
      expected: [200],
      name: "GET /dashboard/school-admin",
    });
    await api("/dashboard/accountant", {
      token: adminToken,
      expected: [200],
      name: "GET /dashboard/accountant",
    });

    const childrenRes = await api("/parent/children", {
      token: parentToken,
      expected: [200],
      name: "GET /parent/children",
    });
    const childId = childrenRes.data.children?.[0]?.id;
    if (!childId) {
      throw createError("Parent account has no linked child");
    }

    await api(`/parent/home?childId=${childId}`, {
      token: parentToken,
      expected: [200],
      name: "GET /parent/home",
    });

    const feesRes = await api(`/parent/fees?childId=${childId}`, {
      token: parentToken,
      expected: [200],
      name: "GET /parent/fees",
    });

    const invoiceId = feesRes.data.invoices?.[0]?.id || feesRes.data.overdueInvoices?.[0]?.id;
    if (invoiceId) {
      await api(`/parent/invoices/${invoiceId}`, {
        token: parentToken,
        expected: [200],
        name: "GET /parent/invoices/:invoiceId",
      });
      await api(`/parent/invoices/${invoiceId}/pay-balance`, {
        method: "POST",
        token: parentToken,
        body: { amount: 1, method: "ONLINE" },
        expected: [200, 201],
        name: "POST /parent/invoices/:invoiceId/pay-balance",
      });
      await api(`/parent/fees/quick-pay-all`, {
        method: "POST",
        token: parentToken,
        body: { method: "ONLINE" },
        expected: [200, 201],
        name: "POST /parent/fees/quick-pay-all",
      });
    } else {
      console.log("INFO  No parent-linked invoice available to verify invoice detail endpoint");
    }

    await api(`/parent/attendance?childId=${childId}`, {
      token: parentToken,
      expected: [200],
      name: "GET /parent/attendance",
    });
    await api(`/parent/timetable?childId=${childId}`, {
      token: parentToken,
      expected: [200],
      name: "GET /parent/timetable",
    });
    await api(`/parent/settings?childId=${childId}`, {
      token: parentToken,
      expected: [200],
      name: "GET /parent/settings",
    });

    console.log("\nALL CHECKS PASSED: parent/admin smoke run completed.");
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
