const { z } = require("zod");

const env = require("../../config/env");
const { badRequest, notFound } = require("../../utils/httpErrors");
const {
  prisma,
  scopedSchoolId,
  ensureSchoolExists,
  findScopedOrThrow,
  paginationFromQuery,
  paginated,
  baseSchoolSearch,
  asUpdateData,
  loadCustomRoles,
  ensureNotSystemRole,
  newRoleId,
} = require("./school.common");

const parentInviteSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  fullName: z.string().trim().min(1),
  email: z.string().email().optional(),
  phone: z.string().trim().min(3).optional(),
  studentId: z.string().trim().min(1).optional(),
  relationType: z.string().trim().min(1).optional(),
  isPrimary: z.boolean().optional(),
});

const createStaffSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  userId: z.string().trim().min(1).optional(),
  employeeCode: z.string().trim().min(1),
  fullName: z.string().trim().min(1),
  email: z.string().email().optional(),
  phone: z.string().trim().min(3).optional(),
  designation: z.string().trim().min(1).optional(),
  department: z.string().trim().min(1).optional(),
  isActive: z.boolean().optional(),
  joinDate: z.preprocess(
    (v) => (v === "" || v === null ? undefined : v),
    z.coerce.date().optional()
  ),
});

const updateStaffSchema = z.object({
  userId: z.union([z.string().trim().min(1), z.null()]).optional(),
  employeeCode: z.string().trim().min(1).optional(),
  fullName: z.string().trim().min(1).optional(),
  email: z.union([z.string().email(), z.null()]).optional(),
  phone: z.union([z.string().trim().min(3), z.null()]).optional(),
  designation: z.union([z.string().trim().min(1), z.null()]).optional(),
  department: z.union([z.string().trim().min(1), z.null()]).optional(),
  isActive: z.boolean().optional(),
  joinDate: z.preprocess((v) => (v === "" ? null : v), z.union([z.coerce.date(), z.null()]).optional()),
});

const createRoleSchema = z.object({
  schoolId: z.string().trim().min(1).optional(),
  name: z.string().trim().min(1),
  description: z.string().trim().min(1).optional(),
  permissions: z.array(z.string().trim().min(1)).default([]),
});

const updateRoleSchema = z.object({
  name: z.string().trim().min(1).optional(),
  description: z.string().trim().min(1).optional(),
  permissions: z.array(z.string().trim().min(1)).optional(),
  isActive: z.boolean().optional(),
});

async function listParents(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        search: z.string().trim().min(1).optional(),
        schoolId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);

    const where = baseSchoolSearch({ schoolId }, query.search, ["fullName", "email", "phone"]);
    const [total, items] = await Promise.all([
      prisma.parent.count({ where }),
      prisma.parent.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          students: {
            include: {
              student: {
                select: {
                  id: true,
                  admissionNo: true,
                  firstName: true,
                  lastName: true,
                  className: true,
                  section: true,
                },
              },
            },
          },
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: paginated(
        items.map((item) => ({
          ...item,
          students: item.students.map((x) => ({
            relationType: x.relationType,
            isPrimary: x.isPrimary,
            student: x.student,
          })),
        })),
        total,
        page,
        limit
      ),
    });
  } catch (error) {
    return next(error);
  }
}

