const { z } = require("zod");

const { badRequest } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  asUpdateData,
  baseSchoolSearch,
  ensureSchoolExists,
} = require("./school.common");

const announcementStatusEnum = z.enum(["DRAFT", "SCHEDULED", "SENT", "FAILED"]);

const createAnnouncementSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  title: z.string().trim().min(1),
  content: z.string().trim().min(1),
  audience: z.string().trim().min(1),
  status: announcementStatusEnum.optional(),
  scheduledAt: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
});

const updateAnnouncementSchema = z.object({
  title: z.string().trim().min(1).optional(),
  content: z.string().trim().min(1).optional(),
  audience: z.string().trim().min(1).optional(),
  status: announcementStatusEnum.optional(),
  scheduledAt: z.union([z.coerce.date(), z.null()]).optional(),
});

const updateSettingsSchema = z.object({
  name: z.string().trim().min(1).optional(),
  email: z.union([z.string().email(), z.null()]).optional(),
  phone: z.union([z.string().trim().min(3), z.null()]).optional(),
  timezone: z.string().trim().min(1).optional(),
  currencyCode: z.string().trim().length(3).optional(),
});

const decisionSchema = z.object({ reason: z.string().trim().min(1).optional() });

const createFaqSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  question: z.string().trim().min(1),
  answer: z.string().trim().min(1),
  category: z.string().trim().min(1),
  isPublished: z.boolean().optional(),
});

const updateFaqSchema = z.object({
  question: z.string().trim().min(1).optional(),
  answer: z.string().trim().min(1).optional(),
  category: z.string().trim().min(1).optional(),
  isPublished: z.boolean().optional(),
});

