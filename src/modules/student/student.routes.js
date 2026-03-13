const router = require("express").Router();
const {
  dashboard,
  getProfile,
  getTimetable,
  getAttendance,
  getHomework,
  submitHomework,
  getStudyMaterials,
  getExams,
  getFees,
  getAnnouncements,
  getEvents,
  registerForEvent,
  getTransport,
  getLibrary,
  getAchievements,
} = require("./student.handlers");

router.get("/dashboard", dashboard);
router.get("/profile", getProfile);
router.get("/timetable", getTimetable);
router.get("/attendance", getAttendance);
router.get("/homework", getHomework);
router.post("/homework/:id/submit", submitHomework);
router.get("/study-materials", getStudyMaterials);
router.get("/exams", getExams);
router.get("/fees", getFees);
router.get("/announcements", getAnnouncements);
router.get("/events", getEvents);
router.post("/events/:id/register", registerForEvent);
router.get("/transport", getTransport);
router.get("/library", getLibrary);
router.get("/achievements", getAchievements);

module.exports = router;
