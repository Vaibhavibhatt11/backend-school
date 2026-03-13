"use strict";

const { z } = require("zod");
const { prisma, scopedSchoolId, findScopedOrThrow, paginationFromQuery, paginated } = require("./school.common");

async function listHomework(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const where = { schoolId };
    if (req.query.classId) where.classId = req.query.classId;
    if (req.query.subjectId) where.subjectId = req.query.subjectId;
    if (req.query.dueFrom) where.dueDate = { gte: new Date(req.query.dueFrom) };
    if (req.query.dueTo) where.dueDate = { ...(where.dueDate || {}), lte: new Date(req.query.dueTo) };
    const [total, items] = await Promise.all([
      prisma.homework.count({ where }),
      prisma.homework.findMany({
        where,
        skip,
        take: limit,
        orderBy: { dueDate: "desc" },
        include: { _count: { select: { submissions: true } } },
      }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function getHomeworkById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const hw = await findScopedOrThrow("homework", req.params.id, schoolId, "Homework", "NOT_FOUND");
    const withSubs = await prisma.homework.findUnique({
      where: { id: hw.id },
      include: { submissions: true },
    });
    return res.status(200).json({ success: true, data: withSubs });
  } catch (e) {
    return next(e);
  }
}

async function createHomework(req, res, next) {
  try {
    const body = z.object({
      schoolId: z.string().optional(),
      classId: z.string().optional(),
      subjectId: z.string().optional(),
      title: z.string().trim().min(1),
      description: z.string().optional(),
      dueDate: z.coerce.date(),
      createdById: z.string().optional(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const hw = await prisma.homework.create({
      data: {
        schoolId,
        classId: body.classId || null,
        subjectId: body.subjectId || null,
        title: body.title,
        description: body.description || null,
        dueDate: body.dueDate,
        createdById: body.createdById || req.user?.sub || null,
        isPublished: body.isPublished !== false,
      },
    });
    return res.status(201).json({ success: true, data: hw });
  } catch (e) {
    return next(e);
  }
}

async function updateHomework(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("homework", req.params.id, schoolId, "Homework", "NOT_FOUND");
    const body = z.object({
      title: z.string().optional(),
      description: z.string().optional(),
      dueDate: z.coerce.date().optional(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    const hw = await prisma.homework.update({ where: { id: req.params.id }, data: body });
    return res.status(200).json({ success: true, data: hw });
  } catch (e) {
    return next(e);
  }
}

async function deleteHomework(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("homework", req.params.id, schoolId, "Homework", "NOT_FOUND");
    await prisma.homework.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

async function submitHomework(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const hw = await findScopedOrThrow("homework", req.params.id, schoolId, "Homework", "NOT_FOUND");
    const body = z.object({
      studentId: z.string().trim().min(1),
      url: z.string().optional(),
      fileUrls: z.array(z.string()).default([]),
      status: z.string().default("SUBMITTED"),
    }).parse(req.body);
    const sub = await prisma.homeworkSubmission.upsert({
      where: {
        homeworkId_studentId: { homeworkId: hw.id, studentId: body.studentId },
      },
      create: {
        homeworkId: hw.id,
        studentId: body.studentId,
        url: body.url || null,
        fileUrls: body.fileUrls || [],
        status: body.status,
      },
      update: { url: body.url || undefined, fileUrls: body.fileUrls || undefined, status: body.status },
    });
    return res.status(200).json({ success: true, data: sub });
  } catch (e) {
    return next(e);
  }
}

// ----- Study materials -----
async function listStudyMaterials(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const where = { schoolId };
    if (req.query.classId) where.classId = req.query.classId;
    if (req.query.subjectId) where.subjectId = req.query.subjectId;
    const [total, items] = await Promise.all([
      prisma.studyMaterial.count({ where }),
      prisma.studyMaterial.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function createStudyMaterial(req, res, next) {
  try {
    const body = z.object({
      schoolId: z.string().optional(),
      classId: z.string().optional(),
      subjectId: z.string().optional(),
      title: z.string().trim().min(1),
      description: z.string().optional(),
      url: z.string().trim().min(1),
      type: z.string().default("PDF"),
      chapter: z.string().optional(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const mat = await prisma.studyMaterial.create({
      data: {
        schoolId,
        classId: body.classId || null,
        subjectId: body.subjectId || null,
        title: body.title,
        description: body.description || null,
        url: body.url,
        type: body.type,
        chapter: body.chapter || null,
        isPublished: body.isPublished !== false,
      },
    });
    return res.status(201).json({ success: true, data: mat });
  } catch (e) {
    return next(e);
  }
}

async function updateStudyMaterial(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("studyMaterial", req.params.id, schoolId, "Study material", "NOT_FOUND");
    const body = z.object({
      title: z.string().optional(),
      description: z.string().optional(),
      url: z.string().optional(),
      type: z.string().optional(),
      chapter: z.string().optional(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    const mat = await prisma.studyMaterial.update({ where: { id: req.params.id }, data: body });
    return res.status(200).json({ success: true, data: mat });
  } catch (e) {
    return next(e);
  }
}

async function deleteStudyMaterial(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("studyMaterial", req.params.id, schoolId, "Study material", "NOT_FOUND");
    await prisma.studyMaterial.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

// ----- Student achievements -----
async function listAchievements(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const where = { schoolId };
    if (req.query.studentId) where.studentId = req.query.studentId;
    const { page, limit, skip } = paginationFromQuery(req.query);
    const [total, items] = await Promise.all([
      prisma.studentAchievement.count({ where }),
      prisma.studentAchievement.findMany({ where, skip, take: limit, orderBy: { issuedAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function createAchievement(req, res, next) {
  try {
    const body = z.object({
      schoolId: z.string().optional(),
      studentId: z.string().trim().min(1),
      title: z.string().trim().min(1),
      description: z.string().optional(),
      type: z.string().default("CERTIFICATE"),
      url: z.string().optional(),
      issuedAt: z.coerce.date().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const ach = await prisma.studentAchievement.create({
      data: {
        schoolId,
        studentId: body.studentId,
        title: body.title,
        description: body.description || null,
        type: body.type,
        url: body.url || null,
        issuedAt: body.issuedAt || new Date(),
      },
    });
    return res.status(201).json({ success: true, data: ach });
  } catch (e) {
    return next(e);
  }
}

async function deleteAchievement(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("studentAchievement", req.params.id, schoolId, "Achievement", "NOT_FOUND");
    await prisma.studentAchievement.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listHomework,
  getHomeworkById,
  createHomework,
  updateHomework,
  deleteHomework,
  submitHomework,
  listStudyMaterials,
  createStudyMaterial,
  updateStudyMaterial,
  deleteStudyMaterial,
  listAchievements,
  createAchievement,
  deleteAchievement,
};
