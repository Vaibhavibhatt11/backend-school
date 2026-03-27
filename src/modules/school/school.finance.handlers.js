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

const FEES_SUMMARY_SCHEMA_VERSION = "1.0.0";

async function getFeesSummary(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const [invoice, payment, structuresCount, byFeeStructure] = await Promise.all([
      prisma.invoice.aggregate({ where: { schoolId }, _sum: { amountDue: true, amountPaid: true } }),
      prisma.payment.aggregate({ where: { schoolId }, _sum: { amount: true } }),
      prisma.feeStructure.count({ where: { schoolId } }),
      prisma.invoice.groupBy({
        by: ["feeStructureId"],
        where: { schoolId },
        _sum: { amountDue: true, amountPaid: true },
        _count: { _all: true },
      }),
    ]);

    const structureIds = byFeeStructure.map((g) => g.feeStructureId).filter((id) => id != null);
    const feeNames =
      structureIds.length > 0
        ? await prisma.feeStructure.findMany({
            where: { id: { in: structureIds }, schoolId },
            select: { id: true, name: true },
          })
        : [];
    const nameById = new Map(feeNames.map((f) => [f.id, f.name]));

    const categories = byFeeStructure
      .map((g) => {
        const amountDue = g._sum.amountDue || 0;
        const amountPaid = g._sum.amountPaid || 0;
        const feeStructureId = g.feeStructureId ?? null;
        const name =
          feeStructureId == null ? "Uncategorized" : nameById.get(feeStructureId) || "Unknown fee";
        return {
          feeStructureId,
          name,
          amountDue,
          amountPaid,
          outstanding: amountDue - amountPaid,
          invoiceCount: g._count._all,
        };
      })
      .sort((a, b) => a.name.localeCompare(b.name, "en"));

    return res.status(200).json({
      success: true,
      data: {
        schemaVersion: FEES_SUMMARY_SCHEMA_VERSION,
        totals: {
          amountDue: invoice._sum.amountDue || 0,
          amountPaid: invoice._sum.amountPaid || 0,
          outstanding: (invoice._sum.amountDue || 0) - (invoice._sum.amountPaid || 0),
          collections: payment._sum.amount || 0,
          feeStructures: structuresCount,
        },
        categories,
      },
    });
  } catch (error) {
    return next(error);
  }
}

function dayBounds(baseDate = new Date()) {
  const start = new Date(baseDate);
  start.setHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return { start, end };
}

async function getFeesSnapshot(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);

    const now = new Date();
    const { start: todayStart, end: todayEnd } = dayBounds(now);
    const thisWeekStart = new Date(todayStart);
    thisWeekStart.setDate(thisWeekStart.getDate() - 7);
    const lastWeekStart = new Date(todayStart);
    lastWeekStart.setDate(lastWeekStart.getDate() - 14);

    const [todayCollection, pendingTotals, thisWeekCollection, lastWeekCollection] = await Promise.all([
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: todayStart, lt: todayEnd } },
        _sum: { amount: true },
      }),
      prisma.invoice.aggregate({
        where: { schoolId, status: { in: ["ISSUED", "PARTIAL", "OVERDUE"] } },
        _sum: { amountDue: true, amountPaid: true },
      }),
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: thisWeekStart, lt: todayEnd } },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: lastWeekStart, lt: thisWeekStart } },
        _sum: { amount: true },
      }),
    ]);

    const thisWeek = thisWeekCollection._sum.amount || 0;
    const lastWeek = lastWeekCollection._sum.amount || 0;
    const vsLastWeekPct =
      lastWeek > 0 ? Number((((thisWeek - lastWeek) / lastWeek) * 100).toFixed(2)) : thisWeek > 0 ? 100 : 0;
    const pendingAmount = (pendingTotals._sum.amountDue || 0) - (pendingTotals._sum.amountPaid || 0);

    return res.status(200).json({
      success: true,
      data: {
        todayCollected: todayCollection._sum.amount || 0,
        pendingAmount,
        thisWeekCollected: thisWeek,
        lastWeekCollected: lastWeek,
        vsLastWeekPct,
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

const bulkGenerateInvoicesSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.string().trim().min(1).optional(),
  feeStructureId: z.string().trim().min(1),
  dueDate: z.coerce.date(),
  amountPerStudent: z.coerce.number().positive(),
});

async function bulkGenerateInvoices(req, res, next) {
  try {
    const payload = bulkGenerateInvoicesSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    await findScopedOrThrow("feeStructure", payload.feeStructureId, schoolId, "Fee structure", "FEE_STRUCTURE_NOT_FOUND");

    const where = { schoolId, status: "ACTIVE" };
    if (payload.classId) where.classId = payload.classId;
    const students = await prisma.student.findMany({ where, select: { id: true } });
    if (students.length === 0) throw badRequest("No students found for the given criteria", "NO_STUDENTS");

    const created = [];
    for (const s of students) {
      const invoiceNo = generateCode("INV");
      const inv = await prisma.invoice.create({
        data: {
          schoolId,
          studentId: s.id,
          feeStructureId: payload.feeStructureId,
          invoiceNo,
          issueDate: new Date(),
          dueDate: payload.dueDate,
          amountDue: payload.amountPerStudent,
          amountPaid: 0,
          status: "ISSUED",
        },
      });
      created.push({ id: inv.id, invoiceNo: inv.invoiceNo, studentId: s.id });
    }

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "BULK_INVOICES_GENERATED",
        entity: "Invoice",
        meta: { count: created.length, feeStructureId: payload.feeStructureId, classId: payload.classId || null },
      },
    });
    return res.status(201).json({ success: true, data: { generated: created.length, invoices: created.slice(0, 100) } });
  } catch (error) {
    return next(error);
  }
}

