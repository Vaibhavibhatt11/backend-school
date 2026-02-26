const { z } = require("zod");

const { badRequest, notFound } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  baseSchoolSearch,
  asUpdateData,
  generateCode,
  computeInvoiceStatus,
} = require("./school.common");

const invoiceStatusEnum = z.enum(["DRAFT", "ISSUED", "PARTIAL", "PAID", "OVERDUE", "CANCELLED"]);
const paymentMethodEnum = z.enum(["CASH", "CARD", "UPI", "BANK_TRANSFER", "ONLINE"]);

const createFeeSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  amount: z.coerce.number().positive(),
  currency: z.string().trim().length(3).optional(),
  frequency: z.string().trim().min(1),
  isActive: z.boolean().optional(),
});

const updateFeeSchema = z.object({
  name: z.string().trim().min(1).optional(),
  amount: z.coerce.number().positive().optional(),
  currency: z.string().trim().length(3).optional(),
  frequency: z.string().trim().min(1).optional(),
  isActive: z.boolean().optional(),
});

const createInvoiceSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  studentId: z.string().trim().min(1),
  feeStructureId: z.union([z.string().trim().min(1), z.null()]).optional(),
  invoiceNo: z.string().trim().min(1).optional(),
  issueDate: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
  dueDate: z.coerce.date(),
  amountDue: z.coerce.number().positive(),
  notes: z.string().trim().min(1).optional(),
});

const invoiceStatusSchema = z.object({ status: invoiceStatusEnum });

const createPaymentSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  studentId: z.string().trim().min(1),
  invoiceId: z.union([z.string().trim().min(1), z.null()]).optional(),
  receiptNo: z.string().trim().min(1).optional(),
  amount: z.coerce.number().positive(),
  method: paymentMethodEnum,
  transactionRef: z.string().trim().min(1).optional(),
  paidAt: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
  notes: z.string().trim().min(1).optional(),
});

const reportSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  type: z.string().trim().min(1),
  params: z.record(z.string(), z.any()).optional(),
});

