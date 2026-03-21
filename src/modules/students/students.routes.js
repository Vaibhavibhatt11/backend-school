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
  importStudents,
  exportStudents,
  moveStudentClass,
} = require("./students.handlers");

router.get("/", listStudents);
router.get("/export", exportStudents);
router.post("/", createStudent);
router.post("/import", importStudents);
router.get("/:id", getStudentById);
router.put("/:id", updateStudent);
router.delete("/:id", deleteStudent);
router.patch("/:id/status", updateStudentStatus);
router.post("/:id/move-class", moveStudentClass);
router.post("/:id/documents", addStudentDocument);
router.delete("/:id/documents/:docId", deleteStudentDocument);

module.exports = router;
