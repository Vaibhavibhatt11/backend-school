function createHttpError(statusCode, message, errorCode = "REQUEST_ERROR") {
  const error = new Error(message);
  error.statusCode = statusCode;
  error.errorCode = errorCode;
  return error;
}

function badRequest(message, code = "BAD_REQUEST") {
  return createHttpError(400, message, code);
}

function unauthorized(message = "Unauthorized") {
  return createHttpError(401, message, "UNAUTHORIZED");
}

function forbidden(message = "Forbidden") {
  return createHttpError(403, message, "FORBIDDEN");
}

function notFound(message = "Not found", code = "NOT_FOUND") {
  return createHttpError(404, message, code);
}

function conflict(message = "Conflict", code = "CONFLICT") {
  return createHttpError(409, message, code);
}

module.exports = {
  createHttpError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
};
