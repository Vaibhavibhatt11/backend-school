const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const { z } = require("zod");

const env = require("../../config/env");
const prisma = require("../../lib/prisma");
const { badRequest, notFound } = require("../../utils/httpErrors");
const { parsePagination, getPaginationMeta } = require("../../utils/schoolScope");

const schoolStatusEnum = z.enum(["ACTIVE", "PENDING", "SUSPENDED"]);
const ticketPriorityEnum = z.enum(["LOW", "MEDIUM", "HIGH"]);
const ticketStatusEnum = z.enum(["OPEN", "PENDING", "RESOLVED", "CLOSED"]);

const listSchoolsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  search: z.string().trim().min(1).optional(),
  status: schoolStatusEnum.optional(),
});

const createSchoolSchema = z.object({
  code: z.string().trim().min(2),
  name: z.string().trim().min(2),
  email: z.string().email().optional(),
  phone: z.string().trim().min(3).optional(),
  timezone: z.string().trim().min(2).optional(),
  currencyCode: z.string().trim().min(3).max(3).optional(),
  status: schoolStatusEnum.optional(),
});

const updateSchoolSchema = z.object({
  code: z.string().trim().min(2).optional(),
  name: z.string().trim().min(2).optional(),
  email: z.union([z.string().email(), z.null()]).optional(),
  phone: z.union([z.string().trim().min(3), z.null()]).optional(),
  timezone: z.string().trim().min(2).optional(),
  currencyCode: z.string().trim().min(3).max(3).optional(),
});

const updateSchoolStatusSchema = z.object({
  status: schoolStatusEnum,
});

const subscriptionPlanSchema = z.object({
  planCode: z.string().trim().min(1),
  validUntil: z.preprocess(
    (value) => (value === null || value === "" ? undefined : value),
    z.coerce.date().optional()
  ),
});

const subscriptionAutoRenewSchema = z.object({
  autoRenew: z.boolean(),
});

const planUpdateSchema = z.object({
  name: z.string().trim().min(1).optional(),
  priceMonthly: z.coerce.number().min(0).optional(),
  priceYearly: z.coerce.number().min(0).optional(),
  isActive: z.boolean().optional(),
  features: z.array(z.string().trim().min(1)).optional(),
  students: z.coerce.number().int().positive().optional(),
  storage: z.coerce.number().int().positive().optional(),
});

const ticketListQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  search: z.string().trim().min(1).optional(),
  schoolId: z.string().trim().min(1).optional(),
  status: ticketStatusEnum.optional(),
  priority: ticketPriorityEnum.optional(),
});

const ticketReplySchema = z.object({
  message: z.string().trim().min(1),
});

const ticketStatusUpdateSchema = z.object({
  status: ticketStatusEnum,
  assignedToId: z.string().trim().min(1).optional(),
});

const configurationUpdateSchema = z.object({
  platformName: z.string().trim().min(1).optional(),
  supportEmail: z.string().email().optional(),
  supportPhone: z.string().trim().min(3).optional(),
  defaultTimezone: z.string().trim().min(2).optional(),
  defaultCurrencyCode: z.string().trim().length(3).optional(),
  maintenanceMode: z.boolean().optional(),
  newSignups: z.boolean().optional(),
  trialDays: z.coerce.number().int().positive().optional(),
  taxRate: z.coerce.number().min(0).optional(),
  smsUrl: z.string().trim().min(1).optional(),
  smsApiKey: z.string().trim().min(1).optional(),
  senderId: z.string().trim().min(1).optional(),
  whatsAppAccountId: z.string().trim().min(1).optional(),
  whatsAppToken: z.string().trim().min(1).optional(),
  features: z.record(z.string(), z.boolean()).optional(),
});

const activeStatusEnum = z.enum(["ACTIVE", "INACTIVE"]);
const invitationStatusEnum = z.enum(["PENDING", "ACCEPTED", "CANCELLED", "EXPIRED"]);
const managedStaffRoleEnum = z.enum(["HR", "TEACHER"]);
const invitationRoleEnum = z.enum(["SCHOOLADMIN", "ACCOUNTANT", "HR", "TEACHER", "PARENT"]);

const listManagedUsersQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  search: z.string().trim().min(1).optional(),
  schoolId: z.string().trim().min(1).optional(),
  status: activeStatusEnum.optional(),
});

const createAccountantSchema = z.object({
  employeeId: z.string().trim().min(1).optional(),
  firstName: z.string().trim().min(1).optional(),
  lastName: z.string().trim().min(1).optional(),
  fullName: z.string().trim().min(1).optional(),
  email: z.string().email(),
  phone: z.string().trim().min(3).optional(),
  schoolId: z.string().trim().min(1).optional(),
  designation: z.string().trim().min(1).optional(),
  department: z.string().trim().min(1).optional(),
  password: z.string().min(8).optional(),
});

const updateAccountantSchema = z.object({
  employeeId: z.union([z.string().trim().min(1), z.null()]).optional(),
  firstName: z.union([z.string().trim().min(1), z.null()]).optional(),
  lastName: z.union([z.string().trim().min(1), z.null()]).optional(),
  fullName: z.union([z.string().trim().min(1), z.null()]).optional(),
  email: z.union([z.string().email(), z.null()]).optional(),
  phone: z.union([z.string().trim().min(3), z.null()]).optional(),
  schoolId: z.union([z.string().trim().min(1), z.null()]).optional(),
  designation: z.union([z.string().trim().min(1), z.null()]).optional(),
  department: z.union([z.string().trim().min(1), z.null()]).optional(),
  isActive: z.boolean().optional(),
});

const createStaffSchema = z.object({
  employeeId: z.string().trim().min(1).optional(),
  firstName: z.string().trim().min(1).optional(),
  lastName: z.string().trim().min(1).optional(),
  fullName: z.string().trim().min(1).optional(),
  email: z.string().email(),
  phone: z.string().trim().min(3).optional(),
  schoolId: z.string().trim().min(1).optional(),
  designation: z.string().trim().min(1).optional(),
  department: z.string().trim().min(1).optional(),
  role: managedStaffRoleEnum.optional(),
  password: z.string().min(8).optional(),
});

const updateStaffSchema = z.object({
  employeeId: z.union([z.string().trim().min(1), z.null()]).optional(),
  firstName: z.union([z.string().trim().min(1), z.null()]).optional(),
  lastName: z.union([z.string().trim().min(1), z.null()]).optional(),
  fullName: z.union([z.string().trim().min(1), z.null()]).optional(),
  email: z.union([z.string().email(), z.null()]).optional(),
  phone: z.union([z.string().trim().min(3), z.null()]).optional(),
  schoolId: z.union([z.string().trim().min(1), z.null()]).optional(),
  designation: z.union([z.string().trim().min(1), z.null()]).optional(),
  department: z.union([z.string().trim().min(1), z.null()]).optional(),
  role: managedStaffRoleEnum.optional(),
  isActive: z.boolean().optional(),
});

const managedStatusUpdateSchema = z.object({
  status: activeStatusEnum,
});

const createInvitationSchema = z.object({
  email: z.string().email(),
  role: invitationRoleEnum,
  schoolId: z.string().trim().min(1).optional(),
  message: z.string().trim().min(1).optional(),
  expiresInDays: z.coerce.number().int().positive().max(90).optional(),
});

const listInvitationsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  status: invitationStatusEnum.optional(),
  schoolId: z.string().trim().min(1).optional(),
  search: z.string().trim().min(1).optional(),
});

const securityUpdateSchema = z.object({
  enforce2FA: z.boolean().optional(),
  passwordMinLength: z.coerce.number().int().min(6).max(128).optional(),
  passwordUppercase: z.boolean().optional(),
  passwordSpecial: z.boolean().optional(),
  passwordExpiry: z.coerce.number().int().min(0).max(3650).optional(),
  jwtExpiry: z.coerce.number().int().positive().max(43200).optional(),
  refreshExpiry: z.coerce.number().int().positive().max(3650).optional(),
});

const listSessionsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  userId: z.string().trim().min(1).optional(),
});

