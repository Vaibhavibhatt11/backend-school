/**
 * Generates docs/FRONTEND_TEAM_API.json from *.routes.js files.
 * Run: node scripts/generate-frontend-api-json.js
 */
const fs = require("fs");
const path = require("path");

const PREFIX = "/api/v1";
const BASE = "https://backend-school-app.onrender.com";

function add(out, mod, method, p, auth, role, desc) {
  const full = PREFIX + p;
  out.push({
    module: mod,
    method,
    path: full,
    authRequired: auth,
    roles: role || null,
    description: desc || "",
  });
}

const e = [];

add(e, "health", "GET", "/health", false, null, "Liveness");
add(e, "health", "GET", "/ready", false, null, "Readiness (DB/Redis checks)");

add(e, "auth", "POST", "/auth/login", false, null, "Login — returns access + refresh tokens");
add(e, "auth", "POST", "/auth/refresh", false, null, "Refresh access token");
add(e, "auth", "POST", "/auth/logout", false, null, "Logout");
add(e, "auth", "GET", "/auth/me", true, null, "Current user profile");
add(e, "auth", "POST", "/auth/forgot-password", false, null, "Request reset");
add(e, "auth", "POST", "/auth/verify-otp", false, null, "Verify OTP");
add(e, "auth", "POST", "/auth/reset-password", false, null, "Reset password");
add(e, "auth", "POST", "/auth/change-password", true, null, "Change password (authenticated)");

add(
  e,
  "dashboard",
  "GET",
  "/dashboard/school-admin",
  true,
  ["SCHOOLADMIN", "SUPERADMIN", "HR", "ACCOUNTANT"],
  "School admin dashboard stats"
);
add(e, "dashboard", "GET", "/dashboard/hr", true, ["HR", "SCHOOLADMIN", "SUPERADMIN"], "HR dashboard");
add(
  e,
  "dashboard",
  "GET",
  "/dashboard/accountant",
  true,
  ["ACCOUNTANT", "SCHOOLADMIN", "SUPERADMIN"],
  "Accountant dashboard"
);

const sa = [
  ["GET", "/superadmin/dashboard/overview"],
  ["GET", "/superadmin/schools"],
  ["POST", "/superadmin/schools"],
  ["GET", "/superadmin/schools/:id"],
  ["PUT", "/superadmin/schools/:id"],
  ["PATCH", "/superadmin/schools/:id/status"],
  ["DELETE", "/superadmin/schools/:id"],
  ["GET", "/superadmin/subscriptions"],
  ["PATCH", "/superadmin/subscriptions/:schoolId/plan"],
  ["PATCH", "/superadmin/subscriptions/:schoolId/auto-renew"],
  ["GET", "/superadmin/plans"],
  ["PUT", "/superadmin/plans/:planCode"],
  ["GET", "/superadmin/configuration"],
  ["PUT", "/superadmin/configuration"],
  ["GET", "/superadmin/support/tickets"],
  ["GET", "/superadmin/support/tickets/:id"],
  ["POST", "/superadmin/support/tickets/:id/replies"],
  ["PATCH", "/superadmin/support/tickets/:id/status"],
  ["GET", "/superadmin/analytics/overview"],
  ["GET", "/superadmin/accountants"],
  ["POST", "/superadmin/accountants"],
  ["GET", "/superadmin/accountants/:id"],
  ["PUT", "/superadmin/accountants/:id"],
  ["PATCH", "/superadmin/accountants/:id/status"],
  ["DELETE", "/superadmin/accountants/:id"],
  ["GET", "/superadmin/staff"],
  ["POST", "/superadmin/staff"],
  ["GET", "/superadmin/staff/:id"],
  ["PUT", "/superadmin/staff/:id"],
  ["PATCH", "/superadmin/staff/:id/status"],
  ["DELETE", "/superadmin/staff/:id"],
  ["POST", "/superadmin/invitations"],
  ["GET", "/superadmin/invitations"],
  ["POST", "/superadmin/invitations/:id/resend"],
  ["DELETE", "/superadmin/invitations/:id"],
  ["GET", "/superadmin/security/settings"],
  ["PUT", "/superadmin/security/settings"],
  ["GET", "/superadmin/security/sessions"],
  ["DELETE", "/superadmin/security/sessions/:id"],
  ["POST", "/superadmin/security/sessions/revoke-all"],
  ["POST", "/superadmin/security/keys/rotate"],
  ["GET", "/superadmin/security/audit-logs"],
  ["GET", "/superadmin/notifications"],
  ["PATCH", "/superadmin/notifications/:id/read"],
  ["DELETE", "/superadmin/notifications/:id"],
  ["POST", "/superadmin/firebase/upload"],
];
sa.forEach(([m, p]) => add(e, "superadmin", m, p, true, ["SUPERADMIN"], ""));

