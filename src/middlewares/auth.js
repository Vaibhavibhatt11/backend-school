const jwt = require("jsonwebtoken");
const env = require("../config/env");

function logAuthFailure(req, reason) {
  const ip = req.ip || req.headers["x-forwarded-for"] || "unknown";
  console.warn(`[auth] ${reason} path=${req.originalUrl} ip=${ip}`);
}

function parseTokenValue(value) {
  if (typeof value !== "string" || !value.trim()) return null;

  let token = value.trim();

  if (/^Bearer\s+/i.test(token)) {
    token = token.replace(/^Bearer\s+/i, "").trim();
  }

  // Tolerate copied tokens wrapped in quotes.
  token = token.replace(/^['"]+|['"]+$/g, "").trim();

  // Some clients accidentally send "Bearer Bearer <token>".
  if (/^Bearer\s+/i.test(token)) {
    token = token.replace(/^Bearer\s+/i, "").trim();
  }

  if (!token) return null;
  if (token === "undefined" || token === "null") return null;

  return token;
}

function extractAccessToken(req) {
  const headerCandidates = [
    req.headers.authorization,
    req.headers["x-access-token"],
    req.headers["auth-token"],
    req.headers.token,
    req.headers.auothorization, // tolerate common typo from clients
  ];

  for (const candidate of headerCandidates) {
    const parsed = parseTokenValue(candidate);
    if (parsed) return parsed;
  }

  const cookieToken = req.cookies?.accessToken;
  if (typeof cookieToken === "string" && cookieToken.trim()) {
    return cookieToken.trim();
  }

  return null;
}

function tokenHint(token) {
  if (!token) return "empty";
  if (token.length <= 18) return `len=${token.length}`;
  return `len=${token.length},prefix=${token.slice(0, 8)},suffix=${token.slice(-6)}`;
}

function auth(req, res, next) {
  const token = extractAccessToken(req);

  if (!token) {
    logAuthFailure(req, "missing_access_token");
    return res.status(401).json({
      success: false,
      error: { code: "UNAUTHORIZED", message: "Missing access token" },
    });
  }

  let payload;
  try {
    payload = jwt.verify(token, env.JWT_ACCESS_SECRET, {
      algorithms: ["HS256"],
    });

    if (!payload || typeof payload !== "object") {
      logAuthFailure(req, "invalid_token_payload");
      return res.status(401).json({
        success: false,
        error: { code: "UNAUTHORIZED", message: "Invalid access token payload" },
      });
    }

    if (payload.tokenType !== "access" || typeof payload.sub !== "string") {
      logAuthFailure(req, "unexpected_token_type");
      return res.status(401).json({
        success: false,
        error: { code: "UNAUTHORIZED", message: "Invalid access token" },
      });
    }

    req.user = payload;
    return next();
  } catch (error) {
    try {
      const refreshPayload = jwt.verify(token, env.JWT_REFRESH_SECRET, {
        algorithms: ["HS256"],
      });

      if (
        refreshPayload &&
        typeof refreshPayload === "object" &&
        refreshPayload.tokenType === "refresh"
      ) {
        logAuthFailure(req, "refresh_token_used_for_protected_route");
        return res.status(401).json({
          success: false,
          error: {
            code: "UNAUTHORIZED",
            message: "Refresh token cannot be used here. Send accessToken in Authorization header.",
          },
        });
      }
    } catch {
      // not a refresh token either
    }

    if (error.name === "TokenExpiredError") {
      logAuthFailure(req, "expired_access_token");
      return res.status(401).json({
        success: false,
        error: { code: "TOKEN_EXPIRED", message: "Access token expired" },
      });
    }

    logAuthFailure(req, `token_verification_failed ${tokenHint(token)}`);
    return res.status(401).json({
      success: false,
      error: { code: "UNAUTHORIZED", message: "Invalid or expired access token" },
    });
  }
}

module.exports = auth;
