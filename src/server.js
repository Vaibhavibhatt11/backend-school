const app = require("./app");
const env = require("./config/env");
const prisma = require("./lib/prisma");
const { getRedis } = require("./config/redis");

const server = app.listen(env.PORT, () => {
  console.log(`[server] running on http://localhost:${env.PORT}`);
});

let isShuttingDown = false;

async function cleanup(signal) {
  if (isShuttingDown) return;
  isShuttingDown = true;

  console.log(`[server] ${signal} received. shutting down...`);

  server.close(async () => {
    try {
      await prisma.$disconnect();
      console.log("[server] prisma disconnected");
    } catch (error) {
      console.error("[server] prisma disconnect error:", error.message);
    }

    const redis = getRedis();
    if (redis) {
      try {
        await redis.quit();
        console.log("[server] redis disconnected");
      } catch (error) {
        console.error("[server] redis disconnect error:", error.message);
      }
    }

    process.exit(0);
  });

  setTimeout(() => {
    console.error("[server] forced shutdown");
    process.exit(1);
  }, 10_000).unref();
}

process.on("SIGINT", () => cleanup("SIGINT"));
process.on("SIGTERM", () => cleanup("SIGTERM"));

process.on("unhandledRejection", (reason) => {
  console.error("[server] unhandled rejection:", reason);
  cleanup("unhandledRejection");
});

process.on("uncaughtException", (error) => {
  console.error("[server] uncaught exception:", error);
  cleanup("uncaughtException");
});
