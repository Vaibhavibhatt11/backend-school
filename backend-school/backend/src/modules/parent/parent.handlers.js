"use strict";

const { z } = require("zod");
const crypto = require("crypto");

const prisma = require("../../lib/prisma");
const cache = require("../../lib/cache");
const { forbidden, notFound } = require("../../utils/httpErrors");
const { parsePagination } = require("../../utils/schoolScope");
const {
  validateId,
  validateQueryMonth,
  validateSearch,
  parseDayQuery,
  validateSettingsBody,
} = require("./parent.security");

function computeInvoiceStatus(amountDue, amountPaid, dueDate) {
  const due = Number(amountDue ?? 0);
  const paid = Number(amountPaid ?? 0);

  if (paid >= due && due > 0) return "PAID";

  const dueTs = dueDate ? new Date(dueDate).getTime() : NaN;
  const overdue = Number.isFinite(dueTs) ? Date.now() > dueTs : false;

  if (paid > 0 && overdue) return "OVERDUE";
  if (paid > 0) return "PARTIAL";
  return "ISSUED";
}

const paymentMethodEnum = z.enum(["CASH", "CARD", "UPI", "BANK_TRANSFER", "ONLINE"]);
const payInvoiceBalanceSchema = z.object({
  method: paymentMethodEnum.optional().default("ONLINE"),
  amount: z.coerce.number().positive().optional(),
  transactionRef: z.string().trim().min(1).optional(),
  notes: z.string().trim().min(1).optional(),
});

const updateProfileHubSchema = z
  .object({
    studentName: z.string().trim().min(1).max(100).optional(),
    dob: z.string().trim().min(1).optional(),
    bloodGroup: z.string().trim().max(20).optional(),
    fatherName: z.string().trim().max(100).optional(),
    motherName: z.string().trim().max(100).optional(),
  })
  .refine((v) => Object.keys(v).length > 0, {
    message: "At least one field is required",
  });

const createMeetingRequestSchema = z.object({
  staffId: z.string().trim().min(1).optional(),
  staffName: z.string().trim().min(1).max(120).optional(),
  teacher: z.string().trim().min(1).max(120).optional(),
  preferredDate: z.coerce.date().optional(),
  timeSlot: z.string().trim().min(1).max(60).optional(),
  purpose: z.string().trim().max(500).optional(),
});

const createLeaveRequestSchema = z.object({
  fromDate: z.coerce.date(),
  toDate: z.coerce.date(),
  reason: z.string().trim().min(1).max(500),
});

const createParentMessageSchema = z
  .object({
    staffId: z.string().trim().min(1).optional(),
    staffName: z.string().trim().min(1).max(120).optional(),
    teacher: z.string().trim().min(1).max(120).optional(),
    subject: z.string().trim().min(1).max(200).optional(),
    message: z.string().trim().min(1).max(2000),
  })
  .refine((value) => !!(value.staffId || value.staffName || value.teacher), {
    message: "Teacher or staff is required",
  });

function isMissingTableError(error, tableName) {
  const message = String(error?.message || "").toLowerCase();
  const t = String(tableName || "").toLowerCase();
  return error?.code === "P2021" || (t && message.includes(t));
}

function isClientError(error) {
  return !!(error?.statusCode && error.statusCode >= 400 && error.statusCode < 500);
}

async function resolveParent(req) {
  const userId = req.user?.sub;
  if (!userId) throw forbidden("Unauthorized", "UNAUTHORIZED");

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, role: true, schoolId: true, email: true },
  });
  if (!user || user.role !== "PARENT") throw forbidden("Access denied", "FORBIDDEN");

  // Invite flow creates a `Parent` record (email) and a `User` can be created separately.
  const parent = await prisma.parent.findFirst({
    where: { schoolId: user.schoolId, email: user.email },
    include: { students: { include: { student: { select: { id: true } } } } },
  });
  if (!parent) throw forbidden("Parent profile not found", "PARENT_NOT_FOUND");

  return { user, parent };
}

async function resolveChildForParent(parentId, studentId) {
  // Ensure the student is actually linked to this parent (prevents IDOR).
  const rel = await prisma.studentParent.findFirst({
    where: { studentId, parentId },
    include: {
      student: {
        select: {
          id: true,
          admissionNo: true,
          firstName: true,
          lastName: true,
          dob: true,
          gender: true,
          classId: true,
          className: true,
          section: true,
          rollNo: true,
          status: true,
          guardianPhone: true,
          medicalInfo: true,
          schoolId: true,
          parents: {
            select: {
              relationType: true,
              isPrimary: true,
              parent: { select: { id: true, fullName: true, email: true, phone: true } },
            },
          },
          class: {
            select: {
              id: true,
              name: true,
              section: true,
              classTeacherId: true,
              classTeacher: {
                select: {
                  id: true,
                  fullName: true,
                  designation: true,
                  department: true,
                },
              },
            },
          },
        },
      },
    },
  });

  if (!rel?.student) throw notFound("Child not linked to parent");
  return rel.student;
}

async function resolveChildIdForParent(parentId, childIdFromQuery) {
  const raw = childIdFromQuery == null ? "" : String(childIdFromQuery).trim();
  if (raw) {
    // If frontend provides `childId`, just validate it.
    return validateId(raw, "childId");
  }

  // If frontend doesn't provide `childId`, auto-select PRIMARY child.
  const primaryRel = await prisma.studentParent.findFirst({
    where: { parentId, isPrimary: true },
    orderBy: { createdAt: "desc" },
    select: { studentId: true },
  });
  if (primaryRel?.studentId) return primaryRel.studentId;

  // Fallback: use latest linked child.
  const anyRel = await prisma.studentParent.findFirst({
    where: { parentId },
    orderBy: { createdAt: "desc" },
    select: { studentId: true },
  });
  return anyRel?.studentId ?? null;
}

function formatRelativeTime(date) {
  if (!date) return null;
  const now = Date.now();
  const d = new Date(date).getTime();
  const diffMs = now - d;

  const mins = Math.floor(diffMs / 60000);
  if (mins < 60) return `${Math.max(mins, 1)} mins ago`;
  const hours = Math.floor(diffMs / 3600000);
  if (hours < 48) return `${hours} hour${hours === 1 ? "" : "s"} ago`;

  const days = Math.floor(diffMs / 86400000);
  const target = new Date(d);
  if (days === 1) return "Yesterday";
  if (days < 7) return `${days} days ago`;

  return target.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
}

function subjectAbbrev(name) {
  if (!name) return null;
  const s = String(name).toLowerCase();
  if (s.includes("english")) return "Eng";
  if (s.includes("math")) return "Math";
  if (s.includes("science")) return "Sci";
  if (s.includes("history")) return "Hist";
  if (s.includes("hindi")) return "Hin";
  if (s.includes("art") || s.includes("drawing")) return "Art";
  return name.trim().slice(0, 3);
}

async function getParentChildren(parent) {
  const children = await prisma.studentParent.findMany({
    where: { parentId: parent.id },
    include: {
      student: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          className: true,
          section: true,
          status: true,
        },
      },
    },
    orderBy: { createdAt: "desc" },
  });

  return children.map((rel) => ({
    id: rel.student.id,
    name: `${rel.student.firstName ?? ""} ${rel.student.lastName ?? ""}`.trim(),
    grade: `${rel.student.className ?? ""}${rel.student.section ? `-${rel.student.section}` : ""}`.trim(),
    active: rel.student.status === "ACTIVE",
  }));
}

async function getChildAttendance(child, monthStr) {
  const month = validateQueryMonth(monthStr);
  const base = month
    ? (() => {
        const [y, m] = month.split("-").map(Number);
        return new Date(y, m - 1, 1);
      })()
    : new Date(new Date().getFullYear(), new Date().getMonth(), 1);

  const start = new Date(base.getFullYear(), base.getMonth(), 1);
  const end = new Date(base.getFullYear(), base.getMonth() + 1, 0, 23, 59, 59);

  const [monthAtt, leaveRequests] = await Promise.all([
    prisma.studentAttendance.findMany({
      where: { studentId: child.id, date: { gte: start, lte: end } },
      orderBy: { date: "asc" },
      select: { date: true, status: true },
    }),
    prisma.studentLeaveRequest.findMany({
      where: {
        studentId: child.id,
        fromDate: { lte: end },
        toDate: { gte: start },
      },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        fromDate: true,
        toDate: true,
        reason: true,
        status: true,
        createdAt: true,
      },
    }),
  ]);

  // Build a fixed 5-week calendar grid (35 slots) with nulls outside the selected month.
  const firstWeekdayIndex = (new Date(start).getDay() + 6) % 7; // Monday=0
  const calendarDays = new Array(35).fill(null);
  for (let i = 0; i < calendarDays.length; i++) {
    const dayOffset = i - firstWeekdayIndex;
    const d = new Date(start);
    d.setDate(start.getDate() + dayOffset);
    if (d.getMonth() !== start.getMonth()) continue;
    calendarDays[i] = d.getDate();
  }

  const attendanceStats = {
    present: monthAtt.filter((row) => row.status === "PRESENT").length,
    absent: monthAtt.filter((row) => row.status === "ABSENT").length,
    late: monthAtt.filter((row) => row.status === "LATE").length,
  };

  const dailyRecords = monthAtt.map((row) => ({
    date: row.date.toISOString().split("T")[0],
    day: String(row.date.getDate()),
    status: String(row.status || "").toLowerCase(),
    checkIn: "-",
    checkOut: "-",
    subject: "",
    teacher: "",
    room: "",
  }));

  return {
    studentName: `${child.firstName ?? ""} ${child.lastName ?? ""}`.trim(),
    studentClass: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
    calendarDays,
    attendanceStats,
    dailyRecords,
    leaveApplications: leaveRequests.map((item) => ({
      id: item.id,
      fromDate: item.fromDate.toISOString().split("T")[0],
      toDate: item.toDate.toISOString().split("T")[0],
      reason: item.reason,
      status: String(item.status || "PENDING").toLowerCase(),
      appliedOn: item.createdAt.toISOString().split("T")[0],
    })),
  };
}

