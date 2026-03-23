const router = require("express").Router();
const {
  dashboardOverview,
  listFeeStructures,
  createFeeStructure,
  updateFeeStructure,
  deleteFeeStructure,
  listInvoices,
  createInvoice,
  bulkGenerateInvoices,
  getInvoiceById,
  updateInvoiceStatus,
  listPayments,
  createPayment,
  getPaymentById,
  getPaymentReceipt,
  listStudentBalances,
  listReportJobs,
  generateReport,
} = require("./accountant.handlers");

router.get("/dashboard/overview", dashboardOverview);

router.get("/fees/structures", listFeeStructures);
router.post("/fees/structures", createFeeStructure);
router.put("/fees/structures/:id", updateFeeStructure);
router.delete("/fees/structures/:id", deleteFeeStructure);

router.get("/invoices", listInvoices);
router.post("/invoices", createInvoice);
router.post("/invoices/bulk-generate", bulkGenerateInvoices);
router.get("/invoices/:id", getInvoiceById);
router.patch("/invoices/:id/status", updateInvoiceStatus);

router.get("/payments", listPayments);
router.post("/payments", createPayment);
router.get("/payments/:id", getPaymentById);
router.get("/payments/:id/receipt", getPaymentReceipt);

router.get("/students/balances", listStudentBalances);

router.get("/reports/jobs", listReportJobs);
router.post("/reports/generate", generateReport);

module.exports = router;
