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
  computeInvoiceStatus,
} = require("./school.common");

const sortOrderEnum = z.enum(["asc", "desc"]);
const borrowStatusEnum = z.enum(["BORROWED", "RETURNED", "OVERDUE"]);
const refundStatusEnum = z.enum(["PENDING", "APPROVED", "REJECTED", "PROCESSED"]);
const inventoryTxnTypeEnum = z.enum(["IN", "OUT"]);
const syncStatusEnum = z.enum(["PENDING", "SYNCED", "FAILED"]);

const dateInput = z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date());
const optionalDateInput = z.preprocess(
  (v) => (v === "" || v === null ? undefined : v),
  z.coerce.date().optional()
);

const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
function assertTime(value, label) {
  if (!timeRegex.test(String(value || ""))) {
    throw badRequest(`${label} must be in HH:MM format`);
  }
}

function ensureDateRange(startDate, endDate, label = "Date range") {
  if (new Date(startDate).getTime() > new Date(endDate).getTime()) {
    throw badRequest(`${label}: startDate must be before or equal to endDate`);
  }
}

async function ensureClassInSchool(classId, schoolId) {
  if (!classId) return null;
  return findScopedOrThrow("classRoom", classId, schoolId, "Class", "CLASS_NOT_FOUND");
}

const listPageQuery = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  search: z.string().trim().min(1).optional(),
  schoolId: z.string().trim().min(1).optional(),
  sortBy: z.string().trim().min(1).optional(),
  sortOrder: sortOrderEnum.optional(),
});

const createAcademicYearSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  startDate: dateInput,
  endDate: dateInput,
  isActive: z.boolean().optional(),
});

const updateAcademicYearSchema = z.object({
  name: z.string().trim().min(1).optional(),
  startDate: optionalDateInput,
  endDate: optionalDateInput,
  isActive: z.boolean().optional(),
});

const createTermSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  academicYearId: z.string().trim().min(1),
  name: z.string().trim().min(1),
  startDate: dateInput,
  endDate: dateInput,
  isActive: z.boolean().optional(),
});

const updateTermSchema = z.object({
  academicYearId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1).optional(),
  startDate: optionalDateInput,
  endDate: optionalDateInput,
  isActive: z.boolean().optional(),
});

const createHolidaySchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  title: z.string().trim().min(1),
  startDate: dateInput,
  endDate: dateInput,
  description: z.string().trim().min(1).optional(),
});

const updateHolidaySchema = z.object({
  title: z.string().trim().min(1).optional(),
  startDate: optionalDateInput,
  endDate: optionalDateInput,
  description: z.union([z.string().trim().min(1), z.null()]).optional(),
});

const createSectionSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  name: z.string().trim().min(1),
  capacity: z.coerce.number().int().positive().optional(),
});

const updateSectionSchema = z.object({
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  name: z.string().trim().min(1).optional(),
  capacity: z.union([z.coerce.number().int().positive(), z.null()]).optional(),
});

const updatePermissionMatrixSchema = z.object({
  matrix: z.record(z.string(), z.any()),
});

const createStaffDocumentSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  url: z.string().url(),
  type: z.string().trim().min(1),
  sizeKb: z.coerce.number().int().positive().optional(),
});

const createTimetablePeriodSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  startTime: z.string().trim().min(1),
  endTime: z.string().trim().min(1),
  sortOrder: z.coerce.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
});

const updateTimetablePeriodSchema = z.object({
  name: z.string().trim().min(1).optional(),
  startTime: z.string().trim().min(1).optional(),
  endTime: z.string().trim().min(1).optional(),
  sortOrder: z.coerce.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
});

const createDiscountRuleSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  description: z.string().trim().min(1).optional(),
  ruleType: z.string().trim().min(1),
  value: z.coerce.number().min(0),
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  isActive: z.boolean().optional(),
});

const updateDiscountRuleSchema = z.object({
  name: z.string().trim().min(1).optional(),
  description: z.union([z.string().trim().min(1), z.null()]).optional(),
  ruleType: z.string().trim().min(1).optional(),
  value: z.coerce.number().min(0).optional(),
  classId: z.union([z.string().trim().min(1), z.null()]).optional(),
  isActive: z.boolean().optional(),
});

const createRefundSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  amount: z.coerce.number().positive(),
  reason: z.string().trim().min(1).optional(),
  status: refundStatusEnum.optional(),
});

const createReportCardTemplateSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  schema: z.record(z.string(), z.any()),
  isDefault: z.boolean().optional(),
});

const updateReportCardTemplateSchema = z.object({
  name: z.string().trim().min(1).optional(),
  schema: z.record(z.string(), z.any()).optional(),
  isDefault: z.boolean().optional(),
});

const createNotificationTemplateSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  code: z.string().trim().min(1),
  title: z.string().trim().min(1),
  body: z.string().trim().min(1),
  channel: z.string().trim().min(1),
  isActive: z.boolean().optional(),
});

const updateNotificationTemplateSchema = z.object({
  code: z.string().trim().min(1).optional(),
  title: z.string().trim().min(1).optional(),
  body: z.string().trim().min(1).optional(),
  channel: z.string().trim().min(1).optional(),
  isActive: z.boolean().optional(),
});

const createDocumentCategorySchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  code: z.string().trim().min(1),
  name: z.string().trim().min(1),
  description: z.string().trim().min(1).optional(),
  isRequired: z.boolean().optional(),
});

const updateDocumentCategorySchema = z.object({
  code: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1).optional(),
  description: z.union([z.string().trim().min(1), z.null()]).optional(),
  isRequired: z.boolean().optional(),
});

const createBackupExportSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  type: z.string().trim().min(1),
});

const createLibraryBookSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  isbn: z.string().trim().min(1).optional(),
  title: z.string().trim().min(1),
  author: z.string().trim().min(1).optional(),
  category: z.string().trim().min(1).optional(),
  totalCopies: z.coerce.number().int().positive().optional(),
  availableCopies: z.coerce.number().int().nonnegative().optional(),
  isActive: z.boolean().optional(),
});

const updateLibraryBookSchema = z.object({
  isbn: z.union([z.string().trim().min(1), z.null()]).optional(),
  title: z.string().trim().min(1).optional(),
  author: z.union([z.string().trim().min(1), z.null()]).optional(),
  category: z.union([z.string().trim().min(1), z.null()]).optional(),
  totalCopies: z.coerce.number().int().positive().optional(),
  availableCopies: z.coerce.number().int().nonnegative().optional(),
  isActive: z.boolean().optional(),
});

const createBorrowSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  bookId: z.string().trim().min(1),
  borrowerType: z.string().trim().min(1),
  borrowerRefId: z.string().trim().min(1),
  dueDate: dateInput,
});

const createInventoryItemSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  sku: z.string().trim().min(1),
  name: z.string().trim().min(1),
  category: z.string().trim().min(1).optional(),
  qty: z.coerce.number().int().nonnegative().optional(),
  unit: z.string().trim().min(1).optional(),
  lowStockThreshold: z.coerce.number().int().nonnegative().optional(),
  isActive: z.boolean().optional(),
});

const updateInventoryItemSchema = z.object({
  sku: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1).optional(),
  category: z.union([z.string().trim().min(1), z.null()]).optional(),
  qty: z.coerce.number().int().nonnegative().optional(),
  unit: z.string().trim().min(1).optional(),
  lowStockThreshold: z.coerce.number().int().nonnegative().optional(),
  isActive: z.boolean().optional(),
});

const createInventoryTransactionSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  itemId: z.string().trim().min(1),
  type: inventoryTxnTypeEnum,
  qty: z.coerce.number().int().positive(),
  note: z.string().trim().min(1).optional(),
});

const createOfflineSyncRecordSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  deviceId: z.string().trim().min(1),
  module: z.string().trim().min(1),
  action: z.string().trim().min(1),
  payload: z.record(z.string(), z.any()).optional(),
  status: syncStatusEnum.optional(),
});

