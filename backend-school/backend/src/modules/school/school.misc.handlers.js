const { z } = require("zod");

const { badRequest, notFound } = require("../../utils/httpErrors");
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
const cache = require("../../lib/cache");
const { CACHE_TTL } = cache;

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
  feeManagement: z.record(z.string(), z.unknown()).optional(),
  examManagement: z.record(z.string(), z.unknown()).optional(),
  timetableManagement: z.record(z.string(), z.unknown()).optional(),
  operationsManagement: z.record(z.string(), z.unknown()).optional(),
  hostelManagement: z.record(z.string(), z.unknown()).optional(),
  eventsWorkbench: z.record(z.string(), z.unknown()).optional(),
  libraryManagement: z.record(z.string(), z.unknown()).optional(),
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
    const preferences =
      school.preferences && typeof school.preferences === "object"
        ? school.preferences
        : {};
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
        ...preferences,
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
    const school = await ensureSchoolExists(schoolId);
    const data = asUpdateData({
      name: payload.name,
      email: payload.email,
      phone: payload.phone,
      timezone: payload.timezone,
      currencyCode: payload.currencyCode,
    });
    if (data.currencyCode) data.currencyCode = data.currencyCode.toUpperCase();
    const nextPreferences = {
      ...(school.preferences && typeof school.preferences === "object"
        ? school.preferences
        : {}),
      ...(payload.feeManagement !== undefined
        ? { feeManagement: payload.feeManagement }
        : {}),
      ...(payload.examManagement !== undefined
        ? { examManagement: payload.examManagement }
        : {}),
      ...(payload.timetableManagement !== undefined
        ? { timetableManagement: payload.timetableManagement }
        : {}),
      ...(payload.operationsManagement !== undefined
        ? { operationsManagement: payload.operationsManagement }
        : {}),
      ...(payload.hostelManagement !== undefined
        ? { hostelManagement: payload.hostelManagement }
        : {}),
      ...(payload.eventsWorkbench !== undefined
        ? { eventsWorkbench: payload.eventsWorkbench }
        : {}),
      ...(payload.libraryManagement !== undefined
        ? { libraryManagement: payload.libraryManagement }
        : {}),
    };
    const hasPrefUpdate =
      payload.feeManagement !== undefined ||
      payload.examManagement !== undefined ||
      payload.timetableManagement !== undefined ||
      payload.operationsManagement !== undefined ||
      payload.hostelManagement !== undefined ||
      payload.eventsWorkbench !== undefined ||
      payload.libraryManagement !== undefined;
    if (!Object.keys(data).length && !hasPrefUpdate) {
      throw badRequest("At least one field is required");
    }
    if (hasPrefUpdate) data.preferences = nextPreferences;

    const updatedSchool = await prisma.school.update({ where: { id: schoolId }, data });
    return res.status(200).json({
      success: true,
      data: {
        settings: {
          schoolId: updatedSchool.id,
          name: updatedSchool.name,
          email: updatedSchool.email,
          phone: updatedSchool.phone,
          timezone: updatedSchool.timezone,
          currencyCode: updatedSchool.currencyCode,
          status: updatedSchool.status,
        },
        ...(updatedSchool.preferences &&
        typeof updatedSchool.preferences === "object"
          ? updatedSchool.preferences
          : {}),
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

// --- School profile (current school) - PDF required ---
async function getSchoolProfile(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const cacheKey = cache.cacheKeys.schoolProfile(schoolId);
    const cached = await cache.get(cacheKey);
    if (cached) return res.status(200).json(cached);

    const school = await ensureSchoolExists(schoolId);
    const payload = {
      success: true,
      data: {
        profile: {
          id: school.id,
          code: school.code,
          name: school.name,
          email: school.email,
          phone: school.phone,
          status: school.status,
          timezone: school.timezone,
          currencyCode: school.currencyCode,
          createdAt: school.createdAt,
          updatedAt: school.updatedAt,
        },
      },
    };
    await cache.set(cacheKey, payload, CACHE_TTL.profile());
    return res.status(200).json(payload);
  } catch (error) {
    return next(error);
  }
}

const updateSchoolProfileSchema = z.object({
  name: z.string().trim().min(1).optional(),
  email: z.union([z.string().email(), z.null()]).optional(),
  phone: z.union([z.string().trim().min(1), z.null()]).optional(),
  timezone: z.string().trim().min(1).optional(),
  currencyCode: z.string().trim().length(3).optional(),
});

async function updateSchoolProfile(req, res, next) {
  try {
    const payload = updateSchoolProfileSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    await ensureSchoolExists(schoolId);
    const data = asUpdateData(payload);
    if (data.currencyCode) data.currencyCode = data.currencyCode.toUpperCase();
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const school = await prisma.school.update({ where: { id: schoolId }, data });
    await cache.del(cache.cacheKeys.schoolProfile(schoolId));
    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "SCHOOL_PROFILE_UPDATED",
        entity: "School",
        entityId: school.id,
        meta: data,
      },
    });
    return res.status(200).json({
      success: true,
      data: {
        profile: {
          id: school.id,
          code: school.code,
          name: school.name,
          email: school.email,
          phone: school.phone,
          status: school.status,
          timezone: school.timezone,
          currencyCode: school.currencyCode,
          updatedAt: school.updatedAt,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

// --- Announcement by id with delivery status ---
async function getAnnouncementById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const announcement = await prisma.announcement.findUnique({
      where: { id: req.params.id },
      include: {
        createdBy: { select: { id: true, fullName: true, email: true } },
        notificationLogs: {
          orderBy: { createdAt: "desc" },
          take: 50,
          select: { id: true, channel: true, status: true, targetType: true, createdAt: true, error: true },
        },
      },
    });
    if (!announcement || announcement.schoolId !== schoolId) throw notFound("Announcement not found", "ANNOUNCEMENT_NOT_FOUND");
    return res.status(200).json({
      success: true,
      data: {
        announcement,
        deliverySummary: {
          total: announcement.notificationLogs.length,
          sent: announcement.notificationLogs.filter((l) => l.status === "sent" || l.status === "SENT").length,
          failed: announcement.notificationLogs.filter((l) => l.status === "failed" || l.status === "FAILED").length,
        },
      },
    });
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
  getAnnouncementById,
  listAuditLogs,
  getSettings,
  updateSettings,
  getSchoolProfile,
  updateSchoolProfile,
  listFaceCheckins,
  approveFaceCheckin,
  rejectFaceCheckin,
  listAiFaqs,
  createAiFaq,
  updateAiFaq,
  deleteAiFaq,
};
