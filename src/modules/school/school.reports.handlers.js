"use strict";

const { z } = require("zod");
const {
  prisma,
  scopedSchoolId,
  paginationFromQuery,
  paginated,
  dayStart,
} = require("./school.common");
const { badRequest } = require("../../utils/httpErrors");
const { MAX_EXPORT_LIMIT } = require("../../utils/schoolScope");

async function reportStudents(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        className: z.string().trim().min(1).optional(),
        section: z.string().trim().min(1).optional(),
        status: z.enum(["ACTIVE", "INACTIVE"]).optional(),
        format: z.enum(["json", "csv"]).optional(),
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().max(MAX_EXPORT_LIMIT).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.className) where.className = query.className;
    if (query.section) where.section = query.section;
    if (query.status) where.status = query.status;

    const [total, students] = await Promise.all([
      prisma.student.count({ where }),
      prisma.student.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ className: "asc" }, { section: "asc" }, { rollNo: "asc" }],
        select: {
          id: true,
          admissionNo: true,
          firstName: true,
          lastName: true,
          dob: true,
          gender: true,
          className: true,
          section: true,
          rollNo: true,
          status: true,
          guardianPhone: true,
        },
      }),
    ]);

    if ((query.format || "json") === "csv") {
      const header = "admissionNo,firstName,lastName,dob,gender,className,section,rollNo,status,guardianPhone";
      const rows = students.map((s) =>
        [
          s.admissionNo,
          s.firstName,
          s.lastName,
          s.dob ? s.dob.toISOString().slice(0, 10) : "",
          s.gender || "",
          s.className,
          s.section || "",
          s.rollNo ?? "",
          s.status,
          s.guardianPhone || "",
        ]
          .map((v) => (String(v).includes(",") ? `"${String(v).replace(/"/g, '""')}"` : v))
          .join(",")
      );
      res.setHeader("Content-Type", "text/csv; charset=utf-8");
      res.setHeader("Content-Disposition", `attachment; filename="students-report-${Date.now()}.csv"`);
      return res.status(200).send([header, ...rows].join("\r\n"));
    }
    return res.status(200).json({ success: true, data: paginated(students, total, page, limit) });
  } catch (error) {
    return next(error);
  }
}

async function reportAttendance(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        type: z.enum(["student", "staff"]).default("student"),
        dateFrom: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date()),
        dateTo: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date()),
        classId: z.string().trim().min(1).optional(),
        format: z.enum(["json", "csv"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const start = dayStart(query.dateFrom);
    const end = dayStart(query.dateTo);
    if (end < start) throw badRequest("dateTo must be >= dateFrom");

    if (query.type === "student") {
      const where = { schoolId, date: { gte: start, lte: end } };
      if (query.classId) where.student = { classId: query.classId };
      const records = await prisma.studentAttendance.groupBy({
        by: ["date", "status"],
        where,
        _count: { _all: true },
      });
      const summary = records.reduce((acc, r) => {
        const key = r.date.toISOString().slice(0, 10);
        if (!acc[key]) acc[key] = { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
        acc[key][r.status] = r._count._all;
        return acc;
      }, {});
      return res.status(200).json({
        success: true,
        data: { dateFrom: start, dateTo: end, summary, type: "student" },
      });
    }

    const where = { schoolId, date: { gte: start, lte: end } };
    const records = await prisma.staffAttendance.groupBy({
      by: ["date", "status"],
      where,
      _count: { _all: true },
    });
    const summary = records.reduce((acc, r) => {
      const key = r.date.toISOString().slice(0, 10);
      if (!acc[key]) acc[key] = { PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
      acc[key][r.status] = r._count._all;
      return acc;
    }, {});
    return res.status(200).json({
      success: true,
      data: { dateFrom: start, dateTo: end, summary, type: "staff" },
    });
  } catch (error) {
    return next(error);
  }
}

async function reportFees(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        dateFrom: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
        dateTo: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const start = query.dateFrom || new Date(new Date().getFullYear(), new Date().getMonth(), 1);
    const end = query.dateTo || new Date();

    const [invoiceAgg, paymentAgg, overdueCount] = await Promise.all([
      prisma.invoice.aggregate({
        where: { schoolId, issueDate: { gte: start, lte: end } },
        _sum: { amountDue: true, amountPaid: true },
        _count: true,
      }),
      prisma.payment.aggregate({
        where: { schoolId, paidAt: { gte: start, lte: end } },
        _sum: { amount: true },
        _count: true,
      }),
      prisma.invoice.count({
        where: { schoolId, status: "OVERDUE" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        period: { from: start, to: end },
        invoices: {
          count: invoiceAgg._count,
          totalDue: invoiceAgg._sum.amountDue || 0,
          totalPaid: invoiceAgg._sum.amountPaid || 0,
        },
        collections: {
          count: paymentAgg._count,
          total: paymentAgg._sum.amount || 0,
        },
        overdueInvoicesCount: overdueCount,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function reportExamPerformance(req, res, next) {
  try {
    const query = z
      .object({
        schoolId: z.string().trim().min(1).optional(),
        examId: z.string().trim().min(1).optional(),
        classId: z.string().trim().min(1).optional(),
        subjectId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);

    const examWhere = { schoolId };
    if (query.examId) examWhere.id = query.examId;
    if (query.classId) examWhere.classId = query.classId;
    if (query.subjectId) examWhere.subjectId = query.subjectId;

    const results = await prisma.examResult.findMany({
      where: { exam: examWhere },
      include: {
        exam: { select: { id: true, name: true, examDate: true, maxMarks: true, classId: true, subjectId: true } },
        student: { select: { id: true, admissionNo: true, firstName: true, lastName: true, className: true, section: true } },
      },
    });

    const byExam = {};
    for (const r of results) {
      const id = r.exam.id;
      if (!byExam[id]) {
        byExam[id] = {
          exam: r.exam,
          results: [],
          totalMarks: 0,
          avgMarks: 0,
          maxMarks: r.exam.maxMarks,
          count: 0,
        };
      }
      byExam[id].results.push({ student: r.student, marks: r.marks, grade: r.grade });
      byExam[id].totalMarks += r.marks;
      byExam[id].count += 1;
    }
    for (const id of Object.keys(byExam)) {
      const e = byExam[id];
      e.avgMarks = e.count > 0 ? e.totalMarks / e.count : 0;
    }

    return res.status(200).json({
      success: true,
      data: { summary: Object.values(byExam), rawCount: results.length },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  reportStudents,
  reportAttendance,
  reportFees,
  reportExamPerformance,
};
