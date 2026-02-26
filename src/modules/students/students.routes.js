const router = require("express").Router();
const {
  listStudents,
  createStudent,
  getStudentById,
  updateStudent,
  deleteStudent,
  updateStudentStatus,
  addStudentDocument,
  deleteStudentDocument,
} = require("./students.handlers");

router.get("/", listStudents);
router.post("/", createStudent);
router.get("/:id", getStudentById);
router.put("/:id", updateStudent);
router.delete("/:id", deleteStudent);
router.patch("/:id/status", updateStudentStatus);
router.post("/:id/documents", addStudentDocument);
router.delete("/:id/documents/:docId", deleteStudentDocument);

module.exports = router;
