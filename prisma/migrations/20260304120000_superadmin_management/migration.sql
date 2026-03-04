-- CreateEnum
CREATE TYPE "public"."InvitationStatus" AS ENUM ('PENDING', 'ACCEPTED', 'CANCELLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "public"."SubscriptionPaymentStatus" AS ENUM ('PAID', 'DUE', 'FAILED', 'REFUNDED', 'PENDING');

-- CreateEnum
CREATE TYPE "public"."SubscriptionStatus" AS ENUM ('ACTIVE', 'EXPIRED', 'SUSPENDED', 'CANCELLED');

-- AlterTable
ALTER TABLE "public"."RefreshToken"
  ADD COLUMN "lastUsedAt" TIMESTAMP(3),
  ADD COLUMN "ipAddress" TEXT,
  ADD COLUMN "userAgent" TEXT;

-- AlterTable
ALTER TABLE "public"."SubscriptionPlan"
  ADD COLUMN "maxStudents" INTEGER,
  ADD COLUMN "storageGb" INTEGER;

-- AlterTable
ALTER TABLE "public"."SchoolSubscription"
  ADD COLUMN "paymentStatus" "public"."SubscriptionPaymentStatus" NOT NULL DEFAULT 'PAID',
  ADD COLUMN "status" "public"."SubscriptionStatus" NOT NULL DEFAULT 'ACTIVE';

-- AlterTable
ALTER TABLE "public"."PlatformConfiguration"
  ADD COLUMN "newSignups" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "trialDays" INTEGER NOT NULL DEFAULT 14,
  ADD COLUMN "taxRate" DOUBLE PRECISION NOT NULL DEFAULT 0,
  ADD COLUMN "smsUrl" TEXT,
  ADD COLUMN "smsApiKey" TEXT,
  ADD COLUMN "senderId" TEXT,
  ADD COLUMN "whatsAppAccountId" TEXT,
  ADD COLUMN "whatsAppToken" TEXT;

-- CreateTable
CREATE TABLE "public"."SecuritySetting" (
  "id" TEXT NOT NULL,
  "enforce2FA" BOOLEAN NOT NULL DEFAULT false,
  "passwordMinLength" INTEGER NOT NULL DEFAULT 8,
  "passwordUppercase" BOOLEAN NOT NULL DEFAULT true,
  "passwordSpecial" BOOLEAN NOT NULL DEFAULT true,
  "passwordExpiryDays" INTEGER NOT NULL DEFAULT 90,
  "jwtExpiryMinutes" INTEGER NOT NULL DEFAULT 15,
  "refreshExpiryDays" INTEGER NOT NULL DEFAULT 7,
  "apiKeyVersion" INTEGER NOT NULL DEFAULT 1,
  "lastKeyRotationAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "SecuritySetting_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Invitation" (
  "id" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "role" "public"."Role" NOT NULL,
  "schoolId" TEXT,
  "status" "public"."InvitationStatus" NOT NULL DEFAULT 'PENDING',
  "tokenHash" TEXT,
  "message" TEXT,
  "invitedById" TEXT,
  "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expiresAt" TIMESTAMP(3),
  "acceptedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "Invitation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."SuperadminNotification" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "message" TEXT NOT NULL,
  "type" TEXT NOT NULL DEFAULT 'INFO',
  "readAt" TIMESTAMP(3),
  "meta" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "SuperadminNotification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."FirebaseCredential" (
  "id" TEXT NOT NULL,
  "projectId" TEXT,
  "clientEmail" TEXT,
  "privateKey" TEXT,
  "serviceJson" JSONB,
  "uploadedById" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "FirebaseCredential_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Invitation_email_status_idx" ON "public"."Invitation"("email", "status");

-- CreateIndex
CREATE INDEX "Invitation_schoolId_status_idx" ON "public"."Invitation"("schoolId", "status");

-- CreateIndex
CREATE INDEX "SuperadminNotification_userId_createdAt_idx" ON "public"."SuperadminNotification"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "SuperadminNotification_userId_readAt_idx" ON "public"."SuperadminNotification"("userId", "readAt");

-- AddForeignKey
ALTER TABLE "public"."Invitation"
  ADD CONSTRAINT "Invitation_schoolId_fkey"
  FOREIGN KEY ("schoolId")
  REFERENCES "public"."School"("id")
  ON DELETE SET NULL
  ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Invitation"
  ADD CONSTRAINT "Invitation_invitedById_fkey"
  FOREIGN KEY ("invitedById")
  REFERENCES "public"."User"("id")
  ON DELETE SET NULL
  ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."SuperadminNotification"
  ADD CONSTRAINT "SuperadminNotification_userId_fkey"
  FOREIGN KEY ("userId")
  REFERENCES "public"."User"("id")
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."FirebaseCredential"
  ADD CONSTRAINT "FirebaseCredential_uploadedById_fkey"
  FOREIGN KEY ("uploadedById")
  REFERENCES "public"."User"("id")
  ON DELETE SET NULL
  ON UPDATE CASCADE;
