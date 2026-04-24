const router = require("express").Router();
const multer = require("multer");
const {
  dashboardOverview,
  listSchools,
  createSchool,
  getSchoolById,
  updateSchool,
  updateSchoolStatus,
  deleteSchool,
  listSubscriptions,
  updateSubscriptionPlan,
  updateSubscriptionAutoRenew,
  listPlans,
  updatePlan,
  getConfiguration,
  updateConfiguration,
  listSupportTickets,
  getSupportTicketById,
  createSupportTicketReply,
  updateSupportTicketStatus,
  analyticsOverview,
  listAccountants,
  createAccountant,
  getAccountantById,
  updateAccountant,
  updateAccountantStatus,
  deleteAccountant,
  listStaffMembers,
  createStaffMember,
  getStaffMemberById,
  updateStaffMember,
  updateStaffMemberStatus,
  deleteStaffMember,
  createInvitation,
  listInvitations,
  resendInvitation,
  cancelInvitation,
  getSecuritySettings,
  updateSecuritySettings,
  listSecuritySessions,
  revokeSecuritySession,
  revokeAllSecuritySessions,
  rotateSecurityKeys,
  listSecurityAuditLogs,
  listNotifications,
  markNotificationRead,
  deleteNotification,
  uploadFirebaseServiceAccount,
} = require("./superadmin.handlers");

const firebaseUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 2 * 1024 * 1024 },
});

router.get("/dashboard/overview", dashboardOverview);
router.get("/schools", listSchools);
router.post("/schools", createSchool);
router.get("/schools/:id", getSchoolById);
router.put("/schools/:id", updateSchool);
router.patch("/schools/:id/status", updateSchoolStatus);
router.delete("/schools/:id", deleteSchool);

router.get("/subscriptions", listSubscriptions);
router.patch("/subscriptions/:schoolId/plan", updateSubscriptionPlan);
router.patch("/subscriptions/:schoolId/auto-renew", updateSubscriptionAutoRenew);

router.get("/plans", listPlans);
router.put("/plans/:planCode", updatePlan);

router.get("/configuration", getConfiguration);
router.put("/configuration", updateConfiguration);

router.get("/support/tickets", listSupportTickets);
router.get("/support/tickets/:id", getSupportTicketById);
router.post("/support/tickets/:id/replies", createSupportTicketReply);
router.patch("/support/tickets/:id/status", updateSupportTicketStatus);

router.get("/analytics/overview", analyticsOverview);

router.get("/accountants", listAccountants);
router.post("/accountants", createAccountant);
router.get("/accountants/:id", getAccountantById);
router.put("/accountants/:id", updateAccountant);
router.patch("/accountants/:id/status", updateAccountantStatus);
router.delete("/accountants/:id", deleteAccountant);

router.get("/staff", listStaffMembers);
router.post("/staff", createStaffMember);
router.get("/staff/:id", getStaffMemberById);
router.put("/staff/:id", updateStaffMember);
router.patch("/staff/:id/status", updateStaffMemberStatus);
router.delete("/staff/:id", deleteStaffMember);

router.post("/invitations", createInvitation);
router.get("/invitations", listInvitations);
router.post("/invitations/:id/resend", resendInvitation);
router.delete("/invitations/:id", cancelInvitation);

router.get("/security/settings", getSecuritySettings);
router.put("/security/settings", updateSecuritySettings);
router.get("/security/sessions", listSecuritySessions);
router.delete("/security/sessions/:id", revokeSecuritySession);
router.post("/security/sessions/revoke-all", revokeAllSecuritySessions);
router.post("/security/keys/rotate", rotateSecurityKeys);
router.get("/security/audit-logs", listSecurityAuditLogs);

router.get("/notifications", listNotifications);
router.patch("/notifications/:id/read", markNotificationRead);
router.delete("/notifications/:id", deleteNotification);

router.post("/firebase/upload", firebaseUpload.single("file"), uploadFirebaseServiceAccount);

module.exports = router;
