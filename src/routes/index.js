const router = require("express").Router();

const auth = require("../middlewares/auth");
const requireRole = require("../middlewares/requireRole");

const authRoutes = require("../modules/auth/auth.routes");
const dashboardRoutes = require("../modules/dashboard/dashboard.routes");
const superadminRoutes = require("../modules/superadmin/superadmin.routes");
const schoolRoutes = require("../modules/school/school.routes");
const studentsRoutes = require("../modules/students/students.routes");
const hrRoutes = require("../modules/hr/hr.routes");
const accountantRoutes = require("../modules/accountant/accountant.routes");

router.get("/health", (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      service: "school-erp-backend",
      status: "ok",
      timestamp: new Date().toISOString(),
    },
  });
});

router.use("/auth", authRoutes);
router.use("/dashboard", auth, dashboardRoutes);

router.use("/superadmin", auth, requireRole(["SUPERADMIN"]), superadminRoutes);

router.use(
  "/school/students",
  auth,
  requireRole(["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"]),
  studentsRoutes
);

router.use(
  "/school",
  auth,
  requireRole(["SUPERADMIN", "SCHOOLADMIN", "HR", "ACCOUNTANT"]),
  schoolRoutes
);

router.use("/hr", auth, requireRole(["SUPERADMIN", "SCHOOLADMIN", "HR"]), hrRoutes);

router.use(
  "/accountant",
  auth,
  requireRole(["SUPERADMIN", "SCHOOLADMIN", "ACCOUNTANT"]),
  accountantRoutes
);

module.exports = router;
