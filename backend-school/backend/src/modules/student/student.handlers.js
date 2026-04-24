"use strict";

const prisma = require("../../lib/prisma");
const cache = require("../../lib/cache");
const { notFound, forbidden } = require("../../utils/httpErrors");
const { parsePagination } = require("../../utils/schoolScope");
const {
  validateId,
  validateLeaveRequest,
  validateHomeworkSubmit,
  validateProfileUpdate,
  validateSettings,
  validateMeetingRequest,
  validateQueryMonth,
  validateSearch,
} = require("./student.security");

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
    const cacheKey = cache.cacheKeys.studentDashboard(student.id);
    const ttl = cache.CACHE_TTL.studentDashboard();
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const [attendanceSummary, upcomingExams, duesCount, announcementsCount] = await Promise.all([
        prisma.studentAttendance.groupBy({
          by: ["status"],
          where: { studentId: student.id, date: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } },
          _count: true,
        }),
        prisma.exam.findMany({
          where: { schoolId: student.schoolId, examDate: { gte: new Date() }, isPublished: true },
          take: 5,
          orderBy: { examDate: "asc" },
          select: { id: true, name: true, examDate: true, subjectId: true },
        }),
        prisma.invoice.count({ where: { studentId: student.id, status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] } } }),
        prisma.announcement.count({ where: { schoolId: student.schoolId, status: "SENT" } }),
      ]);
      return {
        studentId: student.id,
        attendanceSummary: attendanceSummary.reduce((a, b) => ({ ...a, [b.status]: b._count }), {}),
        upcomingExams,
        pendingDuesCount: duesCount,
        announcementsCount,
      };
    });
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

async function getProfile(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const cacheKey = cache.cacheKeys.studentProfile(student.id);
    const ttl = cache.CACHE_TTL.studentDashboard();
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const full = await prisma.student.findUnique({
        where: { id: student.id },
        select: {
          id: true,
          admissionNo: true,
          firstName: true,
          lastName: true,
          dob: true,
          gender: true,
          className: true,
          section: true,
          rollNo: true,
          status: true,
          guardianPhone: true,
          createdAt: true,
          parents: { select: { relationType: true, isPrimary: true, parent: { select: { id: true, fullName: true, email: true, phone: true } } } },
          class: { select: { id: true, name: true, section: true } },
        },
      });
      if (!full) throw notFound("Student not found");
      return full;
    });
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

async function getTimetable(req, res, next) {
  try {
    const student = await resolveStudent(req);
    if (!student.classId) return res.status(200).json({ success: true, data: { slots: [] } });
    const cacheKey = cache.cacheKeys.studentTimetable(student.classId);
    const ttl = cache.CACHE_TTL.studentTimetable?.() ?? cache.CACHE_TTL.studentDashboard?.() ?? 60;
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const slots = await prisma.liveClassSession.findMany({
        where: { classId: student.classId, startsAt: { gte: new Date() } },
        include: { subject: { select: { id: true, name: true } } },
        orderBy: { startsAt: "asc" },
        take: 50,
      });
      return { slots };
    });
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

