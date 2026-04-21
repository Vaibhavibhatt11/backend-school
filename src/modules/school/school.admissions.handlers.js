"use strict";

const { z } = require("zod");
const {
  prisma,
  scopedSchoolId,
  ensureSchoolExists,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  baseSchoolSearch,
} = require("./school.common");
const { badRequest } = require("../../utils/httpErrors");
const cache = require("../../lib/cache");
const { getPaginationMeta } = require("../../utils/schoolScope");

const createSchema = z.object({
  schoolId: z.string().trim().optional(),
  firstName: z.string().trim().min(1).max(120),
  lastName: z.string().trim().min(1).max(120),
  email: z.string().email().optional().or(z.literal("")),
  phone: z.string().trim().max(20).optional(),
  dob: z.coerce.date().optional(),
  gender: z.string().trim().max(20).optional(),
  appliedClass: z.string().trim().min(1).max(50),
  appliedSection: z.string().trim().max(20).optional(),
});

const updateStatusSchema = z.object({
  status: z.enum(["UNDER_REVIEW", "APPROVED", "REJECTED", "WAITING"]),
});

const updateFeeSchema = z.object({
  paid: z.boolean(),
});

function hashForCache(s) {
  if (!s || typeof s !== "string") return "";
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h << 5) - h + s.charCodeAt(i) | 0;
  return String(h >>> 0);
}

async function listApplications(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      status: z.string().trim().max(30).optional(),
      search: z.string().trim().max(100).optional(),
      schoolId: z.string().trim().optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const cacheKey = cache.cacheKeys.admissionsList(schoolId, page, limit, query.status || "", hashForCache(query.search));
    const ttl = cache.CACHE_TTL.list();
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const where = { schoolId };
      if (query.status) where.status = query.status;
      baseSchoolSearch(where, query.search, ["firstName", "lastName", "email", "applicationNo"]);
      const [total, items] = await Promise.all([
        prisma.admissionApplication.count({ where }),
        prisma.admissionApplication.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
          select: {
            id: true,
            applicationNo: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            appliedClass: true,
            appliedSection: true,
            status: true,
            admissionFeePaid: true,
            registrationNo: true,
            createdAt: true,
            _count: { select: { documents: true } },
          },
        }),
      ]);
      return { items, pagination: getPaginationMeta(total, page, limit) };
    });
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

async function getApplicationById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("admissionApplication", req.params.id, schoolId, "Application", "APPLICATION_NOT_FOUND");
    const withDocs = await prisma.admissionApplication.findUnique({
      where: { id: item.id },
      select: {
        id: true,
        applicationNo: true,
        firstName: true,
        lastName: true,
        email: true,
        phone: true,
        dob: true,
        gender: true,
        appliedClass: true,
        appliedSection: true,
        status: true,
        admissionFeePaid: true,
        registrationNo: true,
        studentId: true,
        createdAt: true,
        updatedAt: true,
        documents: { select: { id: true, name: true, url: true, type: true, createdAt: true } },
      },
    });
    return res.status(200).json({ success: true, data: withDocs });
  } catch (e) {
    return next(e);
  }
}

function invalidateAdmissionsList(schoolId) {
  cache.delByPrefix(`admissions:list:${schoolId}`);
}

async function createApplication(req, res, next) {
  try {
    const body = createSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    await ensureSchoolExists(schoolId);
    const count = await prisma.admissionApplication.count({ where: { schoolId } });
    const applicationNo = `APP-${String(count + 1).padStart(5, "0")}`;
    const application = await prisma.admissionApplication.create({
      data: {
        schoolId,
        applicationNo,
        firstName: body.firstName,
        lastName: body.lastName,
        email: body.email || null,
        phone: body.phone || null,
        dob: body.dob || null,
        gender: body.gender || null,
        appliedClass: body.appliedClass,
        appliedSection: body.appliedSection || null,
      },
    });
    invalidateAdmissionsList(schoolId);
    return res.status(201).json({ success: true, data: application });
  } catch (e) {
    return next(e);
  }
}

async function updateApplicationStatus(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const { status } = updateStatusSchema.parse(req.body);
    await findScopedOrThrow("admissionApplication", req.params.id, schoolId, "Application", "APPLICATION_NOT_FOUND");
    const updated = await prisma.admissionApplication.update({
      where: { id: req.params.id },
      data: { status },
    });
    invalidateAdmissionsList(schoolId);
    return res.status(200).json({ success: true, data: updated });
  } catch (e) {
    return next(e);
  }
}

async function addApplicationDocument(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const app = await findScopedOrThrow("admissionApplication", req.params.id, schoolId, "Application", "APPLICATION_NOT_FOUND");
    const body = z.object({
      name: z.string().trim().min(1).max(200),
      url: z.string().trim().min(1).max(2000),
      type: z.string().trim().max(50).optional(),
    }).parse(req.body);
    const doc = await prisma.admissionDocument.create({
      data: {
        applicationId: app.id,
        name: body.name,
        url: body.url,
        type: body.type || "document",
      },
    });
    invalidateAdmissionsList(schoolId);
    return res.status(201).json({ success: true, data: doc });
  } catch (e) {
    return next(e);
  }
}

async function generateRegistrationNo(schoolId) {
  const year = new Date().getFullYear();
  const prefix = `REG-${year}-`;
  const last = await prisma.student.findFirst({
    where: { schoolId, admissionNo: { startsWith: prefix } },
    orderBy: { admissionNo: "desc" },
    select: { admissionNo: true },
  });
  const nextNum = last ? parseInt(last.admissionNo.replace(prefix, ""), 10) + 1 : 1;
  return `${prefix}${String(nextNum).padStart(5, "0")}`;
}

async function updateAdmissionFeeStatus(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const { paid } = updateFeeSchema.parse(req.body);
    await findScopedOrThrow("admissionApplication", req.params.id, schoolId, "Application", "APPLICATION_NOT_FOUND");
    const updated = await prisma.admissionApplication.update({
      where: { id: req.params.id },
      data: { admissionFeePaid: paid },
    });
    invalidateAdmissionsList(schoolId);
    return res.status(200).json({ success: true, data: updated });
  } catch (e) {
    return next(e);
  }
}

async function onboardApplication(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const app = await findScopedOrThrow("admissionApplication", req.params.id, schoolId, "Application", "APPLICATION_NOT_FOUND");
    if (app.status !== "APPROVED") throw badRequest("Only approved applications can be onboarded", "INVALID_STATUS");
    if (app.studentId) throw badRequest("Already onboarded", "ALREADY_ONBOARDED");

    const regNo = await generateRegistrationNo(schoolId);
    const result = await prisma.$transaction(async (tx) => {
      const student = await tx.student.create({
        data: {
          schoolId,
          admissionNo: regNo,
          firstName: app.firstName,
          lastName: app.lastName,
          className: app.appliedClass,
          section: app.appliedSection || null,
          dob: app.dob,
          gender: app.gender,
          guardianPhone: app.phone,
          status: "ACTIVE",
        },
      });
      await tx.admissionApplication.update({
        where: { id: app.id },
        data: { studentId: student.id, registrationNo: regNo, status: "ONBOARDED" },
      });
      const updatedApp = await tx.admissionApplication.findUnique({ where: { id: app.id } });
      return { student, application: updatedApp };
    });
    invalidateAdmissionsList(schoolId);
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listApplications,
  getApplicationById,
  createApplication,
  updateApplicationStatus,
  updateAdmissionFeeStatus,
  addApplicationDocument,
  onboardApplication,
};