async function getDueList(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        classId: z.string().trim().min(1).optional(),
        status: z.enum(["OVERDUE", "PARTIAL", "ISSUED"]).optional(),
        limit: z.coerce.number().int().positive().max(500).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    else where.status = { in: ["OVERDUE", "PARTIAL", "ISSUED"] };
    if (query.classId) where.student = { classId: query.classId };

    const invoices = await prisma.invoice.findMany({
      where,
      take: query.limit || 200,
      orderBy: [{ dueDate: "asc" }, { amountDue: "desc" }],
      include: {
        student: { select: { id: true, admissionNo: true, firstName: true, lastName: true, className: true, section: true } },
        feeStructure: { select: { id: true, name: true } },
      },
    });
    const totalDue = invoices.reduce((sum, i) => sum + (i.amountDue - (i.amountPaid || 0)), 0);
    return res.status(200).json({
      success: true,
      data: { items: invoices, totalDue, count: invoices.length },
    });
  } catch (error) {
    return next(error);
  }
}

async function getCollectionReport(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        date: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
        dateFrom: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
        dateTo: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const start = query.date
      ? new Date(query.date.getFullYear(), query.date.getMonth(), query.date.getDate(), 0, 0, 0)
      : query.dateFrom
        ? new Date(query.dateFrom)
        : new Date(new Date().setDate(new Date().getDate() - 30));
    const end = query.date
      ? new Date(start)
      : query.dateTo
        ? new Date(query.dateTo)
        : new Date();
    if (query.date) end.setDate(end.getDate() + 1);

    const payments = await prisma.payment.findMany({
      where: { schoolId, paidAt: { gte: start, lte: end } },
      orderBy: { paidAt: "asc" },
      include: {
        student: { select: { admissionNo: true, firstName: true, lastName: true } },
        invoice: { select: { invoiceNo: true } },
      },
    });
    const total = payments.reduce((sum, p) => sum + p.amount, 0);
    const byMethod = payments.reduce((acc, p) => {
      acc[p.method] = (acc[p.method] || 0) + p.amount;
      return acc;
    }, {});

    return res.status(200).json({
      success: true,
      data: { dateFrom: start, dateTo: end, totalCollection: total, byMethod, payments: payments.slice(0, 200) },
    });
  } catch (error) {
    return next(error);
  }
}

async function getPendingDuesReport(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        classId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const where = { schoolId, status: { in: ["ISSUED", "PARTIAL", "OVERDUE"] } };
    if (query.classId) where.student = { classId: query.classId };

    const invoices = await prisma.invoice.findMany({
      where,
      include: {
        student: { select: { id: true, admissionNo: true, firstName: true, lastName: true, className: true, section: true } },
      },
    });
    const totalPending = invoices.reduce((sum, i) => sum + (i.amountDue - (i.amountPaid || 0)), 0);
    return res.status(200).json({
      success: true,
      data: { items: invoices, totalPending, count: invoices.length },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStudentLedger(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const studentId = req.params.studentId;
    await findScopedOrThrow("student", studentId, schoolId, "Student", "STUDENT_NOT_FOUND");

    const [invoices, payments] = await Promise.all([
      prisma.invoice.findMany({
        where: { schoolId, studentId },
        orderBy: { issueDate: "asc" },
        include: { feeStructure: { select: { name: true } } },
      }),
      prisma.payment.findMany({
        where: { schoolId, studentId },
        orderBy: { paidAt: "asc" },
        include: { invoice: { select: { invoiceNo: true } } },
      }),
    ]);

    const balance = invoices.reduce((sum, i) => sum + i.amountDue - (i.amountPaid || 0), 0);
    return res.status(200).json({
      success: true,
      data: { studentId, invoices, payments, outstandingBalance: balance },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getFeesSummary,
  getFeesSnapshot,
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
  bulkGenerateInvoices,
  getDueList,
  getCollectionReport,
  getPendingDuesReport,
  getStudentLedger,
  listReportJobs,
  generateReport,
};
