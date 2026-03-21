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

    const [
      students,
      staff,
      classes,
      subjects,
      pendingInvoices,
      invoicesTotals,
      monthCollection,
      announcements,
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
    ]);

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
