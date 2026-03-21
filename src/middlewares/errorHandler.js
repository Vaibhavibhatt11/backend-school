function errorHandler(error, req, res, next) {
  if (error?.name === "ZodError") {
    return res.status(400).json({
      success: false,
      error: {
        code: "VALIDATION_ERROR",
        message: error.issues?.[0]?.message || "Validation failed",
      },
    });
  }

  if (error?.statusCode) {
    return res.status(error.statusCode).json({
      success: false,
      error: {
        code: error.errorCode || "REQUEST_ERROR",
        message: error.message || "Request failed",
      },
    });
  }

  if (error?.code === "P2002") {
    return res.status(409).json({
      success: false,
      error: { code: "DUPLICATE_VALUE", message: "Unique value already exists" },
    });
  }

  console.error(error);
  return res.status(500).json({
    success: false,
    error: { code: "INTERNAL_SERVER_ERROR", message: "Something went wrong" },
  });
}

module.exports = errorHandler;
