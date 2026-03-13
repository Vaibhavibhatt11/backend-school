"use strict";

const { z } = require("zod");
const { prisma, scopedSchoolId, findScopedOrThrow, paginationFromQuery, paginated } = require("./school.common");

async function listEvents(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, req.query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(req.query);
    const where = { schoolId };
    if (req.query.eventType) where.eventType = req.query.eventType;
    if (req.query.from) where.startDate = { gte: new Date(req.query.from) };
    if (req.query.to) where.endDate = { ...(where.endDate || {}), lte: new Date(req.query.to) };
    const [total, items] = await Promise.all([
      prisma.event.count({ where }),
      prisma.event.findMany({
        where,
        skip,
        take: limit,
        orderBy: { startDate: "desc" },
        include: { _count: { select: { registrations: true } } },
      }),
    ]);
    return res.status(200).json({ success: true, data: paginated(items, total, page, limit) });
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
      include: { registrations: true, gallery: true },
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
      title: z.string().trim().min(1),
      description: z.string().optional(),
      eventType: z.string().default("GENERAL"),
      startDate: z.coerce.date(),
      endDate: z.coerce.date().optional().nullable(),
      location: z.string().optional(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    const schoolId = scopedSchoolId(req, body.schoolId, true);
    const event = await prisma.event.create({
      data: {
        schoolId,
        title: body.title,
        description: body.description || null,
        eventType: body.eventType,
        startDate: body.startDate,
        endDate: body.endDate || null,
        location: body.location || null,
        isPublished: body.isPublished !== false,
      },
    });
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
      title: z.string().optional(),
      description: z.string().optional(),
      eventType: z.string().optional(),
      startDate: z.coerce.date().optional(),
      endDate: z.coerce.date().optional().nullable(),
      location: z.string().optional(),
      isPublished: z.boolean().optional(),
    }).parse(req.body);
    const event = await prisma.event.update({ where: { id: req.params.id }, data: body });
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
      email: z.string().email().optional(),
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
    return res.status(201).json({ success: true, data: reg });
  } catch (e) {
    return next(e);
  }
}

async function addGalleryImage(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    await findScopedOrThrow("event", req.params.id, schoolId, "Event", "NOT_FOUND");
    const body = z.object({ url: z.string().trim().min(1), caption: z.string().optional(), sortOrder: z.number().optional() }).parse(req.body);
    const img = await prisma.eventGalleryImage.create({
      data: { eventId: req.params.id, url: body.url, caption: body.caption || null, sortOrder: body.sortOrder ?? 0 },
    });
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
