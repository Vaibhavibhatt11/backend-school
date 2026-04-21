const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const compression = require("compression");
const morgan = require("morgan");
const cookieParser = require("cookie-parser");
const swaggerUi = require("swagger-ui-express");

const env = require("./config/env");
const apiRoutes = require("./routes");
const { apiRateLimiter } = require("./middlewares/apiRateLimit");
const ensureDatabaseReady = require("./middlewares/ensureDatabaseReady");
const { getOpenApiSpec } = require("./docs/openapi");
const notFound = require("./middlewares/notFound");
const errorHandler = require("./middlewares/errorHandler");
const { apiResponseEnvelope } = require("./utils/apiResponse");

const app = express();
const swaggerEnabled =
  env.SWAGGER_ENABLED !== undefined
    ? env.SWAGGER_ENABLED === "true"
    : env.NODE_ENV !== "production";
const openApiSpec = swaggerEnabled ? getOpenApiSpec() : null;

function normalizeOrigin(origin) {
  return String(origin || "")
    .trim()
    .replace(/^['"]+|['"]+$/g, "")
    .replace(/\/+$/, "");
}

const corsOrigins = env.CORS_ORIGIN
  ? env.CORS_ORIGIN.split(",").map(normalizeOrigin).filter(Boolean)
  : [];

function buildCorsOriginHandler(allowedOrigins) {
  // Common local development patterns (localhost, 127.0.0.1, 0.0.0.0 with any port)
  const localOriginPattern = /^https?:\/\/(localhost|127\.0\.0\.1|0\.0\.0\.0)(:\d+)?$/i;

  // Trusted hosted patterns (GitHub Pages, Render)
  const trustedHostedPattern = /(^https:\/\/[a-z0-9-]+\.github\.io$)|(^https:\/\/[a-z0-9-]+\.onrender\.com$)/i;

  const allowedSet = new Set(allowedOrigins);

  return (origin, callback) => {
    // 1. Allow non-browser callers (curl, Postman, server-to-server)
    if (!origin) return callback(null, true);

    const normalized = normalizeOrigin(origin);

    // 2. Allow if explicitly whitelisted or if wildcard is used
    if (allowedSet.has(normalized) || allowedOrigins.includes("*")) {
      return callback(null, true);
    }

    // 3. Always allow localhost and common development origins for better DX
    if (localOriginPattern.test(normalized)) {
      return callback(null, true);
    }

    // 4. Allow trusted production domains
    if (trustedHostedPattern.test(normalized)) {
      return callback(null, true);
    }

    // 5. Fallback: if no CORS_ORIGIN is defined and not in strict production, allow all
    if (allowedOrigins.length === 0 && env.NODE_ENV !== "production") {
      return callback(null, true);
    }

    // Log rejected origins to help debugging
    console.warn(`[CORS] Request from blocked origin: ${origin}`);
    return callback(null, false);
  };
}

function resolveTrustProxy(value, nodeEnv) {
  if (value === undefined) {
    return nodeEnv === "production" ? 1 : false;
  }

  const normalized = String(value).trim().toLowerCase();
  if (!normalized || normalized === "false" || normalized === "0") return false;
  if (normalized === "true") return 1;
  if (/^\d+$/.test(normalized)) return Number(normalized);

  // Keep Express-supported named values like "loopback", "linklocal", "uniquelocal".
  return value;
}

app.disable("x-powered-by");
const trustProxy = resolveTrustProxy(env.TRUST_PROXY, env.NODE_ENV);
if (trustProxy !== false) {
  app.set("trust proxy", trustProxy);
}

// Apply CORS before Helmet to ensure preflight requests (OPTIONS) are handled correctly
app.use(
  cors({
    origin: buildCorsOriginHandler(corsOrigins),
    credentials: true,
  })
);

app.use(helmet());
app.use(compression());
app.use(morgan(env.NODE_ENV === "production" ? "combined" : "dev"));
app.use(express.json({ limit: env.REQUEST_BODY_LIMIT }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(apiResponseEnvelope);

app.get("/", (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      service: "School ERP Backend API",
      version: "v1",
      docs: swaggerEnabled ? "/api/docs" : null,
      health: "/api/v1/health",
    },
  });
});

if (swaggerEnabled) {
  app.get("/api/docs.json", (req, res) => {
    return res.status(200).json(openApiSpec);
  });

  app.use(
    "/api/docs",
    swaggerUi.serve,
    swaggerUi.setup(openApiSpec, {
      explorer: true,
      customSiteTitle: "School ERP API Docs",
      swaggerOptions: {
        persistAuthorization: true,
      },
    })
  );
}

app.use("/api/v1", apiRateLimiter, ensureDatabaseReady, apiRoutes);
app.use(notFound);
app.use(errorHandler);

module.exports = app;