async function getChildFees(child) {
  const invoices = await prisma.invoice.findMany({
    where: {
      studentId: child.id,
      status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] },
    },
    orderBy: { dueDate: "asc" },
    take: 50,
    include: {
      feeStructure: {
        select: { name: true },
      },
    },
  });

  const totalOutstanding = invoices.reduce((sum, i) => sum + Math.max(0, (i.amountDue ?? 0) - (i.amountPaid ?? 0)), 0);
  const overdueInvoices = invoices.filter((i) => i.status === "OVERDUE");

  const mapInvoice = (i) => {
    const dueDate = i.dueDate ? new Date(i.dueDate).toLocaleDateString("en-GB", { day: "2-digit", month: "short" }) : null;
    const type = i.status === "OVERDUE" ? "overdue" : "pending";
    const outstandingAmount = Math.max(0, (i.amountDue ?? 0) - (i.amountPaid ?? 0));
    return {
      id: i.id,
      title: i.feeStructure?.name ?? i.invoiceNo ?? "Invoice",
      subtitle: null,
      amount: outstandingAmount,
      dueDate,
      type,
    };
  };

  return {
    totalOutstanding,
    invoices: invoices.map(mapInvoice),
    overdueInvoices: overdueInvoices.map(mapInvoice),
  };
}

function getLatestTerm() {
  const now = new Date();
  const month = now.getMonth() + 1;

  let term = "Term 1";
  if (month >= 5 && month <= 8) term = "Term 2";
  if (month >= 9 && month <= 12) term = "Term 3";

  return { term, termStart: null, termEnd: null };
}

async function getSubjectScores(child) {
  const results = await prisma.examResult.findMany({
    where: { studentId: child.id },
    orderBy: { createdAt: "desc" },
    take: 10,
    include: { exam: { select: { subject: { select: { name: true } } } } },
  });

  const buckets = new Map();
  for (const r of results) {
    const subjectName = r.exam?.subject?.name;
    const key = subjectAbbrev(subjectName) ?? subjectName ?? "Other";
    const prev = buckets.get(key) ?? { sum: 0, count: 0 };
    buckets.set(key, { sum: prev.sum + (r.marks ?? 0), count: prev.count + 1 });
  }

  const out = {};
  for (const [k, v] of buckets.entries()) {
    out[k] = v.count ? Math.round((v.sum / v.count) * 10) / 10 : 0;
  }

  return out;
}

async function getChildProfile(child) {
  const medical =
    child.medicalInfo && typeof child.medicalInfo === "object" ? child.medicalInfo : {};

  const parents = child.parents ?? [];
  let fatherName = null;
  let fatherPhone = null;
  let fatherEmail = null;
  let motherName = null;
  let motherPhone = null;
  let motherEmail = null;
  let guardianName = null;
  let guardianPhone = child.guardianPhone ?? null;
  for (const p of parents) {
    const rt = String(p.relationType ?? "").toLowerCase();
    if (!fatherName && rt.includes("father")) {
      fatherName = p.parent?.fullName ?? null;
      fatherPhone = p.parent?.phone ?? null;
      fatherEmail = p.parent?.email ?? null;
    }
    if (!motherName && rt.includes("mother")) {
      motherName = p.parent?.fullName ?? null;
      motherPhone = p.parent?.phone ?? null;
      motherEmail = p.parent?.email ?? null;
    }
    if (!guardianName && p.isPrimary) {
      guardianName = p.parent?.fullName ?? null;
      guardianPhone = guardianPhone ?? p.parent?.phone ?? null;
    }
  }

  return {
    studentId: child.id,
    admissionNo: child.admissionNo ?? null,
    studentName: `${child.firstName ?? ""} ${child.lastName ?? ""}`.trim(),
    studentClass: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
    className: child.className ?? null,
    classSection: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
    dob: child.dob ?? null,
    gender: child.gender ?? null,
    rollNo: child.rollNo ?? null,
    bloodGroup: medical?.bloodGroup ?? medical?.blood_group ?? null,
    fatherName,
    fatherPhone,
    fatherEmail,
    motherName,
    motherPhone,
    motherEmail,
    guardianName,
    guardianPhone,
    emergencyContact: guardianPhone ?? fatherPhone ?? motherPhone ?? null,
    allergies: medical?.allergies ?? medical?.allergy ?? null,
    medicalConditions: medical?.medicalConditions ?? medical?.chronicCondition ?? null,
    medicalInfo: medical,
  };
}

function normalizeText(value) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

async function getChildTeacherDirectory(child) {
  if (!child.classId) return [];

  const byId = new Map();
  const classTeacher = child.class?.classTeacher;
  if (classTeacher?.id) {
    byId.set(classTeacher.id, {
      id: classTeacher.id,
      fullName: classTeacher.fullName,
      designation: classTeacher.designation ?? "Class Teacher",
      department: classTeacher.department ?? null,
      label: "Class Teacher",
      subjects: [],
    });
  }

  const subjectTeachers = await prisma.classSubject.findMany({
    where: { classId: child.classId, teacherId: { not: null } },
    include: {
      teacher: {
        select: {
          id: true,
          fullName: true,
          designation: true,
          department: true,
        },
      },
      subject: { select: { name: true } },
    },
  });

  for (const row of subjectTeachers) {
    const teacher = row.teacher;
    if (!teacher?.id) continue;
    const existing = byId.get(teacher.id) ?? {
      id: teacher.id,
      fullName: teacher.fullName,
      designation: teacher.designation ?? "Teacher",
      department: teacher.department ?? null,
      label: "Subject Teacher",
      subjects: [],
    };
    if (row.subject?.name && !existing.subjects.includes(row.subject.name)) {
      existing.subjects.push(row.subject.name);
    }
    byId.set(teacher.id, existing);
  }

  return [...byId.values()].sort((a, b) => a.fullName.localeCompare(b.fullName));
}

function pickStaffByName(staffList, rawName) {
  const target = normalizeText(rawName);
  if (!target) return null;
  return (
    staffList.find((item) => normalizeText(item.fullName) === target) ||
    staffList.find((item) => normalizeText(item.fullName).includes(target)) ||
    null
  );
}

async function resolveStaffForChild(child, rawStaffId, rawStaffName) {
  if (rawStaffId) {
    const staffId = validateId(rawStaffId, "staffId");
    const staff = await prisma.staff.findFirst({
      where: { id: staffId, schoolId: child.schoolId, isActive: true },
      select: { id: true, fullName: true, designation: true, department: true },
    });
    if (!staff) throw notFound("Staff not found", "STAFF_NOT_FOUND");
    return staff;
  }

  const staffName = String(rawStaffName ?? "").trim();
  if (!staffName) return null;

  const preferred = await getChildTeacherDirectory(child);
  const preferredMatch = pickStaffByName(preferred, staffName);
  if (preferredMatch) return preferredMatch;

  const fallback = await prisma.staff.findFirst({
    where: {
      schoolId: child.schoolId,
      isActive: true,
      fullName: { contains: staffName, mode: "insensitive" },
    },
    orderBy: { fullName: "asc" },
    select: { id: true, fullName: true, designation: true, department: true },
  });
  return fallback ?? null;
}

function buildMeetingRemark(value) {
  const payload = {};
  if (value?.teacherName) payload.teacherName = value.teacherName;
  if (value?.timeSlot) payload.timeSlot = value.timeSlot;
  return Object.keys(payload).length > 0 ? JSON.stringify(payload) : null;
}

function parseMeetingRemark(remark) {
  if (!remark) return {};
  try {
    const parsed = JSON.parse(remark);
    return parsed && typeof parsed === "object" ? parsed : {};
  } catch {
    return {};
  }
}

