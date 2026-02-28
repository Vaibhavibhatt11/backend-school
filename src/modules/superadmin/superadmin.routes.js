const router = require("express").Router();
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
} = require("./superadmin.handlers");

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

module.exports = router;
