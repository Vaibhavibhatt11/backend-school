"use strict";

const { badRequest } = require("../../utils/httpErrors");
const {
  validateId,
  validateQueryMonth,
  validateSearch,
  sanitizeString,
} = require("../student/student.security");

function requireChildId(query) {
  const childId = query?.childId;
  if (!childId) throw badRequest("childId is required", "CHILD_ID_REQUIRED");
  return validateId(String(childId), "childId");
}

function parseDayQuery(day) {
  // Accept `YYYY-MM-DD` or an integer day-of-month.
  if (day == null || day === "") return null;
  if (typeof day === "string" && /^\d{4}-\d{2}-\d{2}$/.test(day)) return day;
  const n = Number(day);
  if (!Number.isInteger(n) || n < 1 || n > 31) {
    throw badRequest("Invalid day", "INVALID_INPUT");
  }
  return n;
}

function validateSettingsBody(body) {
  const prefs = body?.preferences ?? body ?? {};
  if (prefs == null || typeof prefs !== "object" || Array.isArray(prefs)) {
    throw badRequest("preferences must be an object", "INVALID_INPUT");
  }
  // keep it bounded
  const json = JSON.stringify(prefs);
  if (json.length > 10000) throw badRequest("preferences too large", "INVALID_INPUT");
  return prefs;
}

function validateAiAsk(body) {
  const q = sanitizeString(body?.question, 2000, "question");
  if (!q) throw badRequest("question is required", "INVALID_INPUT");
  return { question: q };
}

module.exports = {
  requireChildId,
  validateId,
  validateQueryMonth,
  validateSearch,
  parseDayQuery,
  validateSettingsBody,
  validateAiAsk,
};

