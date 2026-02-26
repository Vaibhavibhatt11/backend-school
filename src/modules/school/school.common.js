const crypto = require("crypto");

const prisma = require("../../lib/prisma");
const { notFound, badRequest } = require("../../utils/httpErrors");
const { resolveSchoolId, parsePagination, getPaginationMeta } = require("../../utils/schoolScope");

function getQuerySchoolId(req) {
  return typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
}

function scopedSchoolId(req, schoolIdInput, requireForSuperadmin = true) {
  return resolveSchoolId(req, schoolIdInput || getQuerySchoolId(req), {
    requireForSuperadmin,
  });
}

function dayStart(dateInput = new Date()) {
  const d = new Date(dateInput);
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), 0, 0, 0));
}

function dayWindow(dateInput = new Date()) {
  const start = dayStart(dateInput);
  const end = new Date(start);
  end.setUTCDate(end.getUTCDate() + 1);
  return { start, end };
}

function generateCode(prefix) {
  return `${prefix}-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
}

function asUpdateData(payload) {
  const data = {};
  for (const [key, value] of Object.entries(payload)) {
    if (value !== undefined) data[key] = value;
  }
  return data;
}

async function ensureSchoolExists(schoolId) {
  const school = await prisma.school.findUnique({ where: { id: schoolId } });
  if (!school) throw notFound("School not found", "SCHOOL_NOT_FOUND");
  return school;
}

async function findScopedOrThrow(model, id, schoolId, entityName, code) {
  const item = await prisma[model].findUnique({ where: { id } });
  if (!item || item.schoolId !== schoolId) {
    throw notFound(`${entityName} not found`, code);
  }
  return item;
}

function paginationFromQuery(query) {
  const { page, limit } = parsePagination(query);
  const skip = (page - 1) * limit;
  return { page, limit, skip };
}

function paginated(items, total, page, limit) {
  return {
    items,
    pagination: getPaginationMeta(total, page, limit),
  };
}

function baseSchoolSearch(where, search, fields) {
  if (!search) return where;
  where.OR = fields.map((field) => ({ [field]: { contains: search, mode: "insensitive" } }));
  return where;
}

function computeInvoiceStatus(amountDue, amountPaid) {
  if (amountPaid <= 0) return "ISSUED";
  if (amountPaid >= amountDue) return "PAID";
  return "PARTIAL";
}

async function loadCustomRoles(schoolId) {
  const roles = await prisma.schoolRole.findMany({
    where: { schoolId },
    orderBy: { createdAt: "asc" },
  });
  return roles.map((role) => ({
    id: role.id,
    schoolId: role.schoolId,
    name: role.name,
    description: role.description || "",
    permissions: role.permissions || [],
    isActive: role.isActive,
    createdAt: role.createdAt,
    updatedAt: role.updatedAt,
  }));
}

function ensureNotSystemRole(roleId) {
  if (["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT", "HR", "TEACHER", "PARENT"].includes(roleId)) {
    throw badRequest("Built-in roles cannot be modified");
  }
}

function newRoleId() {
  return `ROLE_${crypto.randomUUID().replace(/-/g, "").slice(0, 12).toUpperCase()}`;
}

module.exports = {
  prisma,
  getQuerySchoolId,
  scopedSchoolId,
  dayStart,
  dayWindow,
  generateCode,
  asUpdateData,
  ensureSchoolExists,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  baseSchoolSearch,
  computeInvoiceStatus,
  loadCustomRoles,
  ensureNotSystemRole,
  newRoleId,
};