const st = [
  ["GET", "/school/students"],
  ["GET", "/school/students/export"],
  ["POST", "/school/students"],
  ["POST", "/school/students/import"],
  ["GET", "/school/students/:id"],
  ["PUT", "/school/students/:id"],
  ["DELETE", "/school/students/:id"],
  ["PATCH", "/school/students/:id/status"],
  ["POST", "/school/students/:id/move-class"],
  ["POST", "/school/students/:id/documents"],
  ["DELETE", "/school/students/:id/documents/:docId"],
];
st.forEach(([m, p]) =>
  add(e, "school.students", m, p, true, ["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"], "")
);

const routeRe = /router\.(get|post|put|patch|delete)\(\s*["']([^"']+)["']/gi;

function extractRoutes(fileRel, moduleName, prefix, roles, note) {
  const full = path.join(__dirname, "..", fileRel);
  const src = fs.readFileSync(full, "utf8");
  let m;
  while ((m = routeRe.exec(src))) {
    const method = m[1].toUpperCase();
    const routePath = prefix + m[2];
    add(e, moduleName, method, routePath, true, roles, note || "");
  }
}

extractRoutes("src/modules/school/school.routes.js", "school", "/school", [
  "SUPERADMIN",
  "SCHOOLADMIN",
  "HR",
  "ACCOUNTANT",
]);
extractRoutes("src/modules/hr/hr.routes.js", "hr", "/hr", ["SUPERADMIN", "SCHOOLADMIN", "HR"]);
extractRoutes(
  "src/modules/accountant/accountant.routes.js",
  "accountant",
  "/accountant",
  ["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT"]
);
extractRoutes("src/modules/student/student.routes.js", "student", "/student", ["STUDENT"]);
extractRoutes(
  "src/modules/parent/parent.routes.js",
  "parent",
  "/parent",
  ["PARENT"],
  "Use childId query/body where required for child-scoped data"
);
extractRoutes(
  "src/modules/app/app.routes.js",
  "app",
  "/app",
  ["STUDENT", "PARENT"],
  "Unified portal — effective role from JWT"
);

const doc = {
  meta: {
    title: "School ERP API — Frontend handoff",
    apiVersion: "v1",
    baseUrlProduction: BASE,
    baseUrlLocal: "http://localhost:3000",
    apiPrefix: PREFIX,
    fullBaseUrlProduction: `${BASE}${PREFIX}`,
    swaggerUi: `${BASE}/api/docs`,
    openApiJson: `${BASE}/api/docs.json`,
    generatedAt: new Date().toISOString().slice(0, 10),
    authentication: {
      header: "Authorization: Bearer <access_token>",
      loginPath: `${PREFIX}/auth/login`,
      refreshPath: `${PREFIX}/auth/refresh`,
      note:
        "Most routes require JWT. Role is enforced server-side (see roles on each endpoint). Cookie-based auth may be used where configured.",
    },
    cors: "Server must allow your web origin via CORS_ORIGIN (comma-separated).",
    parentPortal:
      "Parent endpoints require valid childId for child-specific resources when documented in handler — never trust client-only IDs without server checks.",
  },
  endpointCount: e.length,
  endpoints: e,
};

const outDir = path.join(__dirname, "..", "docs");
fs.mkdirSync(outDir, { recursive: true });
const outFile = path.join(outDir, "FRONTEND_TEAM_API.json");
fs.writeFileSync(outFile, JSON.stringify(doc, null, 2), "utf8");
console.log("Wrote", outFile, "—", e.length, "endpoints");
