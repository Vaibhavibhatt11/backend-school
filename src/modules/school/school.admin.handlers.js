const { z } = require("zod");

const { notFound } = require("../../utils/httpErrors");
const { prisma, scopedSchoolId, paginated, paginationFromQuery } = require("./school.common");

function utcDayStart(dateInput) {
  const date = new Date(dateInput);
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 0, 0, 0));
}

function startOfIsoWeek(dateInput) {
  const date = utcDayStart(dateInput);
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() - (day - 1));
  return date;
}

function asSummary(rows) {
  const summary = { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
  for (const row of rows) {
    summary[row.status] = row._count._all;
  }
  return summary;
}

async function getProfileMe(req, res, next) {
  try {
    const userId = req.user?.sub;
    if (!userId) throw notFound("User not found", "USER_NOT_FOUND");

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        email: true,
        role: true,
        schoolId: true,
        branchId: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
      },
    });

    if (!user) throw notFound("User not found", "USER_NOT_FOUND");
    return res.status(200).json({ success: true, message: "Profile fetched successfully", data: { profile: user } });
  } catch (error) {
    return next(error);
  }
}

async function getPendingApprovalsSummary(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);

    const [leavePending, studentLeavePending, facePending, leaveItems, studentLeaveItems] = await Promise.all([
      prisma.leaveRequest.count({ where: { schoolId, status: "PENDING" } }),
      prisma.studentLeaveRequest.count({ where: { schoolId, status: "PENDING" } }),
      prisma.faceCheckinLog.count({ where: { schoolId, status: "PENDING" } }),
      prisma.leaveRequest.findMany({
        where: { schoolId, status: "PENDING" },
        include: { staff: { select: { fullName: true } } },
        orderBy: { createdAt: "desc" },
        take: 6,
      }),
      prisma.studentLeaveRequest.findMany({
        where: { schoolId, status: "PENDING" },
        include: { student: { select: { firstName: true, lastName: true } } },
        orderBy: { createdAt: "desc" },
        take: 6,
      }),
    ]);

    const topItems = [
      ...leaveItems.map((item) => ({
        id: item.id,
        type: "STAFF_LEAVE",
        title: item.staff?.fullName || "Staff Leave Request",
        submittedAt: item.createdAt,
      })),
      ...studentLeaveItems.map((item) => ({
        id: item.id,
        type: "STUDENT_LEAVE",
        title: `${item.student?.firstName || ""} ${item.student?.lastName || ""}`.trim() || "Student Leave Request",
        submittedAt: item.createdAt,
      })),
    ]
      .sort((a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime())
      .slice(0, 10);

    return res.status(200).json({
      success: true,
      message: "Pending approvals summary fetched successfully",
      data: {
        totalPending: leavePending + studentLeavePending + facePending,
        byType: {
          staffLeave: leavePending,
          studentLeave: studentLeavePending,
          faceCheckins: facePending,
        },
        topItems,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getSchoolNotifications(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        status: z.string().trim().min(1).optional(),
      })
      .parse(req.query);

    const schoolId = scopedSchoolId(req, undefined, true);
    const { page, limit, skip } = paginationFromQuery(query);

    const where = { schoolId };
    if (query.status) where.status = query.status;

    const [total, items] = await Promise.all([
      prisma.notificationLog.count({ where }),
      prisma.notificationLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          template: { select: { title: true, code: true } },
          announcement: { select: { title: true, content: true } },
        },
      }),
    ]);

    const normalized = items.map((item) => ({
      id: item.id,
      type: item.channel,
      status: item.status,
      title: item.announcement?.title || item.template?.title || item.template?.code || "Notification",
      description:
        item.announcement?.content ||
        (typeof item.payload === "object" && item.payload ? item.payload.message || item.payload.body : null) ||
        item.error ||
        "",
      targetType: item.targetType,
      createdAt: item.createdAt,
      unread: item.status !== "sent" && item.status !== "SENT",
    }));

    return res.status(200).json({
      success: true,
      message: "Notifications fetched successfully",
      data: paginated(normalized, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function getFeesSnapshot(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const now = new Date();

    const todayStart = utcDayStart(now);
    const todayEnd = new Date(todayStart);
    todayEnd.setUTCDate(todayEnd.getUTCDate() + 1);

    const weekStart = startOfIsoWeek(now);
    const weekEnd = new Date(weekStart);
    weekEnd.setUTCDate(weekEnd.getUTCDate() + 7);

    const prevWeekStart = new Date(weekStart);
    prevWeekStart.setUTCDate(prevWeekStart.getUTCDate() - 7);
    const prevWeekEnd = new Date(weekStart);

    const [todayPayments, weekPayments, prevWeekPayments, invoiceTotals, school] = await Promise.all([
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: todayStart, lt: todayEnd } },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: weekStart, lt: weekEnd } },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: prevWeekStart, lt: prevWeekEnd } },
        _sum: { amount: true },
      }),
      prisma.invoice.aggregate({
        where: { schoolId, status: { in: ["ISSUED", "PARTIAL", "OVERDUE"] } },
        _sum: { amountDue: true, amountPaid: true },
      }),
      prisma.school.findUnique({
        where: { id: schoolId },
        select: { currencyCode: true },
      }),
    ]);

    const pendingAmount =
      (invoiceTotals._sum.amountDue || 0) - (invoiceTotals._sum.amountPaid || 0);
    const thisWeekCollected = weekPayments._sum.amount || 0;
    const lastWeekCollected = prevWeekPayments._sum.amount || 0;
    const vsLastWeekPct =
      lastWeekCollected > 0
        ? ((thisWeekCollected - lastWeekCollected) / lastWeekCollected) * 100
        : thisWeekCollected > 0
          ? 100
          : 0;

    return res.status(200).json({
      success: true,
      message: "Fee snapshot fetched successfully",
      data: {
        todayCollected: todayPayments._sum.amount || 0,
        thisWeekCollected,
        lastWeekCollected,
        pendingAmount,
        vsLastWeekPct: Number(vsLastWeekPct.toFixed(2)),
        currencyCode: school?.currencyCode || "USD",
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getAttendanceTrend(req, res, next) {
  try {
    const query = z
      .object({
        type: z.enum(["student", "staff"]).default("student"),
        days: z.coerce.number().int().min(1).max(31).default(7),
      })
      .parse(req.query);

    const schoolId = scopedSchoolId(req, undefined, true);
    const baseDate = utcDayStart(new Date());
    const fromDate = new Date(baseDate);
    fromDate.setUTCDate(fromDate.getUTCDate() - (query.days - 1));

    const totalPopulation =
      query.type === "student"
        ? await prisma.student.count({ where: { schoolId } })
        : await prisma.staff.count({ where: { schoolId } });

    const days = [];
    for (let i = 0; i < query.days; i += 1) {
      const start = new Date(fromDate);
      start.setUTCDate(fromDate.getUTCDate() + i);
      const end = new Date(start);
      end.setUTCDate(end.getUTCDate() + 1);

      const rows =
        query.type === "student"
          ? await prisma.studentAttendance.groupBy({
              by: ["status"],
              where: { schoolId, date: { gte: start, lt: end } },
              _count: { _all: true },
            })
          : await prisma.staffAttendance.groupBy({
              by: ["status"],
              where: { schoolId, date: { gte: start, lt: end } },
              _count: { _all: true },
            });

      const summary = asSummary(rows);
      const present = (summary.PRESENT || 0) + (summary.LATE || 0);
      const presentPct = totalPopulation > 0 ? Number(((present / totalPopulation) * 100).toFixed(2)) : 0;

      days.push({
        date: start.toISOString().slice(0, 10),
        total: totalPopulation,
        present,
        presentPct,
        summary,
      });
    }

    return res.status(200).json({
      success: true,
      message: "Attendance trend fetched successfully",
      data: { type: query.type, days },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getProfileMe,
  getPendingApprovalsSummary,
  getSchoolNotifications,
  getFeesSnapshot,
  getAttendanceTrend,
};
