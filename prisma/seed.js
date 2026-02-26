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

  for (const plan of defaultPlans) {
    await prisma.subscriptionPlan.upsert({
      where: { planCode: plan.planCode },
      update: {
        name: plan.name,
        priceMonthly: plan.priceMonthly,
        priceYearly: plan.priceYearly,
        isActive: plan.isActive,
        features: plan.features,
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
      features: {
        aiFaq: true,
        faceCheckin: true,
        liveClasses: true,
        accounting: true,
        hr: true,
      },
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

  console.log("Seed complete.");
  console.log("Login users (password: Admin123!):");
  console.log("- super@school.edu (superadmin)");
  console.log("- admin@school.edu (schooladmin)");
  console.log("- acc@school.edu (accountant)");
  console.log("- hr@school.edu (hr)");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
