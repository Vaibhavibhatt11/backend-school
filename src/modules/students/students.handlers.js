const { z } = require("zod");
const prisma = require("../../lib/prisma");

const studentStatusEnum = z.enum(["ACTIVE", "INACTIVE"]);

const listQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().trim().min(1).optional(),
  status: studentStatusEnum.optional(),
  className: z.string().trim().min(1).optional(),
  section: z.string().trim().min(1).optional(),
  schoolId: z.string().trim().min(1).optional(),
});

const createStudentSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.string().trim().min(1).optional(),
  admissionNo: z.string().trim().min(1),
  firstName: z.string().trim().min(1),
  lastName: z.string().trim().min(1),
  dob: z.preprocess(
    (value) => (value === null || value === "" ? undefined : value),
    z.coerce.date().optional()
  ),
  gender: z.string().trim().min(1).optional(),
  className: z.string().trim().min(1),
  section: z.string().trim().min(1).optional(),
  rollNo: z.coerce.number().int().positive().optional(),
  status: studentStatusEnum.optional(),
  guardianPhone: z.string().trim().min(1).optional(),
});

const updateStudentSchema = z.object({
  classId: z.string().trim().min(1).optional(),
  admissionNo: z.string().trim().min(1).optional(),
  firstName: z.string().trim().min(1).optional(),
  lastName: z.string().trim().min(1).optional(),
  dob: z.preprocess(
    (value) => (value === null || value === "" ? null : value),
    z.union([z.coerce.date(), z.null()]).optional()
  ),
  gender: z.preprocess(
    (value) => (value === "" ? null : value),
    z.union([z.string().trim().min(1), z.null()]).optional()
  ),
  className: z.string().trim().min(1).optional(),
  section: z.preprocess(
    (value) => (value === "" ? null : value),
    z.union([z.string().trim().min(1), z.null()]).optional()
  ),
  rollNo: z.preprocess(
    (value) => (value === "" ? null : value),
    z.union([z.coerce.number().int().positive(), z.null()]).optional()
  ),
  guardianPhone: z.preprocess(
    (value) => (value === "" ? null : value),
    z.union([z.string().trim().min(1), z.null()]).optional()
  ),
});

const statusSchema = z.object({
  status: studentStatusEnum,
});

const createDocumentSchema = z.object({
  name: z.string().trim().min(1),
  url: z.string().trim().min(1),
  type: z.string().trim().min(1).optional(),
  sizeKb: z.coerce.number().int().positive().optional(),
});

function badRequest(message, code = "BAD_REQUEST") {
  const error = new Error(message);
  error.statusCode = 400;
  error.errorCode = code;
  return error;
}

function forbidden(message = "Forbidden") {
  const error = new Error(message);
  error.statusCode = 403;
  error.errorCode = "FORBIDDEN";
  return error;
}

function notFound(message = "Student not found") {
  const error = new Error(message);
  error.statusCode = 404;
  error.errorCode = "STUDENT_NOT_FOUND";
  return error;
}

function getRequestSchoolId(req, schoolIdInput) {
  if (req.user?.role === "SUPERADMIN") {
    return schoolIdInput || null;
  }

  if (!req.user?.schoolId) {
    throw forbidden("School context is missing for current user");
  }

  return req.user.schoolId;
}

function ensureSchoolScopeForList(req, schoolIdInput) {
  const schoolId = getRequestSchoolId(req, schoolIdInput);
  if (!schoolId) {
    throw badRequest(
      "schoolId is required for SUPERADMIN while listing students",
      "SCHOOL_CONTEXT_REQUIRED"
    );
  }
  return schoolId;
}

async function findScopedStudentOrThrow(req, studentId, schoolIdInput) {
  const role = req.user?.role;
  const callerSchoolId = getRequestSchoolId(req, schoolIdInput);

  const student = await prisma.student.findUnique({
    where: { id: studentId },
    include: {
      class: {
        select: { id: true, name: true, section: true },
      },
    },
  });

  if (!student) throw notFound();

  if (role !== "SUPERADMIN" && student.schoolId !== callerSchoolId) {
    throw notFound();
  }

  if (role === "SUPERADMIN" && callerSchoolId && student.schoolId !== callerSchoolId) {
    throw notFound();
  }

  return student;
}

function toStudentDto(student) {
  return {
    id: student.id,
    schoolId: student.schoolId,
    classId: student.classId,
    admissionNo: student.admissionNo,
    firstName: student.firstName,
    lastName: student.lastName,
    dob: student.dob,
    gender: student.gender,
    className: student.className,
    section: student.section,
    rollNo: student.rollNo,
    status: student.status,
    guardianPhone: student.guardianPhone,
    createdAt: student.createdAt,
    updatedAt: student.updatedAt,
    class: student.class || null,
  };
}