async function getAttendance(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const where = { studentId: student.id };
    const month = validateQueryMonth(req.query.month);
    if (month) {
      const [y, m] = month.split("-").map(Number);
      const start = new Date(y, m - 1, 1);
      const end = new Date(y, m - 1 + 1, 0, 23, 59, 59);
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
    const homeworkId = validateId(req.params.id, "homeworkId");
    const hw = await prisma.homework.findFirst({ where: { id: homeworkId, schoolId: student.schoolId } });
    if (!hw) throw notFound("Homework not found");
    const body = validateHomeworkSubmit(req.body || {});
    const sub = await prisma.homeworkSubmission.upsert({
      where: { homeworkId_studentId: { homeworkId, studentId: student.id } },
      create: {
        homeworkId,
        studentId: student.id,
        url: body.url ?? null,
        fileUrls: body.fileUrls || [],
        status: body.status || "SUBMITTED",
      },
      update: {
        ...(body.url !== undefined && { url: body.url }),
        ...(body.fileUrls !== undefined && { fileUrls: body.fileUrls }),
        ...(body.status !== undefined && { status: body.status }),
      },
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
    const items = await prisma.studyMaterial.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: 100,
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

async function getExams(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const cacheKey = cache.cacheKeys.studentExams(student.id);
    const ttl = cache.CACHE_TTL.studentExams?.() ?? cache.CACHE_TTL.studentDashboard?.() ?? 120;
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const where = { schoolId: student.schoolId };
      if (student.classId) where.classId = student.classId;
      const items = await prisma.exam.findMany({
        where,
        orderBy: { examDate: "desc" },
        include: { subject: { select: { id: true, name: true } } },
      });
      const examIds = items.map((e) => e.id);
      const results = examIds.length
        ? await prisma.examResult.findMany({
            where: { examId: { in: examIds }, studentId: student.id },
          })
        : [];
      const resultByExam = Object.fromEntries(results.map((r) => [r.examId, r]));
      const withResults = items.map((e) => ({ ...e, result: resultByExam[e.id] ?? null }));
      return { items: withResults };
    });
    return res.status(200).json({ success: true, data: result });
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
    const eventIds = items.map((e) => e.id);
    const registrations =
      eventIds.length > 0
        ? await prisma.eventRegistration.findMany({
            where: { eventId: { in: eventIds }, studentId: student.id },
            select: { eventId: true },
          })
        : [];
    const registeredSet = new Set(registrations.map((r) => r.eventId));
    const withReg = items.map((ev) => ({ ...ev, registered: registeredSet.has(ev.id) }));
    return res.status(200).json({ success: true, data: { items: withReg } });
  } catch (e) {
    return next(e);
  }
}

async function registerForEvent(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const eventId = validateId(req.params.id, "eventId");
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
      include: { book: { select: { id: true, title: true, author: true } } },
      orderBy: { issuedAt: "desc" },
      take: 50,
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
      take: 100,
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

async function updateProfile(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const data = validateProfileUpdate(req.body || {});
    if (Object.keys(data).length === 0) {
      return res.status(200).json({ success: true, data: await prisma.student.findUnique({ where: { id: student.id } }) });
    }
    const updated = await prisma.student.update({ where: { id: student.id }, data });
    if (cache.delByPrefix) cache.delByPrefix(`student:profile:${student.id}`);
    return res.status(200).json({ success: true, data: updated });
  } catch (e) {
    return next(e);
  }
}

async function getHomeworkById(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const id = validateId(req.params.id, "id");
    const where = { id, schoolId: student.schoolId, isPublished: true };
    if (student.classId) where.OR = [{ classId: null }, { classId: student.classId }];
    const hw = await prisma.homework.findFirst({
      where,
      include: { subject: true, submissions: { where: { studentId: student.id }, take: 1 } },
    });
    if (!hw) throw notFound("Homework not found");
    return res.status(200).json({ success: true, data: hw });
  } catch (e) {
    return next(e);
  }
}

async function getExamResultById(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const examId = validateId(req.params.id, "examId");
    const exam = await prisma.exam.findFirst({
      where: { id: examId, schoolId: student.schoolId },
      include: { subject: true },
    });
    if (!exam) throw notFound("Exam not found");
    const result = await prisma.examResult.findUnique({
      where: { examId_studentId: { examId, studentId: student.id } },
    });
    return res.status(200).json({ success: true, data: { exam, result } });
  } catch (e) {
    return next(e);
  }
}

async function getFeesReceipts(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const payments = await prisma.payment.findMany({
      where: { studentId: student.id },
      include: { invoice: true },
      orderBy: { paidAt: "desc" },
    });
    return res.status(200).json({ success: true, data: { items: payments } });
  } catch (e) {
    return next(e);
  }
}

async function getPaymentReceipt(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const id = validateId(req.params.id, "paymentId");
    const payment = await prisma.payment.findFirst({
      where: { id, studentId: student.id },
      include: { invoice: true, collectedBy: { select: { fullName: true } } },
    });
    if (!payment) throw notFound("Receipt not found");
    return res.status(200).json({ success: true, data: payment });
  } catch (e) {
    return next(e);
  }
}