async function listAnnouncements(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      status: announcementStatusEnum.optional(),
      search: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["title", "content"]);
    if (query.status) where.status = query.status;

    const [total, items] = await Promise.all([
      prisma.announcement.count({ where }),
      prisma.announcement.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createAnnouncement(req, res, next) {
  try {
    const payload = createAnnouncementSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const announcement = await prisma.announcement.create({
      data: {
        schoolId,
        title: payload.title,
        content: payload.content,
        audience: payload.audience,
        status: payload.status || "DRAFT",
        scheduledAt: payload.scheduledAt,
        createdById: req.user?.sub || null,
      },
    });
    return res.status(201).json({ success: true, data: { announcement } });
  } catch (error) {
    return next(error);
  }
}

async function updateAnnouncement(req, res, next) {
  try {
    const payload = updateAnnouncementSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const announcement = await findScopedOrThrow("announcement", req.params.id, schoolId, "Announcement", "ANNOUNCEMENT_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const updated = await prisma.announcement.update({ where: { id: announcement.id }, data });
    return res.status(200).json({ success: true, data: { announcement: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteAnnouncement(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const announcement = await findScopedOrThrow("announcement", req.params.id, schoolId, "Announcement", "ANNOUNCEMENT_NOT_FOUND");
    await prisma.announcement.delete({ where: { id: announcement.id } });
    return res.status(200).json({ success: true, data: { message: "Announcement deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function sendAnnouncement(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const announcement = await findScopedOrThrow("announcement", req.params.id, schoolId, "Announcement", "ANNOUNCEMENT_NOT_FOUND");
    const updated = await prisma.announcement.update({
      where: { id: announcement.id },
      data: { status: "SENT", sentAt: new Date() },
    });
    return res.status(200).json({ success: true, data: { announcement: updated } });
  } catch (error) {
    return next(error);
  }
}

async function listAuditLogs(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      action: z.string().trim().min(1).optional(),
      entity: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.action) where.action = query.action;
    if (query.entity) where.entity = query.entity;
    const [total, items] = await Promise.all([
      prisma.auditLog.count({ where }),
      prisma.auditLog.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function getSettings(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const school = await ensureSchoolExists(schoolId);
    return res.status(200).json({
      success: true,
      data: {
        settings: {
          schoolId: school.id,
          name: school.name,
          email: school.email,
          phone: school.phone,
          timezone: school.timezone,
          currencyCode: school.currencyCode,
          status: school.status,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSettings(req, res, next) {
  try {
    const payload = updateSettingsSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    await ensureSchoolExists(schoolId);
    const data = asUpdateData(payload);
    if (data.currencyCode) data.currencyCode = data.currencyCode.toUpperCase();
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const school = await prisma.school.update({ where: { id: schoolId }, data });
    return res.status(200).json({
      success: true,
      data: {
        settings: {
          schoolId: school.id,
          name: school.name,
          email: school.email,
          phone: school.phone,
          timezone: school.timezone,
          currencyCode: school.currencyCode,
          status: school.status,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listFaceCheckins(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      status: z.string().trim().min(1).optional(),
      personType: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    if (query.personType) where.personType = query.personType;
    const [total, items] = await Promise.all([
      prisma.faceCheckinLog.count({ where }),
      prisma.faceCheckinLog.findMany({ where, skip, take: limit, orderBy: { capturedAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function approveFaceCheckin(req, res, next) {
  try {
    const payload = decisionSchema.parse(req.body || {});
    const schoolId = scopedSchoolId(req, undefined, true);
    const faceCheckin = await findScopedOrThrow("faceCheckinLog", req.params.id, schoolId, "Face checkin", "FACE_CHECKIN_NOT_FOUND");
    const updated = await prisma.faceCheckinLog.update({
      where: { id: faceCheckin.id },
      data: { status: "APPROVED", reason: payload.reason || null, reviewedById: req.user?.sub || null, reviewedAt: new Date() },
    });
    return res.status(200).json({ success: true, data: { faceCheckin: updated } });
  } catch (error) {
    return next(error);
  }
}

async function rejectFaceCheckin(req, res, next) {
  try {
    const payload = decisionSchema.parse(req.body || {});
    const schoolId = scopedSchoolId(req, undefined, true);
    const faceCheckin = await findScopedOrThrow("faceCheckinLog", req.params.id, schoolId, "Face checkin", "FACE_CHECKIN_NOT_FOUND");
    const updated = await prisma.faceCheckinLog.update({
      where: { id: faceCheckin.id },
      data: { status: "REJECTED", reason: payload.reason || null, reviewedById: req.user?.sub || null, reviewedAt: new Date() },
    });
    return res.status(200).json({ success: true, data: { faceCheckin: updated } });
  } catch (error) {
    return next(error);
  }
}

async function listAiFaqs(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      category: z.string().trim().min(1).optional(),
      search: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["question", "answer"]);
    if (query.category) where.category = query.category;
    const [total, items] = await Promise.all([
      prisma.aiFaq.count({ where }),
      prisma.aiFaq.findMany({ where, skip, take: limit, orderBy: { updatedAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createAiFaq(req, res, next) {
  try {
    const payload = createFaqSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const faq = await prisma.aiFaq.create({
      data: {
        schoolId,
        question: payload.question,
        answer: payload.answer,
        category: payload.category,
        isPublished: payload.isPublished ?? false,
        createdById: req.user?.sub || null,
      },
    });
    return res.status(201).json({ success: true, data: { faq } });
  } catch (error) {
    return next(error);
  }
}

async function updateAiFaq(req, res, next) {
  try {
    const payload = updateFaqSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const faq = await findScopedOrThrow("aiFaq", req.params.id, schoolId, "FAQ", "FAQ_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const updated = await prisma.aiFaq.update({ where: { id: faq.id }, data });
    return res.status(200).json({ success: true, data: { faq: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteAiFaq(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const faq = await findScopedOrThrow("aiFaq", req.params.id, schoolId, "FAQ", "FAQ_NOT_FOUND");
    await prisma.aiFaq.delete({ where: { id: faq.id } });
    return res.status(200).json({ success: true, data: { message: "FAQ deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  sendAnnouncement,
  listAuditLogs,
  getSettings,
  updateSettings,
  listFaceCheckins,
  approveFaceCheckin,
  rejectFaceCheckin,
  listAiFaqs,
  createAiFaq,
  updateAiFaq,
  deleteAiFaq,
};