async function listStudents(req, res, next) {
  try {
    const query = listQuerySchema.parse(req.query);
    const schoolId = ensureSchoolScopeForList(req, query.schoolId);

    const where = {
      schoolId,
    };

    if (query.status) where.status = query.status;
    if (query.className) where.className = query.className;
    if (query.section) where.section = query.section;
    if (query.search) {
      where.OR = [
        { admissionNo: { contains: query.search, mode: "insensitive" } },
        { firstName: { contains: query.search, mode: "insensitive" } },
        { lastName: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const skip = (query.page - 1) * query.limit;

    const [total, items] = await Promise.all([
      prisma.student.count({ where }),
      prisma.student.findMany({
        where,
        skip,
        take: query.limit,
        orderBy: { createdAt: "desc" },
        include: {
          class: {
            select: { id: true, name: true, section: true },
          },
        },
      }),
    ]);

    const totalPages = Math.max(1, Math.ceil(total / query.limit));

    return res.status(200).json({
      success: true,
      data: {
        items: items.map(toStudentDto),
        pagination: {
          page: query.page,
          limit: query.limit,
          total,
          totalPages,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function createStudent(req, res, next) {
  try {
    const payload = createStudentSchema.parse(req.body);
    const schoolId = getRequestSchoolId(req, payload.schoolId);

    if (!schoolId) {
      throw badRequest(
        "schoolId is required for SUPERADMIN while creating student",
        "SCHOOL_CONTEXT_REQUIRED"
      );
    }

    const created = await prisma.student.create({
      data: {
        schoolId,
        classId: payload.classId,
        admissionNo: payload.admissionNo,
        firstName: payload.firstName,
        lastName: payload.lastName,
        dob: payload.dob,
        gender: payload.gender,
        className: payload.className,
        section: payload.section,
        rollNo: payload.rollNo,
        status: payload.status || "ACTIVE",
        guardianPhone: payload.guardianPhone,
      },
      include: {
        class: {
          select: { id: true, name: true, section: true },
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: { student: toStudentDto(created) },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStudentById(req, res, next) {
  try {
    const schoolId = typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
    const student = await findScopedStudentOrThrow(req, req.params.id, schoolId);

    return res.status(200).json({
      success: true,
      data: { student: toStudentDto(student) },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateStudent(req, res, next) {
  try {
    const payload = updateStudentSchema.parse(req.body);
    const schoolId = typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
    const existing = await findScopedStudentOrThrow(req, req.params.id, schoolId);

    const updateData = Object.fromEntries(
      Object.entries(payload).filter(([, value]) => value !== undefined)
    );

    if (Object.keys(updateData).length === 0) {
      throw badRequest("At least one field is required to update");
    }

    const updated = await prisma.student.update({
      where: { id: existing.id },
      data: updateData,
      include: {
        class: {
          select: { id: true, name: true, section: true },
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: { student: toStudentDto(updated) },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteStudent(req, res, next) {
  try {
    const schoolId = typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
    const existing = await findScopedStudentOrThrow(req, req.params.id, schoolId);

    await prisma.student.delete({
      where: { id: existing.id },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Student deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateStudentStatus(req, res, next) {
  try {
    const payload = statusSchema.parse(req.body);
    const schoolId = typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
    const existing = await findScopedStudentOrThrow(req, req.params.id, schoolId);

    const updated = await prisma.student.update({
      where: { id: existing.id },
      data: { status: payload.status },
      include: {
        class: {
          select: { id: true, name: true, section: true },
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: { student: toStudentDto(updated) },
    });
  } catch (error) {
    return next(error);
  }
}

async function addStudentDocument(req, res, next) {
  try {
    const payload = createDocumentSchema.parse(req.body);
    const schoolId = typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
    const student = await findScopedStudentOrThrow(req, req.params.id, schoolId);

    const document = await prisma.studentDocument.create({
      data: {
        schoolId: student.schoolId,
        studentId: student.id,
        name: payload.name,
        url: payload.url,
        type: payload.type || "OTHER",
        sizeKb: payload.sizeKb || null,
        uploadedById: req.user?.sub || null,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: student.schoolId,
        actorId: req.user?.sub || null,
        action: "STUDENT_DOCUMENT_ADDED",
        entity: "StudentDocument",
        entityId: document.id,
        meta: {
          studentId: document.studentId,
          schoolId: document.schoolId,
          name: document.name,
          type: document.type,
          sizeKb: document.sizeKb,
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: { document },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteStudentDocument(req, res, next) {
  try {
    const schoolId = typeof req.query.schoolId === "string" ? req.query.schoolId : undefined;
    const student = await findScopedStudentOrThrow(req, req.params.id, schoolId);
    const document = await prisma.studentDocument.findUnique({
      where: { id: req.params.docId },
    });

    if (!document || document.studentId !== student.id || document.schoolId !== student.schoolId) {
      throw badRequest("Document not found for this student", "DOCUMENT_NOT_FOUND");
    }

    await prisma.studentDocument.delete({
      where: { id: document.id },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: student.schoolId,
        actorId: req.user?.sub || null,
        action: "STUDENT_DOCUMENT_DELETED",
        entity: "StudentDocument",
        entityId: document.id,
        meta: {
          studentId: student.id,
          schoolId: student.schoolId,
          docId: document.id,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Student document deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listStudents,
  createStudent,
  getStudentById,
  updateStudent,
  deleteStudent,
  updateStudentStatus,
  addStudentDocument,
  deleteStudentDocument,
};