async function inviteParent(req, res, next) {
  try {
    const payload = parentInviteSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    await ensureSchoolExists(schoolId);
    if (!payload.email && !payload.phone) {
      throw badRequest("Either email or phone is required");
    }

    let student = null;
    if (payload.studentId) {
      student = await findScopedOrThrow("student", payload.studentId, schoolId, "Student", "STUDENT_NOT_FOUND");
    }

    const parent = await prisma.parent.create({
      data: {
        schoolId,
        fullName: payload.fullName,
        email: payload.email,
        phone: payload.phone,
        isActive: true,
      },
    });

    if (student) {
      await prisma.studentParent.create({
        data: {
          studentId: student.id,
          parentId: parent.id,
          relationType: payload.relationType || "GUARDIAN",
          isPrimary: payload.isPrimary || false,
        },
      });
    }

    const otp = String(Math.floor(100000 + Math.random() * 900000));
    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "PARENT_INVITED",
        entity: "Parent",
        entityId: parent.id,
        meta: { otp, studentId: student?.id || null },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        parent,
        invitation: {
          sent: true,
          debugOtp: env.NODE_ENV === "production" ? undefined : otp,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function resendParentOtp(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const parent = await findScopedOrThrow("parent", req.params.id, schoolId, "Parent", "PARENT_NOT_FOUND");
    const otp = String(Math.floor(100000 + Math.random() * 900000));

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "PARENT_OTP_RESENT",
        entity: "Parent",
        entityId: parent.id,
        meta: { otp },
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        message: "OTP resent successfully",
        debugOtp: env.NODE_ENV === "production" ? undefined : otp,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function listStaff(req, res, next) {
  try {
    const query = z
      .object({
        page: z.coerce.number().int().positive().optional(),
        limit: z.coerce.number().int().positive().optional(),
        search: z.string().trim().min(1).optional(),
        department: z.string().trim().min(1).optional(),
        isActive: z.enum(["true", "false"]).optional(),
        schoolId: z.string().trim().min(1).optional(),
      })
      .parse(req.query);
    const schoolId = scopedSchoolId(req, query.schoolId, true);
    const { page, limit, skip } = paginationFromQuery(query);
    const where = baseSchoolSearch({ schoolId }, query.search, ["employeeCode", "fullName", "email"]);
    if (query.department) where.department = query.department;
    if (query.isActive) where.isActive = query.isActive === "true";

    const [total, items] = await Promise.all([
      prisma.staff.count({ where }),
      prisma.staff.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: { user: { select: { id: true, fullName: true, email: true, role: true } } },
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

async function createStaff(req, res, next) {
  try {
    const payload = createStaffSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    await ensureSchoolExists(schoolId);

    const staff = await prisma.staff.create({
      data: {
        schoolId,
        userId: payload.userId,
        employeeCode: payload.employeeCode,
        fullName: payload.fullName,
        email: payload.email,
        phone: payload.phone,
        designation: payload.designation,
        department: payload.department,
        isActive: payload.isActive ?? true,
        joinDate: payload.joinDate,
      },
      include: { user: { select: { id: true, fullName: true, email: true, role: true } } },
    });

    return res.status(201).json({
      success: true,
      data: { staff },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateStaff(req, res, next) {
  try {
    const payload = updateStaffSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const staff = await findScopedOrThrow("staff", req.params.id, schoolId, "Staff", "STAFF_NOT_FOUND");
    const data = asUpdateData(payload);
    if (!Object.keys(data).length) throw badRequest("At least one field is required");

    const updated = await prisma.staff.update({
      where: { id: staff.id },
      data,
      include: { user: { select: { id: true, fullName: true, email: true, role: true } } },
    });

    return res.status(200).json({
      success: true,
      data: { staff: updated },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteStaff(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const staff = await findScopedOrThrow("staff", req.params.id, schoolId, "Staff", "STAFF_NOT_FOUND");
    await prisma.staff.delete({ where: { id: staff.id } });

    return res.status(200).json({
      success: true,
      data: { message: "Staff deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function listRoles(req, res, next) {
  try {
    const schoolId = scopedSchoolId(req, undefined, true);
    const customRoles = await loadCustomRoles(schoolId);

    const builtIn = [
      { id: "SUPERADMIN", name: "Super Admin", isSystem: true, isActive: true, permissions: ["*"] },
      { id: "SCHOOLADMIN", name: "School Admin", isSystem: true, isActive: true, permissions: ["students.manage", "staff.manage", "settings.manage"] },
      { id: "HR", name: "HR", isSystem: true, isActive: true, permissions: ["staff.manage", "attendance.view"] },
      { id: "ACCOUNTANT", name: "Accountant", isSystem: true, isActive: true, permissions: ["fees.manage", "invoices.manage", "payments.manage"] },
      { id: "TEACHER", name: "Teacher", isSystem: true, isActive: true, permissions: ["students.view", "attendance.mark", "exams.manage"] },
      { id: "PARENT", name: "Parent", isSystem: true, isActive: true, permissions: ["students.view.own", "fees.view.own"] },
    ];

    return res.status(200).json({
      success: true,
      data: {
        items: [
          ...builtIn,
          ...customRoles.map((r) => ({ ...r, isSystem: false })),
        ],
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function createRole(req, res, next) {
  try {
    const payload = createRoleSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, payload.schoolId, true);
    const roleId = newRoleId();

    const role = await prisma.schoolRole.create({
      data: {
        schoolId,
        id: roleId,
        name: payload.name,
        description: payload.description || "",
        permissions: payload.permissions,
        isActive: true,
        createdById: req.user?.sub || null,
        updatedById: req.user?.sub || null,
      },
    });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "SCHOOL_ROLE_CREATED",
        entity: "SchoolRole",
        entityId: role.id,
        meta: {
          roleId: role.id,
          name: role.name,
          description: role.description || "",
          permissions: role.permissions,
          isActive: role.isActive,
        },
      },
    });

    return res.status(201).json({
      success: true,
      data: {
        role: { ...role, description: role.description || "", isSystem: false },
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function updateRole(req, res, next) {
  try {
    ensureNotSystemRole(req.params.id);
    const payload = updateRoleSchema.parse(req.body);
    const schoolId = scopedSchoolId(req, undefined, true);
    const existing = await prisma.schoolRole.findFirst({
      where: { schoolId, id: req.params.id },
    });
    if (!existing) throw notFound("Role not found", "ROLE_NOT_FOUND");

    const updateData = {
      name: payload.name ?? existing.name,
      description: payload.description ?? existing.description ?? "",
      permissions: payload.permissions ?? existing.permissions ?? [],
      isActive: payload.isActive ?? existing.isActive,
      updatedById: req.user?.sub || null,
    };

    const updated = await prisma.schoolRole.update({
      where: { id: existing.id },
      data: updateData,
    });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "SCHOOL_ROLE_UPDATED",
        entity: "SchoolRole",
        entityId: updated.id,
        meta: {
          roleId: updated.id,
          name: updated.name,
          description: updated.description || "",
          permissions: updated.permissions,
          isActive: updated.isActive,
        },
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Role updated successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteRole(req, res, next) {
  try {
    ensureNotSystemRole(req.params.id);
    const schoolId = scopedSchoolId(req, undefined, true);
    const role = await prisma.schoolRole.findFirst({
      where: { schoolId, id: req.params.id },
    });
    if (!role) throw notFound("Role not found", "ROLE_NOT_FOUND");

    await prisma.schoolRole.delete({ where: { id: role.id } });

    await prisma.auditLog.create({
      data: {
        schoolId,
        actorId: req.user?.sub || null,
        action: "SCHOOL_ROLE_DELETED",
        entity: "SchoolRole",
        entityId: role.id,
        meta: { roleId: role.id },
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Role deleted successfully" },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listParents,
  inviteParent,
  resendParentOtp,
  listStaff,
  createStaff,
  updateStaff,
  deleteStaff,
  listRoles,
  createRole,
  updateRole,
  deleteRole,
};
