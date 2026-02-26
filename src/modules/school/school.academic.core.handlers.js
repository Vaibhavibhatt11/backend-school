const { z } = require("zod");

const { badRequest } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  baseSchoolSearch,
  asUpdateData,
  dayStart,
  dayWindow,
} = require("./school.common");

const attendanceStatusEnum = z.enum(["PRESENT", "ABSENT", "LATE", "LEAVE"]);

const createClassSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  section: z.string().trim().min(1),
  classTeacherId: z.union([z.string().trim().min(1), z.null()]).optional(),
  capacity: z.coerce.number().int().positive().optional(),
});

const updateClassSchema = z.object({
  name: z.string().trim().min(1).optional(),
  section: z.string().trim().min(1).optional(),
  classTeacherId: z.union([z.string().trim().min(1), z.null()]).optional(),
  capacity: z.union([z.coerce.number().int().positive(), z.null()]).optional(),
});

const createSubjectSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  code: z.string().trim().min(1),
  isActive: z.boolean().optional(),
});

const updateSubjectSchema = z.object({
  name: z.string().trim().min(1).optional(),
  code: z.string().trim().min(1).optional(),
  isActive: z.boolean().optional(),
});

const markAttendanceSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  type: z.enum(["student", "staff"]),
  studentId: z.string().trim().min(1).optional(),
  staffId: z.string().trim().min(1).optional(),
  date: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
  status: attendanceStatusEnum,
  remark: z.string().trim().min(1).optional(),
});

const bulkMarkAttendanceSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  type: z.enum(["student", "staff"]),
  date: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
  records: z.array(z.object({
    studentId: z.string().trim().min(1).optional(),
    staffId: z.string().trim().min(1).optional(),
    status: attendanceStatusEnum,
    remark: z.string().trim().min(1).optional(),
  })).min(1),
});

async function listClasses(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      search: z.string().trim().min(1).optional(),
      schoolId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name", "section"]);

    const [total, items] = await Promise.all([
      prisma.classRoom.count({ where }),
      prisma.classRoom.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ name: "asc" }, { section: "asc" }],
        include: {
          classTeacher: { select: { id: true, fullName: true, employeeCode: true } },
          _count: { select: { students: true } },
        },
      }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createClass(req, res, next) {
  try {
    const payload = createClassSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    if (payload.classTeacherId) {
      await findScopedOrThrow("staff", payload.classTeacherId, schoolId, "Staff", "STAFF_NOT_FOUND");
    }
    const classRoom = await prisma.classRoom.create({
      data: {
        schoolId,
        name: payload.name,
        section: payload.section,
        classTeacherId: payload.classTeacherId || null,
        capacity: payload.capacity,
      },
      include: { classTeacher: { select: { id: true, fullName: true, employeeCode: true } } },
    });
    return res.status(201).json({ success: true, data: { classRoom } });
  } catch (error) {
    return next(error);
  }
}

