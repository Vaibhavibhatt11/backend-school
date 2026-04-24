const { z } = require("zod");

const { badRequest, notFound } = require("../../utils/httpErrors");
const { parsePagination, getPaginationMeta } = require("../../utils/schoolScope");
const { prisma, scopedSchoolId, loadCustomRoles } = require("../school/school.common");

const leaveStatusEnum = z.enum(["PENDING", "APPROVED", "REJECTED"]);

const builtInHrRoles = [
  { id: "HR", name: "HR", permissions: ["staff.manage", "leave.manage"], isSystem: true },
  { id: "TEACHER", name: "Teacher", permissions: ["attendance.mark", "students.view"], isSystem: true },
];

function dayWindow(dateInput = new Date()) {
  const d = new Date(dateInput);
  const start = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), 0, 0, 0));
  const end = new Date(start);
  end.setUTCDate(end.getUTCDate() + 1);
  return { start, end };
}

function toLeaveRequestDto(leave) {
  return {
    id: leave.id,
    schoolId: leave.schoolId,
    staffId: leave.staffId,
    date: leave.date,
    remark: leave.reason || leave.attendance?.remark || null,
    status: leave.status,
    note: leave.note || null,
    comments: leave.comments.map((comment) => ({
      id: comment.id,
      comment: comment.comment,
      createdAt: comment.createdAt,
      actorId: comment.actorId,
    })),
    staff: leave.staff,
  };
}

async function syncLeaveRequestsFromAttendance(schoolId, staffId) {
  const attendanceWhere = { schoolId, status: "LEAVE" };
  if (staffId) attendanceWhere.staffId = staffId;

  const leaveAttendance = await prisma.staffAttendance.findMany({
    where: attendanceWhere,
    select: {
      id: true,
      schoolId: true,
      staffId: true,
      date: true,
      remark: true,
      markedById: true,
    },
  });

  if (!leaveAttendance.length) return;

  const existing = await prisma.leaveRequest.findMany({
    where: { attendanceId: { in: leaveAttendance.map((item) => item.id) } },
    select: { attendanceId: true },
  });
  const existingAttendanceIds = new Set(existing.map((item) => item.attendanceId).filter(Boolean));

  const createData = leaveAttendance
    .filter((item) => !existingAttendanceIds.has(item.id))
    .map((item) => ({
      id: item.id,
      schoolId: item.schoolId,
      staffId: item.staffId,
      attendanceId: item.id,
      date: item.date,
      reason: item.remark || null,
      status: "PENDING",
      createdById: item.markedById || null,
    }));

  if (!createData.length) return;
  await prisma.leaveRequest.createMany({ data: createData, skipDuplicates: true });
}

