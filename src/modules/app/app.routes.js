const router = require("express").Router();
const { requireAuth } = require("../student/student.security");
const {
  listChildren,
  dashboard,
  attendance,
  fees,
  announcements,
} = require("./app.handlers");

router.use(requireAuth);

router.get("/children", listChildren);
router.get("/dashboard", dashboard);
router.get("/attendance", attendance);
router.get("/fees", fees);
router.get("/announcements", announcements);

module.exports = router;

