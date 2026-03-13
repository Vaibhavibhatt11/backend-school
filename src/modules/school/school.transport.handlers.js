"use strict";

const { z } = require("zod");
const { prisma, scopedSchoolId, findScopedOrThrow, paginationFromQuery, paginated } = require("./school.common");

const routeSchema = z.object({
  schoolId: z.string().optional(),
  name: z.string().trim().min(1),
  routeCode: z.string().trim().min(1),
  stops: z.any().optional(),
  isActive: z.boolean().optional(),
});
const allocationSchema = z.object({
  studentId: z.string().trim().min(1),
  routeId: z.string().trim().min(1),
  stopName: z.string().trim().optional(),
  feeAmount: z.number().optional(),
});

async function listRoutes(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const where = { schoolId };
    const [total, items] = await Promise.all([
      prisma.transportRoute.count({ where }),
      prisma.transportRoute.findMany({ where, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function createRoute(req, res, next) {
  try {
    const body = routeSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const route = await prisma.transportRoute.create({
      data: { schoolId, name: body.name, routeCode: body.routeCode, stops: body.stops || null, isActive: body.isActive !== false },
    });
    return res.status(201).json({ success: true, data: route });
  } catch (e) {
    return next(e);
  }
}

async function updateRoute(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("transportRoute", req.params.id, schoolId, "Route", "NOT_FOUND");
    const body = routeSchema.partial().parse(req.body);
    const route = await prisma.transportRoute.update({ where: { id: req.params.id }, data: body });
    return res.status(200).json({ success: true, data: route });
  } catch (e) {
    return next(e);
  }
}

async function deleteRoute(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("transportRoute", req.params.id, schoolId, "Route", "NOT_FOUND");
    await prisma.transportRoute.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

async function listDrivers(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const [total, items] = await Promise.all([
      prisma.transportDriver.count({ where: { schoolId } }),
      prisma.transportDriver.findMany({ where: { schoolId }, skip, take: limit, orderBy: { createdAt: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function createDriver(req, res, next) {
  try {
    const body = z.object({
      schoolId: z.string().optional(),
      fullName: z.string().trim().min(1),
      phone: z.string().optional(),
      licenseNo: z.string().optional(),
      routeId: z.string().optional(),
      isActive: z.boolean().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const driver = await prisma.transportDriver.create({
      data: { schoolId, fullName: body.fullName, phone: body.phone || null, licenseNo: body.licenseNo || null, routeId: body.routeId || null, isActive: body.isActive !== false },
    });
    return res.status(201).json({ success: true, data: driver });
  } catch (e) {
    return next(e);
  }
}

async function listAllocations(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const where = { schoolId };
    if (req.query.routeId) where.routeId = req.query.routeId;
    if (req.query.studentId) where.studentId = req.query.studentId;
    const [total, items] = await Promise.all([
      prisma.transportAllocation.count({ where }),
      prisma.transportAllocation.findMany({
        where,
        skip,
        take: limit,
        include: { student: true, route: true },
        orderBy: { createdAt: "desc" },
      }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function createAllocation(req, res, next) {
  try {
    const body = allocationSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("transportRoute", body.routeId, schoolId, "Route", "NOT_FOUND");
    const allocation = await prisma.transportAllocation.create({
      data: { schoolId, studentId: body.studentId, routeId: body.routeId, stopName: body.stopName || null, feeAmount: body.feeAmount ?? null },
      include: { student: true, route: true },
    });
    return res.status(201).json({ success: true, data: allocation });
  } catch (e) {
    return next(e);
  }
}

async function updateAllocation(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("transportAllocation", req.params.id, schoolId, "Allocation", "NOT_FOUND");
    const body = allocationSchema.partial().parse(req.body);
    const allocation = await prisma.transportAllocation.update({
      where: { id: req.params.id },
      data: body,
      include: { student: true, route: true },
    });
    return res.status(200).json({ success: true, data: allocation });
  } catch (e) {
    return next(e);
  }
}

async function deleteAllocation(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("transportAllocation", req.params.id, schoolId, "Allocation", "NOT_FOUND");
    await prisma.transportAllocation.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listRoutes,
  createRoute,
  updateRoute,
  deleteRoute,
  listDrivers,
  createDriver,
  listAllocations,
  createAllocation,
  updateAllocation,
  deleteAllocation,
};