function mapEventType(eventType) {
  const raw = String(eventType ?? "GENERAL").toLowerCase();
  if (raw.includes("sport")) return "sports";
  if (raw.includes("competition")) return "competition";
  return "all";
}

function mapAchievementGroup(type) {
  const raw = normalizeText(type);
  if (raw.includes("digital")) return "digital";
  if (raw.includes("activity") || raw.includes("participation")) return "activity";
  if (raw.includes("competition") || raw.includes("certificate") || raw.includes("sport")) return "competition";
  return "academic";
}

function fileNameFromUrl(url) {
  const raw = String(url ?? "").trim();
  if (!raw) return null;
  try {
    const parsed = new URL(raw);
    const parts = parsed.pathname.split("/").filter(Boolean);
    return parts.at(-1) || raw;
  } catch {
    const parts = raw.split("/").filter(Boolean);
    return parts.at(-1) || raw;
  }
}

function buildSettingsResponse(preferences) {
  const prefs = preferences && typeof preferences === "object" ? preferences : {};
  return {
    preferences: prefs,
    pushNotificationsEnabled: prefs.pushNotificationsEnabled !== false,
    faceIdEnabled: prefs.faceIdEnabled === true,
    selectedLanguage: prefs.selectedLanguage ?? prefs.language ?? "English (US)",
    darkModeOption: prefs.darkModeOption ?? "system",
    emailNotificationsEnabled: prefs.emailNotificationsEnabled !== false,
    smsNotificationsEnabled: prefs.smsNotificationsEnabled === true,
    profileVisibilityPrivate: prefs.profileVisibilityPrivate !== false,
    analyticsSharingEnabled: prefs.analyticsSharingEnabled === true,
  };
}

function normalizeSettingsPreferences(body) {
  const prefs = validateSettingsBody(body ?? {});
  return {
    ...prefs,
    pushNotificationsEnabled: prefs.pushNotificationsEnabled ?? true,
    faceIdEnabled: prefs.faceIdEnabled ?? false,
    selectedLanguage: prefs.selectedLanguage ?? prefs.language ?? "English (US)",
    language: prefs.selectedLanguage ?? prefs.language ?? "English (US)",
    darkModeOption: prefs.darkModeOption ?? "system",
    emailNotificationsEnabled: prefs.emailNotificationsEnabled ?? true,
    smsNotificationsEnabled: prefs.smsNotificationsEnabled ?? false,
    profileVisibilityPrivate: prefs.profileVisibilityPrivate ?? true,
    analyticsSharingEnabled: prefs.analyticsSharingEnabled ?? false,
  };
}

// ------------------- HANDLERS -------------------

async function listChildren(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const children = await getParentChildren(parent);
    return res.status(200).json({ success: true, data: { children } });
  } catch (e) {
    return next(e);
  }
}

async function getHome(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: {
          childName: "",
          childGrade: "",
          attendance: 0,
          feesDue: 0,
          feesDueDate: null,
          upcomingClass: null,
          classStartIn: null,
          recentNotices: [],
          subjectScores: {},
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const monthKey = req.query.month ? String(req.query.month) : "current";
    const cacheKey = `${cache.cacheKeys.parentHome(child.id)}:${monthKey}`;
    const ttl = cache.CACHE_TTL.parentHome();

    const payload = await cache.getOrSet(cacheKey, ttl, async () => {
      const [attendanceMonth, fees, notices, subjectScores] = await Promise.all([
        getChildAttendance(child, req.query.month),
        getChildFees(child),
        prisma.announcement.findMany({
          where: { schoolId: child.schoolId, status: "SENT" },
          orderBy: { sentAt: "desc" },
          take: 5,
          select: { id: true, title: true, content: true, sentAt: true, audience: true, createdById: true, createdAt: true },
        }),
        getSubjectScores(child),
      ]);

      // Compute a simple upcoming class / timing from LiveClassSession.
      const upcomingLive = await prisma.liveClassSession.findFirst({
        where: { schoolId: child.schoolId, classId: child.classId, startsAt: { gte: new Date() } },
        orderBy: { startsAt: "asc" },
        include: { subject: { select: { id: true, name: true } }, teacher: { select: { fullName: true } } },
        take: 1,
      });

      const nextClassIn =
        upcomingLive?.startsAt
          ? (() => {
              const ms = new Date(upcomingLive.startsAt).getTime() - Date.now();
              const mins = Math.max(0, Math.floor(ms / 60000));
              if (mins < 60) return `${mins} mins`;
              const hours = Math.floor(mins / 60);
              return `${hours} hours`;
            })()
          : null;

      const recentNotices = notices.map((a) => {
        const isUrgent = String(a.audience ?? "").toLowerCase().includes("urgent");
        const time = a.sentAt ? formatRelativeTime(a.sentAt) : formatRelativeTime(a.createdAt);
        return {
          type: isUrgent ? "urgent" : "teacher",
          title: a.title ?? "Notice",
          description: a.content ?? "",
          postedBy: "Admin",
          time,
          urgent: isUrgent,
          teacherName: null,
          teacherClass: null,
        };
      });

      return {
        childName: `${child.firstName ?? ""} ${child.lastName ?? ""}`.trim(),
        childGrade: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
        attendance:
          attendanceMonth.attendanceStats.present +
            attendanceMonth.attendanceStats.absent +
            attendanceMonth.attendanceStats.late >
          0
            ? Math.round(
                ((attendanceMonth.attendanceStats.present + attendanceMonth.attendanceStats.late) * 100) /
                  (attendanceMonth.attendanceStats.present +
                    attendanceMonth.attendanceStats.absent +
                    attendanceMonth.attendanceStats.late)
              )
            : 0,
        feesDue: fees.totalOutstanding,
        feesDueDate: fees.invoices[0]?.dueDate ?? null,
        upcomingClass: upcomingLive?.subject?.name ?? upcomingLive?.title ?? null,
        classStartIn: nextClassIn,
        recentNotices,
        subjectScores,
      };
    });

    return res.status(200).json({ success: true, data: payload });
  } catch (e) {
    // Keep auth/validation/not-found behavior strict, but never return 500 for dashboard payload generation.
    if (e?.statusCode && e.statusCode < 500) {
      return next(e);
    }

    if (
      isMissingTableError(e, "studentattendance") ||
      isMissingTableError(e, "invoice") ||
      isMissingTableError(e, "announcement") ||
      isMissingTableError(e, "examresult") ||
      isMissingTableError(e, "exam") ||
      isMissingTableError(e, "liveclasssession")
    ) {
      return res.status(200).json({
        success: true,
        data: {
          childName: "",
          childGrade: "",
          attendance: 0,
          feesDue: 0,
          feesDueDate: null,
          upcomingClass: null,
          classStartIn: null,
          recentNotices: [],
          subjectScores: {},
        },
      });
    }
    return next(e);
  }
}

async function getAnnouncements(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { announcements: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId); // scope / authorization check

    const type = req.query.type ? String(req.query.type).toLowerCase() : "all";
    const where = { status: "SENT" };

    where.schoolId = child.schoolId;

    const cacheKey = `${cache.cacheKeys.parentAnnouncements(child.id)}:${type}`;
    const ttl = cache.CACHE_TTL.parentAnnouncements();

    const out = await cache.getOrSet(cacheKey, ttl, async () => {
      const scopedWhere = { ...where };

      if (type === "urgent") scopedWhere.audience = { contains: "URGENT", mode: "insensitive" };
      if (type === "teacher") scopedWhere.audience = { contains: "TEACHER", mode: "insensitive" };

      const items = await prisma.announcement.findMany({
        where: scopedWhere,
        orderBy: { sentAt: "desc" },
        take: 20,
        select: { id: true, title: true, content: true, sentAt: true, audience: true, createdAt: true },
      });

      return items.map((a) => {
        const isUrgent = String(a.audience ?? "").toLowerCase().includes("urgent");
        return {
          type: isUrgent ? "urgent" : "teacher",
          title: a.title ?? "Notice",
          description: a.content ?? "",
          postedBy: "Admin",
          time: formatRelativeTime(a.sentAt ?? a.createdAt),
          urgent: isUrgent,
          teacherName: null,
          teacherClass: null,
          attachment: null,
        };
      });
    });

    return res.status(200).json({ success: true, data: { announcements: out } });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { announcements: [] } });
  }
}