async function getFeesSummary(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const [invoice, payment, structures] = await Promise.all([
      prisma.invoice.aggregate({ where: { schoolId }, _sum: { amountDue: true, amountPaid: true } }),
      prisma.payment.aggregate({ where: { schoolId }, _sum: { amount: true } }),
      prisma.feeStructure.count({ where: { schoolId } }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        totals: {
          amountDue: invoice._sum.amountDue || 0,
          amountPaid: invoice._sum.amountPaid || 0,
          outstanding: (invoice._sum.amountDue || 0) - (invoice._sum.amountPaid || 0),
          collections: payment._sum.amount || 0,
          feeStructures: structures,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listFeeStructures(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      search: z.string().trim().min(1).optional(),
      schoolId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name"]);

    const [total, items] = await Promise.all([
      prisma.feeStructure.count({ where }),
      prisma.feeStructure.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createFeeStructure(req, res, next) {
  try {
    const payload = createFeeSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const feeStructure = await prisma.feeStructure.create({
      data: {
        schoolId,
        name: payload.name,
        amount: payload.amount,
        currency: (payload.currency || "USD").toUpperCase(),
        frequency: payload.frequency,
        isActive: payload.isActive ?? true,
      },
    });
    return res.status(201).json({ success: true, data: { feeStructure } });
  } catch (error) {
    return next(error);
  }
}

async function updateFeeStructure(req, res, next) {
  try {
    const payload = updateFeeSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const fee = await findScopedOrThrow("feeStructure", req.params.id, schoolId, "Fee structure", "FEE_STRUCTURE_NOT_FOUND");
    const data = asUpdateData(payload);
    if (data.currency) data.currency = data.currency.toUpperCase();
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const feeStructure = await prisma.feeStructure.update({ where: { id: fee.id }, data });
    return res.status(200).json({ success: true, data: { feeStructure } });
  } catch (error) {
    return next(error);
  }
}

async function deleteFeeStructure(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const fee = await findScopedOrThrow("feeStructure", req.params.id, schoolId, "Fee structure", "FEE_STRUCTURE_NOT_FOUND");
    await prisma.feeStructure.delete({ where: { id: fee.id } });
    return res.status(200).json({ success: true, data: { message: "Fee structure deleted successfully" } });
  } catch (error) {
    return next(error);
  }
}

async function listInvoices(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      search: z.string().trim().min(1).optional(),
      schoolId: z.string().trim().min(1).optional(),
      status: invoiceStatusEnum.optional(),
      studentId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    if (query.studentId) where.studentId = query.studentId;
    if (query.search) {
      where.OR = [
        { invoiceNo: { contains: query.search, mode: "insensitive" } },
        { notes: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.invoice.count({ where }),
      prisma.invoice.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          student: { select: { id: true, firstName: true, lastName: true, admissionNo: true } },
          feeStructure: { select: { id: true, name: true, amount: true } },
        },
      }),
    ]);

    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createInvoice(req, res, next) {
  try {
    const payload = createInvoiceSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    await findScopedOrThrow("student", payload.studentId, schoolId, "Student", "STUDENT_NOT_FOUND");
    if (payload.feeStructureId) {
      await findScopedOrThrow("feeStructure", payload.feeStructureId, schoolId, "Fee structure", "FEE_STRUCTURE_NOT_FOUND");
    }

    const invoice = await prisma.invoice.create({
      data: {
        schoolId,
        studentId: payload.studentId,
        feeStructureId: payload.feeStructureId || null,
        invoiceNo: payload.invoiceNo || generateCode("INV"),
        issueDate: payload.issueDate || new Date(),
        dueDate: payload.dueDate,
        amountDue: payload.amountDue,
        amountPaid: 0,
        status: "ISSUED",
        notes: payload.notes,
      },
    });
    return res.status(201).json({ success: true, data: { invoice } });
  } catch (error) {
    return next(error);
  }
}

async function getInvoiceById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const invoice = await prisma.invoice.findUnique({
      where: { id: req.params.id },
      include: {
        student: { select: { id: true, firstName: true, lastName: true, admissionNo: true } },
        feeStructure: { select: { id: true, name: true, amount: true } },
        payments: { orderBy: { paidAt: "desc" } },
      },
    });
    if (!invoice || invoice.schoolId !== schoolId) throw notFound("Invoice not found", "INVOICE_NOT_FOUND");
    return res.status(200).json({ success: true, data: { invoice } });
  } catch (error) {
    return next(error);
  }
}

async function updateInvoiceStatus(req, res, next) {
  try {
    const payload = invoiceStatusSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const invoice = await findScopedOrThrow("invoice", req.params.id, schoolId, "Invoice", "INVOICE_NOT_FOUND");
    const updated = await prisma.invoice.update({ where: { id: invoice.id }, data: { status: payload.status } });
    return res.status(200).json({ success: true, data: { invoice: updated } });
  } catch (error) {
    return next(error);
  }
}

async function listPayments(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      studentId: z.string().trim().min(1).optional(),
      invoiceId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.studentId) where.studentId = query.studentId;
    if (query.invoiceId) where.invoiceId = query.invoiceId;

    const [total, items] = await Promise.all([
      prisma.payment.count({ where }),
      prisma.payment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { paidAt: "desc" },
        include: {
          student: { select: { id: true, firstName: true, lastName: true, admissionNo: true } },
          invoice: { select: { id: true, invoiceNo: true, amountDue: true, amountPaid: true } },
        },
      }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function createPayment(req, res, next) {
  try {
    const payload = createPaymentSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    await findScopedOrThrow("student", payload.studentId, schoolId, "Student", "STUDENT_NOT_FOUND");
    let invoice = null;
    if (payload.invoiceId) {
      invoice = await findScopedOrThrow("invoice", payload.invoiceId, schoolId, "Invoice", "INVOICE_NOT_FOUND");
    }

    const payment = await prisma.payment.create({
      data: {
        schoolId,
        studentId: payload.studentId,
        invoiceId: payload.invoiceId || null,
        receiptNo: payload.receiptNo || generateCode("REC"),
        amount: payload.amount,
        method: payload.method,
        transactionRef: payload.transactionRef,
        paidAt: payload.paidAt || new Date(),
        collectedById: req.user?.sub || null,
        notes: payload.notes,
      },
    });

    if (invoice) {
      const paid = (invoice.amountPaid || 0) + payload.amount;
      await prisma.invoice.update({
        where: { id: invoice.id },
        data: { amountPaid: paid, status: computeInvoiceStatus(invoice.amountDue, paid) },
      });
    }

    return res.status(201).json({ success: true, data: { payment } });
  } catch (error) {
    return next(error);
  }
}

async function getPaymentReceipt(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const payment = await prisma.payment.findUnique({
      where: { id: req.params.id },
      include: {
        school: { select: { id: true, code: true, name: true, email: true, phone: true, currencyCode: true } },
        student: { select: { id: true, admissionNo: true, firstName: true, lastName: true, className: true, section: true } },
        invoice: { select: { id: true, invoiceNo: true, amountDue: true, amountPaid: true, dueDate: true } },
      },
    });
    if (!payment || payment.schoolId !== schoolId) throw notFound("Payment not found", "PAYMENT_NOT_FOUND");
    return res.status(200).json({ success: true, data: { receipt: payment } });
  } catch (error) {
    return next(error);
  }
}

async function listReportJobs(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      status: z.string().trim().min(1).optional(),
      type: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    if (query.type) where.type = query.type;
    const [total, items] = await Promise.all([
      prisma.reportJob.count({ where }),
      prisma.reportJob.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function generateReport(req, res, next) {
  try {
    const payload = reportSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const reportJob = await prisma.reportJob.create({
      data: {
        schoolId,
        type: payload.type,
        status: "QUEUED",
        requestedBy: req.user?.sub || null,
      },
    });
    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "REPORT_GENERATION_REQUESTED",
        entity: "ReportJob",
        entityId: reportJob.id,
        meta: payload.params || {},
      },
    });
    return res.status(201).json({ success: true, data: { reportJob } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getFeesSummary,
  listFeeStructures,
  createFeeStructure,
  updateFeeStructure,
  deleteFeeStructure,
  listInvoices,
  createInvoice,
  getInvoiceById,
  updateInvoiceStatus,
  listPayments,
  createPayment,
  getPaymentReceipt,
  listReportJobs,
  generateReport,
};
