const { z } = require("zod");

const { badRequest } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  asUpdateData,
} = require("./school.common");

const createExamSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  subjectId: z.union([z.string().trim().min(1), z.null()]).optional(),
  name: z.string().trim().min(1),
  examDate: z.coerce.date(),
  maxMarks: z.coerce.number().positive(),
  status: z.string().trim().min(1).optional(),
  isPublished: z.boolean().optional(),
});

const updateExamSchema = z.object({
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  subjectId: z.union([z.string().trim().min(1), z.null()]).optional(),
  name: z.string().trim().min(1).optional(),
  examDate: z.coerce.date().optional(),
  maxMarks: z.coerce.number().positive().optional(),
  status: z.string().trim().min(1).optional(),
  isPublished: z.boolean().optional(),
});

const saveMarksSchema = z.object({
  results: z.array(
    z.object({
      studentId: z.string().trim().min(1),
      marks: z.coerce.number().min(0),
      grade: z.string().trim().min(1).optional(),
      remarks: z.string().trim().min(1).optional(),
    })
  ).min(1),
});

async function listExams(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      classId: z.string().trim().min(1).optional(),
      subjectId: z.string().trim().min(1).optional(),
      isPublished: z.enum(["true", "false"]).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.classId) where.classId = query.classId;
    if (query.subjectId) where.subjectId = query.subjectId;
    if (query.isPublished) where.isPublished = query.isPublished === "true";

    const [total, items] = await Promise.all([
      prisma.exam.count({ where }),
      prisma.exam.findMany({
        where,
        skip,
        take: limit,
        orderBy: { examDate: "desc" },
        include: {
          classRoom: { select: { id: true, name: true, section: true } },
          subject: { select: { id: true, name: true, code: true } },
          _count: { select: { results: true } },
        },
      }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createExam(req, res, next) {
  try {
    const payload = createExamSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const exam = await prisma.exam.create({
      data: {
        schoolId,
        classId: payload.classId || null,
        subjectId: payload.subjectId || null,
        name: payload.name,
        examDate: payload.examDate,
        maxMarks: payload.maxMarks,
        status: payload.status || "DRAFT",
        isPublished: payload.isPublished ?? false,
      },
    });
    return res.status(201).json({ success: true, data: { exam } });
  } catch (error) {
    return next(error);
  }
}

async function updateExam(req, res, next) {
  try {
    const payload = updateExamSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const exam = await findScopedOrThrow("exam", req.params.id, schoolId, "Exam", "EXAM_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const updated = await prisma.exam.update({ where: { id: exam.id }, data });
    return res.status(200).json({ success: true, data: { exam: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteExam(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const exam = await findScopedOrThrow("exam", req.params.id, schoolId, "Exam", "EXAM_NOT_FOUND");
    await prisma.exam.delete({ where: { id: exam.id } });
    return res.status(200).json({ success: true, data: { message: "Exam deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function saveExamMarks(req, res, next) {
  try {
    const payload = saveMarksSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const exam = await findScopedOrThrow("exam", req.params.id, schoolId, "Exam", "EXAM_NOT_FOUND");

    const operations = payload.results.map((item) =>
      prisma.examResult.upsert({
        where: { examId_studentId: { examId: exam.id, studentId: item.studentId } },
        update: {
          marks: item.marks,
          grade: item.grade,
          remarks: item.remarks,
        },
        create: {
          examId: exam.id,
          studentId: item.studentId,
          marks: item.marks,
          grade: item.grade,
          remarks: item.remarks,
        },
      })
    );

    const results = await prisma.$transaction(operations);
    return res.status(200).json({
      success: true,
      data: { count: results.length, results },
    });
  } catch (error) {
    return next(error);
  }
}

async function publishExam(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const exam = await findScopedOrThrow("exam", req.params.id, schoolId, "Exam", "EXAM_NOT_FOUND");
    const updated = await prisma.exam.update({
      where: { id: exam.id },
      data: { isPublished: true, status: "PUBLISHED" },
    });
    return res.status(200).json({ success: true, data: { exam: updated } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listExams,
  createExam,
  updateExam,
  deleteExam,
  saveExamMarks,
  publishExam,
};
