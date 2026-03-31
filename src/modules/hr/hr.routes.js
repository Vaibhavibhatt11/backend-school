const router = require("express").Router();
const {
  dashboardOverview,
  listStaff,
  getStaffById,
  listLeaveRequests,
  getLeaveRequestById,
  updateLeaveRequestStatus,
  addLeaveRequestComment,
  attendancePerformance,
  attendancePerformanceByStaff,
  getSettings,
  updateSettings,
  listRoles,
  updateRole,
} = require("./hr.handlers");

router.get("/dashboard/overview", dashboardOverview);
router.get("/staff", listStaff);
router.get("/staff/:id", getStaffById);
router.get("/leave-requests", listLeaveRequests);
router.get("/leave-requests/:id", getLeaveRequestById);
router.patch("/leave-requests/:id/status", updateLeaveRequestStatus);
router.post("/leave-requests/:id/comment", addLeaveRequestComment);
router.get("/attendance/performance", attendancePerformance);
router.get("/attendance/performance/:staffId", attendancePerformanceByStaff);
router.get("/settings", getSettings);
router.put("/settings", updateSettings);
router.get("/roles", listRoles);
router.put("/roles/:id", updateRole);

module.exports = router;