async function updateClass(req, res, next) {
  try {
    const payload = updateClassSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const classRoom = await findScopedOrThrow("classRoom", req.params.id, schoolId, "Class", "CLASS_NOT_FOUND");
    if (payload.classTeacherId) {
      await findScopedOrThrow("staff", payload.classTeacherId, schoolId, "Staff", "STAFF_NOT_FOUND");
    }
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const updated = await prisma.classRoom.update({
      where: { id: classRoom.id },
      data,
      include: { classTeacher: { select: { id: true, fullName: true, employeeCode: true } } },
    });
    return res.status(200).json({ success: true, data: { classRoom: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteClass(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const classRoom = await findScopedOrThrow("classRoom", req.params.id, schoolId, "Class", "CLASS_NOT_FOUND");
    await prisma.classRoom.delete({ where: { id: classRoom.id } });
    return res.status(200).json({ success: true, data: { message: "Class deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function listSubjects(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      search: z.string().trim().min(1).optional(),
      schoolId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name", "code"]);

    const [total, items] = await Promise.all([
      prisma.subject.count({ where }),
      prisma.subject.findMany({ where, skip, take: limit, orderBy: { name: "asc" } }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createSubject(req, res, next) {
  try {
    const payload = createSubjectSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const subject = await prisma.subject.create({
      data: {
        schoolId,
        name: payload.name,
        code: payload.code,
        isActive: payload.isActive ?? true,
      },
    });
    return res.status(201).json({ success: true, data: { subject } });
  } catch (error) {
    return next(error);
  }
}

async function updateSubject(req, res, next) {
  try {
    const payload = updateSubjectSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const subject = await findScopedOrThrow("subject", req.params.id, schoolId, "Subject", "SUBJECT_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const updated = await prisma.subject.update({ where: { id: subject.id }, data });
    return res.status(200).json({ success: true, data: { subject: updated } });
  } catch (error) {
    return next(error);
  }
}

async function deleteSubject(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const subject = await findScopedOrThrow("subject", req.params.id, schoolId, "Subject", "SUBJECT_NOT_FOUND");
    await prisma.subject.delete({ where: { id: subject.id } });
    return res.status(200).json({ success: true, data: { message: "Subject deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function attendanceOverview(req, res, next) {
  try {
    const query = z.object({
      schoolId: z.string().trim().min(1).optional(),
      date: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { start, end } = dayWindow(query.date || new Date());

    const [student, staff, totalStudents, totalStaff] = await Promise.all([
      prisma.studentAttendance.groupBy({ by: ["status"], where: { schoolId, date: { gte: start, lt: end } }, _count: { _all: true } }),
      prisma.staffAttendance.groupBy({ by: ["status"], where: { schoolId, date: { gte: start, lt: end } }, _count: { _all: true } }),
      prisma.student.count({ where: { schoolId } }),
      prisma.staff.count({ where: { schoolId } }),
    ]);

    const s = { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
    const t = { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
    for (const item of student) s[item.status] = item._count._all;
    for (const item of staff) t[item.status] = item._count._all;

    return res.status(200).json({
      success: true,
      data: { date: start.toISOString(), students: { total: totalStudents, summary: s }, staff: { total: totalStaff, summary: t } },
    });
  } catch (error) {
    return next(error);
  }
}

async function markAttendance(req, res, next) {
  try {
    const payload = markAttendanceSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const date = dayStart(payload.date || new Date());

    if (payload.type === "student") {
      if (!payload.studentId) throw badRequest("studentId is required");
      await findScopedOrThrow("student", payload.studentId, schoolId, "Student", "STUDENT_NOT_FOUND");
      const attendance = await prisma.studentAttendance.upsert({
        where: { schoolId_studentId_date: { schoolId, studentId: payload.studentId, date } },
        update: { status: payload.status, remark: payload.remark, markedById: req.user?.sub || null },
        create: { schoolId, studentId: payload.studentId, date, status: payload.status, remark: payload.remark, markedById: req.user?.sub || null },
      });
      return res.status(200).json({ success: true, data: { attendance } });
    }

    if (!payload.staffId) throw badRequest("staffId is required");
    await findScopedOrThrow("staff", payload.staffId, schoolId, "Staff", "STAFF_NOT_FOUND");
    const attendance = await prisma.$transaction(async (tx) => {
      const upserted = await tx.staffAttendance.upsert({
        where: { schoolId_staffId_date: { schoolId, staffId: payload.staffId, date } },
        update: { status: payload.status, remark: payload.remark, markedById: req.user?.sub || null },
        create: {
          schoolId,
          staffId: payload.staffId,
          date,
          status: payload.status,
          remark: payload.remark,
          markedById: req.user?.sub || null,
        },
      });

      if (payload.status === "LEAVE") {
        await tx.leaveRequest.upsert({
          where: { attendanceId: upserted.id },
          update: {
            reason: payload.remark || upserted.remark || null,
            date: upserted.date,
            staffId: upserted.staffId,
          },
          create: {
            id: upserted.id,
            schoolId,
            staffId: upserted.staffId,
            attendanceId: upserted.id,
            date: upserted.date,
            reason: payload.remark || null,
            createdById: req.user?.sub || null,
            status: "PENDING",
          },
        });
      } else {
        await tx.leaveRequest.deleteMany({ where: { attendanceId: upserted.id } });
      }

      return upserted;
    });
    return res.status(200).json({ success: true, data: { attendance } });
  } catch (error) {
    return next(error);
  }
}

async function bulkMarkAttendance(req, res, next) {
  try {
    const payload = bulkMarkAttendanceSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const date = dayStart(payload.date || new Date());

    let result = [];
    if (payload.type === "student") {
      const operations = payload.records.map((record) => {
        if (!record.studentId) throw badRequest("studentId is required in records");
        return prisma.studentAttendance.upsert({
          where: { schoolId_studentId_date: { schoolId, studentId: record.studentId, date } },
          update: { status: record.status, remark: record.remark, markedById: req.user?.sub || null },
          create: {
            schoolId,
            studentId: record.studentId,
            date,
            status: record.status,
            remark: record.remark,
            markedById: req.user?.sub || null,
          },
        });
      });
      result = await prisma.$transaction(operations);
    } else {
      result = await prisma.$transaction(async (tx) => {
        const rows = [];
        for (const record of payload.records) {
          if (!record.staffId) throw badRequest("staffId is required in records");
          const attendance = await tx.staffAttendance.upsert({
            where: { schoolId_staffId_date: { schoolId, staffId: record.staffId, date } },
            update: { status: record.status, remark: record.remark, markedById: req.user?.sub || null },
            create: {
              schoolId,
              staffId: record.staffId,
              date,
              status: record.status,
              remark: record.remark,
              markedById: req.user?.sub || null,
            },
          });

          if (record.status === "LEAVE") {
            await tx.leaveRequest.upsert({
              where: { attendanceId: attendance.id },
              update: {
                reason: record.remark || attendance.remark || null,
                date: attendance.date,
                staffId: attendance.staffId,
              },
              create: {
                id: attendance.id,
                schoolId,
                staffId: attendance.staffId,
                attendanceId: attendance.id,
                date: attendance.date,
                reason: record.remark || null,
                createdById: req.user?.sub || null,
                status: "PENDING",
              },
            });
          } else {
            await tx.leaveRequest.deleteMany({ where: { attendanceId: attendance.id } });
          }

          rows.push(attendance);
        }
        return rows;
      });
    }

    return res.status(200).json({ success: true, data: { count: result.length, type: payload.type, date: date.toISOString() } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listClasses,
  createClass,
  updateClass,
  deleteClass,
  listSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
  attendanceOverview,
  markAttendance,
  bulkMarkAttendance,
};
