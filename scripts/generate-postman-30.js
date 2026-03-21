/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

function statusTest(code) {
  return `pm.test("Status ${code}", function () { pm.response.to.have.status(${code}); });`;
}

function requestItem(name, method, endpoint, options = {}) {
  const request = {
    method,
    header: [],
    url: `{{baseUrl}}${endpoint}`,
  };

  if (options.auth) {
    request.auth = {
      type: "bearer",
      bearer: [{ key: "token", value: "{{accessToken}}", type: "string" }],
    };
  }

  if (options.body) {
    request.header.push({ key: "Content-Type", value: "application/json" });
    request.body = {
      mode: "raw",
      raw: JSON.stringify(options.body, null, 2),
      options: { raw: { language: "json" } },
    };
  }

  const item = { name, request };
  if (options.tests && options.tests.length > 0) {
    item.event = [
      {
        listen: "test",
        script: {
          type: "text/javascript",
          exec: options.tests,
        },
      },
    ];
  }

  return item;
}

function folder(name, items) {
  return { name, item: items };
}

const collection = {
  info: {
    _postman_id: crypto.randomUUID(),
    name: "School ERP - 30 API Test Pack",
    schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    description:
      "Module-wise 30 API collection for School ERP. Run auth first, then modules. Uses collection variables for tokens and IDs.",
  },
  variable: [
    { key: "baseUrl", value: "http://localhost:5000/api/v1" },
    { key: "accessToken", value: "" },
    { key: "refreshToken", value: "" },
    { key: "forgotEmail", value: "admin@school.edu" },
    { key: "otp", value: "654321" },
    { key: "resetToken", value: "" },
    { key: "resetNewPassword", value: "Admin123!" },
    { key: "changeCurrentPassword", value: "" },
    { key: "changeNewPassword", value: "" },
    { key: "staffId", value: "" },
    { key: "classId", value: "" },
    { key: "subjectId", value: "" },
    { key: "studentId", value: "" },
  ],
  item: [
    folder("01 Auth (7 + optional change-password)", [
      requestItem("1) POST /auth/login", "POST", "/auth/login", {
        body: {
          email: "admin@school.edu",
          password: "Admin123!",
        },
        tests: [
          statusTest(200),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('accessToken', j.data.accessToken);",
          "pm.collectionVariables.set('refreshToken', j.data.refreshToken);",
        ],
      }),
      requestItem("2) GET /auth/me", "GET", "/auth/me", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("3) POST /auth/refresh", "POST", "/auth/refresh", {
        body: {
          refreshToken: "{{refreshToken}}",
        },
        tests: [
          statusTest(200),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('accessToken', j.data.accessToken);",
          "pm.collectionVariables.set('refreshToken', j.data.refreshToken);",
        ],
      }),
      requestItem("4) POST /auth/forgot-password", "POST", "/auth/forgot-password", {
        body: {
          email: "{{forgotEmail}}",
        },
        tests: [
          statusTest(200),
          "const j = pm.response.json();",
          "if (j?.data?.debugOtp) { pm.collectionVariables.set('otp', String(j.data.debugOtp)); }",
        ],
      }),
      requestItem("5) POST /auth/verify-otp", "POST", "/auth/verify-otp", {
        body: {
          email: "{{forgotEmail}}",
          otp: "{{otp}}",
        },
        tests: [
          statusTest(200),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('resetToken', j.data.resetToken);",
        ],
      }),
      requestItem("6) POST /auth/reset-password", "POST", "/auth/reset-password", {
        body: {
          resetToken: "{{resetToken}}",
          newPassword: "{{resetNewPassword}}",
        },
        tests: [statusTest(200)],
      }),
      requestItem("7) POST /auth/change-password (Optional)", "POST", "/auth/change-password", {
        auth: true,
        body: {
          currentPassword: "{{changeCurrentPassword}}",
          newPassword: "{{changeNewPassword}}",
        },
      }),
    ]),

    folder("02 Dashboard (1)", [
      requestItem("9) GET /dashboard/school-admin", "GET", "/dashboard/school-admin", {
        auth: true,
        tests: [statusTest(200)],
      }),
    ]),

    folder("03 Staff (4)", [
      requestItem("24) GET /school/staff", "GET", "/school/staff", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("25) POST /school/staff", "POST", "/school/staff", {
        auth: true,
        body: {
          employeeCode: "EMP-{{$timestamp}}",
          fullName: "API Test Staff",
          email: "staff{{$timestamp}}@school.edu",
          phone: "9999999999",
          designation: "Teacher",
          department: "Academics",
        },
        tests: [
          statusTest(201),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('staffId', j.data.staff.id);",
        ],
      }),
      requestItem("26) PUT /school/staff/:id", "PUT", "/school/staff/{{staffId}}", {
        auth: true,
        body: {
          designation: "Senior Teacher",
        },
        tests: [statusTest(200)],
      }),
    ]),

    folder("04 Classes (4)", [
      requestItem("16) GET /school/classes", "GET", "/school/classes", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("17) POST /school/classes", "POST", "/school/classes", {
        auth: true,
        body: {
          name: "10",
          section: "A",
          classTeacherId: "{{staffId}}",
          capacity: 40,
        },
        tests: [
          statusTest(201),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('classId', j.data.classRoom.id);",
        ],
      }),
      requestItem("18) PUT /school/classes/:id", "PUT", "/school/classes/{{classId}}", {
        auth: true,
        body: {
          capacity: 45,
        },
        tests: [statusTest(200)],
      }),
    ]),

    folder("05 Subjects (4)", [
      requestItem("20) GET /school/subjects", "GET", "/school/subjects", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("21) POST /school/subjects", "POST", "/school/subjects", {
        auth: true,
        body: {
          name: "Mathematics",
          code: "MATH-{{$timestamp}}",
        },
        tests: [
          statusTest(201),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('subjectId', j.data.subject.id);",
        ],
      }),
      requestItem("22) PUT /school/subjects/:id", "PUT", "/school/subjects/{{subjectId}}", {
        auth: true,
        body: {
          name: "Advanced Mathematics",
        },
        tests: [statusTest(200)],
      }),
    ]),

    folder("06 Students (6)", [
      requestItem("10) GET /school/students", "GET", "/school/students", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("11) POST /school/students", "POST", "/school/students", {
        auth: true,
        body: {
          classId: "{{classId}}",
          admissionNo: "ADM-{{$timestamp}}",
          firstName: "Ava",
          lastName: "Singh",
          className: "10",
          section: "A",
          guardianPhone: "9999999999",
        },
        tests: [
          statusTest(201),
          "const j = pm.response.json();",
          "pm.collectionVariables.set('studentId', j.data.student.id);",
        ],
      }),
      requestItem("12) GET /school/students/:id", "GET", "/school/students/{{studentId}}", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("13) PUT /school/students/:id", "PUT", "/school/students/{{studentId}}", {
        auth: true,
        body: {
          section: "B",
          rollNo: 5,
        },
        tests: [statusTest(200)],
      }),
      requestItem(
        "14) PATCH /school/students/:id/status",
        "PATCH",
        "/school/students/{{studentId}}/status",
        {
          auth: true,
          body: {
            status: "ACTIVE",
          },
          tests: [statusTest(200)],
        }
      ),
    ]),

    folder("07 Attendance (2)", [
      requestItem("28) GET /school/attendance/overview", "GET", "/school/attendance/overview", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("29) POST /school/attendance/mark", "POST", "/school/attendance/mark", {
        auth: true,
        body: {
          type: "student",
          studentId: "{{studentId}}",
          status: "PRESENT",
        },
        tests: [statusTest(200)],
      }),
    ]),

    folder("08 Finance (1)", [
      requestItem("30) GET /school/invoices", "GET", "/school/invoices", {
        auth: true,
        tests: [statusTest(200)],
      }),
    ]),

    folder("09 Cleanup (5)", [
      requestItem("8) POST /auth/logout", "POST", "/auth/logout", {
        body: {
          refreshToken: "{{refreshToken}}",
        },
        tests: [statusTest(200)],
      }),
      requestItem("15) DELETE /school/students/:id", "DELETE", "/school/students/{{studentId}}", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("19) DELETE /school/classes/:id", "DELETE", "/school/classes/{{classId}}", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("23) DELETE /school/subjects/:id", "DELETE", "/school/subjects/{{subjectId}}", {
        auth: true,
        tests: [statusTest(200)],
      }),
      requestItem("27) DELETE /school/staff/:id", "DELETE", "/school/staff/{{staffId}}", {
        auth: true,
        tests: [statusTest(200)],
      }),
    ]),
  ],
};

const environment = {
  id: crypto.randomUUID(),
  name: "School ERP - Local",
  values: [
    { key: "baseUrl", value: "http://localhost:5000/api/v1", enabled: true },
    { key: "accessToken", value: "", enabled: true },
    { key: "refreshToken", value: "", enabled: true },
    { key: "forgotEmail", value: "admin@school.edu", enabled: true },
    { key: "otp", value: "654321", enabled: true },
    { key: "resetToken", value: "", enabled: true },
    { key: "resetNewPassword", value: "Admin123!", enabled: true },
    { key: "changeCurrentPassword", value: "", enabled: true },
    { key: "changeNewPassword", value: "", enabled: true },
    { key: "staffId", value: "", enabled: true },
    { key: "classId", value: "", enabled: true },
    { key: "subjectId", value: "", enabled: true },
    { key: "studentId", value: "", enabled: true },
  ],
  _postman_variable_scope: "environment",
  _postman_exported_at: new Date().toISOString(),
  _postman_exported_using: "Codex",
};

const outDir = path.resolve(__dirname, "..", "postman");
fs.mkdirSync(outDir, { recursive: true });

const collectionPath = path.join(outDir, "School-ERP-30.postman_collection.json");
const envPath = path.join(outDir, "School-ERP-Local.postman_environment.json");

fs.writeFileSync(collectionPath, JSON.stringify(collection, null, 2));
fs.writeFileSync(envPath, JSON.stringify(environment, null, 2));

console.log(`Generated: ${collectionPath}`);
console.log(`Generated: ${envPath}`);
