-- Student API and scale: indexes for high concurrency and quick response
-- Only indexes for tables that exist in this DB. Homework index skipped (table may not exist yet).
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND indexname = 'StudentAttendance_studentId_date_idx') THEN
    CREATE INDEX "StudentAttendance_studentId_date_idx" ON "public"."StudentAttendance"("studentId", "date");
  END IF;
END $$;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND indexname = 'ExamResult_studentId_createdAt_idx') THEN
    CREATE INDEX "ExamResult_studentId_createdAt_idx" ON "public"."ExamResult"("studentId", "createdAt");
  END IF;
END $$;
