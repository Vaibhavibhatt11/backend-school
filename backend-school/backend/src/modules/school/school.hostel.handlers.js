"use strict";

const { z } = require("zod");
const { prisma, scopedSchoolId, findScopedOrThrow, paginationFromQuery, paginated } = require("./school.common");
const cache = require("../../lib/cache");
const { getPaginationMeta } = require("../../utils/schoolScope");

function invalidateHostel(schoolId) {
  cache.delByPrefix(`hostel:rooms:${schoolId}`);
  cache.delByPrefix(`hostel:allocations:${schoolId}`);
}

async function listRooms(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const cacheKey = cache.cacheKeys.hostelRoomsList(schoolId);
    const ttl = cache.CACHE_TTL.list();
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const items = await prisma.hostelRoom.findMany({
        where: { schoolId },
        orderBy: [{ block: "asc" }, { roomNo: "asc" }],
        select: { id: true, block: true, roomNo: true, capacity: true, isActive: true, createdAt: true },
      });
      return { items };
    });
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

async function createRoom(req, res, next) {
  try {
    const body = z.object({
      schoolId: z.string().optional(),
      block: z.string().trim().min(1).max(50),
      roomNo: z.string().trim().min(1).max(20),
      capacity: z.number().int().min(1).max(50).default(1),
      isActive: z.boolean().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const room = await prisma.hostelRoom.create({
      data: { schoolId, block: body.block, roomNo: body.roomNo, capacity: body.capacity, isActive: body.isActive !== false },
    });
    invalidateHostel(schoolId);
    return res.status(201).json({ success: true, data: room });
  } catch (e) {
    return next(e);
  }
}

async function updateRoom(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("hostelRoom", req.params.id, schoolId, "Room", "NOT_FOUND");
    const body = z.object({ block: z.string().max(50).optional(), roomNo: z.string().max(20).optional(), capacity: z.number().int().min(1).optional(), isActive: z.boolean().optional() }).parse(req.body);
    const room = await prisma.hostelRoom.update({ where: { id: req.params.id }, data: body });
    invalidateHostel(schoolId);
    return res.status(200).json({ success: true, data: room });
  } catch (e) {
    return next(e);
  }
}

async function deleteRoom(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("hostelRoom", req.params.id, schoolId, "Room", "NOT_FOUND");
    await prisma.hostelRoom.delete({ where: { id: req.params.id } });
    invalidateHostel(schoolId);
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

async function listAllocations(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const cacheKey = cache.cacheKeys.hostelAllocationsList(schoolId, page, limit);
    const ttl = cache.CACHE_TTL.list();
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const where = { schoolId };
      if (req.query.roomId) where.roomId = req.query.roomId;
      if (req.query.studentId) where.studentId = req.query.studentId;
      const [total, items] = await Promise.all([
        prisma.hostelAllocation.count({ where }),
        prisma.hostelAllocation.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
          select: {
            id: true,
            studentId: true,
            roomId: true,
            fromDate: true,
            toDate: true,
            createdAt: true,
            student: { select: { id: true, firstName: true, lastName: true, admissionNo: true } },
            room: { select: { id: true, block: true, roomNo: true, capacity: true } },
          },
        }),
      ]);
      return { items, pagination: getPaginationMeta(total, page, limit) };
    });
    return res.status(200).json({ success: true, data: result });
  } catch (e) {
    return next(e);
  }
}

async function createAllocation(req, res, next) {
  try {
    const body = z.object({
      studentId: z.string().trim().min(1),
      roomId: z.string().trim().min(1),
      fromDate: z.coerce.date().optional(),
      toDate: z.coerce.date().optional().nullable(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("hostelRoom", body.roomId, schoolId, "Room", "NOT_FOUND");
    const allocation = await prisma.hostelAllocation.create({
      data: { schoolId, studentId: body.studentId, roomId: body.roomId, fromDate: body.fromDate || new Date(), toDate: body.toDate || null },
      include: { student: { select: { id: true, firstName: true, lastName: true, admissionNo: true } }, room: { select: { id: true, block: true, roomNo: true, capacity: true } } },
    });
    invalidateHostel(schoolId);
    return res.status(201).json({ success: true, data: allocation });
  } catch (e) {
    return next(e);
  }
}

async function listAttendance(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const date = req.query.date ? new Date(req.query.date) : new Date();
    const start = new Date(date); start.setUTCHours(0,0,0,0);
    const end = new Date(date); end.setUTCHours(23,59,59,999);
    const items = await prisma.hostelAttendance.findMany({
      where: { schoolId, date: { gte: start, lte: end } },
      orderBy: { createdAt: "asc" },
    });
    return res.status(200).json({ success: true, data: { items, date: date.toISOString().slice(0,10) } });
  } catch (e) {
    return next(e);
  }
}

async function markHostelAttendance(req, res, next) {
  try {
    const body = z.object({
      studentId: z.string().trim().min(1),
      date: z.coerce.date(),
      status: z.string().default("PRESENT"),
      remark: z.string().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const att = await prisma.hostelAttendance.upsert({
      where: {
        schoolId_studentId_date: { schoolId, studentId: body.studentId, date: body.date },
      },
      create: { schoolId, studentId: body.studentId, date: body.date, status: body.status, remark: body.remark || null },
      update: { status: body.status, remark: body.remark || null },
    });
    return res.status(200).json({ success: true, data: att });
  } catch (e) {
    return next(e);
  }
}

async function listVisitors(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const [total, items] = await Promise.all([
      prisma.hostelVisitor.count({ where: { schoolId } }),
      prisma.hostelVisitor.findMany({ where: { schoolId }, skip, take: limit, orderBy: { inTime: "desc" } }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
  } catch (e) {
    return next(e);
  }
}

async function createVisitor(req, res, next) {
  try {
    const body = z.object({
      visitorName: z.string().trim().min(1),
      studentId: z.string().optional(),
      purpose: z.string().optional(),
      idProof: z.string().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const visitor = await prisma.hostelVisitor.create({
      data: { schoolId, visitorName: body.visitorName, studentId: body.studentId || null, purpose: body.purpose || null, idProof: body.idProof || null },
    });
    return res.status(201).json({ success: true, data: visitor });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listRooms,
  createRoom,
  updateRoom,
  deleteRoom,
  listAllocations,
  createAllocation,
  listAttendance,
  markHostelAttendance,
  listVisitors,
  createVisitor,
};
