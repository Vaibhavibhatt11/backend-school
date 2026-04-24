const prisma = require("../lib/prisma");

async function ensureDatabaseReady(req, res, next) {
  if (req.method === "OPTIONS") {
    return next();
  }

  if (req.path === "/health" || req.path === "/ready") {
    return next();
  }

  try {
    await prisma.ensureReady();
    return next();
  } catch (error) {
    return next(error);
  }
}

module.exports = ensureDatabaseReady;
