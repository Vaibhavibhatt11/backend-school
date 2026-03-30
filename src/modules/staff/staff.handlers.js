const { z } = require("zod");

const prisma = require("../../lib/prisma");
const { notFound } = require("../../utils/httpErrors");
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

async function safeHomeworkCount(where) {
  try {
    return await prisma.homework.count({ where });
  } catch (error) {
    if (error?.code === "P2021") return 0;
    throw error;
  }
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
        todaySchedule,
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
        name: staff.fullName || "",
        department: staff.department || "",
        qualification: staff.designation || "",
        experience: `${experienceYears} years`,
        contact: staff.phone || "",
        email: staff.email || "",
        documents: documents.map((doc) => doc.name),
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

    const classSubjectRows = await prisma.classSubject.findMany({
      where: { teacherId: staff.id, class: { schoolId } },
      select: { classId: true },
      distinct: ["classId"],
    });
    const classIds = classSubjectRows.map((item) => item.classId);

    const [announcements, meetings, studentParents] = await Promise.all([
      prisma.announcement.findMany({
        where: { schoolId },
        orderBy: { createdAt: "desc" },
        take: limit,
        select: { title: true },
      }),
      prisma.meetingRequest.findMany({
        where: { schoolId, staffId: staff.id },
        orderBy: { createdAt: "desc" },
        include: { student: { select: { firstName: true, lastName: true } } },
        take: limit,
      }),
      prisma.studentParent.findMany({
        where:
          classIds.length > 0
            ? { student: { classId: { in: classIds } } }
            : {},
        include: {
          parent: { select: { fullName: true } },
          student: { select: { firstName: true, lastName: true } },
        },
        take: limit,
      }),
    ]);

    return res.status(200).json({
      success: true,
      message: "Staff communication data fetched successfully",
      data: {
        chats: studentParents.map((item) => ({
          to: `Parent - ${item.parent.fullName}`,
          last: `Regarding ${item.student.firstName} ${item.student.lastName}`.trim(),
        })),
        announcements: announcements.map((item) => item.title),
        meetings: meetings.map((item) => ({
          title: `${item.student?.firstName || ""} ${item.student?.lastName || ""}`.trim() || "Parent Meeting",
          time: item.preferredDate ? item.preferredDate.toISOString().slice(0, 16).replace("T", " ") : "TBD",
        })),
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
};
