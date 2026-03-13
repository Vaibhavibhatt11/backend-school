"use strict";

const prisma = require("../../lib/prisma");
const { notFound, forbidden } = require("../../utils/httpErrors");
const { parsePagination, getPaginationMeta } = require("../../utils/schoolScope");

async function resolveStudent(req) {
  const userId = req.user?.sub;
  if (!userId) throw forbidden("Unauthorized");
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, role: true, schoolId: true, studentProfile: { select: { id: true, schoolId: true, className: true, section: true, classId: true } } },
  });
  if (!user) throw notFound("User not found");
  if (user.role !== "STUDENT" || !user.studentProfile) throw forbidden("Student profile required");
  return user.studentProfile;
}

async function dashboard(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const [attendanceSummary, upcomingExams, duesCount, announcementsCount] = await Promise.all([
      prisma.studentAttendance.groupBy({
        by: ["status"],
        where: { studentId: student.id, date: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } },
        _count: true,
      }),
      prisma.exam.findMany({
        where: { schoolId: student.schoolId, examDate: { gte: new Date() }, isPublished: false },
        take: 5,
        orderBy: { examDate: "asc" },
        select: { id: true, name: true, examDate: true, subjectId: true },
      }),
      prisma.invoice.count({ where: { studentId: student.id, status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] } } }),
      prisma.announcement.count({ where: { schoolId: student.schoolId, status: "SENT" } }),
    ]);
    return res.status(200).json({
      success: true,
      data: {
        studentId: student.id,
        attendanceSummary: attendanceSummary.reduce((a, b) => ({ ...a, [b.status]: b._count }), {}),
        upcomingExams,
        pendingDuesCount: duesCount,
        announcementsCount,
      },
    });
  } catch (e) {
    return next(e);
  }
}

async function getProfile(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const full = await prisma.student.findUnique({
      where: { id: student.id },
      include: { parents: { include: { parent: true } }, class: true },
    });
    if (!full) throw notFound("Student not found");
    return res.status(200).json({ success: true, data: full });
  } catch (e) {
    return next(e);
  }
}

async function getTimetable(req, res, next) {
  try {
    const student = await resolveStudent(req);
    if (!student.classId) return res.status(200).json({ success: true, data: { slots: [] } });
    const slots = await prisma.liveClassSession.findMany({
      where: { classId: student.classId, startsAt: { gte: new Date() } },
      include: { subject: true },
      orderBy: { startsAt: "asc" },
      take: 50,
    });
    return res.status(200).json({ success: true, data: { slots } });
  } catch (e) {
    return next(e);
  }
}