const updateOfflineSyncRecordSchema = z.object({
  status: syncStatusEnum.optional(),
  syncedAt: z.preprocess((v) => (v === "" ? null : v), z.union([z.coerce.date(), z.null()]).optional()),
  attemptedAt: z.preprocess((v) => (v === "" ? null : v), z.union([z.coerce.date(), z.null()]).optional()),
  retryCount: z.coerce.number().int().nonnegative().optional(),
});
async function listAcademicYears(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        isActive: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name"]);
    if (query.isActive) where.isActive = query.isActive === "true";

    const sortBy = ["name", "startDate", "endDate", "createdAt"].includes(query.sortBy)
      ? query.sortBy
      : "startDate";
    const sortOrder = query.sortOrder || "desc";

    const [total, items] = await Promise.all([
      prisma.academicYear.count({ where }),
      prisma.academicYear.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ [sortBy]: sortOrder }],
        include: { _count: { select: { terms: true } } },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createAcademicYear(req, res, next) {
  try {
    const payload = createAcademicYearSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    ensureDateRange(payload.startDate, payload.endDate, "Academic year dates");

    const academicYear = await prisma.$transaction(async (tx) => {
      if (payload.isActive) {
        await tx.academicYear.updateMany({
          where: { schoolId, isActive: true },
          data: { isActive: false },
        });
      }
      return tx.academicYear.create({
        data: {
          schoolId,
          name: payload.name,
          startDate: payload.startDate,
          endDate: payload.endDate,
          isActive: payload.isActive ?? false,
        },
      });
    });

    return res.status(201).json({
      success: true,
      data: { academicYear },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateAcademicYear(req, res, next) {
  try {
    const payload = updateAcademicYearSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "academicYear",
      req.params.id,
      schoolId,
      "Academic year",
      "ACADEMIC_YEAR_NOT_FOUND"
    );
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const startDate = payload.startDate || item.startDate;
    const endDate = payload.endDate || item.endDate;
    ensureDateRange(startDate, endDate, "Academic year dates");

    const academicYear = await prisma.$transaction(async (tx) => {
      if (payload.isActive === true) {
        await tx.academicYear.updateMany({
          where: { schoolId, isActive: true, NOT: { id: item.id } },
          data: { isActive: false },
        });
      }
      return tx.academicYear.update({
        where: { id: item.id },
        data,
      });
    });

    return res.status(200).json({
      success: true,
      data: { academicYear },
    });
  } catch (error) {
    return next(error);
  }
}

async function activateAcademicYear(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "academicYear",
      req.params.id,
      schoolId,
      "Academic year",
      "ACADEMIC_YEAR_NOT_FOUND"
    );

    const academicYear = await prisma.$transaction(async (tx) => {
      await tx.academicYear.updateMany({
        where: { schoolId, isActive: true, NOT: { id: item.id } },
        data: { isActive: false },
      });
      return tx.academicYear.update({
        where: { id: item.id },
        data: { isActive: true },
      });
    });

    return res.status(200).json({
      success: true,
      data: { academicYear, message: "Academic year activated successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteAcademicYear(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "academicYear",
      req.params.id,
      schoolId,
      "Academic year",
      "ACADEMIC_YEAR_NOT_FOUND"
    );
    await prisma.academicYear.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Academic year deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listTerms(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        academicYearId: z.string().trim().min(1).optional(),
        isActive: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name"]);
    if (query.academicYearId) where.academicYearId = query.academicYearId;
    if (query.isActive) where.isActive = query.isActive === "true";

    const [total, items] = await Promise.all([
      prisma.schoolTerm.count({ where }),
      prisma.schoolTerm.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ startDate: "asc" }],
        include: {
          academicYear: {
            select: { id: true, name: true, startDate: true, endDate: true, isActive: true },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createTerm(req, res, next) {
  try {
    const payload = createTermSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    ensureDateRange(payload.startDate, payload.endDate, "Term dates");

    const academicYear = await findScopedOrThrow(
      "academicYear",
      payload.academicYearId,
      schoolId,
      "Academic year",
      "ACADEMIC_YEAR_NOT_FOUND"
    );
    if (
      payload.startDate.getTime() < new Date(academicYear.startDate).getTime() ||
      payload.endDate.getTime() > new Date(academicYear.endDate).getTime()
    ) {
      throw badRequest("Term dates must be inside selected academic year range");
    }

    const term = await prisma.schoolTerm.create({
      data: {
        schoolId,
        academicYearId: payload.academicYearId,
        name: payload.name,
        startDate: payload.startDate,
        endDate: payload.endDate,
        isActive: payload.isActive ?? true,
      },
      include: {
        academicYear: {
          select: { id: true, name: true, startDate: true, endDate: true, isActive: true },
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: { term },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateTerm(req, res, next) {
  try {
    const payload = updateTermSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "schoolTerm",
      req.params.id,
      schoolId,
      "Term",
      "TERM_NOT_FOUND"
    );
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const academicYearId = payload.academicYearId || item.academicYearId;
    const academicYear = await findScopedOrThrow(
      "academicYear",
      academicYearId,
      schoolId,
      "Academic year",
      "ACADEMIC_YEAR_NOT_FOUND"
    );
    const startDate = payload.startDate || item.startDate;
    const endDate = payload.endDate || item.endDate;
    ensureDateRange(startDate, endDate, "Term dates");
    if (
      startDate.getTime() < new Date(academicYear.startDate).getTime() ||
      endDate.getTime() > new Date(academicYear.endDate).getTime()
    ) {
      throw badRequest("Term dates must be inside selected academic year range");
    }

    const term = await prisma.schoolTerm.update({
      where: { id: item.id },
      data,
      include: {
        academicYear: {
          select: { id: true, name: true, startDate: true, endDate: true, isActive: true },
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: { term },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteTerm(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("schoolTerm", req.params.id, schoolId, "Term", "TERM_NOT_FOUND");
    await prisma.schoolTerm.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Term deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listHolidays(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        from: optionalDateInput,
        to: optionalDateInput,
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["title", "description"]);
    if (query.from || query.to) {
      where.AND = [];
      if (query.from) where.AND.push({ endDate: { gte: query.from } });
      if (query.to) where.AND.push({ startDate: { lte: query.to } });
    }

    const [total, items] = await Promise.all([
      prisma.holiday.count({ where }),
      prisma.holiday.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ startDate: "asc" }],
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createHoliday(req, res, next) {
  try {
    const payload = createHolidaySchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    ensureDateRange(payload.startDate, payload.endDate, "Holiday dates");

    const holiday = await prisma.holiday.create({
      data: {
        schoolId,
        title: payload.title,
        startDate: payload.startDate,
        endDate: payload.endDate,
        description: payload.description,
      },
    });

    return res.status(201).json({
      success: true,
      data: { holiday },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateHoliday(req, res, next) {
  try {
    const payload = updateHolidaySchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("holiday", req.params.id, schoolId, "Holiday", "HOLIDAY_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const startDate = payload.startDate || item.startDate;
    const endDate = payload.endDate || item.endDate;
    ensureDateRange(startDate, endDate, "Holiday dates");

    const holiday = await prisma.holiday.update({
      where: { id: item.id },
      data,
    });

    return res.status(200).json({
      success: true,
      data: { holiday },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteHoliday(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("holiday", req.params.id, schoolId, "Holiday", "HOLIDAY_NOT_FOUND");
    await prisma.holiday.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Holiday deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listSections(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        classId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name"]);
    if (query.classId) where.classId = query.classId;

    const [total, items] = await Promise.all([
      prisma.section.count({ where }),
      prisma.section.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ createdAt: "desc" }],
        include: { classRoom: { select: { id: true, name: true, section: true } } },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createSection(req, res, next) {
  try {
    const payload = createSectionSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    if (payload.classId) await ensureClassInSchool(payload.classId, schoolId);

    const section = await prisma.section.create({
      data: {
        schoolId,
        classId: payload.classId || null,
        name: payload.name,
        capacity: payload.capacity || null,
      },
      include: { classRoom: { select: { id: true, name: true, section: true } } },
    });

    return res.status(201).json({
      success: true,
      data: { section },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSection(req, res, next) {
  try {
    const payload = updateSectionSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("section", req.params.id, schoolId, "Section", "SECTION_NOT_FOUND");
    if (payload.classId) await ensureClassInSchool(payload.classId, schoolId);

    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const section = await prisma.section.update({
      where: { id: item.id },
      data,
      include: { classRoom: { select: { id: true, name: true, section: true } } },
    });

    return res.status(200).json({
      success: true,
      data: { section },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteSection(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("section", req.params.id, schoolId, "Section", "SECTION_NOT_FOUND");
    await prisma.section.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Section deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function getPermissionMatrix(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const matrix = await prisma.permissionMatrix.findUnique({
      where: { schoolId },
    });
    return res.status(200).json({
      success: true,
      data: {
        schoolId,
        matrix: matrix?.matrix || {},
        updatedBy: matrix?.updatedBy || null,
        updatedAt: matrix?.updatedAt || null,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updatePermissionMatrix(req, res, next) {
  try {
    const payload = updatePermissionMatrixSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);

    const matrix = await prisma.permissionMatrix.upsert({
      where: { schoolId },
      update: {
        matrix: payload.matrix,
        updatedBy: req.user?.sub || null,
      },
      create: {
        schoolId,
        matrix: payload.matrix,
        updatedBy: req.user?.sub || null,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "PERMISSION_MATRIX_UPDATED",
        entity: "PermissionMatrix",
        entityId: schoolId,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        schoolId: matrix.schoolId,
        matrix: matrix.matrix,
        updatedBy: matrix.updatedBy,
        updatedAt: matrix.updatedAt,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listStaffDocuments(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        type: z.string().trim().min(1).optional(),
        schoolId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const staff = await findScopedOrThrow("staff", req.params.id, schoolId, "Staff", "STAFF_NOT_FOUND");
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId, staffId: staff.id };
    if (query.type) where.type = query.type;

    const [total, items] = await Promise.all([
      prisma.staffDocument.count({ where }),
      prisma.staffDocument.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function addStaffDocument(req, res, next) {
  try {
    const payload = createStaffDocumentSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const staff = await findScopedOrThrow("staff", req.params.id, schoolId, "Staff", "STAFF_NOT_FOUND");

    const document = await prisma.staffDocument.create({
      data: {
        schoolId,
        staffId: staff.id,
        name: payload.name,
        url: payload.url,
        type: payload.type,
        sizeKb: payload.sizeKb,
        uploadedById: req.user?.sub || null,
      },
    });

    return res.status(201).json({
      success: true,
      data: { document },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteStaffDocument(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const staff = await findScopedOrThrow("staff", req.params.id, schoolId, "Staff", "STAFF_NOT_FOUND");
    const doc = await prisma.staffDocument.findUnique({
      where: { id: req.params.docId },
    });
    if (!doc || doc.schoolId !== schoolId || doc.staffId !== staff.id) {
      throw notFound("Document not found", "STAFF_DOCUMENT_NOT_FOUND");
    }

    await prisma.staffDocument.delete({ where: { id: doc.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Document deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listTimetablePeriods(req, res, next) {
  try {
    const query = listPageQuery.parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name", "startTime", "endTime"]);

    const [total, items] = await Promise.all([
      prisma.timetablePeriod.count({ where }),
      prisma.timetablePeriod.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }],
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createTimetablePeriod(req, res, next) {
  try {
    const payload = createTimetablePeriodSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    assertTime(payload.startTime, "startTime");
    assertTime(payload.endTime, "endTime");

    const period = await prisma.timetablePeriod.create({
      data: {
        schoolId,
        name: payload.name,
        startTime: payload.startTime,
        endTime: payload.endTime,
        sortOrder: payload.sortOrder || 0,
        isActive: payload.isActive ?? true,
      },
    });

    return res.status(201).json({
      success: true,
      data: { period },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateTimetablePeriod(req, res, next) {
  try {
    const payload = updateTimetablePeriodSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "timetablePeriod",
      req.params.id,
      schoolId,
      "Timetable period",
      "TIMETABLE_PERIOD_NOT_FOUND"
    );

    if (payload.startTime) assertTime(payload.startTime, "startTime");
    if (payload.endTime) assertTime(payload.endTime, "endTime");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const period = await prisma.timetablePeriod.update({
      where: { id: item.id },
      data,
    });
    return res.status(200).json({
      success: true,
      data: { period },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteTimetablePeriod(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "timetablePeriod",
      req.params.id,
      schoolId,
      "Timetable period",
      "TIMETABLE_PERIOD_NOT_FOUND"
    );
    await prisma.timetablePeriod.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Timetable period deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}
async function listFeeDiscountRules(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        isActive: z.enum(["true", "false"]).optional(),
        classId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name", "description", "ruleType"]);
    if (query.isActive) where.isActive = query.isActive === "true";
    if (query.classId) where.classId = query.classId;

    const [total, items] = await Promise.all([
      prisma.feeDiscountRule.count({ where }),
      prisma.feeDiscountRule.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createFeeDiscountRule(req, res, next) {
  try {
    const payload = createDiscountRuleSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    if (payload.classId) await ensureClassInSchool(payload.classId, schoolId);

    const rule = await prisma.feeDiscountRule.create({
      data: {
        schoolId,
        name: payload.name,
        description: payload.description,
        ruleType: payload.ruleType,
        value: payload.value,
        classId: payload.classId || null,
        isActive: payload.isActive ?? true,
      },
    });

    return res.status(201).json({
      success: true,
      data: { rule },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateFeeDiscountRule(req, res, next) {
  try {
    const payload = updateDiscountRuleSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "feeDiscountRule",
      req.params.id,
      schoolId,
      "Fee discount rule",
      "FEE_DISCOUNT_RULE_NOT_FOUND"
    );
    if (payload.classId) await ensureClassInSchool(payload.classId, schoolId);

    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const rule = await prisma.feeDiscountRule.update({
      where: { id: item.id },
      data,
    });

    return res.status(200).json({
      success: true,
      data: { rule },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteFeeDiscountRule(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "feeDiscountRule",
      req.params.id,
      schoolId,
      "Fee discount rule",
      "FEE_DISCOUNT_RULE_NOT_FOUND"
    );
    await prisma.feeDiscountRule.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Fee discount rule deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listPaymentRefunds(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const payment = await findScopedOrThrow(
      "payment",
      req.params.id,
      schoolId,
      "Payment",
      "PAYMENT_NOT_FOUND"
    );
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId, paymentId: payment.id };

    const [total, items] = await Promise.all([
      prisma.paymentRefund.count({ where }),
      prisma.paymentRefund.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createPaymentRefund(req, res, next) {
  try {
    const payload = createRefundSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const payment = await findScopedOrThrow(
      "payment",
      req.params.id,
      schoolId,
      "Payment",
      "PAYMENT_NOT_FOUND"
    );

    const existing = await prisma.paymentRefund.aggregate({
      where: { schoolId, paymentId: payment.id, status: { in: ["APPROVED", "PROCESSED"] } },
      _sum: { amount: true },
    });
    const alreadyRefunded = existing._sum.amount || 0;
    if (alreadyRefunded + payload.amount > payment.amount) {
      throw badRequest("Refund amount exceeds paid amount");
    }

    const refundStatus = payload.status || "APPROVED";
    const refund = await prisma.$transaction(async (tx) => {
      const created = await tx.paymentRefund.create({
        data: {
          schoolId,
          paymentId: payment.id,
          amount: payload.amount,
          reason: payload.reason,
          status: refundStatus,
          processedById: req.user?.sub || null,
        },
      });

      if (payment.invoiceId && ["APPROVED", "PROCESSED"].includes(refundStatus)) {
        const invoice = await tx.invoice.findUnique({ where: { id: payment.invoiceId } });
        if (invoice) {
          const nextPaid = Math.max(0, (invoice.amountPaid || 0) - payload.amount);
          await tx.invoice.update({
            where: { id: invoice.id },
            data: {
              amountPaid: nextPaid,
              status: computeInvoiceStatus(invoice.amountDue, nextPaid),
            },
          });
        }
      }

      return created;
    });

    return res.status(201).json({
      success: true,
      data: { refund },
    });
  } catch (error) {
    return next(error);
  }
}

async function listReportCardTemplates(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        isDefault: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["name"]);
    if (query.isDefault) where.isDefault = query.isDefault === "true";

    const [total, items] = await Promise.all([
      prisma.reportCardTemplate.count({ where }),
      prisma.reportCardTemplate.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createReportCardTemplate(req, res, next) {
  try {
    const payload = createReportCardTemplateSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);

    const template = await prisma.$transaction(async (tx) => {
      if (payload.isDefault) {
        await tx.reportCardTemplate.updateMany({
          where: { schoolId, isDefault: true },
          data: { isDefault: false },
        });
      }
      return tx.reportCardTemplate.create({
        data: {
          schoolId,
          name: payload.name,
          schema: payload.schema,
          isDefault: payload.isDefault ?? false,
        },
      });
    });

    return res.status(201).json({
      success: true,
      data: { template },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateReportCardTemplate(req, res, next) {
  try {
    const payload = updateReportCardTemplateSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "reportCardTemplate",
      req.params.id,
      schoolId,
      "Report card template",
      "REPORT_CARD_TEMPLATE_NOT_FOUND"
    );
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const template = await prisma.$transaction(async (tx) => {
      if (payload.isDefault === true) {
        await tx.reportCardTemplate.updateMany({
          where: { schoolId, isDefault: true, NOT: { id: item.id } },
          data: { isDefault: false },
        });
      }
      return tx.reportCardTemplate.update({
        where: { id: item.id },
        data,
      });
    });

    return res.status(200).json({
      success: true,
      data: { template },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteReportCardTemplate(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "reportCardTemplate",
      req.params.id,
      schoolId,
      "Report card template",
      "REPORT_CARD_TEMPLATE_NOT_FOUND"
    );
    await prisma.reportCardTemplate.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Report card template deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listNotificationTemplates(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        channel: z.string().trim().min(1).optional(),
        isActive: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["code", "title", "body"]);
    if (query.channel) where.channel = query.channel;
    if (query.isActive) where.isActive = query.isActive === "true";

    const [total, items] = await Promise.all([
      prisma.notificationTemplate.count({ where }),
      prisma.notificationTemplate.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createNotificationTemplate(req, res, next) {
  try {
    const payload = createNotificationTemplateSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const template = await prisma.notificationTemplate.create({
      data: {
        schoolId,
        code: payload.code,
        title: payload.title,
        body: payload.body,
        channel: payload.channel,
        isActive: payload.isActive ?? true,
      },
    });
    return res.status(201).json({
      success: true,
      data: { template },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateNotificationTemplate(req, res, next) {
  try {
    const payload = updateNotificationTemplateSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "notificationTemplate",
      req.params.id,
      schoolId,
      "Notification template",
      "NOTIFICATION_TEMPLATE_NOT_FOUND"
    );
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const template = await prisma.notificationTemplate.update({
      where: { id: item.id },
      data,
    });
    return res.status(200).json({
      success: true,
      data: { template },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteNotificationTemplate(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "notificationTemplate",
      req.params.id,
      schoolId,
      "Notification template",
      "NOTIFICATION_TEMPLATE_NOT_FOUND"
    );
    await prisma.notificationTemplate.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Notification template deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listNotificationLogs(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        schoolId: z.string().trim().min(1).optional(),
        status: z.string().trim().min(1).optional(),
        channel: z.string().trim().min(1).optional(),
        templateId: z.string().trim().min(1).optional(),
        announcementId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    if (query.channel) where.channel = query.channel;
    if (query.templateId) where.templateId = query.templateId;
    if (query.announcementId) where.announcementId = query.announcementId;

    const [total, items] = await Promise.all([
      prisma.notificationLog.count({ where }),
      prisma.notificationLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          template: { select: { id: true, code: true, title: true, channel: true } },
          announcement: { select: { id: true, title: true, audience: true } },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function listDocumentCategories(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        isRequired: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["code", "name", "description"]);
    if (query.isRequired) where.isRequired = query.isRequired === "true";

    const [total, items] = await Promise.all([
      prisma.documentCategory.count({ where }),
      prisma.documentCategory.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createDocumentCategory(req, res, next) {
  try {
    const payload = createDocumentCategorySchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const category = await prisma.documentCategory.create({
      data: {
        schoolId,
        code: payload.code,
        name: payload.name,
        description: payload.description,
        isRequired: payload.isRequired ?? false,
      },
    });
    return res.status(201).json({
      success: true,
      data: { category },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateDocumentCategory(req, res, next) {
  try {
    const payload = updateDocumentCategorySchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "documentCategory",
      req.params.id,
      schoolId,
      "Document category",
      "DOCUMENT_CATEGORY_NOT_FOUND"
    );
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const category = await prisma.documentCategory.update({
      where: { id: item.id },
      data,
    });
    return res.status(200).json({
      success: true,
      data: { category },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteDocumentCategory(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "documentCategory",
      req.params.id,
      schoolId,
      "Document category",
      "DOCUMENT_CATEGORY_NOT_FOUND"
    );
    await prisma.documentCategory.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Document category deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listBackupExportJobs(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        schoolId: z.string().trim().min(1).optional(),
        status: z.string().trim().min(1).optional(),
        type: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.status) where.status = query.status;
    if (query.type) where.type = query.type;

    const [total, items] = await Promise.all([
      prisma.backupExportJob.count({ where }),
      prisma.backupExportJob.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createBackupExportJob(req, res, next) {
  try {
    const payload = createBackupExportSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const job = await prisma.backupExportJob.create({
      data: {
        schoolId,
        type: payload.type,
        status: "QUEUED",
        requestedById: req.user?.sub || null,
      },
    });
    return res.status(201).json({
      success: true,
      data: { job },
    });
  } catch (error) {
    return next(error);
  }
}
async function listLibraryBooks(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        category: z.string().trim().min(1).optional(),
        isActive: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["title", "author", "isbn"]);
    if (query.category) where.category = query.category;
    if (query.isActive) where.isActive = query.isActive === "true";

    const [total, items] = await Promise.all([
      prisma.libraryBook.count({ where }),
      prisma.libraryBook.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);
    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createLibraryBook(req, res, next) {
  try {
    const payload = createLibraryBookSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const totalCopies = payload.totalCopies || 1;
    const availableCopies =
      payload.availableCopies === undefined ? totalCopies : payload.availableCopies;
    if (availableCopies > totalCopies) {
      throw badRequest("availableCopies cannot be greater than totalCopies");
    }

    const book = await prisma.libraryBook.create({
      data: {
        schoolId,
        isbn: payload.isbn,
        title: payload.title,
        author: payload.author,
        category: payload.category,
        totalCopies,
        availableCopies,
        isActive: payload.isActive ?? true,
      },
    });
    return res.status(201).json({
      success: true,
      data: { book },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateLibraryBook(req, res, next) {
  try {
    const payload = updateLibraryBookSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("libraryBook", req.params.id, schoolId, "Library book", "BOOK_NOT_FOUND");

    const totalCopies = payload.totalCopies ?? item.totalCopies;
    const availableCopies = payload.availableCopies ?? item.availableCopies;
    if (availableCopies > totalCopies) {
      throw badRequest("availableCopies cannot be greater than totalCopies");
    }

    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const book = await prisma.libraryBook.update({
      where: { id: item.id },
      data,
    });
    return res.status(200).json({
      success: true,
      data: { book },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteLibraryBook(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow("libraryBook", req.params.id, schoolId, "Library book", "BOOK_NOT_FOUND");
    const activeBorrowCount = await prisma.libraryBorrow.count({
      where: { schoolId, bookId: item.id, status: "BORROWED" },
    });
    if (activeBorrowCount > 0) {
      throw badRequest("Cannot delete book while active borrow records exist");
    }
    await prisma.libraryBook.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Book deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listLibraryBorrows(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        schoolId: z.string().trim().min(1).optional(),
        bookId: z.string().trim().min(1).optional(),
        borrowerType: z.string().trim().min(1).optional(),
        borrowerRefId: z.string().trim().min(1).optional(),
        status: borrowStatusEnum.optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.bookId) where.bookId = query.bookId;
    if (query.borrowerType) where.borrowerType = query.borrowerType;
    if (query.borrowerRefId) where.borrowerRefId = query.borrowerRefId;
    if (query.status) where.status = query.status;

    const [total, items] = await Promise.all([
      prisma.libraryBorrow.count({ where }),
      prisma.libraryBorrow.findMany({
        where,
        skip,
        take: limit,
        orderBy: { issuedAt: "desc" },
        include: {
          book: {
            select: { id: true, title: true, author: true, isbn: true },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createLibraryBorrow(req, res, next) {
  try {
    const payload = createBorrowSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const book = await findScopedOrThrow("libraryBook", payload.bookId, schoolId, "Library book", "BOOK_NOT_FOUND");
    if (!book.isActive) throw badRequest("Book is inactive");
    if (book.availableCopies <= 0) throw badRequest("No copies available for borrowing");

    const borrow = await prisma.$transaction(async (tx) => {
      await tx.libraryBook.update({
        where: { id: book.id },
        data: { availableCopies: { decrement: 1 } },
      });

      return tx.libraryBorrow.create({
        data: {
          schoolId,
          bookId: book.id,
          borrowerType: payload.borrowerType,
          borrowerRefId: payload.borrowerRefId,
          dueDate: payload.dueDate,
          status: "BORROWED",
        },
        include: { book: { select: { id: true, title: true, author: true, isbn: true } } },
      });
    });

    return res.status(201).json({
      success: true,
      data: { borrow },
    });
  } catch (error) {
    return next(error);
  }
}

async function returnLibraryBorrow(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "libraryBorrow",
      req.params.id,
      schoolId,
      "Borrow record",
      "BORROW_NOT_FOUND"
    );
    if (item.status === "RETURNED") {
      return res.status(200).json({
        success: true,
        data: { borrow: item, message: "Borrow already returned" },
      });
    }

    const borrow = await prisma.$transaction(async (tx) => {
      const updated = await tx.libraryBorrow.update({
        where: { id: item.id },
        data: { status: "RETURNED", returnedAt: new Date() },
      });
      await tx.libraryBook.update({
        where: { id: item.bookId },
        data: { availableCopies: { increment: 1 } },
      });
      return updated;
    });

    return res.status(200).json({
      success: true,
      data: { borrow, message: "Book returned successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listInventoryItems(req, res, next) {
  try {
    const query = listPageQuery
      .extend({
        category: z.string().trim().min(1).optional(),
        isActive: z.enum(["true", "false"]).optional(),
        lowStockOnly: z.enum(["true", "false"]).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["sku", "name", "category"]);
    if (query.category) where.category = query.category;
    if (query.isActive) where.isActive = query.isActive === "true";

    const [total, items] = await Promise.all([
      prisma.inventoryItem.count({ where }),
      prisma.inventoryItem.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);
    const filtered =
      query.lowStockOnly === "true"
        ? items.filter((item) => item.qty <= item.lowStockThreshold)
        : items;

    return res.status(200).json({
      success: true,
      data: paginated(filtered, query.lowStockOnly === "true" ? filtered.length : total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createInventoryItem(req, res, next) {
  try {
    const payload = createInventoryItemSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const item = await prisma.inventoryItem.create({
      data: {
        schoolId,
        sku: payload.sku,
        name: payload.name,
        category: payload.category,
        qty: payload.qty ?? 0,
        unit: payload.unit || "pcs",
        lowStockThreshold: payload.lowStockThreshold ?? 0,
        isActive: payload.isActive ?? true,
      },
    });
    return res.status(201).json({
      success: true,
      data: { item },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateInventoryItem(req, res, next) {
  try {
    const payload = updateInventoryItemSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "inventoryItem",
      req.params.id,
      schoolId,
      "Inventory item",
      "INVENTORY_ITEM_NOT_FOUND"
    );
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const updated = await prisma.inventoryItem.update({
      where: { id: item.id },
      data,
    });
    return res.status(200).json({
      success: true,
      data: { item: updated },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteInventoryItem(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const item = await findScopedOrThrow(
      "inventoryItem",
      req.params.id,
      schoolId,
      "Inventory item",
      "INVENTORY_ITEM_NOT_FOUND"
    );
    await prisma.inventoryItem.delete({ where: { id: item.id } });
    return res.status(200).json({
      success: true,
      data: { message: "Inventory item deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listInventoryTransactions(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        schoolId: z.string().trim().min(1).optional(),
        itemId: z.string().trim().min(1).optional(),
        type: inventoryTxnTypeEnum.optional(),
        from: optionalDateInput,
        to: optionalDateInput,
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);

    const where = { schoolId };
    if (query.itemId) where.itemId = query.itemId;
    if (query.type) where.type = query.type;
    if (query.from || query.to) {
      where.createdAt = {};
      if (query.from) where.createdAt.gte = query.from;
      if (query.to) where.createdAt.lte = query.to;
    }

    const [total, items] = await Promise.all([
      prisma.inventoryTransaction.count({ where }),
      prisma.inventoryTransaction.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          item: { select: { id: true, sku: true, name: true, unit: true } },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createInventoryTransaction(req, res, next) {
  try {
    const payload = createInventoryTransactionSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const item = await findScopedOrThrow(
      "inventoryItem",
      payload.itemId,
      schoolId,
      "Inventory item",
      "INVENTORY_ITEM_NOT_FOUND"
    );

    if (payload.type === "OUT" && item.qty < payload.qty) {
      throw badRequest("Insufficient stock for stock-out");
    }

    const transaction = await prisma.$transaction(async (tx) => {
      const updatedQty = payload.type === "IN" ? item.qty + payload.qty : item.qty - payload.qty;
      await tx.inventoryItem.update({
        where: { id: item.id },
        data: { qty: updatedQty },
      });

      return tx.inventoryTransaction.create({
        data: {
          schoolId,
          itemId: item.id,
          type: payload.type,
          qty: payload.qty,
          note: payload.note,
          actorId: req.user?.sub || null,
        },
        include: {
          item: { select: { id: true, sku: true, name: true, qty: true, unit: true } },
        },
      });
    });

    return res.status(201).json({
      success: true,
      data: { transaction },
    });
  } catch (error) {
    return next(error);
  }
}

async function listOfflineSyncRecords(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        schoolId: z.string().trim().min(1).optional(),
        deviceId: z.string().trim().min(1).optional(),
        module: z.string().trim().min(1).optional(),
        status: syncStatusEnum.optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = { schoolId };
    if (query.deviceId) where.deviceId = query.deviceId;
    if (query.module) where.module = query.module;
    if (query.status) where.status = query.status;

    const [total, items] = await Promise.all([
      prisma.offlineSyncRecord.count({ where }),
      prisma.offlineSyncRecord.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(items, total, page, limit),
    });
  } catch (error) {
    return next(error);
  }
}

async function createOfflineSyncRecord(req, res, next) {
  try {
    const payload = createOfflineSyncRecordSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const record = await prisma.offlineSyncRecord.create({
      data: {
        schoolId,
        deviceId: payload.deviceId,
        module: payload.module,
        action: payload.action,
        payload: payload.payload || null,
        status: payload.status || "PENDING",
      },
    });
    return res.status(201).json({
      success: true,
      data: { record },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateOfflineSyncRecord(req, res, next) {
  try {
    const payload = updateOfflineSyncRecordSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const record = await findScopedOrThrow(
      "offlineSyncRecord",
      req.params.id,
      schoolId,
      "Offline sync record",
      "OFFLINE_SYNC_RECORD_NOT_FOUND"
    );

    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");
    const updated = await prisma.offlineSyncRecord.update({
      where: { id: record.id },
      data,
    });
    return res.status(200).json({
      success: true,
      data: { record: updated },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listAcademicYears,
  createAcademicYear,
  updateAcademicYear,
  activateAcademicYear,
  deleteAcademicYear,
  listTerms,
  createTerm,
  updateTerm,
  deleteTerm,
  listHolidays,
  createHoliday,
  updateHoliday,
  deleteHoliday,
  listSections,
  createSection,
  updateSection,
  deleteSection,
  getPermissionMatrix,
  updatePermissionMatrix,
  listStaffDocuments,
  addStaffDocument,
  deleteStaffDocument,
  listTimetablePeriods,
  createTimetablePeriod,
  updateTimetablePeriod,
  deleteTimetablePeriod,
  listFeeDiscountRules,
  createFeeDiscountRule,
  updateFeeDiscountRule,
  deleteFeeDiscountRule,
  listPaymentRefunds,
  createPaymentRefund,
  listReportCardTemplates,
  createReportCardTemplate,
  updateReportCardTemplate,
  deleteReportCardTemplate,
  listNotificationTemplates,
  createNotificationTemplate,
  updateNotificationTemplate,
  deleteNotificationTemplate,
  listNotificationLogs,
  listDocumentCategories,
  createDocumentCategory,
  updateDocumentCategory,
  deleteDocumentCategory,
  listBackupExportJobs,
  createBackupExportJob,
  listLibraryBooks,
  createLibraryBook,
  updateLibraryBook,
  deleteLibraryBook,
  listLibraryBorrows,
  createLibraryBorrow,
  returnLibraryBorrow,
  listInventoryItems,
  createInventoryItem,
  updateInventoryItem,
  deleteInventoryItem,
  listInventoryTransactions,
  createInventoryTransaction,
  listOfflineSyncRecords,
  createOfflineSyncRecord,
  updateOfflineSyncRecord,
};
