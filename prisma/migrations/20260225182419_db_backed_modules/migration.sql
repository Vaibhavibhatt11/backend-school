-- CreateEnum
CREATE TYPE "public"."LeaveRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "public"."SubscriptionPlan" (
    "planCode" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "priceMonthly" DOUBLE PRECISION NOT NULL,
    "priceYearly" DOUBLE PRECISION NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "features" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SubscriptionPlan_pkey" PRIMARY KEY ("planCode")
);

-- CreateTable
CREATE TABLE "public"."SchoolSubscription" (
    "schoolId" TEXT NOT NULL,
    "planCode" TEXT NOT NULL,
    "autoRenew" BOOLEAN NOT NULL DEFAULT false,
    "validUntil" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SchoolSubscription_pkey" PRIMARY KEY ("schoolId")
);

-- CreateTable
CREATE TABLE "public"."PlatformConfiguration" (
    "id" TEXT NOT NULL,
    "platformName" TEXT NOT NULL,
    "supportEmail" TEXT NOT NULL,
    "supportPhone" TEXT NOT NULL,
    "defaultTimezone" TEXT NOT NULL,
    "defaultCurrencyCode" TEXT NOT NULL,
    "maintenanceMode" BOOLEAN NOT NULL DEFAULT false,
    "features" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlatformConfiguration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."SchoolRole" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "permissions" TEXT[],
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdById" TEXT,
    "updatedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SchoolRole_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."HrSetting" (
    "schoolId" TEXT NOT NULL,
    "approvalLevels" INTEGER NOT NULL DEFAULT 1,
    "allowSelfAttendanceRegularization" BOOLEAN NOT NULL DEFAULT false,
    "probationMonths" INTEGER NOT NULL DEFAULT 6,
    "updatedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HrSetting_pkey" PRIMARY KEY ("schoolId")
);

-- CreateTable
CREATE TABLE "public"."HrRolePolicy" (
    "schoolId" TEXT NOT NULL,
    "roleId" TEXT NOT NULL,
    "name" TEXT,
    "permissions" TEXT[],
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "updatedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HrRolePolicy_pkey" PRIMARY KEY ("schoolId","roleId")
);

-- CreateTable
CREATE TABLE "public"."LeaveRequest" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "staffId" TEXT NOT NULL,
    "attendanceId" TEXT,
    "date" TIMESTAMP(3) NOT NULL,
    "reason" TEXT,
    "status" "public"."LeaveRequestStatus" NOT NULL DEFAULT 'PENDING',
    "note" TEXT,
    "createdById" TEXT,
    "reviewedById" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LeaveRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."LeaveRequestComment" (
    "id" TEXT NOT NULL,
    "leaveRequestId" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "actorId" TEXT,
    "comment" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LeaveRequestComment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."StudentDocument" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "sizeKb" INTEGER,
    "uploadedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentDocument_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SchoolSubscription_planCode_idx" ON "public"."SchoolSubscription"("planCode");

-- CreateIndex
CREATE INDEX "SchoolRole_schoolId_isActive_idx" ON "public"."SchoolRole"("schoolId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "SchoolRole_schoolId_name_key" ON "public"."SchoolRole"("schoolId", "name");

-- CreateIndex
CREATE INDEX "HrRolePolicy_schoolId_idx" ON "public"."HrRolePolicy"("schoolId");

-- CreateIndex
CREATE UNIQUE INDEX "LeaveRequest_attendanceId_key" ON "public"."LeaveRequest"("attendanceId");

-- CreateIndex
CREATE INDEX "LeaveRequest_schoolId_status_date_idx" ON "public"."LeaveRequest"("schoolId", "status", "date");

-- CreateIndex
CREATE UNIQUE INDEX "LeaveRequest_schoolId_staffId_date_key" ON "public"."LeaveRequest"("schoolId", "staffId", "date");

-- CreateIndex
CREATE INDEX "LeaveRequestComment_leaveRequestId_createdAt_idx" ON "public"."LeaveRequestComment"("leaveRequestId", "createdAt");

-- CreateIndex
CREATE INDEX "LeaveRequestComment_schoolId_idx" ON "public"."LeaveRequestComment"("schoolId");

-- CreateIndex
CREATE INDEX "StudentDocument_schoolId_studentId_idx" ON "public"."StudentDocument"("schoolId", "studentId");

-- AddForeignKey
ALTER TABLE "public"."SchoolSubscription" ADD CONSTRAINT "SchoolSubscription_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SchoolSubscription" ADD CONSTRAINT "SchoolSubscription_planCode_fkey" FOREIGN KEY ("planCode") REFERENCES "public"."SubscriptionPlan"("planCode") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SchoolRole" ADD CONSTRAINT "SchoolRole_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SchoolRole" ADD CONSTRAINT "SchoolRole_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SchoolRole" ADD CONSTRAINT "SchoolRole_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HrSetting" ADD CONSTRAINT "HrSetting_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HrSetting" ADD CONSTRAINT "HrSetting_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HrRolePolicy" ADD CONSTRAINT "HrRolePolicy_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HrRolePolicy" ADD CONSTRAINT "HrRolePolicy_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequest" ADD CONSTRAINT "LeaveRequest_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequest" ADD CONSTRAINT "LeaveRequest_staffId_fkey" FOREIGN KEY ("staffId") REFERENCES "public"."Staff"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequest" ADD CONSTRAINT "LeaveRequest_attendanceId_fkey" FOREIGN KEY ("attendanceId") REFERENCES "public"."StaffAttendance"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequest" ADD CONSTRAINT "LeaveRequest_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequest" ADD CONSTRAINT "LeaveRequest_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequestComment" ADD CONSTRAINT "LeaveRequestComment_leaveRequestId_fkey" FOREIGN KEY ("leaveRequestId") REFERENCES "public"."LeaveRequest"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequestComment" ADD CONSTRAINT "LeaveRequestComment_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LeaveRequestComment" ADD CONSTRAINT "LeaveRequestComment_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."StudentDocument" ADD CONSTRAINT "StudentDocument_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."StudentDocument" ADD CONSTRAINT "StudentDocument_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "public"."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."StudentDocument" ADD CONSTRAINT "StudentDocument_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
