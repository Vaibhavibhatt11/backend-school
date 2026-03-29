/**
 * Regression: GET /dashboard/school-admin, GET /school/approvals/pending-summary,
 * GET /school/fees/summary (Bearer, school admin).
 *
 * JSON schema for fees summary: docs/schemas/get-school-fees-summary.response.schema.json
 *
 * Usage:
 *   REGRESSION_BASE_URL=https://host/api/v1 node scripts/regression-admin-dashboard-approvals-fees.js
 *   REGRESSION_EMAIL=admin@school.edu REGRESSION_PASSWORD='***' ...
 *
 * Offline (no HTTP server; uses Prisma + handlers directly):
 *   REGRESSION_OFFLINE=1 node scripts/regression-admin-dashboard-approvals-fees.js
 */
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const assert = require("node:assert/strict");

const BASE_URL = (
  process.env.REGRESSION_BASE_URL ||
  process.env.SMOKE_BASE_URL ||
  "http://localhost:5000/api/v1"
).replace(/\/+$/, "");

const OFFLINE = process.env.REGRESSION_OFFLINE === "1" || process.env.REGRESSION_OFFLINE === "true";

async function api(pathname, { method = "GET", token, body } = {}) {
  const headers = { Accept: "application/json" };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body !== undefined) headers["Content-Type"] = "application/json";
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
  return { response, parsed };
}

function assertFeesSummaryPayload(parsed) {
  assert.equal(parsed.success, true);
  assert.ok(parsed.data);
  assert.match(parsed.data.schemaVersion, /^[0-9]+\.[0-9]+\.[0-9]+$/);
  const { totals, categories } = parsed.data;
  assert.ok(totals);
  for (const k of ["amountDue", "amountPaid", "outstanding", "collections"]) {
    assert.equal(typeof totals[k], "number");
  }
  assert.equal(typeof totals.feeStructures, "number");
  assert.ok(Array.isArray(categories));
  for (const row of categories) {
    assert.ok("feeStructureId" in row);
    assert.equal(typeof row.name, "string");
    for (const n of ["amountDue", "amountPaid", "outstanding"]) {
      assert.equal(typeof row[n], "number");
    }
    assert.equal(typeof row.invoiceCount, "number");
  }
}

async function runHttpMode() {
  const email = process.env.REGRESSION_EMAIL || "admin@school.edu";
  const password = process.env.REGRESSION_PASSWORD || "Admin123!";

  const login = await api("/auth/login", {
    method: "POST",
    body: { email, password },
  });
  assert.equal(
    login.response.status,
    200,
    `login failed: ${login.response.status} ${JSON.stringify(login.parsed)}`
  );
  const token = login.parsed?.data?.accessToken;
  assert.ok(token, "missing accessToken");

  const dash = await api("/dashboard/school-admin", { token });
  assert.equal(dash.response.status, 200, `dashboard: ${JSON.stringify(dash.parsed)}`);
  assert.equal(dash.parsed.success, true);

  const appr = await api("/school/approvals/pending-summary", { token });
  assert.equal(appr.response.status, 200, `approvals: ${JSON.stringify(appr.parsed)}`);
  assert.equal(appr.parsed.success, true);
  assert.ok(appr.parsed.data?.buckets);

  const fees = await api("/school/fees/summary", { token });
  assert.equal(fees.response.status, 200, `fees summary: ${JSON.stringify(fees.parsed)}`);
  assertFeesSummaryPayload(fees.parsed);
}

async function runOfflineMode() {
  const prisma = require("../src/lib/prisma");
  const { schoolAdminDashboard } = require("../src/modules/dashboard/dashboard.handlers");
  const { getPendingApprovalsSummary } = require("../src/modules/school/school.misc.handlers");
  const { getFeesSummary } = require("../src/modules/school/school.finance.handlers");

  const school = await prisma.school.findFirst();
  assert.ok(school, "no school in database");
  const user = await prisma.user.findFirst({
    where: { schoolId: school.id, role: "SCHOOLADMIN", isActive: true },
  });
  assert.ok(user, "no SCHOOLADMIN user for school");

  const req = { query: {}, user: { role: "SCHOOLADMIN", schoolId: school.id, sub: user.id } };

  await new Promise((resolve, reject) => {
    const res = {
      status(code) {
        this._code = code;
        return this;
      },
      json(body) {
        try {
          assert.equal(this._code, 200);
          assert.equal(body.success, true);
          resolve();
        } catch (e) {
          reject(e);
        }
      },
    };
    schoolAdminDashboard(req, res, reject);
  });

  await new Promise((resolve, reject) => {
    const res = {
      status(code) {
        this._code = code;
        return this;
      },
      json(body) {
        try {
          assert.equal(this._code, 200);
          assert.equal(body.success, true);
          assert.ok(body.data?.buckets);
          resolve();
        } catch (e) {
          reject(e);
        }
      },
    };
    getPendingApprovalsSummary(req, res, reject);
  });

  await new Promise((resolve, reject) => {
    const res = {
      status(code) {
        this._code = code;
        return this;
      },
      json(body) {
        try {
          assert.equal(this._code, 200);
          assertFeesSummaryPayload(body);
          resolve();
        } catch (e) {
          reject(e);
        }
      },
    };
    getFeesSummary(req, res, reject);
  });

  await prisma.$disconnect();
}

async function main() {
  if (OFFLINE) {
    await runOfflineMode();
    console.log("PASS  regression (offline) dashboard + approvals + fees summary");
    return;
  }

  await runHttpMode();
  console.log("PASS  regression (HTTP) dashboard + approvals + fees summary");
}

main().catch((err) => {
  console.error("FAIL ", err.message || err);
  process.exit(1);
});
