const { z } = require("zod");

const { notFound } = require("../../utils/httpErrors");
const {
  scopedSchoolId,
  prisma,
  paginationFromQuery,
  paginated,
} = require("../school/school.common");
const financeHandlers = require("../school/school.finance.handlers");

async function dashboardOverview(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    const [invoiceTotals, paymentTotals, dueInvoices] = await Promise.all([
      prisma.invoice.aggregate({ where: { schoolId }, _sum: { amountDue: true, amountPaid: true } }),
      prisma.payment.aggregate({ where: { schoolId }, _sum: { amount: true } }),
      prisma.invoice.count({ where: { schoolId, status: { in: ["ISSUED", "PARTIAL", "OVERDUE"] } } }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        totals: {
          invoiceAmount: invoiceTotals._sum.amountDue || 0,
          invoicePaidAmount: invoiceTotals._sum.amountPaid || 0,
          paymentAmount: paymentTotals._sum.amount || 0,
          outstandingAmount: (invoiceTotals._sum.amountDue || 0) - (invoiceTotals._sum.amountPaid || 0),
          dueInvoices,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getPaymentById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    const payment = await prisma.payment.findUnique({
      where: { id: req.params.id },
      include: {
        student: { select: { id: true, firstName: true, lastName: true, admissionNo: true } },
        invoice: { select: { id: true, invoiceNo: true, amountDue: true, amountPaid: true } },
      },
    });
    if (!payment || payment.schoolId !== schoolId) throw notFound("Payment not found", "PAYMENT_NOT_FOUND");
    return res.status(200).json({ success: true, data: { payment } });
  } catch (error) {
    return next(error);
  }
}

async function listStudentBalances(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      minBalance: z.coerce.number().min(0).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const pageInfo = paginationFromQuery(query);
    const skip = (pageInfo.page - 1) * pageInfo.limit;

    const rows = await prisma.invoice.groupBy({
      by: ["studentId"],
      where: { schoolId },
      _sum: { amountDue: true, amountPaid: true },
    });

    let items = rows.map((row) => ({
      studentId: row.studentId,
      amountDue: row._sum.amountDue || 0,
      amountPaid: row._sum.amountPaid || 0,
      balance: (row._sum.amountDue || 0) - (row._sum.amountPaid || 0),
    }));

    if (typeof query.minBalance === "number") {
      items = items.filter((item) => item.balance >= query.minBalance);
    }

    const total = items.length;
    const paged = items.slice(skip, skip + pageInfo.limit);
    const students = await prisma.student.findMany({
      where: { id: { in: paged.map((x) => x.studentId) } },
      select: { id: true, firstName: true, lastName: true, admissionNo: true, className: true, section: true },
    });
    const studentMap = new Map(students.map((s) => [s.id, s]));

    return res.status(200).json({
      success: true,
      data: paginated(
        paged.map((item) => ({ ...item, student: studentMap.get(item.studentId) || null })),
        total,
        pageInfo.page,
        pageInfo.limit
      ),
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  dashboardOverview,
  listFeeStructures: financeHandlers.listFeeStructures,
  createFeeStructure: financeHandlers.createFeeStructure,
  updateFeeStructure: financeHandlers.updateFeeStructure,
  deleteFeeStructure: financeHandlers.deleteFeeStructure,
  listInvoices: financeHandlers.listInvoices,
  createInvoice: financeHandlers.createInvoice,
  getInvoiceById: financeHandlers.getInvoiceById,
  updateInvoiceStatus: financeHandlers.updateInvoiceStatus,
  listPayments: financeHandlers.listPayments,
  createPayment: financeHandlers.createPayment,
  getPaymentById,
  getPaymentReceipt: financeHandlers.getPaymentReceipt,
  listStudentBalances,
  listReportJobs: financeHandlers.listReportJobs,
  generateReport: financeHandlers.generateReport,
};