async function getNotifications(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { notifications: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const settings = await prisma.studentSettings.findUnique({ where: { studentId: child.id } });
    const prefs = settings?.preferences && typeof settings.preferences === "object" ? settings.preferences : {};
    const readAtRaw = prefs.notificationsLastReadAt ? new Date(prefs.notificationsLastReadAt) : null;
    const readAt = readAtRaw && !Number.isNaN(readAtRaw.getTime()) ? readAtRaw : null;
    const cacheKey = `${cache.cacheKeys.parentNotifications(child.id)}:${readAt ? readAt.toISOString() : "never"}`;
    const ttl = cache.CACHE_TTL.parentNotifications();

    const sections = await cache.getOrSet(cacheKey, ttl, async () => {
      const items = await prisma.announcement.findMany({
        where: { schoolId: child.schoolId, status: "SENT" },
        orderBy: { sentAt: "desc" },
        take: 30,
        select: { id: true, title: true, content: true, sentAt: true, audience: true, createdAt: true },
      });

      const now = Date.now();
      const isSameDay = (a, b) => new Date(a).toDateString() === new Date(b).toDateString();

      const todayItems = [];
      const yesterdayItems = [];
      const lastWeekItems = [];

      for (const a of items) {
        const d = a.sentAt ?? a.createdAt;
        const relType = String(a.audience ?? "").toLowerCase().includes("fee")
          ? "fee"
          : String(a.audience ?? "").toLowerCase().includes("attendance")
            ? "attendance"
            : String(a.audience ?? "").toLowerCase().includes("exam")
              ? "exam"
              : "general";

        const card = {
          type: relType,
          title: a.title ?? "Notification",
          description: a.content ?? "",
          time: formatRelativeTime(d),
          unread: readAt ? new Date(d).getTime() > readAt.getTime() : true,
          action: undefined,
        };

        if (isSameDay(d, now)) todayItems.push(card);
        else if (isSameDay(d, now - 86400000)) yesterdayItems.push(card);
        else lastWeekItems.push(card);
      }

      const outSections = [];
      if (todayItems.length) outSections.push({ section: "Today", items: todayItems });
      if (yesterdayItems.length) outSections.push({ section: "Yesterday", items: yesterdayItems });
      if (lastWeekItems.length) outSections.push({ section: "Last Week", items: lastWeekItems });
      return outSections;
    });

    return res.status(200).json({ success: true, data: { notifications: sections } });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { notifications: [] } });
  }
}

async function markNotificationsRead(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: { marked: true, markedAt: new Date().toISOString() },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const existing = await prisma.studentSettings.findUnique({ where: { studentId: child.id } });
    const preferences = {
      ...(existing?.preferences && typeof existing.preferences === "object" ? existing.preferences : {}),
      notificationsLastReadAt: new Date().toISOString(),
    };
    await prisma.studentSettings.upsert({
      where: { studentId: child.id },
      update: { preferences },
      create: { schoolId: child.schoolId, studentId: child.id, preferences },
    });
    await cache.delByPrefix(`parent:notifications:${child.id}`);
    return res.status(200).json({
      success: true,
      data: { marked: true, markedAt: preferences.notificationsLastReadAt },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: { marked: true, markedAt: new Date().toISOString() },
    });
  }
}

async function getAttendance(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: {
          calendarDays: new Array(35).fill(null),
          attendanceStats: { present: 0, absent: 0, late: 0 },
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const monthKey = req.query.month ? String(req.query.month) : "current";
    const cacheKey = cache.cacheKeys.parentAttendance(child.id, monthKey);
    const ttl = cache.CACHE_TTL.parentAttendance();

    const result = await cache.getOrSet(cacheKey, ttl, async () => getChildAttendance(child, req.query.month));
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: { calendarDays: new Array(35).fill(null), attendanceStats: { present: 0, absent: 0, late: 0 } },
    });
  }
}

async function getFees(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: { totalOutstanding: 0, invoices: [], overdueInvoices: [] },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const cacheKey = cache.cacheKeys.parentFees(child.id);
    const ttl = cache.CACHE_TTL.parentFees();

    const fees = await cache.getOrSet(cacheKey, ttl, async () => getChildFees(child));
    return res.status(200).json({
      success: true,
      data: {
        studentName: `${child.firstName ?? ""} ${child.lastName ?? ""}`.trim(),
        studentGrade: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
        ...fees,
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: { studentName: "", studentGrade: "", totalOutstanding: 0, invoices: [], overdueInvoices: [] },
    });
  }
}

async function getInvoiceDetail(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const invoiceId = validateId(req.params.invoiceId, "invoiceId");
    const invoice = await prisma.invoice.findFirst({
      where: { id: invoiceId, schoolId: parent.schoolId },
      include: { payments: { orderBy: { paidAt: "desc" } } },
    });

    if (!invoice) throw notFound("Invoice not found");

    // Prevent IDOR: ensure this invoice belongs to a student linked to this parent.
    const child = await resolveChildForParent(parent.id, invoice.studentId);

    const paymentHistory = (invoice.payments ?? []).map((p) => ({
      ref: p.receiptNo ?? p.id,
      amount: p.amount ?? 0,
      date: p.paidAt ? new Date(p.paidAt).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" }) : null,
      time: p.paidAt ? new Date(p.paidAt).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) : null,
      method: p.method ?? null,
    }));

    return res.status(200).json({
      success: true,
      data: {
        invoice: {
          ...invoice,
          studentName: `${child.firstName ?? ""} ${child.lastName ?? ""}`.trim(),
          studentClass: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
        },
        paymentHistory,
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return next(notFound("Invoice not found"));
  }
}

async function payInvoiceBalance(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const invoiceId = validateId(req.params.invoiceId, "invoiceId");
    const payload = payInvoiceBalanceSchema.parse(req.body ?? {});

    const invoice = await prisma.invoice.findFirst({
      where: { id: invoiceId, schoolId: parent.schoolId },
    });

    if (!invoice) throw notFound("Invoice not found");

    // Prevent IDOR: ensure this invoice belongs to a student linked to this parent.
    await resolveChildForParent(parent.id, invoice.studentId);

    const amountDue = Number(invoice.amountDue ?? 0);
    const amountPaid = Number(invoice.amountPaid ?? 0);
    const outstanding = Math.max(0, amountDue - amountPaid);

    if (outstanding <= 0) {
      return res.status(200).json({
        success: true,
        data: {
          payment: null,
          invoice,
          outstanding: 0,
        },
      });
    }

    const requested = payload.amount == null ? null : Number(payload.amount);
    const payAmount = requested == null ? outstanding : Math.min(outstanding, requested);

    if (payAmount <= 0) {
      return res.status(200).json({ success: true, data: { payment: null, invoice, outstanding } });
    }

    const receiptNo = `REC-${crypto.randomUUID().slice(0, 10).toUpperCase()}`;
    const now = new Date();

    const payment = await prisma.payment.create({
      data: {
        schoolId: parent.schoolId,
        studentId: invoice.studentId,
        invoiceId: invoice.id,
        receiptNo,
        amount: payAmount,
        method: payload.method,
        transactionRef: payload.transactionRef ?? null,
        paidAt: now,
        collectedById: req.user?.sub || null,
        notes: payload.notes ?? null,
      },
    });

    const newAmountPaid = amountPaid + payAmount;
    const updatedInvoice = await prisma.invoice.update({
      where: { id: invoice.id },
      data: {
        amountPaid: newAmountPaid,
        status: computeInvoiceStatus(amountDue, newAmountPaid, invoice.dueDate),
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: parent.schoolId,
        actorId: req.user?.sub || null,
        action: "PARENT_INVOICE_PAID",
        entity: "Invoice",
        entityId: updatedInvoice.id,
        meta: { paymentId: payment.id, amount: payAmount, method: payload.method },
      },
    });

    await Promise.all([
      cache.del(cache.cacheKeys.parentFees(invoice.studentId)),
      cache.delByPrefix(cache.cacheKeys.parentHome(invoice.studentId)),
    ]);

    return res.status(201).json({
      success: true,
      data: {
        payment,
        invoice: updatedInvoice,
        outstanding: Math.max(0, amountDue - newAmountPaid),
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return next(e);
  }
}

async function quickPayAllInvoices(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);

    if (!childId) {
      return res.status(200).json({ success: true, data: { paidCount: 0, payments: [] } });
    }

    const child = await resolveChildForParent(parent.id, childId);

    // Optional payment metadata. Frontend currently calls without body, so defaults apply.
    const payload = payInvoiceBalanceSchema.parse(req.body ?? {});

    const invoices = await prisma.invoice.findMany({
      where: {
        schoolId: parent.schoolId,
        studentId: child.id,
        status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] },
      },
      orderBy: { dueDate: "asc" },
      select: { id: true, amountDue: true, amountPaid: true, studentId: true },
    });

    const targetInvoices = invoices.filter((inv) => Math.max(0, Number(inv.amountDue ?? 0) - Number(inv.amountPaid ?? 0)) > 0);

    if (targetInvoices.length === 0) {
      return res.status(200).json({ success: true, data: { paidCount: 0, payments: [] } });
    }

    const now = new Date();
    const receiptsByInvoiceId = new Map();
    for (const inv of targetInvoices) {
      receiptsByInvoiceId.set(inv.id, `REC-${crypto.randomUUID().slice(0, 10).toUpperCase()}`);
    }

    const { payments, updatedInvoices } = await prisma.$transaction(async (tx) => {
      const payments = [];
      const updatedInvoices = [];

      for (const inv of targetInvoices) {
        const amountDue = Number(inv.amountDue ?? 0);
        const amountPaid = Number(inv.amountPaid ?? 0);
        const outstanding = Math.max(0, amountDue - amountPaid);
        if (outstanding <= 0) continue;

        const payment = await tx.payment.create({
          data: {
            schoolId: parent.schoolId,
            studentId: inv.studentId,
            invoiceId: inv.id,
            receiptNo: receiptsByInvoiceId.get(inv.id),
            amount: outstanding,
            method: payload.method,
            transactionRef: payload.transactionRef ?? null,
            paidAt: now,
            collectedById: req.user?.sub || null,
            notes: payload.notes ?? null,
          },
        });

        const newAmountPaid = amountPaid + outstanding;
        const updatedInvoice = await tx.invoice.update({
          where: { id: inv.id },
          data: { amountPaid: newAmountPaid, status: computeInvoiceStatus(amountDue, newAmountPaid, inv.dueDate) },
        });

        payments.push(payment);
        updatedInvoices.push(updatedInvoice);
      }

      return { payments, updatedInvoices };
    });

    await Promise.all([
      cache.del(cache.cacheKeys.parentFees(child.id)),
      cache.delByPrefix(cache.cacheKeys.parentHome(child.id)),
    ]);

    await prisma.auditLog.create({
      data: {
        schoolId: parent.schoolId,
        actorId: req.user?.sub || null,
        action: "PARENT_QUICK_PAY_ALL",
        entity: "Invoice",
        entityId: child.id,
        meta: { paidCount: payments.length, method: payload.method },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        paidCount: payments.length,
        payments,
        invoices: updatedInvoices,
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return next(e);
  }
}

async function getTimetable(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { items: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const day = parseDayQuery(req.query.day);
    const dayKey = day ? String(day) : "today";
    const cacheKey = cache.cacheKeys.parentTimetable(child.id, dayKey);
    const ttl = cache.CACHE_TTL.parentTimetable();

    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const targetDate = day
        ? (() => {
            if (typeof day === "string") {
              const parsed = new Date(`${day}T00:00:00.000Z`);
              if (!Number.isNaN(parsed.getTime())) return parsed;
            }
            const now = new Date();
            return new Date(now.getFullYear(), now.getMonth(), Number(day));
          })()
        : new Date();

      // For now, return next live sessions within the day (contract-ready).
      const start = new Date(targetDate);
      start.setHours(0, 0, 0, 0);
      const end = new Date(targetDate);
      end.setHours(23, 59, 59, 999);

      const sessions = await prisma.liveClassSession.findMany({
        where: {
          schoolId: child.schoolId,
          classId: child.classId,
          startsAt: { gte: start, lte: end },
          status: { in: ["TIMETABLE", "UPCOMING", "LIVE"] },
        },
        orderBy: { startsAt: "asc" },
        take: 20,
        select: {
          startsAt: true,
          title: true,
          subject: { select: { name: true } },
          teacher: { select: { fullName: true } },
        },
      });

      const now = Date.now();
      const items = sessions.map((s) => {
        const startsAt = new Date(s.startsAt);
        const diff = startsAt.getTime() - now;
        return {
          time: startsAt.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
          subject: s.subject?.name ?? s.title,
          teacher: s.teacher?.fullName ?? null,
          room: null,
          period: startsAt.getHours().toString(),
          isLive: diff <= 60 * 60 * 1000 && diff >= -60 * 60 * 1000,
        };
      });

      return { date: targetDate.toISOString().split("T")[0], items };
    });

    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { items: [] } });
  }
}

