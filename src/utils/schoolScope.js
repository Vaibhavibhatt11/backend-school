const { badRequest, forbidden } = require("./httpErrors");

function isSuperadmin(req) {
  return req.user?.role === "SUPERADMIN";
}

function resolveSchoolId(req, schoolIdInput, options = {}) {
  const { requireForSuperadmin = false } = options;

  if (isSuperadmin(req)) {
    const schoolId = schoolIdInput || null;
    if (requireForSuperadmin && !schoolId) {
      throw badRequest(
        "schoolId is required for SUPERADMIN",
        "SCHOOL_CONTEXT_REQUIRED"
      );
    }
    return schoolId;
  }

  if (!req.user?.schoolId) {
    throw forbidden("School context is missing for current user");
  }

  if (schoolIdInput && schoolIdInput !== req.user.schoolId) {
    throw forbidden("Cannot access another school's data");
  }

  return req.user.schoolId;
}

function parsePagination(query, defaults = {}) {
  const defaultPage = defaults.page || 1;
  const defaultLimit = defaults.limit || 20;
  const maxLimit = defaults.maxLimit || 100;

  const page = Number.parseInt(String(query.page || defaultPage), 10);
  const limit = Number.parseInt(String(query.limit || defaultLimit), 10);

  return {
    page: Number.isFinite(page) && page > 0 ? page : defaultPage,
    limit:
      Number.isFinite(limit) && limit > 0
        ? Math.min(limit, maxLimit)
        : defaultLimit,
  };
}

function getPaginationMeta(total, page, limit) {
  const totalPages = Math.max(1, Math.ceil(total / limit));
  return { page, limit, total, totalPages };
}

module.exports = {
  isSuperadmin,
  resolveSchoolId,
  parsePagination,
  getPaginationMeta,
};
