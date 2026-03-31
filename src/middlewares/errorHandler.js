function errorHandler(error, req, res, next) {
  // express/body-parser: malformed JSON body (Postman raw typo, wrong Content-Type, etc.)
  if (error?.type === "entity.parse.failed") {
    return res.status(400).json({
      success: false,
      error: {
        code: "INVALID_JSON_BODY",
        message:
          "Request body is not valid JSON. In Postman: Body → raw → JSON. Use double quotes, commas between fields, no trailing comma after the last property.",
        detail: error.message,
      },
    });
  }

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