async function getAttendance(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const where = { studentId: student.id };
    if (req.query.month) {
      const d = new Date(req.query.month);
      const start = new Date(d.getFullYear(), d.getMonth(), 1);
      const end = new Date(d.getFullYear(), d.getMonth() + 1, 0, 23, 59, 59);
      where.date = { gte: start, lte: end };
    }
    const [total, items] = await Promise.all([
      prisma.studentAttendance.count({ where }),
      prisma.studentAttendance.findMany({ where, skip, take: limit, orderBy: { date: "desc" } }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function getHomework(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const where = { schoolId: student.schoolId, isPublished: true };
    if (student.classId) where.OR = [{ classId: null }, { classId: student.classId }];
    const { page, limit, skip } = parsePagination(req.query);
    const [total, items] = await Promise.all([
      prisma.homework.count({ where }),
      prisma.homework.findMany({
        where,
        skip,
        take: limit,
        orderBy: { dueDate: "desc" },
        include: {
          submissions: { where: { studentId: student.id }, take: 1 },
        },
      }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function submitHomework(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const homeworkId = req.params.id;
    const hw = await prisma.homework.findFirst({ where: { id: homeworkId, schoolId: student.schoolId } });
    if (!hw) throw notFound("Homework not found");
    const body = req.body || {};
    const sub = await prisma.homeworkSubmission.upsert({
      where: { homeworkId_studentId: { homeworkId, studentId: student.id } },
      create: {
        homeworkId,
        studentId: student.id,
        url: body.url || null,
        fileUrls: Array.isArray(body.fileUrls) ? body.fileUrls : [],
        status: body.status || "SUBMITTED",
      },
      update: { url: body.url || undefined, fileUrls: Array.isArray(body.fileUrls) ? body.fileUrls : undefined, status: body.status || "SUBMITTED" },
    });
    return res.status(200).json({ success: true, data: sub });
  } catch (e) {
    return next(e);
  }
}

async function getStudyMaterials(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const where = { schoolId: student.schoolId, isPublished: true };
    if (student.classId) where.OR = [{ classId: null }, { classId: student.classId }];
    const items = await prisma.studyMaterial.findMany({ where, orderBy: { createdAt: "desc" } });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

async function getExams(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const where = { schoolId: student.schoolId };
    if (student.classId) where.classId = student.classId;
    const items = await prisma.exam.findMany({
      where,
      orderBy: { examDate: "desc" },
      include: { subject: true },
    });
    const withResults = await Promise.all(
      items.map(async (e) => {
        const r = await prisma.examResult.findUnique({ where: { examId_studentId: { examId: e.id, studentId: student.id } } });
        return { ...e, result: r };
      })
    );
    return res.status(200).json({ success: true, data: { items: withResults } });
  } catch (e) {
    return next(e);
  }
}

async function getFees(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const [invoices, payments, pending] = await Promise.all([
      prisma.invoice.findMany({ where: { studentId: student.id }, orderBy: { dueDate: "desc" }, take: 50 }),
      prisma.payment.findMany({ where: { studentId: student.id }, orderBy: { paidAt: "desc" }, take: 20 }),
      prisma.invoice.aggregate({ where: { studentId: student.id, status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] } }, _sum: { amountDue: true } } ),
    ]);
    return res.status(200).json({ success: true, data: { invoices, payments, pendingDues: pending._sum?.amountDue ?? 0 } });
  } catch (e) {
    return next(e);
  }
}

async function getAnnouncements(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const [total, items] = await Promise.all([
      prisma.announcement.count({ where: { schoolId: student.schoolId, status: "SENT" } }),
      prisma.announcement.findMany({
        where: { schoolId: student.schoolId, status: "SENT" },
        skip,
        take: limit,
        orderBy: { sentAt: "desc" },
      }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function getEvents(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const where = { schoolId: student.schoolId, isPublished: true, startDate: { gte: new Date() } };
    const items = await prisma.event.findMany({ where, orderBy: { startDate: "asc" }, take: 50 });
    const withReg = await Promise.all(
      items.map(async (ev) => {
        const reg = await prisma.eventRegistration.findUnique({
          where: { eventId_studentId: { eventId: ev.id, studentId: student.id } },
        }).catch(() => null);
        return { ...ev, registered: !!reg };
      })
    );
    return res.status(200).json({ success: true, data: { items: withReg } });
  } catch (e) {
    return next(e);
  }
}

async function registerForEvent(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const eventId = req.params.id;
    const event = await prisma.event.findFirst({ where: { id: eventId, schoolId: student.schoolId, isPublished: true } });
    if (!event) throw notFound("Event not found");
    const reg = await prisma.eventRegistration.upsert({
      where: { eventId_studentId: { eventId, studentId: student.id } },
      create: { eventId, schoolId: student.schoolId, studentId: student.id, status: "REGISTERED" },
      update: { status: "REGISTERED" },
    });
    return res.status(200).json({ success: true, data: reg });
  } catch (e) {
    return next(e);
  }
}

async function getTransport(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const allocation = await prisma.transportAllocation.findUnique({
      where: { studentId: student.id },
      include: { route: true },
    });
    return res.status(200).json({ success: true, data: allocation || null });
  } catch (e) {
    return next(e);
  }
}

async function getLibrary(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const borrows = await prisma.libraryBorrow.findMany({
      where: { schoolId: student.schoolId, borrowerType: "STUDENT", borrowerRefId: student.id },
      include: { book: true },
      orderBy: { issuedAt: "desc" },
    });
    return res.status(200).json({ success: true, data: { items: borrows } });
  } catch (e) {
    return next(e);
  }
}

async function getAchievements(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const items = await prisma.studentAchievement.findMany({
      where: { studentId: student.id },
      orderBy: { issuedAt: "desc" },
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  dashboard,
  getProfile,
  getTimetable,
  getAttendance,
  getHomework,
  submitHomework,
  getStudyMaterials,
  getExams,
  getFees,
  getAnnouncements,
  getEvents,
  registerForEvent,
  getTransport,
  getLibrary,
  getAchievements,
};