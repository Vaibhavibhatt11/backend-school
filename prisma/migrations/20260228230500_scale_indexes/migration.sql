-- Scale indexes for high-volume querying
CREATE INDEX IF NOT EXISTS "Staff_schoolId_department_isActive_createdAt_idx"
  ON "Staff"("schoolId", "department", "isActive", "createdAt");

CREATE INDEX IF NOT EXISTS "Student_schoolId_status_createdAt_idx"
  ON "Student"("schoolId", "status", "createdAt");

CREATE INDEX IF NOT EXISTS "Student_schoolId_className_section_idx"
  ON "Student"("schoolId", "className", "section");

CREATE INDEX IF NOT EXISTS "StudentAttendance_schoolId_date_status_idx"
  ON "StudentAttendance"("schoolId", "date", "status");

CREATE INDEX IF NOT EXISTS "StaffAttendance_schoolId_date_status_idx"
  ON "StaffAttendance"("schoolId", "date", "status");

CREATE INDEX IF NOT EXISTS "Invoice_schoolId_studentId_createdAt_idx"
  ON "Invoice"("schoolId", "studentId", "createdAt");

CREATE INDEX IF NOT EXISTS "Payment_schoolId_studentId_paidAt_idx"
  ON "Payment"("schoolId", "studentId", "paidAt");

CREATE INDEX IF NOT EXISTS "AuditLog_schoolId_action_createdAt_idx"
  ON "AuditLog"("schoolId", "action", "createdAt");