async function dashboardOverview(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    const { start, end } = dayWindow(new Date());

    const [staffTotal, presentToday, absentToday, leaveToday] = await Promise.all([
      prisma.staff.count({ where: { schoolId } }),
      prisma.staffAttendance.count({ where: { schoolId, date: { gte: start, lt: end }, status: "PRESENT" } }),
      prisma.staffAttendance.count({ where: { schoolId, date: { gte: start, lt: end }, status: "ABSENT" } }),
      prisma.staffAttendance.count({ where: { schoolId, date: { gte: start, lt: end }, status: "LEAVE" } }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        staffTotal,
        attendanceToday: { present: presentToday, absent: absentToday, leave: leaveToday },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listStaff(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      search: z.string().trim().min(1).optional(),
      department: z.string().trim().min(1).optional(),
      isActive: z.enum(["true", "false"]).optional(),
      schoolId: z.string().trim().min(1).optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;
    const where = { schoolId };
    if (query.department) where.department = query.department;
    if (query.isActive) where.isActive = query.isActive === "true";
    if (query.search) {
      where.OR = [
        { employeeCode: { contains: query.search, mode: "insensitive" } },
        { fullName: { contains: query.search, mode: "insensitive" } },
        { email: { contains: query.search, mode: "insensitive" } },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.staff.count({ where }),
      prisma.staff.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: { items, pagination: getPaginationMeta(total, page, limit) },
    });
  } catch (error) {
    return next(error);
  }
}

async function getStaffById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    const staff = await prisma.staff.findUnique({
      where: { id: req.params.id },
      include: {
        user: { select: { id: true, fullName: true, email: true, role: true } },
      },
    });
    if (!staff || staff.schoolId !== schoolId) throw notFound("Staff not found", "STAFF_NOT_FOUND");

    return res.status(200).json({ success: true, data: { staff } });
  } catch (error) {
    return next(error);
  }
}

async function listLeaveRequests(req, res, next) {
  try {
    const query = z.object({
      page: z.coerce.number().int().positive().optional(),
      limit: z.coerce.number().int().positive().optional(),
      schoolId: z.string().trim().min(1).optional(),
      staffId: z.string().trim().min(1).optional(),
      status: leaveStatusEnum.optional(),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);

    await syncLeaveRequestsFromAttendance(schoolId, query.staffId);

    const { page, limit } = parsePagination(query);
    const skip = (page - 1) * limit;
    const where = { schoolId };
    if (query.staffId) where.staffId = query.staffId;
    if (query.status) where.status = query.status;

    const [total, rows] = await Promise.all([
      prisma.leaveRequest.count({ where }),
      prisma.leaveRequest.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: "desc" },
        include: {
          attendance: {
            select: { id: true, remark: true, date: true },
          },
          staff: { select: { id: true, employeeCode: true, fullName: true, department: true } },
          comments: {
            orderBy: { createdAt: "asc" },
            select: { id: true, comment: true, createdAt: true, actorId: true },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        items: rows.map(toLeaveRequestDto),
        pagination: getPaginationMeta(total, page, limit),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function getLeaveRequestById(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    await syncLeaveRequestsFromAttendance(schoolId);

    const leave = await prisma.leaveRequest.findUnique({
      where: { id: req.params.id },
      include: {
        attendance: { select: { id: true, remark: true, date: true } },
        staff: { select: { id: true, employeeCode: true, fullName: true, department: true } },
        comments: {
          orderBy: { createdAt: "asc" },
          select: { id: true, comment: true, createdAt: true, actorId: true },
        },
      },
    });
    if (!leave || leave.schoolId !== schoolId) {
      throw notFound("Leave request not found", "LEAVE_REQUEST_NOT_FOUND");
    }

    return res.status(200).json({
      success: true,
      data: { leaveRequest: toLeaveRequestDto(leave) },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateLeaveRequestStatus(req, res, next) {
  try {
    const payload = z.object({ status: leaveStatusEnum, note: z.string().trim().min(1).optional() }).parse(req.body);
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    await syncLeaveRequestsFromAttendance(schoolId);

    const leave = await prisma.leaveRequest.findUnique({ where: { id: req.params.id } });
    if (!leave || leave.schoolId !== schoolId) {
      throw notFound("Leave request not found", "LEAVE_REQUEST_NOT_FOUND");
    }

    const updated = await prisma.leaveRequest.update({
      where: { id: leave.id },
      data: {
        status: payload.status,
        note: payload.note || null,
        reviewedById: req.user?.sub || null,
        reviewedAt: new Date(),
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "LEAVE_REQUEST_STATUS_UPDATED",
        entity: "LeaveRequest",
        entityId: leave.id,
        meta: { status: updated.status, note: updated.note || null },
      },
    });

    return res.status(200).json({ success: true, data: { message: "Leave request status updated" } });
  } catch (error) {
    return next(error);
  }
}

async function addLeaveRequestComment(req, res, next) {
  try {
    const payload = z.object({ comment: z.string().trim().min(1) }).parse(req.body);
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    await syncLeaveRequestsFromAttendance(schoolId);

    const leave = await prisma.leaveRequest.findUnique({ where: { id: req.params.id } });
    if (!leave || leave.schoolId !== schoolId) {
      throw notFound("Leave request not found", "LEAVE_REQUEST_NOT_FOUND");
    }

    const comment = await prisma.leaveRequestComment.create({
      data: {
        leaveRequestId: leave.id,
        schoolId,
        actorId: req.user?.sub || null,
        comment: payload.comment,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "LEAVE_REQUEST_COMMENT_ADDED",
        entity: "LeaveRequest",
        entityId: leave.id,
        meta: { commentId: comment.id, comment: comment.comment },
      },
    });

    return res.status(201).json({ success: true, data: { message: "Comment added" } });
  } catch (error) {
    return next(error);
  }
}

async function attendancePerformance(req, res, next) {
  try {
    const query = z.object({
      schoolId: z.string().trim().min(1).optional(),
      from: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      to: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const where = { schoolId };
    if (query.from || query.to) {
      where.date = {};
      if (query.from) where.date.gte = query.from;
      if (query.to) where.date.lte = query.to;
    }

    const rows = await prisma.staffAttendance.groupBy({
      by: ["staffId", "status"],
      where,
      _count: { _all: true },
    });

    const map = new Map();
    for (const row of rows) {
      const item = map.get(row.staffId) || { staffId: row.staffId, PRESENT: 0, ABSENT: 0, LATE: 0, LEAVE: 0 };
      item[row.status] = row._count._all;
      map.set(row.staffId, item);
    }

    const staffIds = Array.from(map.keys());
    const staff = await prisma.staff.findMany({
      where: { id: { in: staffIds } },
      select: { id: true, fullName: true, employeeCode: true, department: true },
    });
    const staffMap = new Map(staff.map((s) => [s.id, s]));

    const items = Array.from(map.values()).map((item) => ({
      staff: staffMap.get(item.staffId) || null,
      present: item.PRESENT,
      absent: item.ABSENT,
      late: item.LATE,
      leave: item.LEAVE,
      score: item.PRESENT + item.LATE * 0.5,
    }));

    return res.status(200).json({ success: true, data: { items } });
  } catch (error) {
    return next(error);
  }
}

async function attendancePerformanceByStaff(req, res, next) {
  try {
    const query = z.object({
      schoolId: z.string().trim().min(1).optional(),
      from: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
      to: z.preprocess((v) => (v === "" || v === null ? undefined : v), z.coerce.date().optional()),
    }).parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const staff = await prisma.staff.findUnique({ where: { id: req.params.staffId } });
    if (!staff || staff.schoolId !== schoolId) throw notFound("Staff not found", "STAFF_NOT_FOUND");
    const where = { schoolId, staffId: staff.id };
    if (query.from || query.to) {
      where.date = {};
      if (query.from) where.date.gte = query.from;
      if (query.to) where.date.lte = query.to;
    }
    const rows = await prisma.staffAttendance.findMany({ where, orderBy: { date: "desc" } });
    return res.status(200).json({ success: true, data: { staff, items: rows } });
  } catch (error) {
    return next(error);
  }
}

async function getSettings(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    const settings = await prisma.hrSetting.upsert({
      where: { schoolId },
      update: {},
      create: { schoolId },
    });

    return res.status(200).json({
      success: true,
      data: {
        settings: {
          approvalLevels: settings.approvalLevels,
          allowSelfAttendanceRegularization: settings.allowSelfAttendanceRegularization,
          probationMonths: settings.probationMonths,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateSettings(req, res, next) {
  try {
    const payload = z.object({
      approvalLevels: z.coerce.number().int().min(1).max(5).optional(),
      allowSelfAttendanceRegularization: z.boolean().optional(),
      probationMonths: z.coerce.number().int().min(0).max(24).optional(),
    }).parse(req.body);
    if (!Object.keys(payload).length) throw badRequest("At least one field is required");
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);

    const updated = await prisma.hrSetting.upsert({
      where: { schoolId },
      update: {
        ...payload,
        updatedById: req.user?.sub || null,
      },
      create: {
        schoolId,
        approvalLevels: payload.approvalLevels ?? 1,
        allowSelfAttendanceRegularization: payload.allowSelfAttendanceRegularization ?? false,
        probationMonths: payload.probationMonths ?? 6,
        updatedById: req.user?.sub || null,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        entity: "HrSettings",
        action: "HR_SETTINGS_UPDATED",
        meta: {
          approvalLevels: updated.approvalLevels,
          allowSelfAttendanceRegularization: updated.allowSelfAttendanceRegularization,
          probationMonths: updated.probationMonths,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        settings: {
          approvalLevels: updated.approvalLevels,
          allowSelfAttendanceRegularization: updated.allowSelfAttendanceRegularization,
          probationMonths: updated.probationMonths,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listRoles(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);
    const [custom, policies] = await Promise.all([
      loadCustomRoles(schoolId),
      prisma.hrRolePolicy.findMany({ where: { schoolId } }),
    ]);
    const policyMap = new Map(policies.map((policy) => [policy.roleId, policy]));

    const defaults = builtInHrRoles.map((role) => {
      const policy = policyMap.get(role.id);
      if (!policy) return role;
      return {
        ...role,
        name: policy.name || role.name,
        permissions: policy.permissions?.length ? policy.permissions : role.permissions,
        isActive: policy.isActive,
      };
    });

    return res.status(200).json({
      success: true,
      data: { items: [...defaults, ...custom.map((x) => ({ ...x, isSystem: false }))] },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateRole(req, res, next) {
  try {
    const payload = z.object({
      name: z.string().trim().min(1).optional(),
      permissions: z.array(z.string().trim().min(1)).optional(),
      isActive: z.boolean().optional(),
    }).parse(req.body);
    if (!Object.keys(payload).length) throw badRequest("At least one field is required");
    const schoolId = scopedSchoolId(req, typeof req.query.schoolId === "string" ? req.query.schoolId : undefined, true);

    const customRole = await prisma.schoolRole.findFirst({
      where: { schoolId, id: req.params.id },
    });

    if (customRole) {
      await prisma.schoolRole.update({
        where: { id: customRole.id },
        data: {
          name: payload.name ?? customRole.name,
          permissions: payload.permissions ?? customRole.permissions,
          isActive: payload.isActive ?? customRole.isActive,
          updatedById: req.user?.sub || null,
        },
      });
    } else {
      const existing = await prisma.hrRolePolicy.findUnique({
        where: { schoolId_roleId: { schoolId, roleId: req.params.id } },
      });

      await prisma.hrRolePolicy.upsert({
        where: { schoolId_roleId: { schoolId, roleId: req.params.id } },
        update: {
          name: payload.name ?? existing?.name ?? null,
          permissions: payload.permissions ?? existing?.permissions ?? [],
          isActive: payload.isActive ?? existing?.isActive ?? true,
          updatedById: req.user?.sub || null,
        },
        create: {
          schoolId,
          roleId: req.params.id,
          name: payload.name ?? null,
          permissions: payload.permissions ?? [],
          isActive: payload.isActive ?? true,
          updatedById: req.user?.sub || null,
        },
      });
    }

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        entity: "HrRolePolicy",
        entityId: req.params.id,
        action: "HR_ROLE_UPDATED",
        meta: payload,
      },
    });
    return res.status(200).json({ success: true, data: { message: "Role updated successfully" } });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  dashboardOverview,
  listStaff,
  getStaffById,
  listLeaveRequests,
  getLeaveRequestById,
  updateLeaveRequestStatus,
  addLeaveRequestComment,
  attendancePerformance,
  attendancePerformanceByStaff,
  getSettings,
  updateSettings,
  listRoles,
  updateRole,
};