async function createMeetingRequest(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "No child selected" },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const payload = createMeetingRequestSchema.parse(req.body || {});
    const staff = await resolveStaffForChild(
      child,
      payload.staffId,
      payload.staffName ?? payload.teacher
    );
    const teacherName = staff?.fullName ?? payload.staffName ?? payload.teacher ?? null;

    const rec = await prisma.meetingRequest.create({
      data: {
        schoolId: child.schoolId,
        studentId: child.id,
        requestedById: req.user?.sub || null,
        staffId: staff?.id ?? null,
        preferredDate: payload.preferredDate ?? null,
        purpose: payload.purpose ?? null,
        remark: buildMeetingRemark({
          teacherName,
          timeSlot: payload.timeSlot,
        }),
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: child.schoolId,
        actorId: req.user?.sub || null,
        action: "PARENT_MEETING_REQUESTED",
        entity: "MeetingRequest",
        entityId: rec.id,
        meta: {
          childId: child.id,
          teacherName,
          staffId: staff?.id ?? null,
          preferredDate: payload.preferredDate ? payload.preferredDate.toISOString() : null,
          timeSlot: payload.timeSlot ?? null,
          purpose: payload.purpose ?? null,
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        id: rec.id,
        teacher: teacherName ?? "School Staff",
        staffId: staff?.id ?? null,
        purpose: rec.purpose ?? "",
        status: rec.status,
        date: rec.preferredDate ? rec.preferredDate.toISOString().split("T")[0] : null,
        timeSlot: payload.timeSlot ?? null,
        remark: rec.remark,
      },
    });
  } catch (e) {
    return next(e);
  }
}

async function getProgressReports(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      const termInfo = getLatestTerm();
      return res.status(200).json({
        success: true,
        data: {
          studentName: "",
          studentClass: "",
          academicYear: String(new Date().getFullYear()),
          selectedTerm: termInfo.term,
          terms: [termInfo.term],
          gpa: 0,
          subjectScores: {},
          attendance: { present: 0, absent: 0, late: 0 },
          feeHistory: [0, 0, 0, 0, 0],
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const termInfo = getLatestTerm();
    const examResults = await prisma.examResult.findMany({
      where: { studentId: child.id },
      include: { exam: { select: { subjectId: true, subject: { select: { name: true } } } } },
      orderBy: { createdAt: "desc" },
      take: 20,
    });

    const totalMarks = examResults.reduce((s, r) => s + (r.marks ?? 0), 0);
    const gpa = examResults.length ? Math.round((totalMarks / examResults.length) * 10) / 10 : 0;

    const subjectScores = await getSubjectScores(child);
    const attendance = await getChildAttendance(child);

    // Fee history (last 5 months)
    const now = new Date();
    const months = [];
    for (let i = 4; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      months.push(d);
    }

    const feeHistory = await Promise.all(
      months.map(async (m) => {
        const start = new Date(m.getFullYear(), m.getMonth(), 1);
        const end = new Date(m.getFullYear(), m.getMonth() + 1, 0, 23, 59, 59);
        const sum = await prisma.invoice.aggregate({
          where: {
            studentId: child.id,
            status: { in: ["ISSUED", "OVERDUE", "PARTIAL"] },
            dueDate: { gte: start, lte: end },
          },
          _sum: { amountDue: true, amountPaid: true },
        });
        return Math.round(Math.max(0, (sum._sum.amountDue ?? 0) - (sum._sum.amountPaid ?? 0)) * 100) / 100;
      })
    );

    return res.status(200).json({
      success: true,
      data: {
        studentName: `${child.firstName ?? ""} ${child.lastName ?? ""}`.trim(),
        studentClass: `${child.className ?? ""}${child.section ? `-${child.section}` : ""}`.trim(),
        academicYear: String(new Date().getFullYear()),
        selectedTerm: req.query.term ?? termInfo.term,
        terms: [termInfo.term],
        gpa,
        subjectScores,
        attendance: attendance.attendanceStats,
        feeHistory,
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    const termInfo = getLatestTerm();
    return res.status(200).json({
      success: true,
      data: {
        studentName: "",
        studentClass: "",
        academicYear: String(new Date().getFullYear()),
        selectedTerm: termInfo.term,
        terms: [termInfo.term],
        gpa: 0,
        subjectScores: {},
        attendance: { present: 0, absent: 0, late: 0 },
        feeHistory: [0, 0, 0, 0, 0],
      },
    });
  }
}

async function getLiveClasses(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { liveClass: null, upcomingClasses: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const cacheKey = cache.cacheKeys.parentLiveClasses(child.id);
    const ttl = cache.CACHE_TTL.parentLiveClasses();

    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const now = new Date();
      const [current, upcoming] = await Promise.all([
        prisma.liveClassSession.findFirst({
          where: { schoolId: child.schoolId, classId: child.classId, startsAt: { lte: now }, endsAt: { gte: now } },
          orderBy: { startsAt: "desc" },
          include: { subject: { select: { name: true } }, teacher: { select: { fullName: true } } },
        }),
        prisma.liveClassSession.findMany({
          where: { schoolId: child.schoolId, classId: child.classId, startsAt: { gt: now } },
          orderBy: { startsAt: "asc" },
          take: 5,
          include: { subject: { select: { name: true } }, teacher: { select: { fullName: true } } },
        }),
      ]);

      const liveClass = current
        ? {
            title: current.subject?.name ?? current.title,
            teacher: current.teacher?.fullName ?? null,
            time: current.startsAt.toISOString(),
          }
        : null;

      const upcomingClasses = upcoming.map((s) => ({
        title: s.subject?.name ?? s.title,
        teacher: s.teacher?.fullName ?? null,
        time: s.startsAt.toISOString(),
        room: null,
        subject: s.subject?.name ?? s.title,
        isLive: false,
      }));

      return { liveClass, upcomingClasses };
    });

    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { liveClass: null, upcomingClasses: [] } });
  }
}

async function getProfileHub(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: {
          studentName: "",
          studentClass: "",
          dob: null,
          bloodGroup: null,
          fatherName: null,
          motherName: null,
          medicalInfo: null,
          academicYear: String(new Date().getFullYear()),
          currentTermPercentage: null,
          classAvg: null,
          subjectScores: {},
          documents: [],
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const cacheKey = cache.cacheKeys.parentProfileHub(child.id);
    const ttl = cache.CACHE_TTL.parentProfileHub();
    const payload = await cache.getOrSet(cacheKey, ttl, async () => {
      const [profile, subjectScores, docs, classResults] = await Promise.all([
        getChildProfile(child),
        getSubjectScores(child),
        prisma.studentDocument.findMany({
          where: { studentId: child.id },
          orderBy: { createdAt: "desc" },
          take: 6,
        }),
        child.classId
          ? prisma.examResult.findMany({
              where: { exam: { classId: child.classId } },
              select: { marks: true },
              take: 300,
            })
          : Promise.resolve([]),
      ]);
      const subjectValues = Object.values(subjectScores).map((value) => Number(value) || 0);
      const currentTermPercentage = subjectValues.length
        ? Math.round((subjectValues.reduce((sum, value) => sum + value, 0) / subjectValues.length) * 10) / 10
        : null;
      const classAvg = classResults.length
        ? Math.round(
            (classResults.reduce((sum, item) => sum + (Number(item.marks) || 0), 0) / classResults.length) * 10
          ) / 10
        : null;
      return {
        ...profile,
        academicYear: String(new Date().getFullYear()),
        currentTermPercentage,
        classAvg,
        subjectScores,
        documents: docs.map((d) => ({
          id: d.id,
          name: d.name ?? "Document",
          url: d.url,
          type: d.type,
          status: "AVAILABLE",
          sizeKb: d.sizeKb ?? null,
          createdAt: d.createdAt,
        })),
      };
    });

    return res.status(200).json({ success: true, data: payload });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: {
        studentName: "",
        studentClass: "",
        dob: null,
        bloodGroup: null,
        fatherName: null,
        motherName: null,
        medicalInfo: null,
        academicYear: String(new Date().getFullYear()),
        currentTermPercentage: null,
        classAvg: null,
        subjectScores: {},
        documents: [],
      },
    });
  }
}

