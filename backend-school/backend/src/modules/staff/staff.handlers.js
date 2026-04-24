const { z } = require("zod");

const prisma = require("../../lib/prisma");
const { badRequest, notFound } = require("../../utils/httpErrors");
const { resolveSchoolId } = require("../../utils/schoolScope");

function resolveStaffSchoolId(req) {
  return resolveSchoolId(req, undefined, { requireForSuperadmin: true });
}

async function findStaffProfile(req, schoolId) {
  const userId = req.user?.sub;
  if (!userId) throw notFound("Staff profile not found", "STAFF_NOT_FOUND");

  let staff = await prisma.staff.findFirst({
    where: { schoolId, userId },
  });

  if (!staff && req.user?.email) {
    staff = await prisma.staff.findFirst({
      where: { schoolId, email: req.user.email },
    });
  }

  if (!staff) throw notFound("Staff profile not found", "STAFF_NOT_FOUND");
  return staff;
}

function normalizeText(value) {
  return String(value ?? "").trim().toLowerCase();
}

function asObject(value) {
  return value && typeof value === "object" ? value : {};
}

function formatDateLabel(value) {
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  return `${date.getDate()} ${months[date.getMonth()]} ${date.getFullYear()}`;
}

function formatTimeLabel(value) {
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const hour24 = date.getHours();
  const hour = hour24 === 0 ? 12 : hour24 > 12 ? hour24 - 12 : hour24;
  const minute = String(date.getMinutes()).padStart(2, "0");
  const suffix = hour24 >= 12 ? "PM" : "AM";
  return `${hour}:${minute} ${suffix}`;
}