const revokeAllSessionsSchema = z.object({
  userId: z.string().trim().min(1).optional(),
  currentRefreshToken: z.string().trim().min(1).optional(),
});

const listAuditLogsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  from: z.preprocess(
    (value) => (value === null || value === "" ? undefined : value),
    z.coerce.date().optional()
  ),
  to: z.preprocess(
    (value) => (value === null || value === "" ? undefined : value),
    z.coerce.date().optional()
  ),
  user: z.string().trim().min(1).optional(),
  action: z.string().trim().min(1).optional(),
  schoolId: z.string().trim().min(1).optional(),
});

const listNotificationsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  unreadOnly: z.enum(["true", "false"]).optional(),
});

const DEFAULT_PLANS = [
  {
    planCode: "BASIC",
    name: "Basic",
    priceMonthly: 49,
    priceYearly: 499,
    isActive: true,
    features: ["Students", "Attendance", "Basic Fees"],
    maxStudents: 500,
    storageGb: 25,
  },
  {
    planCode: "PRO",
    name: "Pro",
    priceMonthly: 99,
    priceYearly: 999,
    isActive: true,
    features: ["Everything in Basic", "Accounting", "HR", "Reports"],
    maxStudents: 1000,
    storageGb: 100,
  },
  {
    planCode: "ENTERPRISE",
    name: "Enterprise",
    priceMonthly: 199,
    priceYearly: 1999,
    isActive: true,
    features: ["Everything in Pro", "AI", "Priority Support", "Custom Integrations"],
    maxStudents: 5000,
    storageGb: 500,
  },
];

const DEFAULT_CONFIGURATION = {
  platformName: "School ERP",
  supportEmail: "support@schoolerp.local",
  supportPhone: "+1-555-0000",
  defaultTimezone: "UTC",
  defaultCurrencyCode: "USD",
  maintenanceMode: false,
  newSignups: true,
  trialDays: 14,
  taxRate: 0,
  smsUrl: null,
  smsApiKey: null,
  senderId: null,
  whatsAppAccountId: null,
  whatsAppToken: null,
  features: {
    aiFaq: true,
    faceCheckin: true,
    liveClasses: true,
    accounting: true,
    hr: true,
  },
};

function toSchoolDto(school) {
  return {
    id: school.id,
    code: school.code,
    name: school.name,
    email: school.email,
    phone: school.phone,
    status: school.status,
    timezone: school.timezone,
    currencyCode: school.currencyCode,
    createdAt: school.createdAt,
    updatedAt: school.updatedAt,
  };
}

function toTicketDto(ticket) {
  return {
    id: ticket.id,
    schoolId: ticket.schoolId,
    schoolName: ticket.school?.name || null,
    ticketNo: ticket.ticketNo,
    issue: ticket.subject,
    subject: ticket.subject,
    description: ticket.description,
    priority: ticket.priority,
    status: ticket.status,
    createdById: ticket.createdById,
    admin: ticket.createdBy?.fullName || null,
    assignedToId: ticket.assignedToId,
    time: ticket.createdAt,
    createdAt: ticket.createdAt,
    updatedAt: ticket.updatedAt,
    school: ticket.school
      ? {
          id: ticket.school.id,
          name: ticket.school.name,
          code: ticket.school.code,
        }
      : null,
    messagesCount: ticket._count?.messages ?? undefined,
  };
}

function percentGrowth(current, previous) {
  if (!previous || previous <= 0) {
    return current > 0 ? 100 : 0;
  }
  return Number((((current - previous) / previous) * 100).toFixed(2));
}

