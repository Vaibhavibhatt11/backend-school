-- Admissions tables (required by GET /dashboard/school-admin and GET /school/approvals/pending-summary)
-- Safe to run on DBs that already have these objects (IF NOT EXISTS / duplicate_object guards).

DO $$
BEGIN
  CREATE TYPE "AdmissionStatus" AS ENUM (
    'DRAFT',
    'SUBMITTED',
    'UNDER_REVIEW',
    'APPROVED',
    'REJECTED',
    'ONBOARDED'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS "AdmissionApplication" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "applicationNo" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "dob" TIMESTAMP(3),
    "gender" TEXT,
    "appliedClass" TEXT NOT NULL,
    "appliedSection" TEXT,
    "status" "AdmissionStatus" NOT NULL DEFAULT 'SUBMITTED',
    "admissionFeePaid" BOOLEAN NOT NULL DEFAULT false,
    "registrationNo" TEXT,
    "studentId" TEXT,
    "meta" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdmissionApplication_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "AdmissionDocument" (
    "id" TEXT NOT NULL,
    "applicationId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdmissionDocument_pkey" PRIMARY KEY ("id")
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'AdmissionApplication_schoolId_fkey'
  ) THEN
    ALTER TABLE "AdmissionApplication"
      ADD CONSTRAINT "AdmissionApplication_schoolId_fkey"
      FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'AdmissionDocument_applicationId_fkey'
  ) THEN
    ALTER TABLE "AdmissionDocument"
      ADD CONSTRAINT "AdmissionDocument_applicationId_fkey"
      FOREIGN KEY ("applicationId") REFERENCES "AdmissionApplication"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "AdmissionApplication_schoolId_applicationNo_key"
  ON "AdmissionApplication"("schoolId", "applicationNo");

CREATE INDEX IF NOT EXISTS "AdmissionApplication_schoolId_status_idx"
  ON "AdmissionApplication"("schoolId", "status");

CREATE INDEX IF NOT EXISTS "AdmissionDocument_applicationId_idx"
  ON "AdmissionDocument"("applicationId");