function buildMeetingRemark(value) {
  const payload = {};
  if (value?.teacherName) payload.teacherName = value.teacherName;
  if (value?.timeSlot) payload.timeSlot = value.timeSlot;
  if (value?.mode) payload.mode = value.mode;
  if (value?.location) payload.location = value.location;
  if (value?.note) payload.note = value.note;
  if (value?.parentId) payload.parentId = value.parentId;
  if (value?.parentName) payload.parentName = value.parentName;
  if (value?.studentId) payload.studentId = value.studentId;
  if (value?.studentName) payload.studentName = value.studentName;
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

function buildMeetingInvitation({
  staffName,
  parentName,
  studentName,
  purpose,
  scheduledAt,
  mode,
  location,
  note,
}) {
  const lines = [
    "Parent-teacher meeting invitation",
    `Teacher: ${staffName || "School Staff"}`,
    `Parent: ${parentName || "Parent"}`,
    ...(studentName ? [`Student: ${studentName}`] : []),
    `Purpose: ${purpose}`,
    `Date: ${formatDateLabel(scheduledAt)}`,
    `Time: ${formatTimeLabel(scheduledAt)}`,
    `Mode: ${mode}`,
    ...(location ? [`Location: ${location}`] : []),
    ...(note ? [`Notes: ${note}`] : []),
  ];
  return lines.join("\n").trim();
}

async function getStaffScopedClassIds(schoolId, staffId) {
  const [classTeacherRows, classSubjectRows] = await Promise.all([
    prisma.classRoom.findMany({
      where: { schoolId, classTeacherId: staffId },
      select: { id: true },
    }),
    prisma.classSubject.findMany({
      where: { teacherId: staffId, class: { schoolId } },
      select: { classId: true },
      distinct: ["classId"],
    }),
  ]);
  return [...new Set([...classTeacherRows.map((item) => item.id), ...classSubjectRows.map((item) => item.classId)])];
}

async function resolveStaffCommunicationTarget({
  schoolId,
  audience,
  recipientId,
  parentId,
  studentId,
}) {
  const targetAudience = normalizeText(audience) === "student" ? "student" : "parent";
  const resolvedStudentId = studentId || (targetAudience === "student" ? recipientId : null);
  const resolvedParentId = parentId || (targetAudience === "parent" ? recipientId : null);

  const student =
    resolvedStudentId
      ? await prisma.student.findFirst({
          where: { id: resolvedStudentId, schoolId },
          select: { id: true, firstName: true, lastName: true, className: true, section: true },
        })
      : null;
  if (resolvedStudentId && !student) {
    throw notFound("Student not found", "STUDENT_NOT_FOUND");
  }

  const parent =
    resolvedParentId
      ? await prisma.parent.findFirst({
          where: { id: resolvedParentId, schoolId },
          select: { id: true, fullName: true, email: true, phone: true },
        })
      : null;
  if (resolvedParentId && !parent) {
    throw notFound("Parent not found", "PARENT_NOT_FOUND");
  }

  if (student && parent) {
    const relation = await prisma.studentParent.findFirst({
      where: { studentId: student.id, parentId: parent.id },
      select: { id: true },
    });
    if (!relation) {
      throw badRequest("Selected parent is not linked to the selected student", "PARENT_STUDENT_MISMATCH");
    }
    return { parent, student };
  }

  if (student && !parent) {
    const relation = await prisma.studentParent.findFirst({
      where: { studentId: student.id },
      orderBy: [{ isPrimary: "desc" }, { createdAt: "asc" }],
      include: { parent: { select: { id: true, fullName: true, email: true, phone: true } } },
    });
    return { parent: relation?.parent ?? null, student };
  }

  if (parent && !student) {
    const relation = await prisma.studentParent.findFirst({
      where: { parentId: parent.id, student: { schoolId } },
      orderBy: [{ isPrimary: "desc" }, { createdAt: "asc" }],
      include: {
        student: {
          select: { id: true, firstName: true, lastName: true, className: true, section: true },
        },
      },
    });
    if (!relation?.student) {
      throw badRequest("Selected parent is not linked to a student yet", "PARENT_WITHOUT_STUDENT");
    }
    return { parent, student: relation.student };
  }

  return { parent: null, student: null };
}

async function safeHomeworkCount(where) {
  try {
    return await prisma.homework.count({ where });
  } catch (error) {
    if (error?.code === "P2021") return 0;
    throw error;
  }
}

const sendStaffMessageSchema = z.object({
  to: z.string().trim().min(1),
  message: z.string().trim().min(1),
  audience: z.enum(["parent", "student"]).optional(),
  recipientId: z.string().trim().min(1).optional(),
  recipientName: z.string().trim().min(1).optional(),
  parentId: z.string().trim().min(1).optional(),
  studentId: z.string().trim().min(1).optional(),
  subject: z.string().trim().min(1).max(200).optional(),
});

const scheduleStaffMeetingSchema = z
  .object({
    parentId: z.string().trim().min(1).optional(),
    parentName: z.string().trim().min(1).max(120).optional(),
    studentId: z.string().trim().min(1).optional(),
    studentName: z.string().trim().min(1).max(120).optional(),
    purpose: z.string().trim().min(1).max(500),
    scheduledAt: z.coerce.date(),
    mode: z.string().trim().min(1).max(60),
    location: z.string().trim().max(160).optional(),
    note: z.string().trim().max(2000).optional(),
  })
  .refine((value) => !!(value.parentId || value.parentName), {
    message: "Parent is required",
  });

async function openAiChatCompletion(systemPrompt, userPrompt) {
  const key = process.env.OPENAI_API_KEY;
  if (!key || !String(key).trim()) {
    return { ok: false, code: "AI_NOT_CONFIGURED" };
  }
  const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${String(key).trim()}`,
    },
    body: JSON.stringify({
      model,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      max_tokens: 1200,
    }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail = body?.error?.message || res.statusText || "OpenAI error";
    return { ok: false, code: "AI_UPSTREAM_ERROR", detail };
  }
  const text = body?.choices?.[0]?.message?.content?.trim();
  if (!text) return { ok: false, code: "AI_EMPTY_RESPONSE", detail: "No content in response" };
  return { ok: true, text };
}

async function getStaffDashboard(req, res, next) {
  try {
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);

    const now = new Date();
    const todayStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0));
    const todayEnd = new Date(todayStart);
    todayEnd.setUTCDate(todayEnd.getUTCDate() + 1);

    const classIds = new Set();
    const [classTeacherRows, classSubjectRows] = await Promise.all([
      prisma.classRoom.findMany({
        where: { schoolId, classTeacherId: staff.id },
        select: { id: true, name: true, section: true },
      }),
      prisma.classSubject.findMany({
        where: { teacherId: staff.id, class: { schoolId } },
        include: { class: { select: { id: true, name: true, section: true } }, subject: { select: { name: true } } },
      }),
    ]);

    for (const row of classTeacherRows) classIds.add(row.id);
    for (const row of classSubjectRows) classIds.add(row.class.id);

    const classList = [...classTeacherRows.map((row) => `${row.name}-${row.section || ""}`.replace(/-$/, ""))];
    for (const row of classSubjectRows) {
      const label = `${row.class.name}-${row.class.section || ""}`.replace(/-$/, "");
      if (!classList.includes(label)) classList.push(label);
    }

    const [todaySessions, recentAnnouncements, upcomingExams, pendingHomework, meetingRequests] = await Promise.all([
      prisma.liveClassSession.findMany({
        where: {
          schoolId,
          teacherId: staff.id,
          startsAt: { gte: todayStart, lt: todayEnd },
        },
        orderBy: { startsAt: "asc" },
        include: {
          classRoom: { select: { name: true, section: true } },
          subject: { select: { name: true } },
        },
        take: 6,
      }),
      prisma.announcement.findMany({
        where: { schoolId },
        orderBy: { createdAt: "desc" },
        take: 8,
        select: { title: true },
      }),
      prisma.exam.findMany({
        where: { schoolId, examDate: { gte: now } },
        orderBy: { examDate: "asc" },
        include: { subject: { select: { name: true } } },
        take: 6,
      }),
      safeHomeworkCount({
        schoolId,
        dueDate: { gte: now },
        OR: classIds.size
          ? [{ classId: { in: [...classIds] } }]
          : [{ createdById: req.user?.sub || "___none___" }],
      }),
      prisma.meetingRequest.findMany({
        where: { schoolId, staffId: staff.id },
        orderBy: { preferredDate: "asc" },
        include: { student: { select: { firstName: true, lastName: true } } },
        take: 6,
      }),
    ]);

    const todaySchedule = todaySessions.map((session) => {
      const hh = String(session.startsAt.getUTCHours()).padStart(2, "0");
      const mm = String(session.startsAt.getUTCMinutes()).padStart(2, "0");
      const subject = session.subject?.name || "Class";
      const cls = session.classRoom ? `${session.classRoom.name}-${session.classRoom.section || ""}`.replace(/-$/, "") : "";
      return `${hh}:${mm} - ${subject}${cls ? ` (${cls})` : ""}`;
    });

    const todayScheduleItems = todaySessions.map((session) => {
      const hh = String(session.startsAt.getUTCHours()).padStart(2, "0");
      const mm = String(session.startsAt.getUTCMinutes()).padStart(2, "0");
      const subject = session.subject?.name || "Class";
      const classLabel = session.classRoom
        ? `${session.classRoom.name}-${session.classRoom.section || ""}`.replace(/-$/, "")
        : "";
      return {
        time: `${hh}:${mm}`,
        subject,
        classLabel,
      };
    });

    const meetings = meetingRequests.map((item) => {
      const name = `${item.student?.firstName || ""} ${item.student?.lastName || ""}`.trim() || "Student";
      const when = item.preferredDate ? item.preferredDate.toISOString().slice(0, 16).replace("T", " ") : "TBD";
      return `${name} - ${when}`;
    });

    const reportDate = new Date();
    reportDate.setUTCDate(reportDate.getUTCDate() - 7);
    const attendanceWhere = {
      schoolId,
      date: { gte: reportDate, lt: todayEnd },
      status: "ABSENT",
    };
    if (classIds.size) {
      attendanceWhere.student = { classId: { in: [...classIds] } };
    }

    const attendanceAlerts = await prisma.studentAttendance.groupBy({
      by: ["studentId"],
      where: attendanceWhere,
      _count: { _all: true },
      orderBy: { studentId: "asc" },
      take: 5,
    });

    const alertStudentIds = attendanceAlerts.map((item) => item.studentId);
    const alertStudents =
      alertStudentIds.length > 0
        ? await prisma.student.findMany({
            where: { id: { in: alertStudentIds } },
            select: { id: true, firstName: true, lastName: true },
          })
        : [];
    const alertMap = new Map(alertStudents.map((item) => [item.id, `${item.firstName} ${item.lastName}`.trim()]));
    const studentAlerts = attendanceAlerts.map((item) => {
      const name = alertMap.get(item.studentId) || "Student";
      return `${name}: ${item._count._all} absences this week`;
    });

    return res.status(200).json({
      success: true,
      message: "Staff dashboard fetched successfully",
      data: {
        staffName: staff.fullName || "",
        todaySchedule,
        todayScheduleItems,
        assignedClasses: classList,
        pendingTasks: [
          `Pending homework plans: ${pendingHomework}`,
          `Upcoming meetings: ${meetings.length}`,
        ],
        studentAlerts,
        upcomingExams: upcomingExams.map((exam) => {
          const date = exam.examDate.toISOString().slice(0, 10);
          return `${exam.subject?.name || exam.name} - ${date}`;
        }),
        meetings,
        notifications: recentAnnouncements.map((item) => item.title),
        homeworkStatus: [`Homework due this week: ${pendingHomework}`],
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStaffProfile(req, res, next) {
  try {
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    const documents = await prisma.staffDocument.findMany({
      where: { schoolId, staffId: staff.id },
      orderBy: { createdAt: "desc" },
      select: { id: true, name: true, url: true, type: true, createdAt: true },
      take: 20,
    });

    const experienceYears = staff.joinDate
      ? Math.max(0, new Date().getUTCFullYear() - new Date(staff.joinDate).getUTCFullYear())
      : 0;

    return res.status(200).json({
      success: true,
      message: "Staff profile fetched successfully",
      data: {
        staffId: staff.id,
        name: staff.fullName || "",
        department: staff.department || "",
        qualification: staff.designation || "",
        experience: `${experienceYears} years`,
        contact: staff.phone || "",
        email: staff.email || "",
        documents: documents.map((doc) => doc.name),
        documentRows: documents.map((doc) => ({
          id: doc.id,
          name: doc.name,
          url: doc.url || "",
          type: doc.type || null,
        })),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStaffReports(req, res, next) {
  try {
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    const sinceDate = new Date();
    sinceDate.setUTCDate(sinceDate.getUTCDate() - 30);

    const classIds = await prisma.classSubject.findMany({
      where: { teacherId: staff.id, class: { schoolId } },
      select: { classId: true },
      distinct: ["classId"],
    });
    const scopedClassIds = classIds.map((item) => item.classId);

    const examWhere = { schoolId, examDate: { gte: new Date() } };
    if (scopedClassIds.length > 0) examWhere.classId = { in: scopedClassIds };

    const attendanceWhere = { schoolId, date: { gte: sinceDate } };
    if (scopedClassIds.length > 0) attendanceWhere.student = { classId: { in: scopedClassIds } };

    const homeworkWhere = { schoolId };
    if (scopedClassIds.length > 0) {
      homeworkWhere.OR = [{ classId: { in: scopedClassIds } }, { createdById: req.user?.sub || "___none___" }];
    } else {
      homeworkWhere.createdById = req.user?.sub || "___none___";
    }

    const [upcomingExams, attendanceCount, homeworkCount, meetingCount] = await Promise.all([
      prisma.exam.count({ where: examWhere }),
      prisma.studentAttendance.count({ where: attendanceWhere }),
      safeHomeworkCount(homeworkWhere),
      prisma.meetingRequest.count({
        where: { schoolId, staffId: staff.id, createdAt: { gte: sinceDate } },
      }),
    ]);

    return res.status(200).json({
      success: true,
      message: "Staff reports fetched successfully",
      data: {
        reportTiles: [
          { title: "Academic Reports", value: `${upcomingExams} upcoming exams` },
          { title: "Attendance Reports", value: `${attendanceCount} records in last 30 days` },
          { title: "Staff Productivity", value: `${homeworkCount} homework plans tracked` },
          { title: "Student Progress", value: `${meetingCount} parent meetings this month` },
        ],
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStaffCommunication(req, res, next) {
  try {
    const query = z
      .object({
        limit: z.coerce.number().int().positive().max(50).optional(),
      })
      .parse(req.query);
    const limit = query.limit || 10;

    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    const classIds = await getStaffScopedClassIds(schoolId, staff.id);

    const [announcements, meetings, studentParents, logs] = await Promise.all([
      prisma.announcement.findMany({
        where: { schoolId },
        orderBy: { createdAt: "desc" },
        take: limit,
        select: { title: true },
      }),
      prisma.meetingRequest.findMany({
        where: { schoolId, staffId: staff.id },
        orderBy: [{ preferredDate: "asc" }, { createdAt: "desc" }],
        include: {
          student: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              className: true,
              section: true,
              parents: {
                select: {
                  isPrimary: true,
                  parent: { select: { id: true, fullName: true } },
                },
              },
            },
          },
        },
        take: limit,
      }),
      prisma.studentParent.findMany({
        where: {
          student: {
            schoolId,
            ...(classIds.length > 0 ? { classId: { in: classIds } } : {}),
          },
        },
        include: {
          parent: { select: { id: true, fullName: true } },
          student: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              className: true,
              section: true,
            },
          },
        },
        take: Math.max(limit * 6, 60),
      }),
      prisma.auditLog.findMany({
        where: {
          schoolId,
          OR: [
            { action: "STAFF_MESSAGE_SENT", actorId: req.user?.sub || null },
            { action: "PARENT_MESSAGE_SENT" },
          ],
        },
        orderBy: { createdAt: "desc" },
        take: Math.max(limit * 20, 200),
      }),
    ]);

    const studentRelationsById = new Map();
    const parentById = new Map();
    for (const relation of studentParents) {
      studentRelationsById.set(relation.student.id, relation);
      parentById.set(relation.parent.id, relation.parent);
    }

    const threadMap = new Map();
    const messageRows = [];

    for (const log of logs) {
      const meta = asObject(log.meta);
      if (
        log.action === "PARENT_MESSAGE_SENT" &&
        meta.staffId &&
        String(meta.staffId) !== String(staff.id)
      ) {
        continue;
      }
      const studentId = String(meta.childId || meta.studentId || log.entityId || "").trim();
      if (studentId && studentRelationsById.size > 0 && !studentRelationsById.has(studentId)) {
        continue;
      }

      let audience = normalizeText(meta.audience) === "student" ? "student" : "parent";
      let recipientId = String(meta.recipientId || "").trim();
      let recipientName = String(meta.recipientName || meta.to || "").trim();

      if (log.action === "PARENT_MESSAGE_SENT") {
        audience = "parent";
        recipientId = String(meta.parentId || recipientId).trim();
        recipientName = recipientName || parentById.get(recipientId)?.fullName || "Parent";
      } else if (audience === "student") {
        recipientId = recipientId || String(meta.studentId || studentId).trim();
        if (!recipientName && recipientId && studentRelationsById.has(recipientId)) {
          const relation = studentRelationsById.get(recipientId);
          recipientName = `${relation.student.firstName || ""} ${relation.student.lastName || ""}`.trim() || "Student";
        }
      } else {
        recipientId = recipientId || String(meta.parentId || "").trim();
        if (!recipientName && recipientId && parentById.has(recipientId)) {
          recipientName = parentById.get(recipientId).fullName || "Parent";
        }
      }

      if (!recipientName) continue;

      const threadKey = recipientId ? `${audience}:${recipientId}` : `${audience}:${normalizeText(recipientName)}`;
      if (!threadMap.has(threadKey)) {
        threadMap.set(threadKey, {
          id: threadKey,
          audience,
          recipientId: recipientId || null,
          to: recipientName,
          last: String(meta.message || "").trim(),
          updatedAt: log.createdAt.toISOString(),
          channel: audience === "student" ? "Student" : "Parent",
        });
      }

      messageRows.push({
        id: log.id,
        threadKey,
        audience,
        recipientId: recipientId || null,
        recipientName,
        message: String(meta.message || "").trim(),
        subject: String(meta.subject || "").trim(),
        createdAt: log.createdAt.toISOString(),
        status: "SENT",
        isOutgoing: log.action === "STAFF_MESSAGE_SENT",
      });
    }

    for (const relation of studentParents) {
      const parentName = relation.parent?.fullName || "Parent";
      const parentId = relation.parent?.id || "";
      if (!parentId) continue;
      const threadKey = `parent:${parentId}`;
      if (threadMap.has(threadKey)) continue;
      threadMap.set(threadKey, {
        id: threadKey,
        audience: "parent",
        recipientId: parentId,
        to: parentName,
        last: `Regarding ${relation.student.firstName} ${relation.student.lastName}`.trim(),
        updatedAt: new Date(0).toISOString(),
        channel: "Parent",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Staff communication data fetched successfully",
      data: {
        chats: [...threadMap.values()].sort(
          (a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
        ),
        announcements: announcements.map((item) => item.title),
        messages: messageRows.sort(
          (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
        ),
        meetings: meetings.map((item) => {
          const remark = parseMeetingRemark(item.remark);
          const studentName = `${item.student?.firstName || ""} ${item.student?.lastName || ""}`.trim();
          const primaryParent =
            item.student?.parents?.find((entry) => entry.isPrimary)?.parent ||
            item.student?.parents?.[0]?.parent ||
            null;
          return {
            id: item.id,
            title: primaryParent?.fullName
              ? `${primaryParent.fullName}${studentName ? ` / ${studentName}` : ""}`
              : studentName || "Parent Meeting",
            parentName: remark.parentName || primaryParent?.fullName || "Parent",
            studentName: remark.studentName || studentName,
            purpose: item.purpose || "Parent meeting",
            scheduledAt: item.preferredDate
              ? item.preferredDate.toISOString()
              : item.createdAt.toISOString(),
            timeSlot: remark.timeSlot || "",
            mode: remark.mode || "Scheduled",
            location: remark.location || "",
            note: remark.note || "",
            status: item.status || "PENDING",
          };
        }),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function sendStaffMessage(req, res, next) {
  try {
    const payload = sendStaffMessageSchema.parse(req.body || {});
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    const { parent, student } = await resolveStaffCommunicationTarget({
      schoolId,
      audience: payload.audience,
      recipientId: payload.recipientId,
      parentId: payload.parentId,
      studentId: payload.studentId,
    });

    const audience = normalizeText(payload.audience) === "student" ? "student" : "parent";
    const recipientId =
      payload.recipientId ||
      (audience === "parent" ? parent?.id : student?.id) ||
      null;
    const recipientName =
      payload.recipientName ||
      (audience === "parent"
        ? parent?.fullName
        : `${student?.firstName || ""} ${student?.lastName || ""}`.trim()) ||
      payload.to;
    const entityId = student?.id || staff.id;

    const log = await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "STAFF_MESSAGE_SENT",
        entity: "StaffCommunication",
        entityId,
        meta: {
          staffId: staff.id,
          staffName: staff.fullName || "",
          audience,
          recipientId,
          recipientName,
          parentId: parent?.id ?? null,
          studentId: student?.id ?? null,
          childId: student?.id ?? null,
          subject: payload.subject ?? "Staff message",
          to: payload.to,
          message: payload.message,
        },
      },
    });

    return res.status(201).json({
      success: true,
      message: "Message sent successfully",
      data: {
        id: log.id,
        to: recipientName,
        message: payload.message,
        subject: payload.subject ?? "Staff message",
        audience,
        recipientId,
        studentId: student?.id ?? null,
        createdAt: log.createdAt,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function scheduleStaffMeeting(req, res, next) {
  try {
    const payload = scheduleStaffMeetingSchema.parse(req.body || {});
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    const { parent, student } = await resolveStaffCommunicationTarget({
      schoolId,
      audience: "parent",
      recipientId: payload.parentId,
      parentId: payload.parentId,
      studentId: payload.studentId,
    });

    if (!student) {
      throw badRequest("A linked student is required to schedule a meeting", "STUDENT_REQUIRED");
    }

    const parentName = payload.parentName || parent?.fullName || "Parent";
    const studentName =
      payload.studentName ||
      `${student.firstName || ""} ${student.lastName || ""}`.trim() ||
      "Student";
    const scheduledAt = payload.scheduledAt;
    const invitationMessage = buildMeetingInvitation({
      staffName: staff.fullName || "School Staff",
      parentName,
      studentName,
      purpose: payload.purpose,
      scheduledAt,
      mode: payload.mode,
      location: payload.location?.trim() || "",
      note: payload.note?.trim() || "",
    });

    const meeting = await prisma.meetingRequest.create({
      data: {
        schoolId,
        studentId: student.id,
        requestedById: req.user?.sub || null,
        staffId: staff.id,
        preferredDate: scheduledAt,
        purpose: payload.purpose,
        status: "SCHEDULED",
        remark: buildMeetingRemark({
          teacherName: staff.fullName || "School Staff",
          timeSlot: formatTimeLabel(scheduledAt),
          mode: payload.mode,
          location: payload.location?.trim() || "",
          note: payload.note?.trim() || "",
          parentId: parent?.id ?? null,
          parentName,
          studentId: student.id,
          studentName,
        }),
      },
    });

    await prisma.auditLog.createMany({
      data: [
        {
          schoolId,
          actorId: req.user?.sub || null,
          action: "STAFF_MEETING_SCHEDULED",
          entity: "MeetingRequest",
          entityId: meeting.id,
          meta: {
            staffId: staff.id,
            staffName: staff.fullName || "",
            parentId: parent?.id ?? null,
            parentName,
            studentId: student.id,
            studentName,
            purpose: payload.purpose,
            scheduledAt: scheduledAt.toISOString(),
            mode: payload.mode,
            location: payload.location?.trim() || "",
            note: payload.note?.trim() || "",
          },
        },
        {
          schoolId,
          actorId: req.user?.sub || null,
          action: "STAFF_MESSAGE_SENT",
          entity: "StaffCommunication",
          entityId: student.id,
          meta: {
            staffId: staff.id,
            staffName: staff.fullName || "",
            audience: "parent",
            recipientId: parent?.id ?? null,
            recipientName: parentName,
            parentId: parent?.id ?? null,
            studentId: student.id,
            childId: student.id,
            subject: "Meeting invitation",
            to: parentName,
            message: invitationMessage,
          },
        },
      ],
    });

    return res.status(201).json({
      success: true,
      message: "Meeting scheduled successfully",
      data: {
        meeting: {
          id: meeting.id,
          title: `${parentName}${studentName ? ` / ${studentName}` : ""}`,
          parentName,
          studentName,
          purpose: meeting.purpose || "",
          scheduledAt: meeting.preferredDate
            ? meeting.preferredDate.toISOString()
            : scheduledAt.toISOString(),
          timeSlot: formatTimeLabel(scheduledAt),
          mode: payload.mode,
          location: payload.location?.trim() || "",
          note: payload.note?.trim() || "",
          status: meeting.status || "SCHEDULED",
        },
        invitationMessage,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function saveMeetingNote(req, res, next) {
  try {
    const payload = z
      .object({
        title: z.string().trim().min(1),
        note: z.string().trim().min(1),
      })
      .parse(req.body || {});
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "STAFF_MEETING_NOTE_SAVED",
        entity: "MeetingNote",
        entityId: staff.id,
        meta: {
          title: payload.title,
          note: payload.note,
        },
      },
    });

    return res.status(201).json({
      success: true,
      message: "Meeting note saved successfully",
      data: { title: payload.title },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStaffSettings(req, res, next) {
  try {
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    const latest = await prisma.auditLog.findFirst({
      where: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "STAFF_SETTINGS_UPDATED",
        entity: "StaffSettings",
        entityId: staff.id,
      },
      orderBy: { createdAt: "desc" },
      select: { meta: true },
    });
    const meta = latest?.meta && typeof latest.meta === "object" ? latest.meta : {};
    return res.status(200).json({
      success: true,
      data: {
        settings: {
          notificationsEnabled: meta.notificationsEnabled !== false,
          privacyMode: meta.privacyMode === true,
          compactView: meta.compactView === true,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function postStaffAiAssist(req, res, next) {
  try {
    const payload = z
      .object({
        prompt: z.string().trim().min(1).max(8000),
        contextType: z.enum(["lesson", "quiz", "homework", "communication", "general"]).optional(),
      })
      .parse(req.body || {});

    const schoolId = resolveStaffSchoolId(req);
    await findStaffProfile(req, schoolId);

    const systemByContext = {
      lesson:
        "You are an expert K-12 teaching coach. Help staff with lesson plans, pacing, differentiation, and classroom activities. Be concise and actionable.",
      quiz:
        "You help teachers draft fair quiz items, rubrics, and learning objectives. Prefer clear wording and Bloom-aligned verbs.",
      homework:
        "You help teachers design homework with clear instructions, reasonable workload, and assessment criteria.",
      communication:
        "You help teachers write professional, warm messages to parents and students. Keep tone appropriate for schools.",
      general:
        "You are an AI teaching assistant embedded in a School ERP. Help staff with pedagogy, operations, and student support. Be practical and safe; do not provide medical/legal advice.",
    };
    const system =
      systemByContext[payload.contextType || "general"] || systemByContext.general;

    const result = await openAiChatCompletion(system, payload.prompt);
    if (!result.ok) {
      if (result.code === "AI_NOT_CONFIGURED") {
        return res.status(503).json({
          success: false,
          message: "AI assistant is not configured. Set OPENAI_API_KEY on the server.",
          error: { code: result.code },
          data: null,
        });
      }
      return res.status(502).json({
        success: false,
        message: result.detail || "AI request failed",
        error: { code: result.code },
        data: null,
      });
    }

    return res.status(200).json({
      success: true,
      message: "AI response generated",
      data: { reply: result.text },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateStaffSettings(req, res, next) {
  try {
    const payload = z
      .object({
        notificationsEnabled: z.boolean().optional(),
        privacyMode: z.boolean().optional(),
        compactView: z.boolean().optional(),
      })
      .parse(req.body || {});
    const schoolId = resolveStaffSchoolId(req);
    const staff = await findStaffProfile(req, schoolId);
    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "STAFF_SETTINGS_UPDATED",
        entity: "StaffSettings",
        entityId: staff.id,
        meta: payload,
      },
    });
    return res.status(200).json({
      success: true,
      data: {
        settings: {
          notificationsEnabled: payload.notificationsEnabled !== false,
          privacyMode: payload.privacyMode === true,
          compactView: payload.compactView === true,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getStaffDashboard,
  getStaffProfile,
  getStaffReports,
  getStaffCommunication,
  sendStaffMessage,
  scheduleStaffMeeting,
  saveMeetingNote,
  getStaffSettings,
  updateStaffSettings,
  postStaffAiAssist,
};
