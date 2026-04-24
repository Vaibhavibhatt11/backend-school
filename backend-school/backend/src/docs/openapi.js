const fs = require("fs");
const path = require("path");
const env = require("../config/env");

const routeGroups = [
  {
    tag: "Auth",
    basePath: "/auth",
    file: "modules/auth/auth.routes.js",
    secured: true,
    publicRoutes: [
      "/login",
      "/refresh",
      "/logout",
      "/forgot-password",
      "/verify-otp",
      "/reset-password",
    ],
    roles: [],
  },
  {
    tag: "Dashboard",
    basePath: "/dashboard",
    file: "modules/dashboard/dashboard.routes.js",
    secured: true,
    roles: ["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT", "HR", "TEACHER", "PARENT"],
  },
  {
    tag: "Superadmin",
    basePath: "/superadmin",
    file: "modules/superadmin/superadmin.routes.js",
    secured: true,
    roles: ["SUPERADMIN"],
  },
  {
    tag: "School Students",
    basePath: "/school/students",
    file: "modules/students/students.routes.js",
    secured: true,
    roles: ["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"],
  },
  {
    tag: "School",
    basePath: "/school",
    file: "modules/school/school.routes.js",
    secured: true,
    roles: ["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"],
  },
  {
    tag: "HR",
    basePath: "/hr",
    file: "modules/hr/hr.routes.js",
    secured: true,
    roles: ["SUPERADMIN", "SCHOOLADMIN", "HR"],
  },
  {
    tag: "Accountant",
    basePath: "/accountant",
    file: "modules/accountant/accountant.routes.js",
    secured: true,
    roles: ["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT"],
  },
];

function parseRouteFile(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  const regex = /router\.(get|post|put|patch|delete)\(\s*["'`]([^"'`]+)["'`]/g;
  const routes = [];
  let match = regex.exec(content);

  while (match) {
    routes.push({
      method: match[1].toLowerCase(),
      routePath: match[2],
    });
    match = regex.exec(content);
  }

  return routes;
}

function normalizeRoutePath(basePath, routePath) {
  if (routePath === "/") {
    return basePath;
  }
  return `${basePath}${routePath}`;
}

function toOpenApiPath(rawPath) {
  return rawPath.replace(/:([a-zA-Z0-9_]+)/g, "{$1}");
}

function getPathParameters(fullPath) {
  const params = [];
  const regex = /\{([a-zA-Z0-9_]+)\}/g;
  let match = regex.exec(fullPath);

  while (match) {
    params.push({
      in: "path",
      name: match[1],
      required: true,
      schema: { type: "string" },
      description: `Path parameter: ${match[1]}`,
    });
    match = regex.exec(fullPath);
  }

  return params;
}

function getSuccessResponseStatus(method) {
  if (method === "post") return "201";
  if (method === "delete") return "204";
  return "200";
}

function buildResponses(method) {
  const successCode = getSuccessResponseStatus(method);

  return {
    [successCode]: {
      description: "Success",
    },
    400: {
      description: "Bad request",
      content: {
        "application/json": {
          schema: { $ref: "#/components/schemas/ApiErrorResponse" },
        },
      },
    },
    401: {
      description: "Unauthorized",
      content: {
        "application/json": {
          schema: { $ref: "#/components/schemas/ApiErrorResponse" },
        },
      },
    },
    403: {
      description: "Forbidden",
      content: {
        "application/json": {
          schema: { $ref: "#/components/schemas/ApiErrorResponse" },
        },
      },
    },
    404: {
      description: "Not found",
      content: {
        "application/json": {
          schema: { $ref: "#/components/schemas/ApiErrorResponse" },
        },
      },
    },
    500: {
      description: "Internal server error",
      content: {
        "application/json": {
          schema: { $ref: "#/components/schemas/ApiErrorResponse" },
        },
      },
    },
    501: {
      description: "Not implemented yet (current scaffold response)",
      content: {
        "application/json": {
          schema: { $ref: "#/components/schemas/ApiErrorResponse" },
        },
      },
    },
  };
}

function toOperationId(method, pathName) {
  const cleanPath = pathName
    .replace(/[{}]/g, "")
    .replace(/[^a-zA-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
  return `${method}_${cleanPath}`;
}

function requiresAuth(group, routePath) {
  if (!group.secured) return false;
  const publicRoutes = new Set(group.publicRoutes || []);
  return !publicRoutes.has(routePath);
}

function createOperation(group, method, fullPath, routePath) {
  const operation = {
    tags: [group.tag],
    summary: `${method.toUpperCase()} ${fullPath}`,
    operationId: toOperationId(method, fullPath),
    responses: buildResponses(method),
    parameters: getPathParameters(fullPath),
    "x-required-roles": group.roles,
  };

  if (requiresAuth(group, routePath)) {
    operation.security = [{ bearerAuth: [] }];
  }

  if (["post", "put", "patch"].includes(method)) {
    operation.requestBody = {
      required: false,
      content: {
        "application/json": {
          schema: {
            type: "object",
            additionalProperties: true,
          },
        },
      },
    };
  }

  return operation;
}

function buildModulePaths() {
  const paths = {};

  for (const group of routeGroups) {
    const filePath = path.join(__dirname, "..", group.file);
    if (!fs.existsSync(filePath)) continue;

    const routes = parseRouteFile(filePath);

    for (const route of routes) {
      const rawPath = `/api/v1${normalizeRoutePath(group.basePath, route.routePath)}`;
      const fullPath = toOpenApiPath(rawPath);

      if (!paths[fullPath]) {
        paths[fullPath] = {};
      }

      paths[fullPath][route.method] = createOperation(
        group,
        route.method,
        fullPath,
        route.routePath
      );
    }
  }

  return paths;
}

function buildOpenApiSpec() {
  const paths = buildModulePaths();
  paths["/api/v1/health"] = {
    get: {
      tags: ["System"],
      summary: "Health check",
      operationId: "get_api_v1_health",
      responses: {
        200: {
          description: "Service healthy",
        },
      },
    },
  };
  paths["/api/v1/ready"] = {
    get: {
      tags: ["System"],
      summary: "Readiness check",
      operationId: "get_api_v1_ready",
      responses: {
        200: {
          description: "Service ready",
        },
        503: {
          description: "Service not ready",
        },
      },
    },
  };

  const servers = [];
  const localServer = `http://localhost:${env.PORT}`;

  if (env.PUBLIC_BASE_URL) {
    servers.push({
      url: env.PUBLIC_BASE_URL.replace(/\/+$/, ""),
      description: "Public access",
    });
  }

  servers.push({
    url: localServer,
    description: "Local development",
  });

  return {
    openapi: "3.0.3",
    info: {
      title: "School ERP Backend API",
      version: "1.0.0",
      description: "Auto-generated API reference for frontend integration.",
    },
    servers,
    tags: [
      { name: "System", description: "System endpoints" },
      ...routeGroups.map((group) => ({ name: group.tag, description: `${group.tag} module` })),
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
      schemas: {
        ApiErrorResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: false },
            error: {
              type: "object",
              properties: {
                code: { type: "string", example: "UNAUTHORIZED" },
                message: { type: "string", example: "Invalid or expired access token" },
              },
            },
          },
        },
      },
    },
    paths,
  };
}

let cachedSpec = null;

function getOpenApiSpec() {
  if (!cachedSpec) {
    cachedSpec = buildOpenApiSpec();
  }
  return cachedSpec;
}

module.exports = { getOpenApiSpec };
