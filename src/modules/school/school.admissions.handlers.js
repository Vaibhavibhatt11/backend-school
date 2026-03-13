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
  generateCode,
} = require("./school.common");
const { badRequest, notFound } = require("../../utils/httpErrors");

const createSchema = z.object({
  schoolId: z.string().trim().optional(),
  firstName: z.string().trim().min(1),
  lastName: z.string().trim().min(1),
  email: z.string().email().optional().or(z.literal("")),
  phone: z.string().trim().optional(),
  dob: z.coerce.date().optional(),
  gender: z.string().trim().optional(),
  appliedClass: z.string().trim().min(1),
  appliedSection: z.string().trim().optional(),
});

const updateStatusSchema = z.object({
  status: z.enum(["UNDER_REVIEW", "APPROVED", "REJECTED"]),
});

async function listApplications(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      status: z.string().trim().optional(),
      search: z.string().trim().optional(),
      schoolId: z.string().trim().optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
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
        include: { documents: true },
      }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
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
      include: { documents: true },
    });
    return res.status(200).json({ success: true, data: withDocs });
  } catch (e) {
    return next(e);
  }
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
    return res.status(200).json({ success: true, data: updated });
  } catch (e) {
    return next(e);
  }
}

async function addApplicationDocument(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const app = await findScopedOrThrow("admissionApplication", req.params.id, schoolId, "Application", "APPLICATION_NOT_FOUND");
    const body = z.object({ name: z.string().trim().min(1), url: z.string().trim().min(1), type: z.string().trim().optional() }).parse(req.body);
    const doc = await prisma.admissionDocument.create({
      data: {
        applicationId: app.id,
        name: body.name,
        url: body.url,
        type: body.type || "document",
      },
    });
    return res.status(201).json({ success: true, data: doc });
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
    const student = await prisma.student.create({
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
    await prisma.admissionApplication.update({
      where: { id: app.id },
      data: { studentId: student.id, registrationNo: regNo, status: "ONBOARDED" },
    });
    const updatedApp = await prisma.admissionApplication.findUnique({ where: { id: app.id } });
    return res.status(200).json({ success: true, data: { student, application: updatedApp } });
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

module.exports = {
  listApplications,
  getApplicationById,
  createApplication,
  updateApplicationStatus,
  addApplicationDocument,
  onboardApplication,
};
