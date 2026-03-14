const { PrismaClient } = require("@prisma/client");

// Singleton for connection pooling: one client per process (critical for 1M+ concurrent users).
// Set DATABASE_URL with ?connection_limit=N (e.g. 20–50 per instance) in production.
const prisma = global.__prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
});
if (process.env.NODE_ENV !== "production") global.__prisma = prisma;

module.exports = prisma;

