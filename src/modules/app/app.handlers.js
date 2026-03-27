"use strict";

const prisma = require("../../lib/prisma");
const cache = require("../../lib/cache");
const { badRequest, forbidden, notFound } = require("../../utils/httpErrors");
const { validateId, validateQueryMonth } = require("../student/student.security");

async function resolveAppUser(req) {
  const userId = req.user?.sub;
  if (!userId) throw forbidden("Unauthorized", "UNAUTHORIZED");

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      schoolId: true,
      email: true,
      role: true,
      studentProfile: {
        select: {
          id: true,
          schoolId: true,
          classId: true,
          className: true,
          section: true,
          firstName: true,
          lastName: true,
        },
      },
    },
  });
  if (!user) throw notFound("User not found");
  if (!["STUDENT", "PARENT"].includes(user.role)) {
    throw forbidden("Access denied for this app module", "FORBIDDEN");
  }
  return user;
}

async function resolveParentByEmail(user) {
  if (!user?.email) return null;
  return prisma.parent.findFirst({
    where: { schoolId: user.schoolId, email: user.email },
    include: {
      students: {
        include: {
          student: {
            select: {
              id: true,
              classId: true,
              className: true,
              section: true,
              firstName: true,
              lastName: true,
              status: true,
            },
          },
        },
      },
    },
  });
}

function studentName(st) {
  return `${st?.firstName ?? ""} ${st?.lastName ?? ""}`.trim();
}

async function resolveActingStudent(user, parent, childIdRaw) {
  const studentIds = new Set();
  if (user.studentProfile?.id) studentIds.add(user.studentProfile.id);
  for (const rel of parent?.students ?? []) {
    if (rel.student?.id) studentIds.add(rel.student.id);
  }

  if (studentIds.size === 0) {
    throw forbidden("No linked student context found", "NO_STUDENT_CONTEXT");
  }

  let actingStudentId = null;
  if (childIdRaw != null && String(childIdRaw).trim() !== "") {
    const childId = validateId(String(childIdRaw).trim(), "childId");
    if (!studentIds.has(childId)) {
      throw forbidden("childId is not accessible for this user", "FORBIDDEN");
    }
    actingStudentId = childId;
  } else if (user.studentProfile?.id) {
    actingStudentId = user.studentProfile.id;
  } else {
    actingStudentId = Array.from(studentIds)[0];
  }

  const actingStudent = await prisma.student.findFirst({
    where: { id: actingStudentId, schoolId: user.schoolId },
    select: {
      id: true,
      schoolId: true,
      classId: true,
      className: true,
      section: true,
      firstName: true,
      lastName: true,
      status: true,
    },
  });
  if (!actingStudent) throw notFound("Student not found");

  const children = [];
  if (parent?.students?.length) {
    for (const rel of parent.students) {
      if (!rel.student) continue;
      children.push({
        id: rel.student.id,
        name: studentName(rel.student),
        grade: `${rel.student.className ?? ""}${rel.student.section ? `-${rel.student.section}` : ""}`.trim(),
        active: rel.student.status === "ACTIVE",
      });
    }
  } else if (user.studentProfile) {
    children.push({
      id: user.studentProfile.id,
      name: studentName(user.studentProfile),
      grade: `${user.studentProfile.className ?? ""}${user.studentProfile.section ? `-${user.studentProfile.section}` : ""}`.trim(),
      active: true,
    });
  }

  return { actingStudent, children };
}

async function listChildren(req, res, next) {
  try {
    const user = await resolveAppUser(req);
    const parent = await resolveParentByEmail(user);
    const { children } = await resolveActingStudent(user, parent, null);
    return res.status(200).json({ success: true, data: { children } });
  } catch (e) {
    return next(e);
  }
}

async function dashboard(req, res, next) {
  try {
    const user = await resolveAppUser(req);
    const parent = await resolveParentByEmail(user);
    const { actingStudent, children } = await resolveActingStudent(user, parent, req.query.childId);

    const cacheKey = `app:dashboard:${actingStudent.id}`;
    const ttl = cache.CACHE_TTL.studentDashboard?.() ?? 60;

    const data = await cache.getOrSet(cacheKey, ttl, async () => {
      const [attendanceSummary, upcomingExams, dues, notices] = await Promise.all([
        prisma.studentAttendance.groupBy({
          by: ["status"],
          where: {
            studentId: actingStudent.id,
            date: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
          },
          _count: true,
        }),
        prisma.exam.findMany({
          where: { schoolId: actingStudent.schoolId, isPublished: true, examDate: { gte: new Date() } },
          orderBy: { examDate: "asc" },
          take: 5,
          select: { id: true, name: true, examDate: true, subjectId: true },
        }),
        prisma.invoice.aggregate({
          where: { studentId: actingStudent.id, status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] } },
          _sum: { amountDue: true },
        }),
        prisma.announcement.findMany({
          where: { schoolId: actingStudent.schoolId, status: "SENT" },
          orderBy: { sentAt: "desc" },
          take: 5,
          select: { id: true, title: true, content: true, sentAt: true },
        }),
      ]);

      const attendance = attendanceSummary.reduce(
        (acc, r) => {
          acc[r.status] = r._count;
          return acc;
        },
        { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 }
      );

      return {
        actingStudent: {
          id: actingStudent.id,
          name: studentName(actingStudent),
          className: actingStudent.className,
          section: actingStudent.section,
        },
        children,
        attendanceSummary: attendance,
        upcomingExams,
        pendingDues: dues._sum.amountDue ?? 0,
        announcements: notices,
      };
    });

    return res.status(200).json({ success: true, data });
  } catch (e) {
    return next(e);
  }
}

async function attendance(req, res, next) {
  try {
    const user = await resolveAppUser(req);
    const parent = await resolveParentByEmail(user);
    const { actingStudent } = await resolveActingStudent(user, parent, req.query.childId);

    const month = validateQueryMonth(req.query.month);
    const where = { studentId: actingStudent.id };
    if (month) {
      const [y, m] = month.split("-").map(Number);
      const start = new Date(y, m - 1, 1);
      const end = new Date(y, m, 0, 23, 59, 59);
      where.date = { gte: start, lte: end };
    }

    const items = await prisma.studentAttendance.findMany({
      where,
      orderBy: { date: "desc" },
      take: 100,
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

async function fees(req, res, next) {
  try {
    const user = await resolveAppUser(req);
    const parent = await resolveParentByEmail(user);
    const { actingStudent } = await resolveActingStudent(user, parent, req.query.childId);

    const [invoices, payments] = await Promise.all([
      prisma.invoice.findMany({ where: { studentId: actingStudent.id }, orderBy: { dueDate: "desc" }, take: 50 }),
      prisma.payment.findMany({ where: { studentId: actingStudent.id }, orderBy: { paidAt: "desc" }, take: 20 }),
    ]);
    return res.status(200).json({ success: true, data: { invoices, payments } });
  } catch (e) {
    return next(e);
  }
}

async function announcements(req, res, next) {
  try {
    const user = await resolveAppUser(req);
    const parent = await resolveParentByEmail(user);
    const { actingStudent } = await resolveActingStudent(user, parent, req.query.childId);
    const items = await prisma.announcement.findMany({
      where: { schoolId: actingStudent.schoolId, status: "SENT" },
      orderBy: { sentAt: "desc" },
      take: 50,
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listChildren,
  dashboard,
  attendance,
  fees,
  announcements,
};

