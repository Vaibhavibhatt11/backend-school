"use strict";

const { badRequest } = require("../../utils/httpErrors");

/** Safe resource ID: alphanumeric, hyphen, underscore; 15–50 chars (cuid/uuid) */
const SAFE_ID_REGEX = /^[a-zA-Z0-9_-]{15,50}$/;

/** Max lengths for user input */
const LIMITS = {
  reason: 2000,
  purpose: 500,
  preferencesJsonLength: 10000,
  fileUrlsMax: 20,
  fileUrlLength: 2048,
  searchLength: 100,
  monthLength: 7,
};

/**
 * Validate resource ID from params (prevents injection and IDOR when used with scoped queries).
 * @param {string} id - req.params.id
 * @returns {void}
 */
function validateId(id, paramName = "id") {
  if (id == null || typeof id !== "string") {
    throw badRequest(`Invalid ${paramName}`, "INVALID_INPUT");
  }
  const trimmed = id.trim();
  if (!trimmed || trimmed.length > 50) {
    throw badRequest(`Invalid ${paramName}`, "INVALID_INPUT");
  }
  if (!SAFE_ID_REGEX.test(trimmed)) {
    throw badRequest(`Invalid ${paramName} format`, "INVALID_INPUT");
  }
  return trimmed;
}

/**
 * Sanitize string: trim and enforce max length.
 */
function sanitizeString(value, maxLen, fieldName = "field") {
  if (value == null) return null;
  const s = String(value).trim();
  if (s.length > maxLen) throw badRequest(`${fieldName} must be at most ${maxLen} characters`, "INVALID_INPUT");
  return s || null;
}

/**
 * Validate and parse date string (ISO or YYYY-MM-DD).
 */
function parseSafeDate(value, fieldName = "date") {
  if (value == null || value === "") return null;
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) throw badRequest(`Invalid ${fieldName}`, "INVALID_INPUT");
  return d;
}

/**
 * Validate leave request body: fromDate, toDate, reason.
 */
function validateLeaveRequest(body) {
  const fromDate = parseSafeDate(body?.fromDate, "fromDate");
  const toDate = parseSafeDate(body?.toDate, "toDate");
  if (!fromDate || !toDate) throw badRequest("fromDate and toDate are required and must be valid dates", "INVALID_INPUT");
  if (toDate < fromDate) throw badRequest("toDate must be on or after fromDate", "INVALID_INPUT");
  const maxFromNow = 365 * 24 * 60 * 60 * 1000;
  if (fromDate.getTime() > Date.now() + maxFromNow) throw badRequest("fromDate must be within the next year", "INVALID_INPUT");
  const reason = sanitizeString(body?.reason, LIMITS.reason, "reason");
  if (!reason) throw badRequest("reason is required", "INVALID_INPUT");
  return { fromDate, toDate, reason };
}

/**
 * Validate homework submission body: optional url, fileUrls (array), status.
 */
function validateHomeworkSubmit(body) {
  const result = {};
  if (body?.url != null) result.url = sanitizeString(body.url, LIMITS.fileUrlLength, "url") || null;
  if (Array.isArray(body?.fileUrls)) {
    if (body.fileUrls.length > LIMITS.fileUrlsMax) throw badRequest(`fileUrls must have at most ${LIMITS.fileUrlsMax} items`, "INVALID_INPUT");
    result.fileUrls = body.fileUrls.slice(0, LIMITS.fileUrlsMax).map((u) => sanitizeString(u, LIMITS.fileUrlLength, "fileUrl") || "").filter(Boolean);
  } else {
    result.fileUrls = [];
  }
  if (body?.status != null) result.status = sanitizeString(body.status, 50, "status") || "SUBMITTED";
  return result;
}

/**
 * Validate profile update: only whitelisted fields.
 */
function validateProfileUpdate(body) {
  const data = {};
  if (body?.guardianPhone !== undefined) {
    const v = body.guardianPhone;
    data.guardianPhone = v === null || v === "" ? null : sanitizeString(v, 30, "guardianPhone");
  }
  return data;
}

/**
 * Validate settings preferences: must be object, limit size.
 */
function validateSettings(body) {
  const prefs = body?.preferences ?? body;
  if (prefs == null) return {};
  if (typeof prefs !== "object" || Array.isArray(prefs)) throw badRequest("preferences must be an object", "INVALID_INPUT");
  const str = JSON.stringify(prefs);
  if (str.length > LIMITS.preferencesJsonLength) throw badRequest("preferences too large", "INVALID_INPUT");
  return prefs;
}

/**
 * Validate meeting request body: optional staffId, preferredDate, purpose.
 */
function validateMeetingRequest(body) {
  let staffId = null;
  if (body?.staffId != null && String(body.staffId).trim() !== "") {
    staffId = validateId(String(body.staffId).trim(), "staffId");
  }
  const preferredDate = parseSafeDate(body?.preferredDate, "preferredDate");
  const purpose = body?.purpose != null ? sanitizeString(body.purpose, LIMITS.purpose, "purpose") : null;
  return { staffId, preferredDate, purpose };
}

/**
 * Validate query: month YYYY-MM, search length.
 */
function validateQueryMonth(month) {
  if (month == null || month === "") return null;
  const s = String(month).trim();
  if (s.length > LIMITS.monthLength) return null;
  if (!/^\d{4}-\d{2}$/.test(s)) return null;
  return s;
}

function validateSearch(search) {
  if (search == null || search === "") return null;
  return sanitizeString(search, LIMITS.searchLength, "search");
}

/**
 * Require JWT present (401 if missing). Use before resolveStudent so unauthenticated requests fail fast.
 */
function requireAuth(req, res, next) {
  if (!req.user?.sub) {
    return res.status(401).json({ success: false, error: "Unauthorized", errorCode: "UNAUTHORIZED" });
  }
  next();
}

module.exports = {
  validateId,
  sanitizeString,
  parseSafeDate,
  validateLeaveRequest,
  validateHomeworkSubmit,
  validateProfileUpdate,
  validateSettings,
  validateMeetingRequest,
  validateQueryMonth,
  validateSearch,
  requireAuth,
  LIMITS,
};
