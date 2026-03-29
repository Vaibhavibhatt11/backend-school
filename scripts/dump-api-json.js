const fs = require("fs");
const path = require("path");

function parseRoutes(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  const regex = /router\.(get|post|put|patch|delete)\(\s*["'`]([^"'`]+)["'`]/g;
  const routes = [];
  let m;
  while ((m = regex.exec(content))) {
    routes.push({ method: m[1].toUpperCase(), path: m[2] });
  }
  return routes;
}

const PREFIX = "/api/v1";
const root = path.join(__dirname, "..", "src");

const modules = [];

modules.push({
  module: "Health",
  mount: "",
  roles: [],
  endpoints: [
    { method: "GET", path: "/health", fullPath: `${PREFIX}/health` },
    { method: "GET", path: "/ready", fullPath: `${PREFIX}/ready` },
  ],
});

const routeGroups = [
  ["Auth", "/auth", "modules/auth/auth.routes.js", []],
  ["Dashboard", "/dashboard", "modules/dashboard/dashboard.routes.js", ["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT", "HR", "TEACHER", "PARENT"]],
  ["Superadmin", "/superadmin", "modules/superadmin/superadmin.routes.js", ["SUPERADMIN"]],
  ["School Students", "/school/students", "modules/students/students.routes.js", ["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"]],
  ["School", "/school", "modules/school/school.routes.js", ["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"]],
  ["HR", "/hr", "modules/hr/hr.routes.js", ["SUPERADMIN", "SCHOOLADMIN", "HR"]],
  ["Accountant", "/accountant", "modules/accountant/accountant.routes.js", ["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT"]],
  ["Student", "/student", "modules/student/student.routes.js", ["STUDENT"]],
];

for (const [name, mount, file, roles] of routeGroups) {
  const parsed = parseRoutes(path.join(root, file));
  const endpoints = parsed.map((r) => {
    const rel = r.path === "/" ? mount : mount + r.path;
    return { method: r.method, path: rel, fullPath: PREFIX + rel };
  });
  modules.push({ module: name, mount, roles, endpoints });
}

const flat = [];
for (const mod of modules) {
  for (const e of mod.endpoints) {
    flat.push({ module: mod.module, method: e.method, path: e.path, fullPath: e.fullPath });
  }
}

const out = {
  apiVersion: "v1",
  basePath: PREFIX,
  exampleBaseUrl: `https://backend-school-app.onrender.com${PREFIX}`,
  generatedAt: new Date().toISOString(),
  modules,
  apis: flat,
};

process.stdout.write(JSON.stringify(out, null, 2));
