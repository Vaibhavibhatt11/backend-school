/**
 * Redis cache for hot read paths (100k concurrent users).
 * get() returns null if cache disabled or miss; set() no-ops if disabled.
 * Values are JSON-serialized.
 */
const env = require("../config/env");
const { getRedis } = require("../config/redis");

function isCacheEnabled() {
  try {
    return env.CACHE_ENABLED === "true" && getRedis() != null;
  } catch {
    return false;
  }
}

function keyWithPrefix(key) {
  const prefix = (env.CACHE_KEY_PREFIX || "se:cache:").replace(/:$/, "");
  return `${prefix}:${key}`;
}

/**
 * @param {string} key - Cache key (prefix added automatically)
 * @returns {Promise<object|null>} Parsed value or null
 */
async function get(key) {
  if (!isCacheEnabled()) return null;
  const redis = getRedis();
  try {
    const fullKey = keyWithPrefix(key);
    const raw = await redis.get(fullKey);
    if (raw == null) return null;
    return JSON.parse(raw);
  } catch (err) {
    if (env.NODE_ENV !== "production") {
      console.warn("[cache] get error:", err?.message);
    }
    return null;
  }
}

/**
 * @param {string} key - Cache key
 * @param {object} value - Serializable value (JSON)
 * @param {number} ttlSeconds - TTL in seconds
 */
async function set(key, value, ttlSeconds) {
  if (!isCacheEnabled() || ttlSeconds <= 0) return;
  const redis = getRedis();
  try {
    const fullKey = keyWithPrefix(key);
    const serialized = JSON.stringify(value);
    await redis.setex(fullKey, ttlSeconds, serialized);
  } catch (err) {
    if (env.NODE_ENV !== "production") {
      console.warn("[cache] set error:", err?.message);
    }
  }
}

/**
 * Invalidate a key (e.g. after profile update)
 * @param {string} key - Cache key
 */
async function del(key) {
  if (!isCacheEnabled()) return;
  const redis = getRedis();
  try {
    await redis.del(keyWithPrefix(key));
  } catch (err) {
    if (env.NODE_ENV !== "production") {
      console.warn("[cache] del error:", err?.message);
    }
  }
}

/**
 * Cache key builders for consistency
 */
const cacheKeys = {
  dashboardSchoolAdmin: (schoolId) => `dashboard:school-admin:${schoolId || "all"}`,
  dashboardHr: (schoolId) => `dashboard:hr:${schoolId || "all"}`,
  dashboardAccountant: (schoolId) => `dashboard:accountant:${schoolId || "all"}`,
  schoolProfile: (schoolId) => `school:profile:${schoolId}`,
  permissionsList: () => `permissions:list`,
  me: (userId) => `me:${userId}`,
};

module.exports = {
  get,
  set,
  del,
  isCacheEnabled,
  cacheKeys,
  CACHE_TTL: {
    dashboard: () => env.CACHE_TTL_DASHBOARD_SEC,
    profile: () => env.CACHE_TTL_PROFILE_SEC,
    me: () => env.CACHE_TTL_ME_SEC,
    permissions: () => env.CACHE_TTL_PERMISSIONS_SEC,
  },
};
