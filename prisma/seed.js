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

function addDays(base, days) {
  const d = new Date(base);
  d.setDate(d.getDate() + days);
  return d;
}

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
  ];

  for (const user of users) {
    await prisma.user.upsert({
      where: { email: user.email },
      update: {
        fullName: user.fullName,
        role: user.role,
        schoolId: user.schoolId,
        isActive: true,
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

  // ---------------------------------------------------------------------------
  // Demo enrichment for Parent/Admin module showcase (non-breaking additions)
  // ---------------------------------------------------------------------------
  const adminUser = await prisma.user.findUnique({ where: { email: "admin@school.edu" } });
  const teacherPasswordHash = await bcrypt.hash("Teacher123!", 10);
  const teacherUser = await prisma.user.upsert({
    where: { email: "teacher@school.edu" },
    update: {
      fullName: "Class Teacher",
      role: "TEACHER",
      schoolId: school.id,
      isActive: true,
      passwordHash: teacherPasswordHash,
    },
    create: {
      fullName: "Class Teacher",
      email: "teacher@school.edu",
      role: "TEACHER",
      schoolId: school.id,
      isActive: true,
      passwordHash: teacherPasswordHash,
    },
  });

  const teacherStaff = await prisma.staff.upsert({
    where: { schoolId_employeeCode: { schoolId: school.id, employeeCode: "EMP-TEA-001" } },
    update: {
      userId: teacherUser.id,
      fullName: "Class Teacher",
      email: "teacher@school.edu",
      designation: "Teacher",
      department: "Academics",
      isActive: true,
    },
    create: {
      schoolId: school.id,
      userId: teacherUser.id,
      employeeCode: "EMP-TEA-001",
      fullName: "Class Teacher",
      email: "teacher@school.edu",
      designation: "Teacher",
      department: "Academics",
      isActive: true,
      joinDate: addDays(new Date(), -240),
    },
  });

  await prisma.classRoom.update({
    where: { id: demoClass.id },
    data: { classTeacherId: teacherStaff.id },
  });

  const subjectSpecs = [
    { code: "ENG", name: "English" },
    { code: "MATH", name: "Mathematics" },
    { code: "SCI", name: "Science" },
    { code: "HIST", name: "History" },
  ];
  const subjects = [];
  for (const spec of subjectSpecs) {
    const subject = await prisma.subject.upsert({
      where: { schoolId_code: { schoolId: school.id, code: spec.code } },
      update: { name: spec.name, isActive: true },
      create: {
        schoolId: school.id,
        code: spec.code,
        name: spec.name,
        isActive: true,
      },
    });
    subjects.push(subject);
    await prisma.classSubject.upsert({
      where: { classId_subjectId: { classId: demoClass.id, subjectId: subject.id } },
      update: { teacherId: teacherStaff.id },
      create: { classId: demoClass.id, subjectId: subject.id, teacherId: teacherStaff.id },
    });
  }

  const feeStructure = await prisma.feeStructure.upsert({
    where: { schoolId_name: { schoolId: school.id, name: "Term Fee" } },
    update: { amount: 1200, currency: "USD", frequency: "TERM", isActive: true },
    create: {
      schoolId: school.id,
      name: "Term Fee",
      amount: 1200,
      currency: "USD",
      frequency: "TERM",
      isActive: true,
    },
  });

  const now = new Date();
  const invoiceRows = [
    {
      invoiceNo: "INV-DEMO-001",
      issueDate: addDays(now, -35),
      dueDate: addDays(now, -7),
      amountDue: 1200,
      amountPaid: 300,
      status: "PARTIAL",
    },
    {
      invoiceNo: "INV-DEMO-002",
      issueDate: addDays(now, -12),
      dueDate: addDays(now, 10),
      amountDue: 950,
      amountPaid: 0,
      status: "ISSUED",
    },
  ];

  const invoices = [];
  for (const inv of invoiceRows) {
    const invoice = await prisma.invoice.upsert({
      where: { schoolId_invoiceNo: { schoolId: school.id, invoiceNo: inv.invoiceNo } },
      update: {
        studentId: demoStudent.id,
        feeStructureId: feeStructure.id,
        issueDate: inv.issueDate,
        dueDate: inv.dueDate,
        amountDue: inv.amountDue,
        amountPaid: inv.amountPaid,
        status: inv.status,
      },
      create: {
        schoolId: school.id,
        studentId: demoStudent.id,
        feeStructureId: feeStructure.id,
        invoiceNo: inv.invoiceNo,
        issueDate: inv.issueDate,
        dueDate: inv.dueDate,
        amountDue: inv.amountDue,
        amountPaid: inv.amountPaid,
        status: inv.status,
      },
    });
    invoices.push(invoice);
  }

  await prisma.payment.upsert({
    where: { schoolId_receiptNo: { schoolId: school.id, receiptNo: "RCPT-DEMO-001" } },
    update: {
      studentId: demoStudent.id,
      invoiceId: invoices[0].id,
      amount: 300,
      method: "ONLINE",
      paidAt: addDays(now, -20),
      collectedById: adminUser?.id || null,
      transactionRef: "TXN-DEMO-001",
    },
    create: {
      schoolId: school.id,
      studentId: demoStudent.id,
      invoiceId: invoices[0].id,
      receiptNo: "RCPT-DEMO-001",
      amount: 300,
      method: "ONLINE",
      paidAt: addDays(now, -20),
      collectedById: adminUser?.id || null,
      transactionRef: "TXN-DEMO-001",
    },
  });

  const attendanceRows = [
    { days: -9, status: "PRESENT" },
    { days: -8, status: "PRESENT" },
    { days: -7, status: "LATE" },
    { days: -6, status: "PRESENT" },
    { days: -5, status: "ABSENT" },
    { days: -4, status: "PRESENT" },
    { days: -3, status: "PRESENT" },
    { days: -2, status: "PRESENT" },
    { days: -1, status: "LATE" },
  ];
  for (const row of attendanceRows) {
    const date = addDays(now, row.days);
    date.setHours(9, 0, 0, 0);
    await prisma.studentAttendance.upsert({
      where: {
        schoolId_studentId_date: {
          schoolId: school.id,
          studentId: demoStudent.id,
          date,
        },
      },
      update: { status: row.status, markedById: adminUser?.id || null },
      create: {
        schoolId: school.id,
        studentId: demoStudent.id,
        date,
        status: row.status,
        markedById: adminUser?.id || null,
      },
    });
  }

  const announcements = [
    {
      title: "Annual Sports Day Registration Open",
      content: "Register before Friday to confirm participation.",
      audience: "PARENT,STUDENT",
    },
    {
      title: "Mid-Term Assessment Schedule Published",
      content: "Please review the date sheet and prepare accordingly.",
      audience: "PARENT,STUDENT",
    },
    {
      title: "Fee Reminder",
      content: "Pending invoices are due soon. Kindly clear dues on time.",
      audience: "PARENT,FEE",
    },
  ];
  for (let i = 0; i < announcements.length; i += 1) {
    const item = announcements[i];
    const existing = await prisma.announcement.findFirst({
      where: { schoolId: school.id, title: item.title },
    });
    if (existing) {
      await prisma.announcement.update({
        where: { id: existing.id },
        data: {
          content: item.content,
          audience: item.audience,
          status: "SENT",
          sentAt: addDays(now, -(i + 1)),
          createdById: adminUser?.id || null,
        },
      });
    } else {
      await prisma.announcement.create({
        data: {
          schoolId: school.id,
          title: item.title,
          content: item.content,
          audience: item.audience,
          status: "SENT",
          sentAt: addDays(now, -(i + 1)),
          createdById: adminUser?.id || null,
        },
      });
    }
  }

  for (const [idx, subject] of subjects.entries()) {
    const exam = await prisma.exam.upsert({
      where: { id: `DEMO-EXAM-${subject.code}` },
      update: {
        schoolId: school.id,
        classId: demoClass.id,
        subjectId: subject.id,
        name: `${subject.name} Unit Test`,
        examDate: addDays(now, -(25 - idx * 3)),
        maxMarks: 100,
        status: "PUBLISHED",
        isPublished: true,
      },
      create: {
        id: `DEMO-EXAM-${subject.code}`,
        schoolId: school.id,
        classId: demoClass.id,
        subjectId: subject.id,
        name: `${subject.name} Unit Test`,
        examDate: addDays(now, -(25 - idx * 3)),
        maxMarks: 100,
        status: "PUBLISHED",
        isPublished: true,
      },
    });

    await prisma.examResult.upsert({
      where: { examId_studentId: { examId: exam.id, studentId: demoStudent.id } },
      update: { marks: 72 + idx * 5, grade: idx > 1 ? "A" : "B+", remarks: "Good progress" },
      create: {
        examId: exam.id,
        studentId: demoStudent.id,
        marks: 72 + idx * 5,
        grade: idx > 1 ? "A" : "B+",
        remarks: "Good progress",
      },
    });
  }

  const liveStart1 = addDays(now, 1);
  liveStart1.setHours(10, 0, 0, 0);
  const liveEnd1 = addDays(now, 1);
  liveEnd1.setHours(11, 0, 0, 0);
  const liveStart2 = addDays(now, 2);
  liveStart2.setHours(9, 30, 0, 0);
  const liveEnd2 = addDays(now, 2);
  liveEnd2.setHours(10, 30, 0, 0);

  await prisma.liveClassSession.upsert({
    where: { id: "DEMO-LIVE-1" },
    update: {
      schoolId: school.id,
      classId: demoClass.id,
      subjectId: subjects[1]?.id || null,
      teacherId: teacherStaff.id,
      title: "Mathematics Live Revision",
      platform: "Google Meet",
      joinUrl: "https://meet.google.com/demo-math",
      startsAt: liveStart1,
      endsAt: liveEnd1,
      status: "UPCOMING",
    },
    create: {
      id: "DEMO-LIVE-1",
      schoolId: school.id,
      classId: demoClass.id,
      subjectId: subjects[1]?.id || null,
      teacherId: teacherStaff.id,
      title: "Mathematics Live Revision",
      platform: "Google Meet",
      joinUrl: "https://meet.google.com/demo-math",
      startsAt: liveStart1,
      endsAt: liveEnd1,
      status: "UPCOMING",
    },
  });
  await prisma.liveClassSession.upsert({
    where: { id: "DEMO-LIVE-2" },
    update: {
      schoolId: school.id,
      classId: demoClass.id,
      subjectId: subjects[2]?.id || null,
      teacherId: teacherStaff.id,
      title: "Science Doubt Session",
      platform: "Zoom",
      joinUrl: "https://zoom.us/j/demo-science",
      startsAt: liveStart2,
      endsAt: liveEnd2,
      status: "UPCOMING",
    },
    create: {
      id: "DEMO-LIVE-2",
      schoolId: school.id,
      classId: demoClass.id,
      subjectId: subjects[2]?.id || null,
      teacherId: teacherStaff.id,
      title: "Science Doubt Session",
      platform: "Zoom",
      joinUrl: "https://zoom.us/j/demo-science",
      startsAt: liveStart2,
      endsAt: liveEnd2,
      status: "UPCOMING",
    },
  });

  await prisma.studentDocument.upsert({
    where: { id: "DEMO-DOC-1" },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      name: "Birth Certificate",
      url: "https://example.com/docs/birth-certificate.pdf",
      type: "PDF",
      sizeKb: 240,
      uploadedById: adminUser?.id || null,
    },
    create: {
      id: "DEMO-DOC-1",
      schoolId: school.id,
      studentId: demoStudent.id,
      name: "Birth Certificate",
      url: "https://example.com/docs/birth-certificate.pdf",
      type: "PDF",
      sizeKb: 240,
      uploadedById: adminUser?.id || null,
    },
  });
  await prisma.studentDocument.upsert({
    where: { id: "DEMO-DOC-2" },
    update: {
      schoolId: school.id,
      studentId: demoStudent.id,
      name: "ID Card",
      url: "https://example.com/docs/student-id.pdf",
      type: "PDF",
      sizeKb: 110,
      uploadedById: adminUser?.id || null,
    },
    create: {
      id: "DEMO-DOC-2",
      schoolId: school.id,
      studentId: demoStudent.id,
      name: "ID Card",
      url: "https://example.com/docs/student-id.pdf",
      type: "PDF",
      sizeKb: 110,
      uploadedById: adminUser?.id || null,
    },
  });

  const libraryBook = await prisma.libraryBook.upsert({
    where: { id: "DEMO-BOOK-1" },
    update: {
      schoolId: school.id,
      title: "Mathematics Practice Workbook",
      author: "A. Sharma",
      category: "Academics",
      totalCopies: 10,
      availableCopies: 7,
      isActive: true,
    },
    create: {
      id: "DEMO-BOOK-1",
      schoolId: school.id,
      isbn: "9780000000001",
      title: "Mathematics Practice Workbook",
      author: "A. Sharma",
      category: "Academics",
      totalCopies: 10,
      availableCopies: 7,
      isActive: true,
    },
  });

  await prisma.libraryBorrow.upsert({
    where: { id: "DEMO-BORROW-1" },
    update: {
      schoolId: school.id,
      bookId: libraryBook.id,
      borrowerType: "STUDENT",
      borrowerRefId: demoStudent.id,
      issuedAt: addDays(now, -6),
      dueDate: addDays(now, 8),
      status: "BORROWED",
    },
    create: {
      id: "DEMO-BORROW-1",
      schoolId: school.id,
      bookId: libraryBook.id,
      borrowerType: "STUDENT",
      borrowerRefId: demoStudent.id,
      issuedAt: addDays(now, -6),
      dueDate: addDays(now, 8),
      status: "BORROWED",
    },
  });

  await prisma.studentSettings.upsert({
    where: { studentId: demoStudent.id },
    update: {
      preferences: {
        pushNotificationsEnabled: true,
        faceIdEnabled: false,
        language: "en",
        darkModeOption: "system",
      },
    },
    create: {
      schoolId: school.id,
      studentId: demoStudent.id,
      preferences: {
        pushNotificationsEnabled: true,
        faceIdEnabled: false,
        language: "en",
        darkModeOption: "system",
      },
    },
  });

  await prisma.reportJob.upsert({
    where: { id: "DEMO-REPORT-1" },
    update: {
      schoolId: school.id,
      type: "FEE_COLLECTION",
      status: "COMPLETED",
      fileUrl: "https://example.com/reports/fee-collection.pdf",
      requestedBy: adminUser?.id || null,
    },
    create: {
      id: "DEMO-REPORT-1",
      schoolId: school.id,
      type: "FEE_COLLECTION",
      status: "COMPLETED",
      fileUrl: "https://example.com/reports/fee-collection.pdf",
      requestedBy: adminUser?.id || null,
    },
  });
  await prisma.reportJob.upsert({
    where: { id: "DEMO-REPORT-2" },
    update: {
      schoolId: school.id,
      type: "ATTENDANCE",
      status: "COMPLETED",
      fileUrl: "https://example.com/reports/attendance.pdf",
      requestedBy: adminUser?.id || null,
    },
    create: {
      id: "DEMO-REPORT-2",
      schoolId: school.id,
      type: "ATTENDANCE",
      status: "COMPLETED",
      fileUrl: "https://example.com/reports/attendance.pdf",
      requestedBy: adminUser?.id || null,
    },
  });

  await prisma.auditLog.upsert({
    where: { id: "DEMO-AUDIT-1" },
    update: {
      schoolId: school.id,
      actorId: adminUser?.id || null,
      action: "INVOICE_CREATED",
      entity: "Invoice",
      entityId: invoices[0].id,
      meta: { source: "seed" },
    },
    create: {
      id: "DEMO-AUDIT-1",
      schoolId: school.id,
      actorId: adminUser?.id || null,
      action: "INVOICE_CREATED",
      entity: "Invoice",
      entityId: invoices[0].id,
      meta: { source: "seed" },
    },
  });
  await prisma.auditLog.upsert({
    where: { id: "DEMO-AUDIT-2" },
    update: {
      schoolId: school.id,
      actorId: adminUser?.id || null,
      action: "ANNOUNCEMENT_SENT",
      entity: "Announcement",
      entityId: null,
      meta: { source: "seed" },
    },
    create: {
      id: "DEMO-AUDIT-2",
      schoolId: school.id,
      actorId: adminUser?.id || null,
      action: "ANNOUNCEMENT_SENT",
      entity: "Announcement",
      entityId: null,
      meta: { source: "seed" },
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
  console.log("- parent@school.edu (PARENT) — linked to demo student STU001");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
