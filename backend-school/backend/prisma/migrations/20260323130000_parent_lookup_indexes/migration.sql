-- Parent app at scale: faster resolveParent (schoolId + email) and listChildren (parentId)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND indexname = 'Parent_schoolId_email_idx') THEN
    CREATE INDEX "Parent_schoolId_email_idx" ON "public"."Parent"("schoolId", "email");
  END IF;
END $$;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND indexname = 'StudentParent_parentId_idx') THEN
    CREATE INDEX "StudentParent_parentId_idx" ON "public"."StudentParent"("parentId");
  END IF;
END $$;
