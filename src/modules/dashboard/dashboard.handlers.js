const { z } = require("zod");

const prisma = require("../../lib/prisma");
const { resolveSchoolId } = require("../../utils/schoolScope");
const cache = require("../../lib/cache");
const { CACHE_TTL } = cache;

const querySchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
});

function monthWindow() {
  const now = new Date();
  const monthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1, 0, 0, 0));
  const monthEnd = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1, 0, 0, 0)
  );
  return { monthStart, monthEnd };
}

function todayWindow() {
  const now = new Date();
  const start = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0));
  const end = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1, 0, 0, 0));
  return { start, end };
}

async function schoolAdminDashboard(req, res, next) {
  try {
    const query = querySchema.parse(req.query);
    const schoolId = resolveSchoolId(req, query.schoolId);
    const cacheKey = cache.cacheKeys.dashboardSchoolAdmin(schoolId);
    const cached = await cache.get(cacheKey);
    if (cached) return res.status(200).json(cached);

    const where = schoolId ? { schoolId } : {};
    const { monthStart, monthEnd } = monthWindow();
    const { start: todayStart, end: todayEnd } = todayWindow();
    const trendStart = new Date(todayStart);
    trendStart.setUTCDate(trendStart.getUTCDate() - 6);
    const weekStart = new Date(todayStart);
    weekStart.setUTCDate(weekStart.getUTCDate() - 7);
    const prevWeekStart = new Date(todayStart);
    prevWeekStart.setUTCDate(prevWeekStart.getUTCDate() - 14);

    const [
      students,
      staff,
      classes,
      subjects,
      pendingInvoices,
      invoicesTotals,
      monthCollection,
      announcements,
      staffToday,
      studentAttendanceTrendRows,
      todayCollection,
      thisWeekCollection,
      lastWeekCollection,
      pendingApprovals,
    ] = await Promise.all([
      prisma.student.count({ where }),
      prisma.staff.count({ where }),
      prisma.classRoom.count({ where }),
      prisma.subject.count({ where }),
      prisma.invoice.count({
        where: {
          ...where,
          status: { in: ["ISSUED", "PARTIAL", "OVERDUE"] },
        },
      }),
      prisma.invoice.aggregate({
        where,
        _sum: { amountDue: true, amountPaid: true },
      }),
      prisma.payment.aggregate({
        where: {
          ...where,
          paidAt: {
            gte: monthStart,
            lt: monthEnd,
          },
        },
        _sum: { amount: true },
      }),
      prisma.announcement.count({ where }),
      prisma.staffAttendance.groupBy({
        by: ["status"],
        where: { ...where, date: { gte: todayStart, lt: todayEnd } },
        _count: { _all: true },
      }),
      prisma.studentAttendance.groupBy({
        by: ["date", "status"],
        where: { ...where, date: { gte: trendStart, lt: todayEnd } },
        _count: { _all: true },
      }),
      prisma.payment.aggregate({
        where: { ...where, paidAt: { gte: todayStart, lt: todayEnd } },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: { ...where, paidAt: { gte: weekStart, lt: todayEnd } },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: { ...where, paidAt: { gte: prevWeekStart, lt: weekStart } },
        _sum: { amount: true },
      }),
      Promise.all([
        prisma.admissionApplication.count({ where: { ...where, status: "UNDER_REVIEW" } }),
        prisma.leaveRequest.count({ where: { ...where, status: "PENDING" } }),
        prisma.faceCheckinLog.count({ where: { ...where, status: "PENDING" } }),
      ]),
    ]);

    const staffSummary = { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
    for (const item of staffToday) staffSummary[item.status] = item._count._all;
    const teacherPresent = (staffSummary.PRESENT || 0) + (staffSummary.LATE || 0);
    const teacherTotal = staff || 0;
    const teacherPresence = teacherTotal > 0 ? Number(((teacherPresent / teacherTotal) * 100).toFixed(2)) : 0;

    const trendMap = new Map();
    for (const row of studentAttendanceTrendRows) {
      const key = row.date.toISOString().slice(0, 10);
      if (!trendMap.has(key)) trendMap.set(key, { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 });
      trendMap.get(key)[row.status] = row._count._all;
    }
    const attendanceTrend = [];
    for (let i = 0; i < 7; i += 1) {
      const date = new Date(trendStart);
      date.setUTCDate(trendStart.getUTCDate() + i);
      const key = date.toISOString().slice(0, 10);
      const summary = trendMap.get(key) || { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
      const present = (summary.PRESENT || 0) + (summary.LATE || 0);
      const pct = students > 0 ? Number(((present / students) * 100).toFixed(2)) : 0;
      attendanceTrend.push({
        date: key,
        presentPct: pct,
        summary,
      });
    }

    const thisWeek = thisWeekCollection._sum.amount || 0;
    const lastWeek = lastWeekCollection._sum.amount || 0;
    const feeVsLastWeekPct =
      lastWeek > 0 ? Number((((thisWeek - lastWeek) / lastWeek) * 100).toFixed(2)) : thisWeek > 0 ? 100 : 0;

    const payload = {
      success: true,
      data: {
        scope: schoolId ? { schoolId } : { schoolId: "all" },
        students,
        staff,
        classes,
        subjects,
        announcements,
        pendingInvoices,
        totals: {
          invoiceAmount: invoicesTotals._sum.amountDue || 0,
          paidAmount: invoicesTotals._sum.amountPaid || 0,
          outstandingAmount:
            (invoicesTotals._sum.amountDue || 0) - (invoicesTotals._sum.amountPaid || 0),
          monthCollection: monthCollection._sum.amount || 0,
        },
        ui: {
          studentsTotal: students,
          teacherPresence,
          teacherPresent,
          teacherTotal,
          pendingApprovals: pendingApprovals[0] + pendingApprovals[1] + pendingApprovals[2],
          attendanceTrend,
          feeToday: todayCollection._sum.amount || 0,
          feePending:
            (invoicesTotals._sum.amountDue || 0) - (invoicesTotals._sum.amountPaid || 0),
          feeVsLastWeekPct,
        },
      },
    };
    await cache.set(cacheKey, payload, CACHE_TTL.dashboard());
    return res.status(200).json(payload);
  } catch (error) {
    return next(error);
  }
}

async function hrDashboard(req, res, next) {
  try {
    const query = querySchema.parse(req.query);
    const schoolId = resolveSchoolId(req, query.schoolId);
    const cacheKey = cache.cacheKeys.dashboardHr(schoolId);
    const cached = await cache.get(cacheKey);
    if (cached) return res.status(200).json(cached);

    const where = schoolId ? { schoolId } : {};
    const { start, end } = todayWindow();

    const [staffTotal, presentToday, lateToday, absentToday, leaveToday] = await Promise.all([
      prisma.staff.count({ where }),
      prisma.staffAttendance.count({
        where: {
          ...where,
          date: { gte: start, lt: end },
          status: "PRESENT",
        },
      }),
      prisma.staffAttendance.count({
        where: {
          ...where,
          date: { gte: start, lt: end },
          status: "LATE",
        },
      }),
      prisma.staffAttendance.count({
        where: {
          ...where,
          date: { gte: start, lt: end },
          status: "ABSENT",
        },
      }),
      prisma.staffAttendance.count({
        where: {
          ...where,
          date: { gte: start, lt: end },
          status: "LEAVE",
        },
      }),
    ]);

    const payload = {
      success: true,
      data: {
        scope: schoolId ? { schoolId } : { schoolId: "all" },
        staffTotal,
        attendanceToday: {
          present: presentToday,
          late: lateToday,
          absent: absentToday,
          leave: leaveToday,
        },
      },
    };
    await cache.set(cacheKey, payload, CACHE_TTL.dashboard());
    return res.status(200).json(payload);
  } catch (error) {
    return next(error);
  }
}

async function accountantDashboard(req, res, next) {
  try {
    const query = querySchema.parse(req.query);
    const schoolId = resolveSchoolId(req, query.schoolId);
    const cacheKey = cache.cacheKeys.dashboardAccountant(schoolId);
    const cached = await cache.get(cacheKey);
    if (cached) return res.status(200).json(cached);

    const where = schoolId ? { schoolId } : {};
    const { monthStart, monthEnd } = monthWindow();

    const [invoiceTotals, paidTotals, dueInvoices, monthPayments, studentsWithBalance] =
      await Promise.all([
        prisma.invoice.aggregate({
          where,
          _sum: { amountDue: true, amountPaid: true },
        }),
        prisma.payment.aggregate({ where, _sum: { amount: true } }),
        prisma.invoice.count({
          where: {
            ...where,
            status: { in: ["ISSUED", "PARTIAL", "OVERDUE"] },
          },
        }),
        prisma.payment.aggregate({
          where: {
            ...where,
            paidAt: { gte: monthStart, lt: monthEnd },
          },
          _sum: { amount: true },
        }),
        prisma.invoice.groupBy({
          by: ["studentId"],
          where,
          _sum: { amountDue: true, amountPaid: true },
        }),
      ]);

    const openBalanceStudents = studentsWithBalance.filter(
      (item) => (item._sum.amountDue || 0) - (item._sum.amountPaid || 0) > 0
    ).length;

    const payload = {
      success: true,
      data: {
        scope: schoolId ? { schoolId } : { schoolId: "all" },
        totals: {
          invoiceAmount: invoiceTotals._sum.amountDue || 0,
          invoicePaidAmount: invoiceTotals._sum.amountPaid || 0,
          paymentAmount: paidTotals._sum.amount || 0,
          outstandingAmount:
            (invoiceTotals._sum.amountDue || 0) - (invoiceTotals._sum.amountPaid || 0),
          dueInvoices,
          monthCollection: monthPayments._sum.amount || 0,
          studentsWithOutstandingBalance: openBalanceStudents,
        },
      },
    };
    await cache.set(cacheKey, payload, CACHE_TTL.dashboard());
    return res.status(200).json(payload);
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  schoolAdminDashboard,
  hrDashboard,
  accountantDashboard,
};