async function updateProfileHub(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "No child selected" },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const payload = updateProfileHubSchema.parse(req.body ?? {});

    let parsedDob = null;
    if (payload.dob !== undefined) {
      const d = new Date(payload.dob);
      if (Number.isNaN(d.getTime())) {
        return res.status(400).json({
          success: false,
          error: { code: "BAD_REQUEST", message: "Invalid date of birth" },
        });
      }
      parsedDob = d;
    }

    await prisma.$transaction(async (tx) => {
      const studentUpdate = {};
      if (payload.studentName !== undefined) {
        const parts = payload.studentName.trim().split(/\s+/).filter(Boolean);
        if (parts.length > 0) {
          studentUpdate.firstName = parts[0];
          studentUpdate.lastName = parts.slice(1).join(" ") || "";
        }
      }
      if (parsedDob !== null) {
        studentUpdate.dob = parsedDob;
      }
      if (payload.bloodGroup !== undefined) {
        const existingMedical =
          child.medicalInfo && typeof child.medicalInfo === "object" ? child.medicalInfo : {};
        studentUpdate.medicalInfo = {
          ...existingMedical,
          bloodGroup: payload.bloodGroup || null,
        };
      }
      if (Object.keys(studentUpdate).length > 0) {
        await tx.student.update({
          where: { id: child.id },
          data: studentUpdate,
        });
      }

      async function upsertGuardianName(relationContains, fullName) {
        if (fullName === undefined) return;
        const trimmed = String(fullName || "").trim();
        if (!trimmed) return;

        const existingRel = await tx.studentParent.findFirst({
          where: {
            studentId: child.id,
            relationType: { contains: relationContains, mode: "insensitive" },
          },
          include: { parent: true },
          orderBy: { createdAt: "desc" },
        });

        if (existingRel?.parent) {
          await tx.parent.update({
            where: { id: existingRel.parent.id },
            data: { fullName: trimmed },
          });
          return;
        }

        const createdParent = await tx.parent.create({
          data: {
            schoolId: child.schoolId,
            fullName: trimmed,
            email: null,
            phone: null,
            isActive: true,
          },
        });
        await tx.studentParent.create({
          data: {
            studentId: child.id,
            parentId: createdParent.id,
            relationType: relationContains.toUpperCase(),
            isPrimary: false,
          },
        });
      }

      await upsertGuardianName("father", payload.fatherName);
      await upsertGuardianName("mother", payload.motherName);
    });

    await cache.del(cache.cacheKeys.parentProfileHub(child.id));
    const refreshed = await resolveChildForParent(parent.id, child.id);
    const [profile, subjectScores, docs] = await Promise.all([
      getChildProfile(refreshed),
      getSubjectScores(refreshed),
      prisma.studentDocument.findMany({
        where: { studentId: child.id },
        orderBy: { createdAt: "desc" },
        take: 6,
      }),
    ]);
    const subjectValues = Object.values(subjectScores).map((value) => Number(value) || 0);
    const currentTermPercentage = subjectValues.length
      ? Math.round((subjectValues.reduce((sum, value) => sum + value, 0) / subjectValues.length) * 10) / 10
      : null;

    return res.status(200).json({
      success: true,
      data: {
        ...profile,
        academicYear: String(new Date().getFullYear()),
        currentTermPercentage,
        classAvg: null,
        subjectScores,
        documents: docs.map((d) => ({
          id: d.id,
          name: d.name ?? "Document",
          url: d.url,
          type: d.type,
          status: "AVAILABLE",
          sizeKb: d.sizeKb ?? null,
          createdAt: d.createdAt,
        })),
      },
    });
  } catch (e) {
    return next(e);
  }
}

async function getLibrary(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: {
          search: "",
          recommendedBooks: [],
          activeLoans: [],
          pagination: { page: 1, limit: 20, total: 0, totalPages: 0 },
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const { page, limit, skip } = parsePagination(req.query);
    const search = validateSearch(req.query.search);

    const where = { schoolId: child.schoolId, isActive: true };
    if (search) where.title = { contains: search, mode: "insensitive" };

    const [recommended, count, loans] = await Promise.all([
      prisma.libraryBook.findMany({ where, orderBy: { title: "asc" }, skip, take: limit, select: { id: true, title: true, author: true, category: true, availableCopies: true } }),
      prisma.libraryBook.count({ where }),
      prisma.libraryBorrow.findMany({
        where: { schoolId: child.schoolId, borrowerType: "STUDENT", borrowerRefId: child.id },
        orderBy: { issuedAt: "desc" },
        take: 20,
        include: { book: { select: { id: true, title: true, author: true } } },
      }),
    ]);

    const activeLoans = loans.map((l) => ({
      id: l.id,
      title: l.book?.title ?? "Book",
      author: l.book?.author ?? null,
      dueDate: l.dueDate ? new Date(l.dueDate).toISOString() : null,
      status: l.status,
    }));

    return res.status(200).json({
      success: true,
      data: {
        search: search ?? "",
        recommendedBooks: recommended.map((b) => ({
          id: b.id,
          title: b.title,
          author: b.author,
          category: b.category ?? null,
          availableCopies: b.availableCopies,
        })),
        activeLoans,
        pagination: { page, limit, total: count, totalPages: Math.ceil(count / limit) },
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: { search: "", recommendedBooks: [], activeLoans: [], pagination: { page: 1, limit: 20, total: 0, totalPages: 0 } },
    });
  }
}

async function getDocuments(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: { documents: [], pagination: { currentPage: 1, totalPages: 0 } },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const { page, limit, skip } = parsePagination(req.query);
    const where = { studentId: child.id };
    const [total, docs] = await Promise.all([
      prisma.studentDocument.count({ where }),
      prisma.studentDocument.findMany({ where, orderBy: { createdAt: "desc" }, skip, take: limit }),
    ]);

    const totalPages = Math.ceil(total / limit);
    return res.status(200).json({
      success: true,
      data: {
        documents: docs.map((d) => ({
          id: d.id,
          name: d.name ?? "Document",
          url: d.url,
          type: d.type,
          status: "AVAILABLE",
          sizeKb: d.sizeKb ?? null,
          createdAt: d.createdAt,
        })),
        pagination: { currentPage: page, totalPages },
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: { documents: [], pagination: { currentPage: 1, totalPages: 0 } },
    });
  }
}

async function getSettings(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: buildSettingsResponse({}),
      });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const s = await prisma.studentSettings.findUnique({ where: { studentId: child.id } });
    return res.status(200).json({ success: true, data: buildSettingsResponse(s?.preferences) });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: buildSettingsResponse({}),
    });
  }
}

