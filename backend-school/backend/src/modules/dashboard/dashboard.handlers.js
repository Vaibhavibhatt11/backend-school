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
    const trendEnd = new Date(todayEnd);

    const [
      students,
      staff,
      classes,
      subjects,
      pendingInvoices,
      invoicesTotals,
      monthCollection,
      announcements,
      staffAttendanceToday,
      leavePending,
      studentLeavePending,
      facePending,
      todayCollection,
      schoolSettings,
      studentTrendRows,
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
      prisma.leaveRequest.count({ where: { ...where, status: "PENDING" } }),
      prisma.studentLeaveRequest.count({ where: { ...where, status: "PENDING" } }),
      prisma.faceCheckinLog.count({ where: { ...where, status: "PENDING" } }),
      prisma.payment.aggregate({
        where: { ...where, paidAt: { gte: todayStart, lt: todayEnd } },
        _sum: { amount: true },
      }),
      schoolId
        ? prisma.school.findUnique({
            where: { id: schoolId },
            select: { currencyCode: true },
          })
        : Promise.resolve(null),
      prisma.studentAttendance.findMany({
        where: {
          ...where,
          date: { gte: trendStart, lt: trendEnd },
        },
        select: { date: true, status: true },
      }),
    ]);

    const teacherPresent = staffAttendanceToday.reduce((acc, row) => {
      if (row.status === "PRESENT" || row.status === "LATE") return acc + row._count._all;
      return acc;
    }, 0);
    const teacherPresence = staff > 0 ? Number(((teacherPresent / staff) * 100).toFixed(2)) : 0;
    const pendingApprovals = leavePending + studentLeavePending + facePending;
    const feePending =
      (invoicesTotals._sum.amountDue || 0) - (invoicesTotals._sum.amountPaid || 0);

    const dayMap = new Map();
    for (let i = 0; i < 7; i += 1) {
      const day = new Date(trendStart);
      day.setUTCDate(trendStart.getUTCDate() + i);
      dayMap.set(day.toISOString().slice(0, 10), {
        date: day.toISOString().slice(0, 10),
        present: 0,
        late: 0,
        absent: 0,
        leave: 0,
      });
    }
    for (const row of studentTrendRows) {
      const key = row.date.toISOString().slice(0, 10);
      const day = dayMap.get(key);
      if (!day) continue;
      if (row.status === "PRESENT") day.present += 1;
      else if (row.status === "LATE") day.late += 1;
      else if (row.status === "ABSENT") day.absent += 1;
      else if (row.status === "LEAVE") day.leave += 1;
    }
    const attendanceTrend = Array.from(dayMap.values()).map((day) => {
      const present = day.present + day.late;
      return {
        date: day.date,
        presentPct: students > 0 ? Number(((present / students) * 100).toFixed(2)) : 0,
        summary: {
          PRESENT: day.present,
          LATE: day.late,
          ABSENT: day.absent,
          LEAVE: day.leave,
        },
      };
    });
    const studentAttendancePct = attendanceTrend.length
      ? attendanceTrend[attendanceTrend.length - 1].presentPct
      : 0;
    const avgAttendance =
      attendanceTrend.length > 0
        ? Number(
            (
              attendanceTrend.reduce((sum, item) => sum + item.presentPct, 0) / attendanceTrend.length
            ).toFixed(2)
          )
        : 0;

    const payload = {
      success: true,
      message: "School admin dashboard fetched successfully",
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
          teacherTotal: staff,
          teacherPresent,
          teacherPresence,
          pendingApprovals,
          feeToday: todayCollection._sum.amount || 0,
          feePending,
          feeVsLastWeekPct: 0,
          attendanceTrend,
          studentAttendancePct,
          studentAttendance: avgAttendance,
          currencyCode: schoolSettings?.currencyCode || "USD",
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
