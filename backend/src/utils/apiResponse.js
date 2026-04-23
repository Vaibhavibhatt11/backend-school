function defaultSuccessMessage(method = "GET") {
  const upper = String(method || "GET").toUpperCase();
  if (upper === "POST") return "Created successfully";
  if (upper === "PUT" || upper === "PATCH") return "Updated successfully";
  if (upper === "DELETE") return "Deleted successfully";
  return "Fetched successfully";
}

function normalizeApiPayload(payload, req) {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    return payload;
  }

  if (typeof payload.success !== "boolean") {
    return payload;
  }

  if (payload.success) {
    return {
      success: true,
      message:
        typeof payload.message === "string" && payload.message.trim()
          ? payload.message.trim()
          : defaultSuccessMessage(req?.method),
      data: payload.data === undefined ? null : payload.data,
    };
  }

  const fallbackErrorMessage =
    (typeof payload.error === "object" &&
      payload.error &&
      typeof payload.error.message === "string" &&
      payload.error.message) ||
    "Request failed";

  return {
    success: false,
    message:
      typeof payload.message === "string" && payload.message.trim()
        ? payload.message.trim()
        : fallbackErrorMessage,
    data: payload.data === undefined ? null : payload.data,
  };
}

function apiResponseEnvelope(req, res, next) {
  const originalJson = res.json.bind(res);
  res.json = (payload) => originalJson(normalizeApiPayload(payload, req));
  return next();
}

module.exports = {
  apiResponseEnvelope,
};