function timeAgo(isoDate) {
  const target = new Date(isoDate).getTime();
  const diff = Math.max(0, Date.now() - target);
  const sec = Math.floor(diff / 1000);
  if (sec < 60) return `${sec}s ago`;
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min} mins ago`;
  const hrs = Math.floor(min / 60);
  if (hrs < 24) return `${hrs} hrs ago`;
  const days = Math.floor(hrs / 24);
  return `${days} days ago`;
}

function normalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

function splitName(fullName) {
  const trimmed = String(fullName || "").trim();
  if (!trimmed) return { firstName: "", lastName: "" };
  const [firstName, ...rest] = trimmed.split(/\s+/);
  return { firstName, lastName: rest.join(" ") };
}

function buildFullName({ fullName, firstName, lastName }) {
  const direct = typeof fullName === "string" ? fullName.trim() : "";
  if (direct) return direct;
  const first = typeof firstName === "string" ? firstName.trim() : "";
  const last = typeof lastName === "string" ? lastName.trim() : "";
  const joined = `${first} ${last}`.trim();
  if (!joined) throw badRequest("Either fullName or firstName is required");
  return joined;
}

function hashToken(token) {
  return crypto.createHash("sha256").update(String(token)).digest("hex");
}

function randomTempPassword() {
  return `Tmp@${crypto.randomBytes(6).toString("hex")}1A`;
}

function toStatusFlag(status) {
  return status === "ACTIVE";
}

function fromStatusFlag(isActive) {
  return isActive ? "ACTIVE" : "INACTIVE";
}

function generateEmployeeCode(prefix) {
  const tail = Date.now().toString().slice(-6);
  const rand = Math.floor(Math.random() * 90 + 10);
  return `${prefix}-${tail}${rand}`;
}

function coerceNullableString(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  const trimmed = String(value).trim();
  return trimmed || null;
}

function managedDtoFromUser(user) {
  const staff = user.staffProfile;
  const name = splitName(user.fullName);
  return {
    id: user.id,
    userId: user.id,
    role: user.role,
    employeeId: staff?.employeeCode || null,
    firstName: name.firstName || null,
    lastName: name.lastName || null,
    fullName: user.fullName,
    email: user.email,
    phone: staff?.phone || null,
    designation: staff?.designation || null,
    department: staff?.department || null,
    status: fromStatusFlag(user.isActive),
    schoolId: user.schoolId || staff?.schoolId || null,
    schoolName: user.school?.name || staff?.school?.name || null,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}

function extractCurrentRefreshToken(req, payloadToken) {
  if (payloadToken) return payloadToken;
  const header = req.headers["x-refresh-token"];
  if (typeof header === "string" && header.trim()) return header.trim();
  return null;
}

function parseFirebaseServiceAccount(req) {
  if (req.file && req.file.buffer) {
    return JSON.parse(req.file.buffer.toString("utf8"));
  }
  if (Array.isArray(req.files) && req.files[0]?.buffer) {
    return JSON.parse(req.files[0].buffer.toString("utf8"));
  }
  if (typeof req.body?.serviceAccount === "string" && req.body.serviceAccount.trim()) {
    return JSON.parse(req.body.serviceAccount);
  }
  throw badRequest("service-account.json file is required", "FIREBASE_FILE_REQUIRED");
}

async function findSchoolOrThrow(id) {
  const school = await prisma.school.findUnique({ where: { id } });
  if (!school) throw notFound("School not found", "SCHOOL_NOT_FOUND");
  return school;
}

async function ensureSecuritySettings() {
  return prisma.securitySetting.upsert({
    where: { id: "GLOBAL" },
    update: {},
    create: {
      id: "GLOBAL",
      enforce2FA: false,
      passwordMinLength: 8,
      passwordUppercase: true,
      passwordSpecial: true,
      passwordExpiryDays: 90,
      jwtExpiryMinutes: 15,
      refreshExpiryDays: 7,
    },
  });
}

function toSecuritySettingsDto(settings) {
  return {
    enforce2FA: settings.enforce2FA,
    passwordMinLength: settings.passwordMinLength,
    passwordUppercase: settings.passwordUppercase,
    passwordSpecial: settings.passwordSpecial,
    passwordExpiry: settings.passwordExpiryDays,
    jwtExpiry: settings.jwtExpiryMinutes,
    refreshExpiry: settings.refreshExpiryDays,
    apiKeyVersion: settings.apiKeyVersion,
    lastKeyRotationAt: settings.lastKeyRotationAt,
  };
}

async function getManagedUserOrThrow(id, roles) {
  const user = await prisma.user.findUnique({
    where: { id },
    include: {
      school: { select: { id: true, name: true, code: true } },
      staffProfile: {
        include: {
          school: { select: { id: true, name: true, code: true } },
        },
      },
    },
  });
  if (!user || !roles.includes(user.role)) {
    throw notFound("Record not found", "RECORD_NOT_FOUND");
  }
  return user;
}

async function syncStaffProfile({
  user,
  schoolIdInput,
  employeeId,
  fullName,
  phone,
  designation,
  department,
  codePrefix,
}) {
  const existing = await prisma.staff.findUnique({
    where: { userId: user.id },
  });

  const targetSchoolId =
    schoolIdInput === undefined
      ? existing?.schoolId || user.schoolId || null
      : schoolIdInput;

  if (!targetSchoolId) {
    if (existing) await prisma.staff.delete({ where: { id: existing.id } });
    return null;
  }

  await findSchoolOrThrow(targetSchoolId);

  const finalCode =
    coerceNullableString(employeeId) ||
    existing?.employeeCode ||
    generateEmployeeCode(codePrefix);

  const payload = {
    schoolId: targetSchoolId,
    employeeCode: finalCode,
    fullName,
    email: user.email,
    phone: phone === undefined ? existing?.phone || null : coerceNullableString(phone),
    designation:
      designation === undefined
        ? existing?.designation || null
        : coerceNullableString(designation),
    department:
      department === undefined
        ? existing?.department || null
        : coerceNullableString(department),
    isActive: user.isActive,
  };

  if (existing) {
    return prisma.staff.update({
      where: { id: existing.id },
      data: payload,
    });
  }

  return prisma.staff.create({
    data: {
      ...payload,
      userId: user.id,
    },
  });
}

async function ensureDefaultPlans() {
  const count = await prisma.subscriptionPlan.count();
  if (count > 0) return;

  await prisma.subscriptionPlan.createMany({
    data: DEFAULT_PLANS.map((plan) => ({
      planCode: plan.planCode,
      name: plan.name,
      priceMonthly: plan.priceMonthly,
      priceYearly: plan.priceYearly,
      isActive: plan.isActive,
      features: plan.features,
      maxStudents: plan.maxStudents,
      storageGb: plan.storageGb,
    })),
    skipDuplicates: true,
  });
}

async function loadPlansMap() {
  await ensureDefaultPlans();
  const plans = await prisma.subscriptionPlan.findMany({
    orderBy: { planCode: "asc" },
  });
  return new Map(plans.map((plan) => [plan.planCode, plan]));
}

async function loadSubscriptionState(schoolIds) {
  const state = new Map(
    schoolIds.map((schoolId) => [
      schoolId,
      {
        schoolId,
        planCode: "BASIC",
        autoRenew: false,
        validUntil: null,
        paymentStatus: "PAID",
        status: "ACTIVE",
        updatedAt: null,
      },
    ])
  );

  if (!schoolIds.length) return state;

  const subscriptions = await prisma.schoolSubscription.findMany({
    where: { schoolId: { in: schoolIds } },
  });

  for (const subscription of subscriptions) {
    const existing = state.get(subscription.schoolId);
    if (!existing) continue;

    existing.planCode = subscription.planCode;
    existing.autoRenew = subscription.autoRenew;
    existing.validUntil = subscription.validUntil ? subscription.validUntil.toISOString() : null;
    existing.paymentStatus = subscription.paymentStatus;
    existing.status = subscription.status;
    existing.updatedAt = subscription.updatedAt.toISOString();
    state.set(subscription.schoolId, existing);
  }

  return state;
}

async function dashboardOverview(req, res, next) {
  try {
    const [schoolsTotal, schoolsByStatus, usersByRole, studentsTotal, paymentsTotal, ticketsOpen] =
      await Promise.all([
        prisma.school.count(),
        prisma.school.groupBy({
          by: ["status"],
          _count: { _all: true },
        }),
        prisma.user.groupBy({
          by: ["role"],
          _count: { _all: true },
        }),
        prisma.student.count(),
        prisma.payment.aggregate({ _sum: { amount: true } }),
        prisma.supportTicket.count({
          where: { status: { in: ["OPEN", "PENDING"] } },
        }),
      ]);

    return res.status(200).json({
      success: true,
      data: {
        schoolsTotal,
        schoolsByStatus: schoolsByStatus.reduce((acc, item) => {
          acc[item.status] = item._count._all;
          return acc;
        }, {}),
        usersByRole: usersByRole.reduce((acc, item) => {
          acc[item.role] = item._count._all;
          return acc;
        }, {}),
        studentsTotal,
        totalPaymentsAmount: paymentsTotal._sum.amount || 0,
        openSupportTickets: ticketsOpen,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listSchools(req, res, next) {
  try {
    const query = listSchoolsQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = {};
    if (query.status) where.status = query.status;
    if (query.search) {
      where.OR = [
        { code: { contains: query.search, mode: "insensitive" } },
        { name: { contains: query.search, mode: "insensitive" } },
        { email: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.school.count({ where }),
      prisma.school.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          subscription: {
            include: {
              plan: true,
            },
          },
          users: {
            where: { role: "SCHOOLADMIN", isActive: true },
            select: { fullName: true },
            orderBy: { createdAt: "asc" },
            take: 1,
          },
          _count: {
            select: {
              students: true,
            },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: items.map((school) => ({
          ...toSchoolDto(school),
          plan:
            school.subscription?.plan?.name ||
            school.subscription?.planCode ||
            "BASIC",
          students: school._count?.students || 0,
          adminName: school.users?.[0]?.fullName || null,
        })),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function createSchool(req, res, next) {
  try {
    const payload = createSchoolSchema.parse(req.body);
    await ensureDefaultPlans();
    const created = await prisma.school.create({
      data: {
        code: payload.code.toUpperCase(),
        name: payload.name,
        email: payload.email,
        phone: payload.phone,
        status: payload.status || "ACTIVE",
        timezone: payload.timezone || "UTC",
        currencyCode: payload.currencyCode?.toUpperCase() || "USD",
      },
    });

    await prisma.schoolSubscription.create({
      data: {
        schoolId: created.id,
        planCode: "BASIC",
        autoRenew: false,
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SCHOOL_CREATED",
        entity: "School",
        entityId: created.id,
        meta: {
          code: created.code,
          name: created.name,
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: { school: toSchoolDto(created) },
    });
  } catch (error) {
    return next(error);
  }
}

async function getSchoolById(req, res, next) {
  try {
    const school = await findSchoolOrThrow(req.params.id);

    const [studentsCount, staffCount, usersCount] = await Promise.all([
      prisma.student.count({ where: { schoolId: school.id } }),
      prisma.staff.count({ where: { schoolId: school.id } }),
      prisma.user.count({ where: { schoolId: school.id } }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        school: toSchoolDto(school),
        stats: {
          studentsCount,
          staffCount,
          usersCount,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSchool(req, res, next) {
  try {
    const payload = updateSchoolSchema.parse(req.body);
    await findSchoolOrThrow(req.params.id);

    const updateData = {};
    for (const [key, value] of Object.entries(payload)) {
      if (value !== undefined) updateData[key] = value;
    }

    if (updateData.currencyCode) {
      updateData.currencyCode = updateData.currencyCode.toUpperCase();
    }
    if (updateData.code) {
      updateData.code = updateData.code.toUpperCase();
    }

    if (!Object.keys(updateData).length) {
      throw badRequest("At least one field is required");
    }

    const updated = await prisma.school.update({
      where: { id: req.params.id },
      data: updateData,
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SCHOOL_UPDATED",
        entity: "School",
        entityId: updated.id,
        meta: updateData,
      },
    });

    return res.status(200).json({
      success: true,
      data: { school: toSchoolDto(updated) },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSchoolStatus(req, res, next) {
  try {
    const payload = updateSchoolStatusSchema.parse(req.body);
    await findSchoolOrThrow(req.params.id);

    const updated = await prisma.school.update({
      where: { id: req.params.id },
      data: { status: payload.status },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SCHOOL_STATUS_UPDATED",
        entity: "School",
        entityId: updated.id,
        meta: { status: payload.status },
      },
    });

    return res.status(200).json({
      success: true,
      data: { school: toSchoolDto(updated) },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteSchool(req, res, next) {
  try {
    await findSchoolOrThrow(req.params.id);

    await prisma.school.delete({
      where: { id: req.params.id },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SCHOOL_DELETED",
        entity: "School",
        entityId: req.params.id,
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "School deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listSubscriptions(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        search: z.string().trim().min(1).optional(),
      })
      .parse(req.query);

    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = {};
    if (query.search) {
      where.OR = [
        { code: { contains: query.search, mode: "insensitive" } },
        { name: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const [total, schools, plansMap] = await Promise.all([
      prisma.school.count({ where }),
      prisma.school.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        select: { id: true, code: true, name: true, status: true },
      }),
      loadPlansMap(),
    ]);

    const subscriptionState = await loadSubscriptionState(schools.map((school) => school.id));

    const items = schools.map((school) => {
      const current = subscriptionState.get(school.id) || {
        planCode: "BASIC",
        autoRenew: false,
        validUntil: null,
        paymentStatus: "PAID",
        status: "ACTIVE",
      };
      const plan = plansMap.get(current.planCode) || null;
      return {
        id: school.id,
        schoolId: school.id,
        schoolCode: school.code,
        schoolName: school.name,
        schoolStatus: school.status,
        planCode: current.planCode,
        planName: plan?.name || current.planCode,
        renewalDate: current.validUntil,
        paymentStatus: current.paymentStatus || "PAID",
        status: current.status || "ACTIVE",
        autoRenew: current.autoRenew,
        validUntil: current.validUntil,
        updatedAt: current.updatedAt,
      };
    });

    return res.status(200).json({
      success: true,
      data: {
        items,
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSubscriptionPlan(req, res, next) {
  try {
    const payload = subscriptionPlanSchema.parse(req.body);
    const planCode = payload.planCode.trim().toUpperCase();
    const school = await findSchoolOrThrow(req.params.schoolId);
    const plansMap = await loadPlansMap();

    if (!plansMap.has(planCode)) {
      throw badRequest("Invalid planCode", "INVALID_PLAN_CODE");
    }

    const subscription = await prisma.schoolSubscription.upsert({
      where: { schoolId: school.id },
      update: {
        planCode,
        validUntil: payload.validUntil || null,
      },
      create: {
        schoolId: school.id,
        planCode,
        autoRenew: false,
        validUntil: payload.validUntil || null,
        paymentStatus: "PAID",
        status: "ACTIVE",
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        schoolId: school.id,
        action: "SUBSCRIPTION_PLAN_UPDATED",
        entity: "SchoolSubscription",
        entityId: school.id,
        meta: {
          schoolId: school.id,
          planCode,
          validUntil: payload.validUntil ? payload.validUntil.toISOString() : null,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        subscription: {
          schoolId: subscription.schoolId,
          planCode: subscription.planCode,
          autoRenew: subscription.autoRenew,
          paymentStatus: subscription.paymentStatus,
          status: subscription.status,
          validUntil: subscription.validUntil ? subscription.validUntil.toISOString() : null,
          updatedAt: subscription.updatedAt.toISOString(),
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSubscriptionAutoRenew(req, res, next) {
  try {
    const payload = subscriptionAutoRenewSchema.parse(req.body);
    const school = await findSchoolOrThrow(req.params.schoolId);
    await ensureDefaultPlans();

    const existing = await prisma.schoolSubscription.findUnique({
      where: { schoolId: school.id },
      select: { planCode: true, validUntil: true },
    });

    const subscription = await prisma.schoolSubscription.upsert({
      where: { schoolId: school.id },
      update: {
        autoRenew: payload.autoRenew,
      },
      create: {
        schoolId: school.id,
        planCode: existing?.planCode || "BASIC",
        autoRenew: payload.autoRenew,
        validUntil: existing?.validUntil || null,
        paymentStatus: "PAID",
        status: "ACTIVE",
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        schoolId: school.id,
        action: "SUBSCRIPTION_AUTORENEW_UPDATED",
        entity: "SchoolSubscription",
        entityId: school.id,
        meta: {
          schoolId: school.id,
          autoRenew: payload.autoRenew,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        subscription: {
          schoolId: subscription.schoolId,
          planCode: subscription.planCode,
          autoRenew: subscription.autoRenew,
          paymentStatus: subscription.paymentStatus,
          status: subscription.status,
          validUntil: subscription.validUntil ? subscription.validUntil.toISOString() : null,
          updatedAt: subscription.updatedAt.toISOString(),
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listPlans(req, res, next) {
  try {
    const plansMap = await loadPlansMap();
    const items = Array.from(plansMap.values())
      .sort((a, b) => a.planCode.localeCompare(b.planCode))
      .map((plan) => ({
        code: plan.planCode,
        name: plan.name,
        priceMonthly: plan.priceMonthly,
        priceYearly: plan.priceYearly,
        isActive: plan.isActive,
        features: plan.features,
        students: plan.maxStudents,
        storage: plan.storageGb,
      }));

    return res.status(200).json({
      success: true,
      data: {
        items,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updatePlan(req, res, next) {
  try {
    const payload = planUpdateSchema.parse(req.body);
    const planCode = req.params.planCode.trim().toUpperCase();
    if (!planCode) throw badRequest("planCode is required");

    const plansMap = await loadPlansMap();
    const current = plansMap.get(planCode);
    const nextPlan = await prisma.subscriptionPlan.upsert({
      where: { planCode },
      update: {
        name: payload.name ?? current?.name ?? planCode,
        priceMonthly: payload.priceMonthly ?? current?.priceMonthly ?? 0,
        priceYearly: payload.priceYearly ?? current?.priceYearly ?? 0,
        isActive: payload.isActive ?? current?.isActive ?? true,
        features: payload.features ?? current?.features ?? [],
        maxStudents: payload.students ?? current?.maxStudents ?? null,
        storageGb: payload.storage ?? current?.storageGb ?? null,
      },
      create: {
        planCode,
        name: payload.name ?? planCode,
        priceMonthly: payload.priceMonthly ?? 0,
        priceYearly: payload.priceYearly ?? 0,
        isActive: payload.isActive ?? true,
        features: payload.features ?? [],
        maxStudents: payload.students ?? null,
        storageGb: payload.storage ?? null,
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "PLAN_UPDATED",
        entity: "SubscriptionPlan",
        entityId: planCode,
        meta: nextPlan,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        plan: {
          code: nextPlan.planCode,
          name: nextPlan.name,
          priceMonthly: nextPlan.priceMonthly,
          priceYearly: nextPlan.priceYearly,
          isActive: nextPlan.isActive,
          features: nextPlan.features,
          students: nextPlan.maxStudents,
          storage: nextPlan.storageGb,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getConfiguration(req, res, next) {
  try {
    const configuration = await prisma.platformConfiguration.upsert({
      where: { id: "GLOBAL" },
      update: {},
      create: {
        id: "GLOBAL",
        ...DEFAULT_CONFIGURATION,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        configuration: {
          platformName: configuration.platformName,
          supportEmail: configuration.supportEmail,
          supportPhone: configuration.supportPhone,
          defaultTimezone: configuration.defaultTimezone,
          defaultCurrencyCode: configuration.defaultCurrencyCode,
          maintenanceMode: configuration.maintenanceMode,
          newSignups: configuration.newSignups,
          trialDays: configuration.trialDays,
          taxRate: configuration.taxRate,
          smsUrl: configuration.smsUrl,
          smsApiKey: configuration.smsApiKey,
          senderId: configuration.senderId,
          whatsAppAccountId: configuration.whatsAppAccountId,
          whatsAppToken: configuration.whatsAppToken,
          features: configuration.features,
        },
        updatedAt: configuration.updatedAt,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateConfiguration(req, res, next) {
  try {
    const payload = configurationUpdateSchema.parse(req.body);
    const existing = await prisma.platformConfiguration.upsert({
      where: { id: "GLOBAL" },
      update: {},
      create: {
        id: "GLOBAL",
        ...DEFAULT_CONFIGURATION,
      },
    });

    const current = {
      platformName: existing.platformName,
      supportEmail: existing.supportEmail,
      supportPhone: existing.supportPhone,
      defaultTimezone: existing.defaultTimezone,
      defaultCurrencyCode: existing.defaultCurrencyCode,
      maintenanceMode: existing.maintenanceMode,
      newSignups: existing.newSignups,
      trialDays: existing.trialDays,
      taxRate: existing.taxRate,
      smsUrl: existing.smsUrl,
      smsApiKey: existing.smsApiKey,
      senderId: existing.senderId,
      whatsAppAccountId: existing.whatsAppAccountId,
      whatsAppToken: existing.whatsAppToken,
      features: existing.features,
    };

    const configuration = { ...current, ...payload };
    if (payload.features && current.features && typeof current.features === "object" && !Array.isArray(current.features)) {
      configuration.features = { ...current.features, ...payload.features };
    }

    const updated = await prisma.platformConfiguration.update({
      where: { id: "GLOBAL" },
      data: configuration,
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "PLATFORM_CONFIGURATION_UPDATED",
        entity: "PlatformConfiguration",
        meta: configuration,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        configuration: {
          platformName: updated.platformName,
          supportEmail: updated.supportEmail,
          supportPhone: updated.supportPhone,
          defaultTimezone: updated.defaultTimezone,
          defaultCurrencyCode: updated.defaultCurrencyCode,
          maintenanceMode: updated.maintenanceMode,
          newSignups: updated.newSignups,
          trialDays: updated.trialDays,
          taxRate: updated.taxRate,
          smsUrl: updated.smsUrl,
          smsApiKey: updated.smsApiKey,
          senderId: updated.senderId,
          whatsAppAccountId: updated.whatsAppAccountId,
          whatsAppToken: updated.whatsAppToken,
          features: updated.features,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listSupportTickets(req, res, next) {
  try {
    const query = ticketListQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = {};
    if (query.schoolId) where.schoolId = query.schoolId;
    if (query.status) where.status = query.status;
    if (query.priority) where.priority = query.priority;
    if (query.search) {
      where.OR = [
        { ticketNo: { contains: query.search, mode: "insensitive" } },
        { subject: { contains: query.search, mode: "insensitive" } },
        { description: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.supportTicket.count({ where }),
      prisma.supportTicket.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          school: { select: { id: true, name: true, code: true } },
          createdBy: { select: { id: true, fullName: true, email: true } },
          _count: { select: { messages: true } },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: items.map(toTicketDto),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getSupportTicketById(req, res, next) {
  try {
    const ticket = await prisma.supportTicket.findUnique({
      where: { id: req.params.id },
      include: {
        school: { select: { id: true, name: true, code: true } },
        createdBy: { select: { id: true, fullName: true, email: true } },
        messages: {
          orderBy: { createdAt: "asc" },
          include: {
            sender: {
              select: { id: true, fullName: true, email: true, role: true },
            },
          },
        },
      },
    });

    if (!ticket) throw notFound("Ticket not found", "TICKET_NOT_FOUND");

    return res.status(200).json({
      success: true,
      data: {
        ticket: {
          ...toTicketDto(ticket),
          messages: ticket.messages.map((item) => ({
            id: item.id,
            message: item.message,
            createdAt: item.createdAt,
            sender: item.sender,
          })),
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function createSupportTicketReply(req, res, next) {
  try {
    const payload = ticketReplySchema.parse(req.body);
    const ticket = await prisma.supportTicket.findUnique({
      where: { id: req.params.id },
      select: { id: true },
    });
    if (!ticket) throw notFound("Ticket not found", "TICKET_NOT_FOUND");

    const reply = await prisma.ticketMessage.create({
      data: {
        ticketId: ticket.id,
        senderId: req.user.sub,
        message: payload.message,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: null,
        actorId: req.user?.sub || null,
        action: "SUPPORT_TICKET_REPLY_ADDED",
        entity: "SupportTicket",
        entityId: ticket.id,
        meta: { messageId: reply.id },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        reply: {
          id: reply.id,
          ticketId: reply.ticketId,
          message: reply.message,
          createdAt: reply.createdAt,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSupportTicketStatus(req, res, next) {
  try {
    const payload = ticketStatusUpdateSchema.parse(req.body);
    const ticket = await prisma.supportTicket.findUnique({
      where: { id: req.params.id },
      select: { id: true, schoolId: true },
    });
    if (!ticket) throw notFound("Ticket not found", "TICKET_NOT_FOUND");

    const updated = await prisma.supportTicket.update({
      where: { id: ticket.id },
      data: {
        status: payload.status,
        assignedToId: payload.assignedToId || undefined,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: ticket.schoolId,
        actorId: req.user?.sub || null,
        action: "SUPPORT_TICKET_STATUS_UPDATED",
        entity: "SupportTicket",
        entityId: ticket.id,
        meta: {
          status: payload.status,
          assignedToId: payload.assignedToId || null,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        ticket: {
          id: updated.id,
          status: updated.status,
          assignedToId: updated.assignedToId,
          updatedAt: updated.updatedAt,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function analyticsOverview(req, res, next) {
  try {
    const now = new Date();
    const monthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1, 0, 0, 0));
    const prevMonthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - 1, 1, 0, 0, 0));

    const [
      totalSchools,
      schoolsBeforeMonth,
      totalUsers,
      usersBeforeMonth,
      revenueTotal,
      revenueThisMonth,
      revenuePrevMonth,
      schoolsByTimezone,
      usersByRole,
      recentAudit,
      activeIssues,
    ] = await Promise.all([
      prisma.school.count(),
      prisma.school.count({ where: { createdAt: { lt: monthStart } } }),
      prisma.user.count(),
      prisma.user.count({ where: { createdAt: { lt: monthStart } } }),
      prisma.payment.aggregate({ _sum: { amount: true } }),
      prisma.payment.aggregate({
        where: { paidAt: { gte: monthStart } },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: { paidAt: { gte: prevMonthStart, lt: monthStart } },
        _sum: { amount: true },
      }),
      prisma.school.groupBy({
        by: ["timezone"],
        _count: { _all: true },
        orderBy: { _count: { timezone: "desc" } },
        take: 5,
      }),
      prisma.user.groupBy({
        by: ["role"],
        _count: { _all: true },
      }),
      prisma.auditLog.findMany({
        orderBy: { createdAt: "desc" },
        take: 8,
        include: {
          school: { select: { id: true, name: true } },
        },
      }),
      prisma.supportTicket.count({ where: { status: { in: ["OPEN", "PENDING"] } } }),
    ]);

    const usersByRoleMap = usersByRole.reduce((acc, row) => {
      acc[row.role] = row._count._all;
      return acc;
    }, {});

    const revenue = revenueTotal._sum.amount || 0;
    const monthRevenue = revenueThisMonth._sum.amount || 0;
    const prevRevenue = revenuePrevMonth._sum.amount || 0;
    const schoolGrowth = percentGrowth(totalSchools, schoolsBeforeMonth);
    const userGrowth = percentGrowth(totalUsers, usersBeforeMonth);
    const revenueGrowth = percentGrowth(monthRevenue, prevRevenue);

    const projectedRevenue = Number(((monthRevenue * 12) / 1_000_000).toFixed(2));
    const health = Number(Math.max(90, 100 - activeIssues * 0.01).toFixed(2));

    const regions = schoolsByTimezone.map((row) => ({
      name: row.timezone || "Unknown",
      schools: row._count._all,
      percentage:
        totalSchools > 0 ? Number(((row._count._all / totalSchools) * 100).toFixed(2)) : 0,
    }));

    const recentEvents = recentAudit.map((row) => ({
      title: row.action,
      school: row.school?.name || "Global",
      region: "N/A",
      status: "ACTIVE",
      time: timeAgo(row.createdAt),
      icon: "history",
      iconBg: "bg-sky-500/10",
      iconColor: "text-sky-500",
      statusClass: "bg-sky-500/10 text-sky-500",
    }));

    return res.status(200).json({
      success: true,
      data: {
        totalSchools,
        schoolGrowth,
        totalUsers,
        userGrowth,
        revenue,
        revenueGrowth,
        projectedRevenue,
        health,
        revenueBreakdown: {
          subscription: Number((revenue * 0.75).toFixed(2)),
          addons: Number((revenue * 0.15).toFixed(2)),
          training: Number((revenue * 0.1).toFixed(2)),
        },
        regions,
        segmentation: {
          admins: (usersByRoleMap.SUPERADMIN || 0) + (usersByRoleMap.SCHOOLADMIN || 0),
          staff:
            (usersByRoleMap.HR || 0) +
            (usersByRoleMap.ACCOUNTANT || 0) +
            (usersByRoleMap.TEACHER || 0),
          parents: usersByRoleMap.PARENT || 0,
        },
        recentEvents,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listManagedUsersByRoles(req, res, next, roles) {
  try {
    const query = listManagedUsersQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = {
      role: { in: roles },
    };

    if (query.schoolId) where.schoolId = query.schoolId;
    if (query.status) where.isActive = toStatusFlag(query.status);
    if (query.search) {
      where.OR = [
        { fullName: { contains: query.search, mode: "insensitive" } },
        { email: { contains: query.search, mode: "insensitive" } },
        {
          staffProfile: {
            employeeCode: { contains: query.search, mode: "insensitive" },
          },
        },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.user.count({ where }),
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          school: { select: { id: true, name: true, code: true } },
          staffProfile: {
            include: {
              school: { select: { id: true, name: true, code: true } },
            },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: items.map(managedDtoFromUser),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function createManagedUser(req, res, next, options) {
  try {
    const payload = options.createSchema.parse(req.body);
    const email = normalizeEmail(payload.email);
    const fullName = buildFullName(payload);
    const role = options.roleResolver(payload);
    const schoolId = coerceNullableString(payload.schoolId);
    if (schoolId) await findSchoolOrThrow(schoolId);

    const plainPassword = payload.password || randomTempPassword();
    const passwordHash = await bcrypt.hash(plainPassword, 10);

    const created = await prisma.user.create({
      data: {
        fullName,
        email,
        passwordHash,
        role,
        isActive: true,
        schoolId,
      },
    });

    await syncStaffProfile({
      user: created,
      schoolIdInput: schoolId,
      employeeId: payload.employeeId,
      fullName,
      phone: payload.phone,
      designation: payload.designation,
      department: payload.department,
      codePrefix: options.employeePrefix,
    });

    await prisma.auditLog.create({
      data: {
        schoolId: schoolId || null,
        actorId: req.user?.sub || null,
        action: `${options.auditPrefix}_CREATED`,
        entity: "User",
        entityId: created.id,
        meta: { role: created.role, email: created.email },
      },
    });

    const withRelations = await getManagedUserOrThrow(created.id, options.allowedRoles);
    return res.status(201).json({
      success: true,
      data: {
        item: managedDtoFromUser(withRelations),
        temporaryPassword:
          payload.password || env.NODE_ENV === "production" ? undefined : plainPassword,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateManagedUser(req, res, next, options) {
  try {
    const payload = options.updateSchema.parse(req.body);
    if (!Object.keys(payload).length) throw badRequest("At least one field is required");

    const existing = await getManagedUserOrThrow(req.params.id, options.allowedRoles);
    let nextRole = existing.role;
    if (typeof options.roleResolver === "function") {
      nextRole = options.roleResolver(payload, existing.role);
    }

    const schoolId =
      payload.schoolId === undefined
        ? existing.schoolId
        : coerceNullableString(payload.schoolId);
    if (schoolId) await findSchoolOrThrow(schoolId);

    const fullName =
      payload.fullName === undefined &&
      payload.firstName === undefined &&
      payload.lastName === undefined
        ? existing.fullName
        : buildFullName({
            fullName: payload.fullName ?? undefined,
            firstName:
              payload.firstName === null
                ? splitName(existing.fullName).firstName
                : payload.firstName,
            lastName:
              payload.lastName === null
                ? splitName(existing.fullName).lastName
                : payload.lastName,
          });

    const updateData = {
      fullName,
      role: nextRole,
      schoolId,
    };
    if (payload.email !== undefined) {
      updateData.email = normalizeEmail(payload.email);
    }
    if (payload.isActive !== undefined) {
      updateData.isActive = payload.isActive;
    }

    const updated = await prisma.user.update({
      where: { id: existing.id },
      data: updateData,
    });

    await syncStaffProfile({
      user: updated,
      schoolIdInput: payload.schoolId === undefined ? undefined : schoolId,
      employeeId: payload.employeeId,
      fullName,
      phone: payload.phone,
      designation: payload.designation,
      department: payload.department,
      codePrefix: options.employeePrefix,
    });

    await prisma.auditLog.create({
      data: {
        schoolId: updated.schoolId || null,
        actorId: req.user?.sub || null,
        action: `${options.auditPrefix}_UPDATED`,
        entity: "User",
        entityId: updated.id,
        meta: {
          role: updated.role,
          schoolId: updated.schoolId,
        },
      },
    });

    const withRelations = await getManagedUserOrThrow(updated.id, options.allowedRoles);
    return res.status(200).json({
      success: true,
      data: {
        item: managedDtoFromUser(withRelations),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateManagedUserStatus(req, res, next, options) {
  try {
    const payload = managedStatusUpdateSchema.parse(req.body);
    const existing = await getManagedUserOrThrow(req.params.id, options.allowedRoles);

    const updated = await prisma.user.update({
      where: { id: existing.id },
      data: {
        isActive: toStatusFlag(payload.status),
      },
    });

    await prisma.staff.updateMany({
      where: { userId: updated.id },
      data: { isActive: updated.isActive },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: updated.schoolId || null,
        actorId: req.user?.sub || null,
        action: `${options.auditPrefix}_STATUS_UPDATED`,
        entity: "User",
        entityId: updated.id,
        meta: { status: payload.status },
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Status updated successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteManagedUser(req, res, next, options) {
  try {
    const existing = await getManagedUserOrThrow(req.params.id, options.allowedRoles);

    await prisma.$transaction([
      prisma.staff.deleteMany({ where: { userId: existing.id } }),
      prisma.user.delete({ where: { id: existing.id } }),
    ]);

    await prisma.auditLog.create({
      data: {
        schoolId: existing.schoolId || null,
        actorId: req.user?.sub || null,
        action: `${options.auditPrefix}_DELETED`,
        entity: "User",
        entityId: existing.id,
        meta: { role: existing.role, email: existing.email },
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listAccountants(req, res, next) {
  return listManagedUsersByRoles(req, res, next, ["ACCOUNTANT"]);
}

async function createAccountant(req, res, next) {
  return createManagedUser(req, res, next, {
    createSchema: createAccountantSchema,
    updateSchema: updateAccountantSchema,
    allowedRoles: ["ACCOUNTANT"],
    roleResolver: () => "ACCOUNTANT",
    employeePrefix: "ACC",
    auditPrefix: "SUPERADMIN_ACCOUNTANT",
  });
}

async function getAccountantById(req, res, next) {
  try {
    const user = await getManagedUserOrThrow(req.params.id, ["ACCOUNTANT"]);
    return res.status(200).json({
      success: true,
      data: { item: managedDtoFromUser(user) },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateAccountant(req, res, next) {
  return updateManagedUser(req, res, next, {
    updateSchema: updateAccountantSchema,
    allowedRoles: ["ACCOUNTANT"],
    roleResolver: () => "ACCOUNTANT",
    employeePrefix: "ACC",
    auditPrefix: "SUPERADMIN_ACCOUNTANT",
  });
}

async function updateAccountantStatus(req, res, next) {
  return updateManagedUserStatus(req, res, next, {
    allowedRoles: ["ACCOUNTANT"],
    auditPrefix: "SUPERADMIN_ACCOUNTANT",
  });
}

async function deleteAccountant(req, res, next) {
  return deleteManagedUser(req, res, next, {
    allowedRoles: ["ACCOUNTANT"],
    auditPrefix: "SUPERADMIN_ACCOUNTANT",
  });
}

async function listStaffMembers(req, res, next) {
  return listManagedUsersByRoles(req, res, next, ["HR", "TEACHER"]);
}

async function createStaffMember(req, res, next) {
  return createManagedUser(req, res, next, {
    createSchema: createStaffSchema,
    updateSchema: updateStaffSchema,
    allowedRoles: ["HR", "TEACHER"],
    roleResolver: (payload) => payload.role || "HR",
    employeePrefix: "STF",
    auditPrefix: "SUPERADMIN_STAFF",
  });
}

async function getStaffMemberById(req, res, next) {
  try {
    const user = await getManagedUserOrThrow(req.params.id, ["HR", "TEACHER"]);
    return res.status(200).json({
      success: true,
      data: { item: managedDtoFromUser(user) },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateStaffMember(req, res, next) {
  return updateManagedUser(req, res, next, {
    updateSchema: updateStaffSchema,
    allowedRoles: ["HR", "TEACHER"],
    roleResolver: (payload, currentRole) => payload.role || currentRole || "HR",
    employeePrefix: "STF",
    auditPrefix: "SUPERADMIN_STAFF",
  });
}

async function updateStaffMemberStatus(req, res, next) {
  return updateManagedUserStatus(req, res, next, {
    allowedRoles: ["HR", "TEACHER"],
    auditPrefix: "SUPERADMIN_STAFF",
  });
}

async function deleteStaffMember(req, res, next) {
  return deleteManagedUser(req, res, next, {
    allowedRoles: ["HR", "TEACHER"],
    auditPrefix: "SUPERADMIN_STAFF",
  });
}

async function listInvitations(req, res, next) {
  try {
    const query = listInvitationsQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = {};
    if (query.status) where.status = query.status;
    if (query.schoolId) where.schoolId = query.schoolId;
    if (query.search) {
      where.OR = [
        { email: { contains: query.search, mode: "insensitive" } },
        { school: { name: { contains: query.search, mode: "insensitive" } } },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.invitation.count({ where }),
      prisma.invitation.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          school: { select: { id: true, name: true, code: true } },
          invitedBy: { select: { id: true, fullName: true, email: true } },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: items.map((item) => ({
          id: item.id,
          email: item.email,
          role: item.role,
          schoolId: item.schoolId,
          schoolName: item.school?.name || null,
          status: item.status,
          message: item.message,
          sentAt: item.sentAt,
          expiresAt: item.expiresAt,
          acceptedAt: item.acceptedAt,
          invitedBy: item.invitedBy
            ? {
                id: item.invitedBy.id,
                fullName: item.invitedBy.fullName,
                email: item.invitedBy.email,
              }
            : null,
        })),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function createInvitation(req, res, next) {
  try {
    const payload = createInvitationSchema.parse(req.body);
    const schoolId = coerceNullableString(payload.schoolId);
    if (schoolId) await findSchoolOrThrow(schoolId);

    const rawToken = crypto.randomBytes(24).toString("hex");
    const expiresAt = new Date(
      Date.now() + (payload.expiresInDays || 7) * 24 * 60 * 60 * 1000
    );

    const invitation = await prisma.invitation.create({
      data: {
        email: normalizeEmail(payload.email),
        role: payload.role,
        schoolId,
        status: "PENDING",
        message: payload.message || null,
        invitedById: req.user?.sub || null,
        tokenHash: hashToken(rawToken),
        sentAt: new Date(),
        expiresAt,
      },
      include: {
        school: { select: { id: true, name: true } },
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: schoolId || null,
        actorId: req.user?.sub || null,
        action: "INVITATION_SENT",
        entity: "Invitation",
        entityId: invitation.id,
        meta: {
          email: invitation.email,
          role: invitation.role,
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        invitation: {
          id: invitation.id,
          email: invitation.email,
          role: invitation.role,
          schoolId: invitation.schoolId,
          schoolName: invitation.school?.name || null,
          status: invitation.status,
          sentAt: invitation.sentAt,
          expiresAt: invitation.expiresAt,
          message: invitation.message,
        },
        message: "Invitation sent successfully",
        debugInviteToken: env.NODE_ENV === "production" ? undefined : rawToken,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function resendInvitation(req, res, next) {
  try {
    const invitation = await prisma.invitation.findUnique({
      where: { id: req.params.id },
    });
    if (!invitation) throw notFound("Invitation not found", "INVITATION_NOT_FOUND");

    const rawToken = crypto.randomBytes(24).toString("hex");
    const updated = await prisma.invitation.update({
      where: { id: invitation.id },
      data: {
        status: "PENDING",
        sentAt: new Date(),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        tokenHash: hashToken(rawToken),
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: updated.schoolId || null,
        actorId: req.user?.sub || null,
        action: "INVITATION_RESENT",
        entity: "Invitation",
        entityId: updated.id,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        message: "Invitation resent successfully",
        debugInviteToken: env.NODE_ENV === "production" ? undefined : rawToken,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function cancelInvitation(req, res, next) {
  try {
    const invitation = await prisma.invitation.findUnique({
      where: { id: req.params.id },
      select: { id: true, schoolId: true },
    });
    if (!invitation) throw notFound("Invitation not found", "INVITATION_NOT_FOUND");

    await prisma.invitation.update({
      where: { id: invitation.id },
      data: {
        status: "CANCELLED",
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId: invitation.schoolId || null,
        actorId: req.user?.sub || null,
        action: "INVITATION_CANCELLED",
        entity: "Invitation",
        entityId: invitation.id,
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Invitation cancelled successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function getSecuritySettings(req, res, next) {
  try {
    const settings = await ensureSecuritySettings();
    return res.status(200).json({
      success: true,
      data: toSecuritySettingsDto(settings),
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSecuritySettings(req, res, next) {
  try {
    const payload = securityUpdateSchema.parse(req.body);
    if (!Object.keys(payload).length) throw badRequest("At least one field is required");

    await ensureSecuritySettings();
    const updated = await prisma.securitySetting.update({
      where: { id: "GLOBAL" },
      data: {
        enforce2FA: payload.enforce2FA,
        passwordMinLength: payload.passwordMinLength,
        passwordUppercase: payload.passwordUppercase,
        passwordSpecial: payload.passwordSpecial,
        passwordExpiryDays: payload.passwordExpiry,
        jwtExpiryMinutes: payload.jwtExpiry,
        refreshExpiryDays: payload.refreshExpiry,
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SECURITY_SETTINGS_UPDATED",
        entity: "SecuritySetting",
        entityId: "GLOBAL",
        meta: payload,
      },
    });

    return res.status(200).json({
      success: true,
      data: toSecuritySettingsDto(updated),
    });
  } catch (error) {
    return next(error);
  }
}

async function listSecuritySessions(req, res, next) {
  try {
    const query = listSessionsQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;
    const targetUserId = query.userId || req.user?.sub;
    if (!targetUserId) throw badRequest("user context missing");

    const currentRefreshToken = extractCurrentRefreshToken(req);
    const currentHash = currentRefreshToken ? hashToken(currentRefreshToken) : null;

    const where = {
      userId: targetUserId,
      revokedAt: null,
      expiresAt: { gt: new Date() },
    };

    const [total, sessions] = await Promise.all([
      prisma.refreshToken.count({ where }),
      prisma.refreshToken.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        sessions: sessions.map((item) => ({
          id: item.id,
          userId: item.userId,
          user: item.user,
          device: item.userAgent || "Unknown Device",
          location: item.ipAddress || "Unknown",
          lastActive: item.lastUsedAt || item.createdAt,
          current: currentHash ? item.tokenHash === currentHash : false,
          expiresAt: item.expiresAt,
          createdAt: item.createdAt,
        })),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function revokeSecuritySession(req, res, next) {
  try {
    const session = await prisma.refreshToken.findUnique({
      where: { id: req.params.id },
      select: { id: true, userId: true },
    });
    if (!session) throw notFound("Session not found", "SESSION_NOT_FOUND");

    await prisma.refreshToken.update({
      where: { id: session.id },
      data: { revokedAt: new Date() },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SECURITY_SESSION_REVOKED",
        entity: "RefreshToken",
        entityId: session.id,
        meta: { targetUserId: session.userId },
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Session revoked successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function revokeAllSecuritySessions(req, res, next) {
  try {
    const payload = revokeAllSessionsSchema.parse(req.body || {});
    const targetUserId = payload.userId || req.user?.sub;
    if (!targetUserId) throw badRequest("user context missing");

    const excludeToken = extractCurrentRefreshToken(req, payload.currentRefreshToken);
    const where = {
      userId: targetUserId,
      revokedAt: null,
    };

    if (excludeToken) {
      where.NOT = { tokenHash: hashToken(excludeToken) };
    }

    const result = await prisma.refreshToken.updateMany({
      where,
      data: { revokedAt: new Date() },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SECURITY_SESSIONS_REVOKED_ALL",
        entity: "RefreshToken",
        meta: {
          targetUserId,
          revokedCount: result.count,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        message: "Sessions revoked successfully",
        revokedCount: result.count,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function rotateSecurityKeys(req, res, next) {
  try {
    await ensureSecuritySettings();
    const rotated = await prisma.securitySetting.update({
      where: { id: "GLOBAL" },
      data: {
        apiKeyVersion: { increment: 1 },
        lastKeyRotationAt: new Date(),
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "SECURITY_KEYS_ROTATED",
        entity: "SecuritySetting",
        entityId: "GLOBAL",
        meta: {
          apiKeyVersion: rotated.apiKeyVersion,
          rotatedAt: rotated.lastKeyRotationAt,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        message: "Security keys rotated successfully",
        apiKeyVersion: rotated.apiKeyVersion,
        rotatedAt: rotated.lastKeyRotationAt,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listSecurityAuditLogs(req, res, next) {
  try {
    const query = listAuditLogsQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = {};
    if (query.schoolId) where.schoolId = query.schoolId;
    if (query.action) where.action = { contains: query.action, mode: "insensitive" };
    if (query.from || query.to) {
      where.createdAt = {};
      if (query.from) where.createdAt.gte = query.from;
      if (query.to) where.createdAt.lte = query.to;
    }
    if (query.user) {
      where.OR = [
        { actorId: query.user },
        { actor: { fullName: { contains: query.user, mode: "insensitive" } } },
        { actor: { email: { contains: query.user, mode: "insensitive" } } },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.auditLog.count({ where }),
      prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          school: { select: { id: true, name: true, code: true } },
          actor: { select: { id: true, fullName: true, email: true, role: true } },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: items.map((item) => ({
          id: item.id,
          action: item.action,
          entity: item.entity,
          entityId: item.entityId,
          school: item.school,
          actor: item.actor,
          ipAddress: item.ipAddress,
          userAgent: item.userAgent,
          meta: item.meta,
          createdAt: item.createdAt,
        })),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listNotifications(req, res, next) {
  try {
    const query = listNotificationsQuerySchema.parse(req.query);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;

    const where = { userId: req.user.sub };
    if (query.unreadOnly === "true") where.readAt = null;

    const [total, unreadCount, items] = await Promise.all([
      prisma.superadminNotification.count({ where }),
      prisma.superadminNotification.count({
        where: { userId: req.user.sub, readAt: null },
      }),
      prisma.superadminNotification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        unreadCount,
        items: items.map((item) => ({
          id: item.id,
          title: item.title,
          message: item.message,
          type: item.type,
          read: Boolean(item.readAt),
          readAt: item.readAt,
          meta: item.meta,
          createdAt: item.createdAt,
        })),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function markNotificationRead(req, res, next) {
  try {
    const notification = await prisma.superadminNotification.findUnique({
      where: { id: req.params.id },
      select: { id: true, userId: true, readAt: true },
    });
    if (!notification || notification.userId !== req.user.sub) {
      throw notFound("Notification not found", "NOTIFICATION_NOT_FOUND");
    }

    if (!notification.readAt) {
      await prisma.superadminNotification.update({
        where: { id: notification.id },
        data: { readAt: new Date() },
      });
    }

    return res.status(200).json({
      success: true,
      data: { message: "Notification marked as read" },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteNotification(req, res, next) {
  try {
    const notification = await prisma.superadminNotification.findUnique({
      where: { id: req.params.id },
      select: { id: true, userId: true },
    });
    if (!notification || notification.userId !== req.user.sub) {
      throw notFound("Notification not found", "NOTIFICATION_NOT_FOUND");
    }

    await prisma.superadminNotification.delete({
      where: { id: notification.id },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Notification deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function uploadFirebaseServiceAccount(req, res, next) {
  try {
    let serviceJson;
    try {
      serviceJson = parseFirebaseServiceAccount(req);
    } catch (error) {
      if (error.statusCode) throw error;
      throw badRequest("Invalid JSON file", "INVALID_FIREBASE_JSON");
    }

    if (!serviceJson || typeof serviceJson !== "object" || Array.isArray(serviceJson)) {
      throw badRequest("Invalid service account payload", "INVALID_FIREBASE_JSON");
    }

    const projectId = serviceJson.project_id || null;
    const clientEmail = serviceJson.client_email || null;
    const privateKey = serviceJson.private_key || null;
    if (!projectId || !clientEmail) {
      throw badRequest(
        "project_id and client_email are required in service account JSON",
        "INVALID_FIREBASE_JSON"
      );
    }

    const credential = await prisma.firebaseCredential.upsert({
      where: { id: "GLOBAL" },
      update: {
        projectId,
        clientEmail,
        privateKey,
        serviceJson,
        uploadedById: req.user?.sub || null,
      },
      create: {
        id: "GLOBAL",
        projectId,
        clientEmail,
        privateKey,
        serviceJson,
        uploadedById: req.user?.sub || null,
      },
    });

    await prisma.auditLog.create({
      data: {
        actorId: req.user?.sub || null,
        action: "FIREBASE_SERVICE_ACCOUNT_UPLOADED",
        entity: "FirebaseCredential",
        entityId: credential.id,
        meta: {
          projectId: credential.projectId,
          clientEmail: credential.clientEmail,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        firebase: {
          id: credential.id,
          projectId: credential.projectId,
          clientEmail: credential.clientEmail,
          updatedAt: credential.updatedAt,
        },
        message: "Firebase service account uploaded successfully",
      },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  dashboardOverview,
  listSchools,
  createSchool,
  getSchoolById,
  updateSchool,
  updateSchoolStatus,
  deleteSchool,
  listSubscriptions,
  updateSubscriptionPlan,
  updateSubscriptionAutoRenew,
  listPlans,
  updatePlan,
  getConfiguration,
  updateConfiguration,
  listSupportTickets,
  getSupportTicketById,
  createSupportTicketReply,
  updateSupportTicketStatus,
  analyticsOverview,
  listAccountants,
  createAccountant,
  getAccountantById,
  updateAccountant,
  updateAccountantStatus,
  deleteAccountant,
  listStaffMembers,
  createStaffMember,
  getStaffMemberById,
  updateStaffMember,
  updateStaffMemberStatus,
  deleteStaffMember,
  createInvitation,
  listInvitations,
  resendInvitation,
  cancelInvitation,
  getSecuritySettings,
  updateSecuritySettings,
  listSecuritySessions,
  revokeSecuritySession,
  revokeAllSecuritySessions,
  rotateSecurityKeys,
  listSecurityAuditLogs,
  listNotifications,
  markNotificationRead,
  deleteNotification,
  uploadFirebaseServiceAccount,
};
