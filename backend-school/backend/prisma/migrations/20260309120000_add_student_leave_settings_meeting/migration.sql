-- Student module: medicalInfo, userId link, leave requests, settings, meeting requests
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'Role' AND e.enumlabel = 'STUDENT') THEN
    ALTER TYPE "public"."Role" ADD VALUE 'STUDENT';
  END IF;
END $$;

ALTER TABLE "public"."Student" ADD COLUMN IF NOT EXISTS "medicalInfo" JSONB;
ALTER TABLE "public"."Student" ADD COLUMN IF NOT EXISTS "userId" TEXT;

CREATE TABLE IF NOT EXISTS "public"."StudentLeaveRequest" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "fromDate" TIMESTAMP(3) NOT NULL,
    "toDate" TIMESTAMP(3) NOT NULL,
    "reason" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "remark" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentLeaveRequest_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "public"."StudentSettings" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "preferences" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentSettings_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "public"."MeetingRequest" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "requestedById" TEXT,
    "staffId" TEXT,
    "preferredDate" TIMESTAMP(3),
    "purpose" TEXT,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "remark" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MeetingRequest_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "StudentSettings_studentId_key" ON "public"."StudentSettings"("studentId");
CREATE INDEX IF NOT EXISTS "StudentLeaveRequest_schoolId_studentId_idx" ON "public"."StudentLeaveRequest"("schoolId", "studentId");
CREATE INDEX IF NOT EXISTS "MeetingRequest_schoolId_studentId_idx" ON "public"."MeetingRequest"("schoolId", "studentId");
CREATE UNIQUE INDEX IF NOT EXISTS "Student_userId_key" ON "public"."Student"("userId");

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'StudentLeaveRequest_schoolId_fkey') THEN
    ALTER TABLE "public"."StudentLeaveRequest" ADD CONSTRAINT "StudentLeaveRequest_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'StudentLeaveRequest_studentId_fkey') THEN
    ALTER TABLE "public"."StudentLeaveRequest" ADD CONSTRAINT "StudentLeaveRequest_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "public"."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'StudentSettings_schoolId_fkey') THEN
    ALTER TABLE "public"."StudentSettings" ADD CONSTRAINT "StudentSettings_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'StudentSettings_studentId_fkey') THEN
    ALTER TABLE "public"."StudentSettings" ADD CONSTRAINT "StudentSettings_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "public"."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'MeetingRequest_schoolId_fkey') THEN
    ALTER TABLE "public"."MeetingRequest" ADD CONSTRAINT "MeetingRequest_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "public"."School"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'MeetingRequest_studentId_fkey') THEN
    ALTER TABLE "public"."MeetingRequest" ADD CONSTRAINT "MeetingRequest_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "public"."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Student_userId_fkey') THEN
    ALTER TABLE "public"."Student" ADD CONSTRAINT "Student_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;