async function updateSettings(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: buildSettingsResponse(normalizeSettingsPreferences(req.body ?? {})) });
    }
    const child = await resolveChildForParent(parent.id, childId);

    const preferences = normalizeSettingsPreferences(req.body ?? {});
    const rec = await prisma.studentSettings.upsert({
      where: { studentId: child.id },
      update: { preferences },
      create: { schoolId: child.schoolId, studentId: child.id, preferences },
    });

    return res.status(200).json({ success: true, data: buildSettingsResponse(rec.preferences) });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: buildSettingsResponse(normalizeSettingsPreferences(req.body ?? {})),
    });
  }
}

async function createLeaveRequest(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "No child selected" },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const payload = createLeaveRequestSchema.parse(req.body || {});
    if (payload.toDate < payload.fromDate) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "toDate must be on or after fromDate" },
      });
    }

    const record = await prisma.studentLeaveRequest.create({
      data: {
        schoolId: child.schoolId,
        studentId: child.id,
        fromDate: payload.fromDate,
        toDate: payload.toDate,
        reason: payload.reason,
      },
    });

    await cache.delByPrefix(`parent:attendance:${child.id}:`);

    return res.status(201).json({
      success: true,
      data: {
        id: record.id,
        fromDate: record.fromDate.toISOString().split("T")[0],
        toDate: record.toDate.toISOString().split("T")[0],
        reason: record.reason,
        status: String(record.status || "PENDING").toLowerCase(),
        appliedOn: record.createdAt.toISOString().split("T")[0],
      },
    });
  } catch (e) {
    return next(e);
  }
}

async function getExamTimetable(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { items: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const month = validateQueryMonth(req.query.month);

    const where = {
      schoolId: child.schoolId,
      isPublished: true,
      OR: [{ classId: child.classId }, { classId: null }],
    };
    if (month) {
      const [year, monthNumber] = month.split("-").map(Number);
      where.examDate = {
        gte: new Date(year, monthNumber - 1, 1),
        lte: new Date(year, monthNumber, 0, 23, 59, 59),
      };
    }

    const items = await prisma.exam.findMany({
      where,
      orderBy: { examDate: "asc" },
      include: { subject: { select: { name: true } } },
      take: 50,
    });

    return res.status(200).json({
      success: true,
      data: {
        items: items.map((exam) => ({
          id: exam.id,
          title: exam.name,
          subject: exam.subject?.name ?? exam.name,
          date: exam.examDate.toISOString().split("T")[0],
          examDate: exam.examDate.toISOString().split("T")[0],
          time: exam.examDate.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
          startTime: exam.examDate.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
          room: null,
          location: null,
          maxMarks: exam.maxMarks,
          status: exam.status,
        })),
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { items: [] } });
  }
}

async function getEventTimetable(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { items: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const month = validateQueryMonth(req.query.month);

    const where = { schoolId: child.schoolId, isPublished: true };
    if (month) {
      const [year, monthNumber] = month.split("-").map(Number);
      where.startDate = {
        gte: new Date(year, monthNumber - 1, 1),
        lte: new Date(year, monthNumber, 0, 23, 59, 59),
      };
    }

    const items = await prisma.event.findMany({
      where,
      orderBy: { startDate: "asc" },
      take: 50,
    });

    return res.status(200).json({
      success: true,
      data: {
        items: items.map((event) => ({
          id: event.id,
          title: event.title,
          description: event.description ?? "",
          type: mapEventType(event.eventType),
          date: event.startDate.toISOString().split("T")[0],
          eventDate: event.startDate.toISOString().split("T")[0],
          time: event.startDate.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
          startTime: event.startDate.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
          location: event.location ?? "",
          venue: event.location ?? "",
        })),
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { items: [] } });
  }
}

async function getEventsHub(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({ success: true, data: { events: [], registeredEventIds: [], eventPhotos: [] } });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const since = new Date();
    since.setDate(since.getDate() - 30);

    const [events, photos, registrations] = await Promise.all([
      prisma.event.findMany({
        where: { schoolId: child.schoolId, isPublished: true, startDate: { gte: since } },
        orderBy: { startDate: "asc" },
        take: 100,
      }),
      prisma.eventGalleryImage.findMany({
        where: { event: { schoolId: child.schoolId, isPublished: true } },
        orderBy: { createdAt: "desc" },
        take: 24,
        include: { event: { select: { title: true } } },
      }),
      prisma.eventRegistration.findMany({
        where: { schoolId: child.schoolId, studentId: child.id, status: "REGISTERED" },
        select: { eventId: true },
      }),
    ]);

    const registeredEventIds = registrations.map((item) => item.eventId);
    const registeredSet = new Set(registeredEventIds);

    return res.status(200).json({
      success: true,
      data: {
        events: events.map((event) => ({
          id: event.id,
          title: event.title,
          type: mapEventType(event.eventType),
          description: event.description ?? "",
          date: event.startDate.toISOString(),
          venue: event.location ?? "",
          registered: registeredSet.has(event.id),
        })),
        registeredEventIds,
        eventPhotos: photos.map((photo) => ({
          id: photo.id,
          title: photo.caption || photo.event?.title || "Event photo",
          event: photo.event?.title || "",
          url: photo.url,
        })),
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { events: [], registeredEventIds: [], eventPhotos: [] } });
  }
}

async function registerForEvent(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) throw notFound("Child not found", "CHILD_NOT_FOUND");
    const child = await resolveChildForParent(parent.id, childId);
    const eventId = validateId(req.params.eventId, "eventId");
    const event = await prisma.event.findFirst({
      where: { id: eventId, schoolId: child.schoolId, isPublished: true },
    });
    if (!event) throw notFound("Event not found", "EVENT_NOT_FOUND");

    const registration = await prisma.eventRegistration.upsert({
      where: { eventId_studentId: { eventId, studentId: child.id } },
      create: { eventId, schoolId: child.schoolId, studentId: child.id, status: "REGISTERED" },
      update: { status: "REGISTERED" },
    });

    return res.status(200).json({ success: true, data: registration });
  } catch (e) {
    return next(e);
  }
}

async function cancelEventRegistration(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) throw notFound("Child not found", "CHILD_NOT_FOUND");
    const child = await resolveChildForParent(parent.id, childId);
    const eventId = validateId(req.params.eventId, "eventId");
    const event = await prisma.event.findFirst({
      where: { id: eventId, schoolId: child.schoolId },
      select: { id: true },
    });
    if (!event) throw notFound("Event not found", "EVENT_NOT_FOUND");

    const registration = await prisma.eventRegistration.upsert({
      where: { eventId_studentId: { eventId, studentId: child.id } },
      create: { eventId, schoolId: child.schoolId, studentId: child.id, status: "CANCELLED" },
      update: { status: "CANCELLED" },
    });

    return res.status(200).json({ success: true, data: registration });
  } catch (e) {
    return next(e);
  }
}