async function getNotifications(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const where = { schoolId: student.schoolId, status: "SENT" };
    const [total, items] = await Promise.all([
      prisma.announcement.count({ where }),
      prisma.announcement.findMany({
        where,
        skip,
        take: limit,
        orderBy: { sentAt: "desc" },
        select: { id: true, title: true, content: true, sentAt: true, audience: true },
      }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function getCirculars(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const where = { schoolId: student.schoolId, status: "SENT" };
    if (req.query.type) where.audience = req.query.type;
    const [total, items] = await Promise.all([
      prisma.announcement.count({ where }),
      prisma.announcement.findMany({ where, skip, take: limit, orderBy: { sentAt: "desc" } }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function getHealth(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const s = await prisma.student.findUnique({
      where: { id: student.id },
      select: { medicalInfo: true },
    });
    return res.status(200).json({ success: true, data: { medicalInfo: s?.medicalInfo ?? null } });
  } catch (e) {
    return next(e);
  }
}

async function getSettings(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const s = await prisma.studentSettings.findUnique({ where: { studentId: student.id } });
    return res.status(200).json({
      success: true,
      data: s?.preferences ?? { notifications: true, language: "en", privacy: {} },
    });
  } catch (e) {
    return next(e);
  }
}

async function updateSettings(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const prefs = validateSettings(req.body || {});
    const rec = await prisma.studentSettings.upsert({
      where: { studentId: student.id },
      create: { schoolId: student.schoolId, studentId: student.id, preferences: prefs },
      update: { preferences: prefs },
    });
    return res.status(200).json({ success: true, data: rec.preferences });
  } catch (e) {
    return next(e);
  }
}

async function getLeaveRequests(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const where = { studentId: student.id };
    const [total, items] = await Promise.all([
      prisma.studentLeaveRequest.count({ where }),
      prisma.studentLeaveRequest.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function createLeaveRequest(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { fromDate, toDate, reason } = validateLeaveRequest(req.body || {});
    const rec = await prisma.studentLeaveRequest.create({
      data: {
        schoolId: student.schoolId,
        studentId: student.id,
        fromDate,
        toDate,
        reason,
      },
    });
    return res.status(201).json({ success: true, data: rec });
  } catch (e) {
    return next(e);
  }
}

async function getSubjectTeachers(req, res, next) {
  try {
    const student = await resolveStudent(req);
    if (!student.classId) return res.status(200).json({ success: true, data: { items: [] } });
    const classData = await prisma.classRoom.findUnique({
      where: { id: student.classId },
      include: { subjectMappings: { include: { subject: true } } },
    });
    if (!classData?.subjectMappings?.length) return res.status(200).json({ success: true, data: { items: [] } });
    const teacherIds = [...new Set(classData.subjectMappings.map((s) => s.teacherId).filter(Boolean))];
    const teachers = await prisma.staff.findMany({
      where: { id: { in: teacherIds }, schoolId: student.schoolId },
      select: { id: true, fullName: true, email: true, phone: true, designation: true },
    });
    const bySubject = classData.subjectMappings
      .filter((s) => s.teacherId)
      .map((s) => ({
        subject: s.subject?.name,
        teacher: teachers.find((t) => t.id === s.teacherId),
      }));
    return res.status(200).json({ success: true, data: { items: bySubject } });
  } catch (e) {
    return next(e);
  }
}

async function getExamTimetable(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const where = { schoolId: student.schoolId };
    if (student.classId) where.classId = student.classId;
    const items = await prisma.exam.findMany({
      where,
      include: { subject: true },
      orderBy: { examDate: "asc" },
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

async function createMeetingRequest(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { staffId, preferredDate, purpose } = validateMeetingRequest(req.body || {});
    const rec = await prisma.meetingRequest.create({
      data: {
        schoolId: student.schoolId,
        studentId: student.id,
        staffId,
        preferredDate,
        purpose,
      },
    });
    return res.status(201).json({ success: true, data: rec });
  } catch (e) {
    return next(e);
  }
}

async function getLibraryBooks(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const { page, limit, skip } = parsePagination(req.query);
    const where = { schoolId: student.schoolId, isActive: true };
    const search = validateSearch(req.query.search);
    if (search) where.title = { contains: search, mode: "insensitive" };
    if (req.query.category != null && req.query.category !== "") {
      where.category = String(req.query.category).trim().slice(0, 100);
    }
    const [total, items] = await Promise.all([
      prisma.libraryBook.count({ where }),
      prisma.libraryBook.findMany({ where, skip, take: limit, orderBy: { title: "asc" } }),
    ]);
    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({ success: true, data: { items, pagination: { page, limit, total, totalPages } } });
  } catch (e) {
    return next(e);
  }
}

async function getReportCards(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const results = await prisma.examResult.findMany({
      where: { studentId: student.id },
      include: { exam: { include: { subject: { select: { id: true, name: true } } } } },
      orderBy: { createdAt: "desc" },
      take: 100,
    });
    return res.status(200).json({ success: true, data: { items: results } });
  } catch (e) {
    return next(e);
  }
}

async function getDocuments(req, res, next) {
  try {
    const student = await resolveStudent(req);
    const items = await prisma.studentDocument.findMany({
      where: { studentId: student.id },
      orderBy: { createdAt: "desc" },
      take: 100,
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  dashboard,
  getProfile,
  updateProfile,
  getTimetable,
  getAttendance,
  getHomework,
  getHomeworkById,
  submitHomework,
  getStudyMaterials,
  getExams,
  getExamResultById,
  getExamTimetable,
  getFees,
  getFeesReceipts,
  getPaymentReceipt,
  getAnnouncements,
  getEvents,
  registerForEvent,
  getTransport,
  getLibrary,
  getLibraryBooks,
  getAchievements,
  getNotifications,
  getCirculars,
  getHealth,
  getSettings,
  updateSettings,
  getLeaveRequests,
  createLeaveRequest,
  getSubjectTeachers,
  createMeetingRequest,
  getReportCards,
  getDocuments,
};