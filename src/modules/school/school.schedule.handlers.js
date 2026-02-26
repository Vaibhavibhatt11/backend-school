const { z } = require("zod");

const { badRequest } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  findScopedOrThrow,
  asUpdateData,
  paginationFromQuery,
  paginated,
} = require("./school.common");

const createSlotSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  subjectId: z.union([z.string().trim().min(1), z.null()]).optional(),
  teacherId: z.union([z.string().trim().min(1), z.null()]).optional(),
  title: z.string().trim().min(1),
  platform: z.string().trim().min(1).optional(),
  joinUrl: z.string().trim().min(1).optional(),
  startsAt: z.coerce.date(),
  endsAt: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
});

const updateSlotSchema = z.object({
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  subjectId: z.union([z.string().trim().min(1), z.null()]).optional(),
  teacherId: z.union([z.string().trim().min(1), z.null()]).optional(),
  title: z.string().trim().min(1).optional(),
  platform: z.union([z.string().trim().min(1), z.null()]).optional(),
  joinUrl: z.union([z.string().trim().min(1), z.null()]).optional(),
  startsAt: z.coerce.date().optional(),
  endsAt: z.union([z.coerce.date(), z.null()]).optional(),
  status: z.string().trim().min(1).optional(),
});

const createLiveSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  subjectId: z.union([z.string().trim().min(1), z.null()]).optional(),
  teacherId: z.union([z.string().trim().min(1), z.null()]).optional(),
  title: z.string().trim().min(1),
  platform: z.string().trim().min(1).optional(),
  joinUrl: z.string().trim().min(1).optional(),
  startsAt: z.coerce.date(),
  endsAt: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
  status: z.string().trim().min(1).optional(),
});

const updateLiveSchema = z.object({
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  subjectId: z.union([z.string().trim().min(1), z.null()]).optional(),
  teacherId: z.union([z.string().trim().min(1), z.null()]).optional(),
  title: z.string().trim().min(1).optional(),
  platform: z.union([z.string().trim().min(1), z.null()]).optional(),
  joinUrl: z.union([z.string().trim().min(1), z.null()]).optional(),
  startsAt: z.coerce.date().optional(),
  endsAt: z.union([z.coerce.date(), z.null()]).optional(),
  status: z.string().trim().min(1).optional(),
});

async function getTimetable(req, res, next) {
  try {
    const query = z.object({
      schoolId: z.string().trim().min(1).optional(),
      classId: z.string().trim().min(1).optional(),
      dateFrom: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      dateTo: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const where = { schoolId };
    if (query.classId) where.classId = query.classId;
    if (query.dateFrom || query.dateTo) {
      where.startsAt = {};
      if (query.dateFrom) where.startsAt.gte = query.dateFrom;
      if (query.dateTo) where.startsAt.lte = query.dateTo;
    }

    const items = await prisma.liveClassSession.findMany({
      where,
      orderBy: { startsAt: "asc" },
      include: {
        classRoom: { select: { id: true, name: true, section: true } },
        subject: { select: { id: true, name: true, code: true } },
        teacher: { select: { id: true, fullName: true, employeeCode: true } },
      },
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (error) {
    return next(error);
  }
}

async function createTimetableSlot(req, res, next) {
  try {
    const payload = createSlotSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const slot = await prisma.liveClassSession.create({
      data: {
        schoolId,
        classId: payload.classId || null,
        subjectId: payload.subjectId || null,
        teacherId: payload.teacherId || null,
        title: payload.title,
        platform: payload.platform,
        joinUrl: payload.joinUrl,
        startsAt: payload.startsAt,
        endsAt: payload.endsAt || null,
        status: "TIMETABLE",
      },
    });
    return res.status(201).json({ success: true, data: { slot } });
  } catch (error) {
    return next(error);
  }
}

async function updateTimetableSlot(req, res, next) {
  try {
    const payload = updateSlotSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const slot = await findScopedOrThrow("liveClassSession", req.params.id, schoolId, "Timetable slot", "TIMETABLE_SLOT_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const updated = await prisma.liveClassSession.update({ where: { id: slot.id }, data });
    return res.status(200).json({ success: true, data: { slot: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteTimetableSlot(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const slot = await findScopedOrThrow("liveClassSession", req.params.id, schoolId, "Timetable slot", "TIMETABLE_SLOT_NOT_FOUND");
    await prisma.liveClassSession.delete({ where: { id: slot.id } });
    return res.status(200).json({ success: true, data: { message: "Timetable slot deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function publishTimetable(req, res, next) {
  try {
    const payload = z.object({
      schoolId: z.string().trim().min(1).optional(),
      classId: z.string().trim().min(1).optional(),
      dateFrom: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      dateTo: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
    }).parse(req.body || {});
    const schoolId = scopedSchoolId(req, payload.schoolId, true);

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "TIMETABLE_PUBLISHED",
        entity: "Timetable",
        meta: {
          classId: payload.classId || null,
          dateFrom: payload.dateFrom ? payload.dateFrom.toISOString() : null,
          dateTo: payload.dateTo ? payload.dateTo.toISOString() : null,
        },
      },
    });

    return res.status(200).json({ success: true, data: { message: "Timetable published successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function listLiveClassSessions(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      status: z.string().trim().min(1).optional(),
      classId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    if (query.classId) where.classId = query.classId;

    const [total, items] = await Promise.all([
      prisma.liveClassSession.count({ where }),
      prisma.liveClassSession.findMany({
        where,
        skip,
        take: limit,
        orderBy: { startsAt: "desc" },
        include: {
          classRoom: { select: { id: true, name: true, section: true } },
          subject: { select: { id: true, name: true, code: true } },
          teacher: { select: { id: true, fullName: true, employeeCode: true } },
        },
      }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createLiveClassSession(req, res, next) {
  try {
    const payload = createLiveSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const session = await prisma.liveClassSession.create({
      data: {
        schoolId,
        classId: payload.classId || null,
        subjectId: payload.subjectId || null,
        teacherId: payload.teacherId || null,
        title: payload.title,
        platform: payload.platform,
        joinUrl: payload.joinUrl,
        startsAt: payload.startsAt,
        endsAt: payload.endsAt || null,
        status: payload.status || "UPCOMING",
      },
    });
    return res.status(201).json({ success: true, data: { session } });
  } catch (error) {
    return next(error);
  }
}

async function updateLiveClassSession(req, res, next) {
  try {
    const payload = updateLiveSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const session = await findScopedOrThrow("liveClassSession", req.params.id, schoolId, "Live class session", "LIVE_CLASS_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const updated = await prisma.liveClassSession.update({ where: { id: session.id }, data });
    return res.status(200).json({ success: true, data: { session: updated } });
  } catch (error) {
    return next(error);
  }
}

async function endLiveClassSession(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const session = await findScopedOrThrow("liveClassSession", req.params.id, schoolId, "Live class session", "LIVE_CLASS_NOT_FOUND");
    const updated = await prisma.liveClassSession.update({
      where: { id: session.id },
      data: { status: "ENDED", endsAt: new Date() },
    });
    return res.status(200).json({ success: true, data: { session: updated } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getTimetable,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
  publishTimetable,
  listLiveClassSessions,
  createLiveClassSession,
  updateLiveClassSession,
  endLiveClassSession,
};
