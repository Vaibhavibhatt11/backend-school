const { z } = require("zod");

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
  features: z.record(z.string(), z.boolean()).optional(),
});

const DEFAULT_PLANS = [
  {
    planCode: "BASIC",
    name: "Basic",
    priceMonthly: 49,
    priceYearly: 499,
    isActive: true,
    features: ["Students", "Attendance", "Basic Fees"],
  },
  {
    planCode: "PRO",
    name: "Pro",
    priceMonthly: 99,
    priceYearly: 999,
    isActive: true,
    features: ["Everything in Basic", "Accounting", "HR", "Reports"],
  },
  {
    planCode: "ENTERPRISE",
    name: "Enterprise",
    priceMonthly: 199,
    priceYearly: 1999,
    isActive: true,
    features: ["Everything in Pro", "AI", "Priority Support", "Custom Integrations"],
  },
];

const DEFAULT_CONFIGURATION = {
  platformName: "School ERP",
  supportEmail: "support@schoolerp.local",
  supportPhone: "+1-555-0000",
  defaultTimezone: "UTC",
  defaultCurrencyCode: "USD",
  maintenanceMode: false,
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
    ticketNo: ticket.ticketNo,
    subject: ticket.subject,
    description: ticket.description,
    priority: ticket.priority,
    status: ticket.status,
    createdById: ticket.createdById,
    assignedToId: ticket.assignedToId,
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

async function findSchoolOrThrow(id) {
  const school = await prisma.school.findUnique({ where: { id } });
  if (!school) throw notFound("School not found", "SCHOOL_NOT_FOUND");
  return school;
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
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: items.map(toSchoolDto),
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
      };
      const plan = plansMap.get(current.planCode) || null;
      return {
        schoolId: school.id,
        schoolCode: school.code,
        schoolName: school.name,
        schoolStatus: school.status,
        planCode: current.planCode,
        planName: plan?.name || current.planCode,
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
    return res.status(200).json({
      success: true,
      data: {
        items: Array.from(plansMap.values()).sort((a, b) => a.planCode.localeCompare(b.planCode)),
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
      },
      create: {
        planCode,
        name: payload.name ?? planCode,
        priceMonthly: payload.priceMonthly ?? 0,
        priceYearly: payload.priceYearly ?? 0,
        isActive: payload.isActive ?? true,
        features: payload.features ?? [],
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
      data: { plan: nextPlan },
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
    const monthEnd = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1, 0, 0, 0)
    );

    const [schools, students, staff, invoices, payments, monthPayments] = await Promise.all([
      prisma.school.count(),
      prisma.student.count(),
      prisma.staff.count(),
      prisma.invoice.aggregate({
        _sum: { amountDue: true, amountPaid: true },
      }),
      prisma.payment.aggregate({
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: {
          paidAt: { gte: monthStart, lt: monthEnd },
        },
        _sum: { amount: true },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        totals: {
          schools,
          students,
          staff,
          invoiceAmount: invoices._sum.amountDue || 0,
          invoicePaidAmount: invoices._sum.amountPaid || 0,
          paymentAmount: payments._sum.amount || 0,
          monthCollection: monthPayments._sum.amount || 0,
        },
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
};
