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
