const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const morgan = require("morgan");
const cookieParser = require("cookie-parser");
const swaggerUi = require("swagger-ui-express");

const env = require("./config/env");
const apiRoutes = require("./routes");
const { getOpenApiSpec } = require("./docs/openapi");
const notFound = require("./middlewares/notFound");
const errorHandler = require("./middlewares/errorHandler");

const app = express();
const swaggerEnabled =
  env.SWAGGER_ENABLED !== undefined
    ? env.SWAGGER_ENABLED === "true"
    : env.NODE_ENV !== "production";
const openApiSpec = swaggerEnabled ? getOpenApiSpec() : null;

const corsOrigin = env.CORS_ORIGIN
  ? env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
  : true;

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
app.use(helmet());
app.use(
  cors({
    origin: corsOrigin,
    credentials: true,
  })
);
app.use(morgan(env.NODE_ENV === "production" ? "combined" : "dev"));
app.use(express.json({ limit: "2mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

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

app.use("/api/v1", apiRoutes);
app.use(notFound);
app.use(errorHandler);

module.exports = app;
