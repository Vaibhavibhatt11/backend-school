const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

if (!process.env.DATABASE_URL) {
  console.error(
    "DATABASE_URL is not set. Create a `.env` file in the project root (copy from `.env.example`) and add your PostgreSQL connection string."
  );
  process.exit(1);
}

const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  const defaultPlans = [
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

  for (const plan of defaultPlans) {
    await prisma.subscriptionPlan.upsert({
      where: { planCode: plan.planCode },
      update: {
        name: plan.name,
        priceMonthly: plan.priceMonthly,
        priceYearly: plan.priceYearly,
        isActive: plan.isActive,
        features: plan.features,
        maxStudents: plan.maxStudents,
        storageGb: plan.storageGb,
      },
      create: plan,
    });
  }

  await prisma.platformConfiguration.upsert({
    where: { id: "GLOBAL" },
    update: {},
    create: {
      id: "GLOBAL",
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
    },
  });

  await prisma.securitySetting.upsert({
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
      apiKeyVersion: 1,
    },
  });

  const school = await prisma.school.upsert({
    where: { code: "DEMO-SCHOOL" },
    update: {},
    create: {
      code: "DEMO-SCHOOL",
      name: "Demo School",
      email: "contact@demoschool.edu",
      phone: "+1-555-0100",
      status: "ACTIVE",
      timezone: "America/New_York",
      currencyCode: "USD",
    },
  });

  await prisma.schoolSubscription.upsert({
    where: { schoolId: school.id },
    update: {},
    create: {
      schoolId: school.id,
      planCode: "BASIC",
      autoRenew: false,
    },
  });

  await prisma.hrSetting.upsert({
    where: { schoolId: school.id },
    update: {},
    create: { schoolId: school.id },
  });

  const defaultPasswordHash = await bcrypt.hash("Admin123!", 10);

  const users = [
    {
      fullName: "Platform Super Admin",
      email: "super@school.edu",
      role: "SUPERADMIN",
      schoolId: null,
    },
    {
      fullName: "School Admin",
      email: "admin@school.edu",
      role: "SCHOOLADMIN",
      schoolId: school.id,
    },
    {
      fullName: "Accounts Manager",
      email: "acc@school.edu",
      role: "ACCOUNTANT",
      schoolId: school.id,
    },
    {
      fullName: "HR Manager",
      email: "hr@school.edu",
      role: "HR",
      schoolId: school.id,
    },
    {
      fullName: "Riya Teacher",
      email: "teacher@school.edu",
      role: "TEACHER",
      schoolId: school.id,
    },
  ];

  for (const user of users) {
    await prisma.user.upsert({
      where: { email: user.email },
      update: {
        fullName: user.fullName,
        role: user.role,
        schoolId: user.schoolId,
        isActive: true,
        passwordHash: defaultPasswordHash,
      },
      create: {
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        schoolId: user.schoolId,
        passwordHash: defaultPasswordHash,
        isActive: true,
      },
    });
  }

  // Test student for frontend development
  const studentPasswordHash = await bcrypt.hash("Student123!", 10);
  const studentUser = await prisma.user.upsert({
    where: { email: "student@school.edu" },
    update: {
      fullName: "Demo Student",
      role: "STUDENT",
      schoolId: school.id,
      isActive: true,
      passwordHash: studentPasswordHash,
    },
    create: {
      fullName: "Demo Student",
      email: "student@school.edu",
      role: "STUDENT",
      schoolId: school.id,
      passwordHash: studentPasswordHash,
      isActive: true,
    },
  });

  const demoClass = await prisma.classRoom.upsert({
    where: {
      schoolId_name_section: { schoolId: school.id, name: "Class 10", section: "A" },
    },
    update: {},
    create: {
      schoolId: school.id,
      name: "Class 10",
      section: "A",
    },
  });

  const demoStudent = await prisma.student.upsert({
    where: { schoolId_admissionNo: { schoolId: school.id, admissionNo: "STU001" } },
    update: {
      userId: studentUser.id,
      firstName: "Demo",
      lastName: "Student",
      className: "Class 10",
      section: "A",
      status: "ACTIVE",
    },
    create: {
      schoolId: school.id,
      classId: demoClass.id,
      admissionNo: "STU001",
      firstName: "Demo",
      lastName: "Student",
      className: "Class 10",
      section: "A",
      status: "ACTIVE",
      userId: studentUser.id,
    },
  });

  // Demo parent (same email on User + Parent so /parent APIs resolve)
  const parentPasswordHash = await bcrypt.hash("Parent123!", 10);
  await prisma.user.upsert({
    where: { email: "parent@school.edu" },
    update: {
      fullName: "Demo Parent",
      role: "PARENT",
      schoolId: school.id,
      isActive: true,
      passwordHash: parentPasswordHash,
    },
    create: {
      fullName: "Demo Parent",
      email: "parent@school.edu",
      role: "PARENT",
      schoolId: school.id,
      passwordHash: parentPasswordHash,
      isActive: true,
    },
  });

  let demoParentRecord = await prisma.parent.findFirst({
    where: { schoolId: school.id, email: "parent@school.edu" },
  });
  if (!demoParentRecord) {
    demoParentRecord = await prisma.parent.create({
      data: {
        schoolId: school.id,
        fullName: "Demo Parent",
        email: "parent@school.edu",
        phone: "+1-555-0199",
        isActive: true,
      },
    });
  } else {
    await prisma.parent.update({
      where: { id: demoParentRecord.id },
      data: { fullName: "Demo Parent", email: "parent@school.edu", isActive: true },
    });
  }

  await prisma.studentParent.upsert({
    where: {
      studentId_parentId: { studentId: demoStudent.id, parentId: demoParentRecord.id },
    },
    update: { relationType: "GUARDIAN", isPrimary: true },
    create: {
      studentId: demoStudent.id,
      parentId: demoParentRecord.id,
      relationType: "GUARDIAN",
      isPrimary: true,
    },
  });

  const teacherUser = await prisma.user.findUnique({
    where: { email: "teacher@school.edu" },
  });

  let teacherStaff = await prisma.staff.findFirst({
    where: {
      schoolId: school.id,
      OR: [
        { employeeCode: "EMP001" },
        ...(teacherUser?.id ? [{ userId: teacherUser.id }] : []),
        { email: "teacher@school.edu" },
      ],
    },
  });
  if (!teacherStaff) {
    teacherStaff = await prisma.staff.create({
      data: {
        schoolId: school.id,
        userId: teacherUser?.id || null,
        employeeCode: "EMP001",
        fullName: "Riya Teacher",
        email: "teacher@school.edu",
        phone: "+1-555-0188",
        designation: "Science Teacher",
        department: "Science",
        isActive: true,
        joinDate: new Date("2021-06-15"),
      },
    });
  } else {
    teacherStaff = await prisma.staff.update({
      where: { id: teacherStaff.id },
      data: {
        schoolId: school.id,
        userId: teacherUser?.id || teacherStaff.userId,
        employeeCode: teacherStaff.employeeCode || "EMP001",
        fullName: "Riya Teacher",
        email: "teacher@school.edu",
        phone: "+1-555-0188",
        designation: "Science Teacher",
        department: "Science",
        isActive: true,
        joinDate: teacherStaff.joinDate || new Date("2021-06-15"),
      },
    });
  }

  const science = await prisma.subject.upsert({
    where: { schoolId_code: { schoolId: school.id, code: "SCI10" } },
    update: {},
    create: {
      schoolId: school.id,
      name: "Science",
      code: "SCI10",
      isActive: true,
    },
  });

  await prisma.classRoom.update({
    where: { id: demoClass.id },
    data: { classTeacherId: teacherStaff.id },
  });

  await prisma.classSubject.upsert({
    where: { classId_subjectId: { classId: demoClass.id, subjectId: science.id } },
    update: { teacherId: teacherStaff.id },
    create: {
      classId: demoClass.id,
      subjectId: science.id,
      teacherId: teacherStaff.id,
    },
  });

  await prisma.staffDocument.upsert({
    where: { id: "seed-staff-doc-emp001" },
    update: {
      schoolId: school.id,
      staffId: teacherStaff.id,
      name: "Joining Letter.pdf",
      url: "https://example.com/docs/joining-letter.pdf",
      type: "PDF",
    },
    create: {
      id: "seed-staff-doc-emp001",
      schoolId: school.id,
      staffId: teacherStaff.id,
      name: "Joining Letter.pdf",
      url: "https://example.com/docs/joining-letter.pdf",
      type: "PDF",
    },
  });

  await prisma.announcement.upsert({
    where: { id: "seed-ann-1" },
    update: {
      schoolId: school.id,
      title: "PTM Schedule Released",
      content: "Parent teacher meetings start this Friday.",
      audience: "PARENT,STUDENT",
      status: "SENT",
      createdById: teacherUser?.id || null,
      sentAt: new Date(),
    },
    create: {
      id: "seed-ann-1",
      schoolId: school.id,
      title: "PTM Schedule Released",
      content: "Parent teacher meetings start this Friday.",
      audience: "PARENT,STUDENT",
      status: "SENT",
      createdById: teacherUser?.id || null,
      sentAt: new Date(),
    },
  });

  const template = await prisma.notificationTemplate.upsert({
    where: { schoolId_code: { schoolId: school.id, code: "GEN_ALERT" } },
    update: {},
    create: {
      schoolId: school.id,
      code: "GEN_ALERT",
      title: "General Alert",
      body: "School update",
      channel: "APP",
      isActive: true,
    },
  });

  await prisma.notificationLog.upsert({
    where: { id: "seed-notif-1" },
    update: {
      schoolId: school.id,
      templateId: template.id,
      announcementId: "seed-ann-1",
      targetType: "PARENT",
      targetRef: demoParentRecord.id,
      channel: "APP",
      status: "SENT",
      payload: { title: "PTM Schedule Released" },
    },
    create: {
      id: "seed-notif-1",
      schoolId: school.id,
      templateId: template.id,
      announcementId: "seed-ann-1",
      targetType: "PARENT",
      targetRef: demoParentRecord.id,
      channel: "APP",
      status: "SENT",
      payload: { title: "PTM Schedule Released" },
    },
  });

  const now = new Date();
  for (let i = 0; i < 7; i += 1) {
    const date = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - i, 0, 0, 0));
    await prisma.studentAttendance.upsert({
      where: {
        schoolId_studentId_date: {
          schoolId: school.id,
          studentId: demoStudent.id,
          date,
        },
      },
      update: { status: i === 2 ? "ABSENT" : i === 4 ? "LATE" : "PRESENT" },
      create: {
        schoolId: school.id,
        studentId: demoStudent.id,
        date,
        status: i === 2 ? "ABSENT" : i === 4 ? "LATE" : "PRESENT",
        remark: "Seed attendance",
        markedById: teacherUser?.id || null,
      },
    });
  }

  const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0));
  await prisma.staffAttendance.upsert({
    where: {
      schoolId_staffId_date: {
        schoolId: school.id,
        staffId: teacherStaff.id,
        date: today,
      },
    },
    update: { status: "PRESENT" },
    create: {
      schoolId: school.id,
      staffId: teacherStaff.id,
      date: today,
      status: "PRESENT",
      markedById: teacherUser?.id || null,
    },
  });

  const invoice = await prisma.invoice.upsert({
    where: { schoolId_invoiceNo: { schoolId: school.id, invoiceNo: "INV-DEMO-001" } },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      invoiceNo: "INV-DEMO-001",
      issueDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)),
      dueDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 25)),
      amountDue: 1500,
      amountPaid: 700,
      status: "PARTIAL",
    },
    create: {
      schoolId: school.id,
      studentId: demoStudent.id,
      invoiceNo: "INV-DEMO-001",
      issueDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)),
      dueDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 25)),
      amountDue: 1500,
      amountPaid: 700,
      status: "PARTIAL",
    },
  });

  await prisma.payment.upsert({
    where: { id: "seed-payment-1" },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      invoiceId: invoice.id,
      receiptNo: "REC-DEMO-001",
      amount: 700,
      method: "ONLINE",
      paidAt: new Date(),
      collectedById: teacherUser?.id || null,
    },
    create: {
      id: "seed-payment-1",
      schoolId: school.id,
      studentId: demoStudent.id,
      invoiceId: invoice.id,
      receiptNo: "REC-DEMO-001",
      amount: 700,
      method: "ONLINE",
      paidAt: new Date(),
      collectedById: teacherUser?.id || null,
    },
  });

  await prisma.liveClassSession.upsert({
    where: { id: "seed-live-1" },
    update: {
      schoolId: school.id,
      classId: demoClass.id,
      subjectId: science.id,
      teacherId: teacherStaff.id,
      title: "Science Live Class",
      startsAt: new Date(Date.now() + 60 * 60 * 1000),
      endsAt: new Date(Date.now() + 2 * 60 * 60 * 1000),
      status: "SCHEDULED",
      joinUrl: "https://meet.example.com/science-live",
      platform: "Google Meet",
    },
    create: {
      id: "seed-live-1",
      schoolId: school.id,
      classId: demoClass.id,
      subjectId: science.id,
      teacherId: teacherStaff.id,
      title: "Science Live Class",
      startsAt: new Date(Date.now() + 60 * 60 * 1000),
      endsAt: new Date(Date.now() + 2 * 60 * 60 * 1000),
      status: "SCHEDULED",
      joinUrl: "https://meet.example.com/science-live",
      platform: "Google Meet",
    },
  });

  // Seed records for admin approvals/testing actions
  const leaveAttendance = await prisma.staffAttendance.upsert({
    where: {
      schoolId_staffId_date: {
        schoolId: school.id,
        staffId: teacherStaff.id,
        date: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 1, 0, 0, 0)),
      },
    },
    update: { status: "LEAVE" },
    create: {
      schoolId: school.id,
      staffId: teacherStaff.id,
      date: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 1, 0, 0, 0)),
      status: "LEAVE",
      markedById: teacherUser?.id || null,
    },
  });

  await prisma.leaveRequest.upsert({
    where: { id: "seed-leave-req-1" },
    update: {
      schoolId: school.id,
      staffId: teacherStaff.id,
      attendanceId: leaveAttendance.id,
      date: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 1, 0, 0, 0)),
      reason: "Medical leave for one day",
      status: "PENDING",
      createdById: teacherUser?.id || null,
    },
    create: {
      id: "seed-leave-req-1",
      schoolId: school.id,
      staffId: teacherStaff.id,
      attendanceId: leaveAttendance.id,
      date: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 1, 0, 0, 0)),
      reason: "Medical leave for one day",
      status: "PENDING",
      createdById: teacherUser?.id || null,
    },
  });

  await prisma.studentLeaveRequest.upsert({
    where: { id: "seed-student-leave-1" },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      fromDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1, 0, 0, 0)),
      toDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 2, 0, 0, 0)),
      reason: "Family function leave request",
      status: "PENDING",
    },
    create: {
      id: "seed-student-leave-1",
      schoolId: school.id,
      studentId: demoStudent.id,
      fromDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1, 0, 0, 0)),
      toDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 2, 0, 0, 0)),
      reason: "Family function leave request",
      status: "PENDING",
    },
  });

  await prisma.faceCheckinLog.upsert({
    where: { id: "seed-face-pending-1" },
    update: {
      schoolId: school.id,
      personType: "VISITOR",
      personRefId: null,
      name: "Demo Visitor",
      location: "Main Gate",
      confidence: 91,
      status: "PENDING",
      reason: null,
    },
    create: {
      id: "seed-face-pending-1",
      schoolId: school.id,
      personType: "VISITOR",
      personRefId: null,
      name: "Demo Visitor",
      location: "Main Gate",
      confidence: 91,
      status: "PENDING",
      reason: null,
    },
  });

  // Seed records for staff module actions and parent library/documents
  await prisma.studentDocument.upsert({
    where: { id: "seed-student-doc-1" },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      name: "Transfer Certificate.pdf",
      url: "https://example.com/docs/transfer-certificate.pdf",
      type: "PDF",
      sizeKb: 420,
      uploadedById: teacherUser?.id || null,
    },
    create: {
      id: "seed-student-doc-1",
      schoolId: school.id,
      studentId: demoStudent.id,
      name: "Transfer Certificate.pdf",
      url: "https://example.com/docs/transfer-certificate.pdf",
      type: "PDF",
      sizeKb: 420,
      uploadedById: teacherUser?.id || null,
    },
  });

  const libraryBook = await prisma.libraryBook.upsert({
    where: { id: "seed-library-book-1" },
    update: {
      schoolId: school.id,
      title: "NCERT Science - Grade 10",
      author: "NCERT",
      category: "Science",
      totalCopies: 12,
      availableCopies: 8,
      isActive: true,
    },
    create: {
      id: "seed-library-book-1",
      schoolId: school.id,
      title: "NCERT Science - Grade 10",
      author: "NCERT",
      category: "Science",
      totalCopies: 12,
      availableCopies: 8,
      isActive: true,
    },
  });

  await prisma.libraryBorrow.upsert({
    where: { id: "seed-library-borrow-1" },
    update: {
      schoolId: school.id,
      bookId: libraryBook.id,
      borrowerType: "STUDENT",
      borrowerRefId: demoStudent.id,
      issuedAt: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 5, 0, 0, 0)),
      dueDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 5, 0, 0, 0)),
      status: "ISSUED",
    },
    create: {
      id: "seed-library-borrow-1",
      schoolId: school.id,
      bookId: libraryBook.id,
      borrowerType: "STUDENT",
      borrowerRefId: demoStudent.id,
      issuedAt: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 5, 0, 0, 0)),
      dueDate: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 5, 0, 0, 0)),
      status: "ISSUED",
    },
  });

  await prisma.meetingRequest.upsert({
    where: { id: "seed-meeting-1" },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      requestedById: teacherUser?.id || null,
      staffId: teacherStaff.id,
      preferredDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
      purpose: "PTM discussion",
      status: "PENDING",
    },
    create: {
      id: "seed-meeting-1",
      schoolId: school.id,
      studentId: demoStudent.id,
      requestedById: teacherUser?.id || null,
      staffId: teacherStaff.id,
      preferredDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
      purpose: "PTM discussion",
      status: "PENDING",
    },
  });

  await prisma.reportJob.upsert({
    where: { id: "seed-report-job-1" },
    update: {
      schoolId: school.id,
      type: "ATTENDANCE",
      status: "QUEUED",
      requestedBy: teacherUser?.id || null,
    },
    create: {
      id: "seed-report-job-1",
      schoolId: school.id,
      type: "ATTENDANCE",
      status: "QUEUED",
      requestedBy: teacherUser?.id || null,
    },
  });

  console.log("Seed complete.");
  console.log("Login users (password: Admin123!):");
  console.log("- super@school.edu (superadmin)");
  console.log("- admin@school.edu (schooladmin)");
  console.log("- acc@school.edu (accountant)");
  console.log("- hr@school.edu (hr)");
  console.log("\nTest student (password: Student123!):");
  console.log("- student@school.edu (STUDENT)");
  console.log("\nTest parent (password: Parent123!):");
  console.log("- parent@school.edu (PARENT) - linked to demo student STU001");
  console.log("\nTest teacher (password: Admin123!):");
  console.log("- teacher@school.edu (TEACHER)");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