async function getAchievements(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: {
          academicAchievements: [],
          competitionCertificates: [],
          activityRecords: [],
          digitalCertificates: [],
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const items = await prisma.studentAchievement.findMany({
      where: { studentId: child.id },
      orderBy: { issuedAt: "desc" },
      take: 100,
    });

    const academicAchievements = [];
    const competitionCertificates = [];
    const activityRecords = [];
    const digitalCertificates = [];

    for (const item of items) {
      const dateLabel = item.issuedAt
        ? item.issuedAt.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" })
        : "";
      const group = mapAchievementGroup(item.type);
      if (group === "digital") {
        digitalCertificates.push({
          id: item.id,
          title: item.title,
          issuedBy: item.description || "School ERP",
          url: item.url,
        });
      } else if (group === "activity") {
        activityRecords.push({
          title: item.title,
          date: dateLabel,
          remarks: item.description || "Recorded by staff",
        });
      } else if (group === "competition") {
        competitionCertificates.push({
          title: item.title,
          date: dateLabel,
          file: fileNameFromUrl(item.url) || "certificate",
          url: item.url,
        });
      } else {
        academicAchievements.push({
          title: item.title,
          date: dateLabel,
          by: item.description || "School Staff",
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: {
        academicAchievements,
        competitionCertificates,
        activityRecords,
        digitalCertificates,
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: {
        academicAchievements: [],
        competitionCertificates: [],
        activityRecords: [],
        digitalCertificates: [],
      },
    });
  }
}

async function getFinanceHub(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(200).json({
        success: true,
        data: {
          feeStructure: [],
          feePayments: [],
          paymentHistory: [],
          receipts: [],
          pendingDues: [],
          scholarship: [],
          paymentNotifications: [],
        },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const discountWhere = {
      schoolId: child.schoolId,
      isActive: true,
      OR: child.classId ? [{ classId: child.classId }, { classId: null }] : [{ classId: null }],
    };
    const [invoices, payments, activeFeeStructures, discountRules, feeAnnouncements] = await Promise.all([
      prisma.invoice.findMany({
        where: { studentId: child.id },
        include: { feeStructure: { select: { id: true, name: true, amount: true } } },
        orderBy: { dueDate: "desc" },
        take: 100,
      }),
      prisma.payment.findMany({
        where: { studentId: child.id },
        include: { invoice: { select: { invoiceNo: true } } },
        orderBy: { paidAt: "desc" },
        take: 100,
      }),
      prisma.feeStructure.findMany({
        where: { schoolId: child.schoolId, isActive: true },
        orderBy: { name: "asc" },
        take: 50,
      }),
      prisma.feeDiscountRule.findMany({
        where: discountWhere,
        orderBy: { createdAt: "desc" },
        take: 20,
      }),
      prisma.announcement.findMany({
        where: {
          schoolId: child.schoolId,
          status: "SENT",
          audience: { contains: "FEE", mode: "insensitive" },
        },
        orderBy: { sentAt: "desc" },
        take: 10,
      }),
    ]);

    const feeStructure = (invoices.some((item) => item.feeStructure) ? invoices.map((item) => item.feeStructure).filter(Boolean) : activeFeeStructures)
      .filter((item, index, list) => item && list.findIndex((value) => value.id === item.id) === index)
      .map((item) => ({
        head: item.name,
        amount: String(item.amount ?? 0),
      }));

    const feePayments = invoices.map((invoice) => ({
      invoice: invoice.invoiceNo || invoice.id,
      amount: String(invoice.amountDue ?? 0),
      status: invoice.status || "ISSUED",
    }));

    const paymentHistory = payments.map((payment) => ({
      date: payment.paidAt
        ? new Date(payment.paidAt).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" })
        : "",
      amount: String(payment.amount ?? 0),
      mode: payment.method || "",
    }));

    const receipts = payments.map((payment) => ({
      receiptNo: payment.receiptNo || payment.id,
      invoice: payment.invoice?.invoiceNo || payment.invoiceId || "-",
    }));

    const pendingDues = invoices
      .filter((invoice) => ["ISSUED", "PARTIAL", "OVERDUE"].includes(invoice.status))
      .map((invoice) => ({
        title: invoice.feeStructure?.name || invoice.invoiceNo || "Invoice",
        amount: String(Math.max(0, Number(invoice.amountDue ?? 0) - Number(invoice.amountPaid ?? 0))),
        due: invoice.dueDate
          ? new Date(invoice.dueDate).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" })
          : "",
      }));

    const scholarship = discountRules.map((rule) => ({
      scheme: rule.name,
      amount: `${rule.value}`,
      status: rule.isActive ? "Active" : "Inactive",
    }));

    const paymentNotifications = [
      ...pendingDues.slice(0, 3).map((item) => ({
        title: "Payment reminder",
        message: `${item.title} due on ${item.due}`,
      })),
      ...feeAnnouncements.map((item) => ({
        title: item.title || "Fee update",
        message: item.content || "",
      })),
    ].slice(0, 8);

    return res.status(200).json({
      success: true,
      data: {
        feeStructure,
        feePayments,
        paymentHistory,
        receipts,
        pendingDues,
        scholarship,
        paymentNotifications,
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({
      success: true,
      data: {
        feeStructure: [],
        feePayments: [],
        paymentHistory: [],
        receipts: [],
        pendingDues: [],
        scholarship: [],
        paymentNotifications: [],
      },
    });
  }
}

async function getMeetings(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) return res.status(200).json({ success: true, data: { meetings: [] } });
    const child = await resolveChildForParent(parent.id, childId);

    const items = await prisma.meetingRequest.findMany({
      where: { schoolId: child.schoolId, studentId: child.id },
      orderBy: { createdAt: "desc" },
      take: 50,
    });
    const staffIds = [...new Set(items.map((item) => item.staffId).filter(Boolean))];
    const staffRows =
      staffIds.length > 0
        ? await prisma.staff.findMany({
            where: { id: { in: staffIds }, schoolId: child.schoolId },
            select: { id: true, fullName: true },
          })
        : [];
    const staffById = new Map(staffRows.map((item) => [item.id, item.fullName]));

    return res.status(200).json({
      success: true,
      data: {
        meetings: items.map((item) => {
          const remark = parseMeetingRemark(item.remark);
          return {
            id: item.id,
            teacher: staffById.get(item.staffId) || remark.teacherName || "School Staff",
            staffId: item.staffId,
            purpose: item.purpose || "",
            date: item.preferredDate ? item.preferredDate.toISOString() : null,
            timeSlot: remark.timeSlot || "",
            status: item.status || "PENDING",
            remark: item.remark,
          };
        }),
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { meetings: [] } });
  }
}

async function getMessages(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) return res.status(200).json({ success: true, data: { messages: [] } });
    const child = await resolveChildForParent(parent.id, childId);

    const logs = await prisma.auditLog.findMany({
      where: {
        schoolId: child.schoolId,
        action: { in: ["PARENT_MESSAGE_SENT", "STAFF_MESSAGE_SENT"] },
        entityId: child.id,
      },
      orderBy: { createdAt: "asc" },
      take: 100,
    });

    const visibleLogs = logs.filter((log) => {
      if (log.action !== "STAFF_MESSAGE_SENT") return true;
      const meta = log.meta && typeof log.meta === "object" ? log.meta : {};
      return String(meta.audience || "parent").toLowerCase() !== "student";
    });

    return res.status(200).json({
      success: true,
      data: {
        messages: visibleLogs.map((log) => {
          const meta = log.meta && typeof log.meta === "object" ? log.meta : {};
          const fromParent = log.action === "PARENT_MESSAGE_SENT";
          return {
            id: log.id,
            to: fromParent
              ? meta.teacherName || meta.to || "Teacher"
              : meta.staffName || meta.to || "Teacher",
            subject: meta.subject || (fromParent ? "Message" : "Staff message"),
            message: meta.message || "",
            time: formatRelativeTime(log.createdAt),
            createdAt: log.createdAt,
            fromParent,
          };
        }),
      },
    });
  } catch (e) {
    if (isClientError(e)) return next(e);
    return res.status(200).json({ success: true, data: { messages: [] } });
  }
}

async function createMessage(req, res, next) {
  try {
    const { parent } = await resolveParent(req);
    const childId = await resolveChildIdForParent(parent.id, req.query.childId);
    if (!childId) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "No child selected" },
      });
    }
    const child = await resolveChildForParent(parent.id, childId);
    const payload = createParentMessageSchema.parse(req.body || {});
    const staff = await resolveStaffForChild(
      child,
      payload.staffId,
      payload.staffName ?? payload.teacher
    );
    const teacherName = staff?.fullName ?? payload.staffName ?? payload.teacher ?? "Teacher";

    const log = await prisma.auditLog.create({
      data: {
        schoolId: child.schoolId,
        actorId: req.user?.sub || null,
        action: "PARENT_MESSAGE_SENT",
        entity: "ParentCommunication",
        entityId: child.id,
        meta: {
          parentId: parent.id,
          childId: child.id,
          staffId: staff?.id ?? null,
          teacherName,
          subject: payload.subject ?? "General message",
          message: payload.message,
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        id: log.id,
        to: teacherName,
        subject: payload.subject ?? "General message",
        message: payload.message,
        time: formatRelativeTime(log.createdAt),
        createdAt: log.createdAt,
        fromParent: true,
      },
    });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listChildren,
  getHome,
  getAnnouncements,
  getNotifications,
  markNotificationsRead,
  getAttendance,
  createLeaveRequest,
  getFees,
  getFinanceHub,
  getInvoiceDetail,
  payInvoiceBalance,
  quickPayAllInvoices,
  getTimetable,
  getExamTimetable,
  getEventTimetable,
  getEventsHub,
  registerForEvent,
  cancelEventRegistration,
  createMeetingRequest,
  getMeetings,
  getMessages,
  createMessage,
  getProgressReports,
  getLiveClasses,
  getProfileHub,
  updateProfileHub,
  getLibrary,
  getDocuments,
  getAchievements,
  getSettings,
  updateSettings,
};

