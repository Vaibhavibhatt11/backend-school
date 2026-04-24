"use strict";

const { z } = require("zod");
const { prisma, scopedSchoolId, findScopedOrThrow, paginationFromQuery, paginated } = require("./school.common");
const cache = require("../../lib/cache");
const { getPaginationMeta } = require("../../utils/schoolScope");

function invalidateEvents(schoolId) {
  cache.delByPrefix(`events:list:${schoolId}`);
}

async function listEvents(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const from = typeof req.query.from === "string" ? req.query.from : "";
    const to = typeof req.query.to === "string" ? req.query.to : "";
    const cacheKey = cache.cacheKeys.eventsList(schoolId, page, limit, from, to);
    const ttl = cache.CACHE_TTL.list();
    const result = await cache.getOrSet(cacheKey, ttl, async () => {
      const where = { schoolId };
      if (req.query.eventType) where.eventType = String(req.query.eventType).trim().slice(0, 30);
      if (req.query.from) where.startDate = { gte: new Date(req.query.from) };
      if (req.query.to) where.endDate = { lte: new Date(req.query.to) };
      const [total, items] = await Promise.all([
        prisma.event.count({ where }),
        prisma.event.findMany({
          where,
          skip,
          take: limit,
          orderBy: { startDate: "desc" },
          select: {
            id: true,
            title: true,
            eventType: true,
            startDate: true,
            endDate: true,
            location: true,
            isPublished: true,
            createdAt: true,
            _count: { select: { registrations: true } },
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

async function getEventById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const event = await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    const withRelations = await prisma.event.findUnique({
      where: { id: event.id },
      select: {
        id: true,
        title: true,
        description: true,
        eventType: true,
        startDate: true,
        endDate: true,
        location: true,
        isPublished: true,
        createdAt: true,
        registrations: { select: { id: true, studentId: true, userId: true, email: true, status: true, createdAt: true } },
        gallery: { select: { id: true, url: true, caption: true, sortOrder: true }, orderBy: { sortOrder: "asc" } },
      },
    });
    return res.status(200).json({ success: true, data: withRelations });
  } catch (e) {
    return next(e);
  }
}

async function createEvent(req, res, next) {
  try {
    const body = z.object({
      schoolId: z.string().optional(),
      title: z.string().trim().min(1).max(200),
      description: z.string().trim().max(5000).optional().nullable(),
      eventType: z.string().trim().max(80).default("GENERAL"),
      startDate: z.coerce.date(),
      endDate: z.coerce.date().optional().nullable(),
      location: z.string().trim().max(200).optional().nullable(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    if (body.endDate && body.endDate < body.startDate) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "End date cannot be before start date" },
      });
    }
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const event = await prisma.event.create({
      data: {
        schoolId,
        title: body.title,
        description: body.description?.trim() || null,
        eventType: body.eventType.trim() || "GENERAL",
        startDate: body.startDate,
        endDate: body.endDate || null,
        location: body.location?.trim() || null,
        isPublished: body.isPublished !== false,
      },
    });
    invalidateEvents(schoolId);
    return res.status(201).json({ success: true, data: event });
  } catch (e) {
    return next(e);
  }
}

async function updateEvent(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    const body = z.object({
      title: z.string().trim().max(200).optional(),
      description: z.string().trim().max(5000).optional().nullable(),
      eventType: z.string().trim().max(80).optional(),
      startDate: z.coerce.date().optional(),
      endDate: z.coerce.date().optional().nullable(),
      location: z.string().trim().max(200).optional().nullable(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    if (body.startDate && body.endDate && body.endDate < body.startDate) {
      return res.status(400).json({
        success: false,
        error: { code: "BAD_REQUEST", message: "End date cannot be before start date" },
      });
    }
    const data = {};
    if (body.title !== undefined) data.title = body.title.trim();
    if (body.description !== undefined) data.description = body.description?.trim() || null;
    if (body.eventType !== undefined) data.eventType = body.eventType.trim() || "GENERAL";
    if (body.startDate !== undefined) data.startDate = body.startDate;
    if (body.endDate !== undefined) data.endDate = body.endDate || null;
    if (body.location !== undefined) data.location = body.location?.trim() || null;
    if (body.isPublished !== undefined) data.isPublished = body.isPublished;
    const event = await prisma.event.update({ where: { id: req.params.id }, data });
    invalidateEvents(schoolId);
    return res.status(200).json({ success: true, data: event });
  } catch (e) {
    return next(e);
  }
}

async function deleteEvent(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    await prisma.event.delete({ where: { id: req.params.id } });
    invalidateEvents(schoolId);
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

async function listRegistrations(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    const items = await prisma.eventRegistration.findMany({
      where: { eventId: req.params.id },
      orderBy: { createdAt: "desc" },
    });
    return res.status(200).json({ success: true, data: { items } });
  } catch (e) {
    return next(e);
  }
}

async function registerForEvent(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const event = await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    const body = z.object({
      studentId: z.string().optional(),
      userId: z.string().optional(),
      email: z.string().email().max(120).optional(),
    }).parse(req.body);
    const reg = await prisma.eventRegistration.create({
      data: {
        eventId: event.id,
        schoolId,
        studentId: body.studentId || null,
        userId: body.userId || null,
        email: body.email || null,
        status: "REGISTERED",
      },
    });
    invalidateEvents(schoolId);
    return res.status(201).json({ success: true, data: reg });
  } catch (e) {
    return next(e);
  }
}

async function addGalleryImage(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    const body = z.object({ url: z.string().trim().min(1).max(2000), caption: z.string().max(200).optional(), sortOrder: z.number().int().optional() }).parse(req.body);
    const img = await prisma.eventGalleryImage.create({
      data: { eventId: req.params.id, url: body.url, caption: body.caption || null, sortOrder: body.sortOrder ?? 0 },
    });
    invalidateEvents(schoolId);
    return res.status(201).json({ success: true, data: img });
  } catch (e) {
    return next(e);
  }
}

async function deleteGalleryImage(req, res, next) {
  try {
    await prisma.eventGalleryImage.delete({ where: { id: req.params.imageId } }).catch(() => null);
    return res.status(200).json({ success: true, data: { deleted: true } });
  } catch (e) {
    return next(e);
  }
}

module.exports = {
  listEvents,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent,
  listRegistrations,
  registerForEvent,
  addGalleryImage,
  deleteGalleryImage,
};
