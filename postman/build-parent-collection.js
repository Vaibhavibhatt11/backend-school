/**
 * Parent app module (PARENT role) — routes from backend/src/modules/parent/parent.routes.js
 * Run: node build-parent-collection.js
 */
const fs = require("fs");
const path = require("path");

const BASE = "{{base_url}}";
const bearerAuth = {
  type: "bearer",
  bearer: [{ key: "token", value: "{{auth_token}}", type: "string" }],
};

function req(name, method, p, body = null, noAuth = false) {
  const pathStr = p.startsWith("/") ? p.slice(1) : p;
  const raw = `${BASE}/${pathStr}`;
  const request = {
    method,
    header: body ? [{ key: "Content-Type", value: "application/json" }] : [],
    url: raw,
  };
  if (!noAuth) request.auth = bearerAuth;
  if (body) {
    request.body = {
      mode: "raw",
      raw: typeof body === "string" ? body : JSON.stringify(body, null, 2),
      options: { raw: { language: "json" } },
    };
  }
  return { name, request };
}

function folder(name, items) {
  return { name, item: items };
}

function eventTest() {
  return [
    {
      listen: "test",
      script: {
        type: "text/javascript",
        exec: [
          "pm.test('Status 2xx', function () { pm.response.to.be.success; });",
          "const j = pm.response.json();",
          "if (j && j.data && j.data.accessToken) { pm.collectionVariables.set('auth_token', j.data.accessToken); pm.collectionVariables.set('accessToken', j.data.accessToken); }",
          "if (j && j.data && j.data.refreshToken) pm.collectionVariables.set('refreshToken', j.data.refreshToken);",
        ],
      },
    },
  ];
}

function eventSaveFirstChild() {
  return [
    {
      listen: "test",
      script: {
        type: "text/javascript",
        exec: [
          "pm.test('Status 2xx', function () { pm.response.to.be.success; });",
          "const j = pm.response.json();",
          "const ch = j && j.data && j.data.children && j.data.children[0];",
          "if (ch && ch.id) pm.collectionVariables.set('childId', ch.id);",
        ],
      },
    },
  ];
}

function toPostmanItem(it) {
  if (it.item) {
    return { name: it.name, item: it.item.map(toPostmanItem) };
  }
  const r = it.request;
  const urlRaw = typeof r.url === "string" ? r.url : r.url?.raw || `${BASE}/`;
  const reqObj = {
    method: r.method,
    header: r.header || [],
    url: urlRaw,
    auth: r.auth || undefined,
    body: r.body || undefined,
  };
  const out = { name: it.name, request: reqObj };
  if (it.event) out.event = it.event;
  return out;
}

const items = [
  folder("00 Health (public)", [
    req("GET /health", "GET", "/health", null, true),
    req("GET /ready", "GET", "/ready", null, true),
  ]),
  folder("01 Auth", [
    (() => {
      const r = req(
        "POST /auth/login (PARENT user)",
        "POST",
        "/auth/login",
        { email: "{{parentEmail}}", password: "{{parentPassword}}" },
        true
      );
      r.event = eventTest();
      return r;
    })(),
    req("POST /auth/refresh", "POST", "/auth/refresh", { refreshToken: "{{refreshToken}}" }, true),
    req("GET /auth/me", "GET", "/auth/me"),
  ]),
  folder("02 Parent app (/parent/*) — requires PARENT JWT", [
    (() => {
      const r = req("GET /parent/children", "GET", "/parent/children");
      r.event = eventSaveFirstChild();
      return r;
    })(),
    req("GET /parent/home", "GET", "/parent/home?childId={{childId}}"),
    req("GET /parent/announcements", "GET", "/parent/announcements?childId={{childId}}"),
    req("GET /parent/notifications", "GET", "/parent/notifications?childId={{childId}}"),
    req("GET /parent/attendance", "GET", "/parent/attendance?childId={{childId}}"),
    req("GET /parent/fees", "GET", "/parent/fees?childId={{childId}}"),
    req("GET /parent/invoices/:invoiceId", "GET", "/parent/invoices/{{invoiceId}}"),
    req("GET /parent/timetable", "GET", "/parent/timetable?childId={{childId}}"),
    req("GET /parent/progress-reports", "GET", "/parent/progress-reports?childId={{childId}}"),
    req("GET /parent/live-classes", "GET", "/parent/live-classes?childId={{childId}}"),
    req("GET /parent/profile-hub", "GET", "/parent/profile-hub?childId={{childId}}"),
    req("GET /parent/library", "GET", "/parent/library?childId={{childId}}"),
    req("GET /parent/documents", "GET", "/parent/documents?childId={{childId}}"),
    req("GET /parent/settings", "GET", "/parent/settings?childId={{childId}}"),
    req("PUT /parent/settings", "PUT", "/parent/settings?childId={{childId}}", {}),
  ]),
];

const collection = {
  info: {
    _postman_id: "school-erp-parent-" + Date.now(),
    name: "School ERP — Parent app (PARENT role)",
    schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    description:
      "Parent app APIs under `/api/v1/parent`. Same family account can use PARENT login (student app may share parent phone — use this collection for parent dashboard). " +
      "**CRITICAL:** Set `base_url` to `https://YOUR-HOST/api/v1`. Run **01 Auth → login**, then **GET /parent/children** (saves `childId`), then other requests. " +
      "Most endpoints require `?childId=...` for the selected child. Source: `src/modules/parent/parent.routes.js`.",
  },
  variable: [
    { key: "base_url", value: "https://backend-school-app.onrender.com/api/v1" },
    { key: "auth_token", value: "" },
    { key: "accessToken", value: "" },
    { key: "refreshToken", value: "" },
    { key: "parentEmail", value: "" },
    { key: "parentPassword", value: "" },
    { key: "invoiceId", value: "" },
    { key: "childId", value: "" },
  ],
  item: items.map(toPostmanItem),
};

const outPath = path.join(__dirname, "School-ERP-Parent.postman_collection.json");
fs.writeFileSync(outPath, JSON.stringify(collection, null, 2), "utf8");
console.log("Written:", outPath);
