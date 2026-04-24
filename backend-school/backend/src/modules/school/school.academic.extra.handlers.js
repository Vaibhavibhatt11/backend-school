const { z } = require("zod");
const { badRequest, notFound } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  asUpdateData,
} = require("./school.common");

const createSyllabusSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.string().trim().min(1).optional(),
  subjectId: z.string().trim().min(1).optional(),
  topic: z.string().trim().min(1),
  progress: z.coerce.number().min(0).max(100).optional(),
  status: z.string().optional(),
});

const updateSyllabusSchema = z.object({
  topic: z.string().trim().min(1).optional(),
  progress: z.coerce.number().min(0).max(100).optional(),
  status: z.string().optional(),
});

const createLessonPlanSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  subjectId: z.string().trim().min(1).optional(),
  syllabusId: z.string().trim().min(1).optional(),
  title: z.string().trim().min(1),
  date: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date()),
  duration: z.coerce.number().int().positive().optional(),
  notes: z.string().optional(),
});

async function listSyllabus(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      classId: z.string().trim().min(1).optional(),
      subjectId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = {
      schoolId,
      ...(query.classId && { classId: query.classId }),
      ...(query.subjectId && { subjectId: query.subjectId }),
    };

    const [total, items] = await Promise.all([
      prisma.syllabus.count({ where }),
      prisma.syllabus.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          classRoom: { select: { id: true, name: true, section: true } },
          subject: { select: { id: true, name: true, code: true } },
        },
      }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createSyllabus(req, res, next) {
  try {
    const payload = createSyllabusSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const syllabus = await prisma.syllabus.create({
      data: {
        schoolId,
        classId: payload.classId || null,
        subjectId: payload.subjectId || null,
        topic: payload.topic,
        progress: payload.progress ?? 0,
        status: payload.status || "IN_PROGRESS",
      },
    });
    return res.status(201).json({ success: true, data: { syllabus } });
  } catch (error) {
    return next(error);
  }
}

async function updateSyllabus(req, res, next) {
  try {
    const payload = updateSyllabusSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const syllabus = await findScopedOrThrow("syllabus", req.params.id, schoolId, "Syllabus", "SYLLABUS_NOT_FOUND");
    const data = asUpdateData(payload);
    const updated = await prisma.syllabus.update({ where: { id: syllabus.id }, data });
    return res.status(200).json({ success: true, data: { syllabus: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteSyllabus(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const syllabus = await findScopedOrThrow("syllabus", req.params.id, schoolId, "Syllabus", "SYLLABUS_NOT_FOUND");
    await prisma.syllabus.delete({ where: { id: syllabus.id } });
    return res.status(200).json({ success: true, data: { message: "Syllabus deleted" } });
  } catch (error) {
    return next(error);
  }
}

async function listLessonPlans(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      subjectId: z.string().trim().min(1).optional(),
      syllabusId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = {
      schoolId,
      ...(query.subjectId && { subjectId: query.subjectId }),
      ...(query.syllabusId && { syllabusId: query.syllabusId }),
    };

    const [total, items] = await Promise.all([
      prisma.lessonPlan.count({ where }),
      prisma.lessonPlan.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: "desc" },
        include: {
          subject: { select: { id: true, name: true } },
          syllabus: { select: { id: true, topic: true } },
        },
      }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createLessonPlan(req, res, next) {
  try {
    const payload = createLessonPlanSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const lessonPlan = await prisma.lessonPlan.create({
      data: {
        schoolId,
        subjectId: payload.subjectId || null,
        syllabusId: payload.syllabusId || null,
        title: payload.title,
        date: payload.date,
        duration: payload.duration ?? 45,
        notes: payload.notes,
      },
    });
    return res.status(201).json({ success: true, data: { lessonPlan } });
  } catch (error) {
    return next(error);
  }
}

async function updateLessonPlan(req, res, next) {
  try {
    const payload = z.object({
      title: z.string().trim().min(1).optional(),
      date: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      duration: z.coerce.number().int().positive().optional(),
      notes: z.string().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const lessonPlan = await findScopedOrThrow("lessonPlan", req.params.id, schoolId, "LessonPlan", "LESSON_PLAN_NOT_FOUND");
    const data = asUpdateData(payload);
    const updated = await prisma.lessonPlan.update({ where: { id: lessonPlan.id }, data });
    return res.status(200).json({ success: true, data: { lessonPlan: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteLessonPlan(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const lessonPlan = await findScopedOrThrow("lessonPlan", req.params.id, schoolId, "LessonPlan", "LESSON_PLAN_NOT_FOUND");
    await prisma.lessonPlan.delete({ where: { id: lessonPlan.id } });
    return res.status(200).json({ success: true, data: { message: "Lesson plan deleted" } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listSyllabus,
  createSyllabus,
  updateSyllabus,
  deleteSyllabus,
  listLessonPlans,
  createLessonPlan,
  updateLessonPlan,
  deleteLessonPlan,
};
