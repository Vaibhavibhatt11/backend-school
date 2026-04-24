/**
 * Redis cache for hot read paths (100k concurrent users).
 * get() returns null if cache disabled or miss; set() no-ops if disabled.
 * Values are JSON-serialized.
 */
const env = require("../config/env");
const { getRedis, connectRedis } = require("../config/redis");

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
    await connectRedis(redis);
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
    await connectRedis(redis);
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
    await connectRedis(redis);
    await redis.del(keyWithPrefix(key));
  } catch (err) {
    if (env.NODE_ENV !== "production") {
      console.warn("[cache] del error:", err?.message);
    }
  }
}

/**
 * Cache key builders for consistency (production: 1M users, quick responses)
 */
const cacheKeys = {
  dashboardSchoolAdmin: (schoolId) => `dashboard:school-admin:${schoolId || "all"}`,
  dashboardHr: (schoolId) => `dashboard:hr:${schoolId || "all"}`,
  dashboardAccountant: (schoolId) => `dashboard:accountant:${schoolId || "all"}`,
  schoolProfile: (schoolId) => `school:profile:${schoolId}`,
  permissionsList: () => `permissions:list`,
  me: (userId) => `me:${userId}`,
  // List caches (invalidate on write); key should include page/limit/status etc. for correctness
  admissionsList: (schoolId, page, limit, status, searchHash) =>
    `admissions:list:${schoolId}:${page}:${limit}:${status || ""}:${searchHash || ""}`,
  transportRoutesList: (schoolId, page, limit) => `transport:routes:${schoolId}:${page}:${limit}`,
  transportAllocationsList: (schoolId, page, limit, routeId) =>
    `transport:allocations:${schoolId}:${page}:${limit}:${routeId || ""}`,
  hostelRoomsList: (schoolId) => `hostel:rooms:${schoolId}`,
  hostelAllocationsList: (schoolId, page, limit) => `hostel:allocations:${schoolId}:${page}:${limit}`,
  eventsList: (schoolId, page, limit, from, to) => `events:list:${schoolId}:${page}:${limit}:${from || ""}:${to || ""}`,
  homeworkList: (schoolId, page, limit, classId) => `homework:list:${schoolId}:${page}:${limit}:${classId || ""}`,
  studyMaterialsList: (schoolId, page, limit) => `study:list:${schoolId}:${page}:${limit}`,
  studentDashboard: (studentId) => `student:dashboard:${studentId}`,
  studentProfile: (studentId) => `student:profile:${studentId}`,
  studentTimetable: (classId) => `student:timetable:${classId || "none"}`,
  studentExams: (studentId) => `student:exams:${studentId}`,
  parentHome: (studentId) => `parent:home:${studentId}`,
  parentAnnouncements: (studentId) => `parent:announcements:${studentId}`,
  parentNotifications: (studentId) => `parent:notifications:${studentId}`,
  parentAttendance: (studentId, monthKey) => `parent:attendance:${studentId}:${monthKey || "current"}`,
  parentFees: (studentId) => `parent:fees:${studentId}`,
  parentTimetable: (studentId, dayKey) => `parent:timetable:${studentId}:${dayKey || "today"}`,
  parentLiveClasses: (studentId) => `parent:live-classes:${studentId}`,
  parentProfileHub: (studentId) => `parent:profile-hub:${studentId}`,
};

const CACHE_TTL_LIST = () => (env.CACHE_TTL_LIST_SEC != null ? env.CACHE_TTL_LIST_SEC : 60);
const CACHE_TTL_STUDENT_DASHBOARD = () => (env.CACHE_TTL_STUDENT_DASHBOARD_SEC != null ? env.CACHE_TTL_STUDENT_DASHBOARD_SEC : 60);
const CACHE_TTL_STUDENT_OTHER = () => (env.CACHE_TTL_STUDENT_OTHER_SEC != null ? env.CACHE_TTL_STUDENT_OTHER_SEC : 120);

/**
 * Get from cache or compute and set (for list/dashboard endpoints). TTL in seconds.
 * @param {string} key
 * @param {number} ttlSeconds
 * @param {() => Promise<object>} fn - async function that returns the value to cache
 * @returns {Promise<object>}
 */
async function getOrSet(key, ttlSeconds, fn) {
  const cached = await get(key);
  if (cached != null) return cached;
  const value = await fn();
  if (ttlSeconds > 0) await set(key, value, ttlSeconds);
  return value;
}

/**
 * Invalidate all keys that start with prefix (e.g. "admissions:list:schoolId" to clear all list pages for that school)
 */
async function delByPrefix(prefix) {
  if (!isCacheEnabled()) return;
  const redis = getRedis();
  try {
    await connectRedis(redis);
    const fullPrefix = keyWithPrefix(prefix);
    const keys = await redis.keys(`${fullPrefix}*`);
    if (keys.length > 0) await redis.del(...keys);
  } catch (err) {
    if (env.NODE_ENV !== "production") console.warn("[cache] delByPrefix error:", err?.message);
  }
}

module.exports = {
  get,
  set,
  del,
  delByPrefix,
  getOrSet,
  isCacheEnabled,
  cacheKeys,
  CACHE_TTL: {
    dashboard: () => env.CACHE_TTL_DASHBOARD_SEC,
    profile: () => env.CACHE_TTL_PROFILE_SEC,
    me: () => env.CACHE_TTL_ME_SEC,
    permissions: () => env.CACHE_TTL_PERMISSIONS_SEC,
    list: CACHE_TTL_LIST,
    studentDashboard: CACHE_TTL_STUDENT_DASHBOARD,
    studentTimetable: CACHE_TTL_STUDENT_OTHER,
    studentExams: CACHE_TTL_STUDENT_OTHER,
    parentHome: CACHE_TTL_STUDENT_OTHER,
    parentAnnouncements: CACHE_TTL_STUDENT_OTHER,
    parentNotifications: CACHE_TTL_STUDENT_OTHER,
    parentAttendance: CACHE_TTL_STUDENT_OTHER,
    parentFees: CACHE_TTL_STUDENT_OTHER,
    parentTimetable: CACHE_TTL_STUDENT_OTHER,
    parentLiveClasses: CACHE_TTL_STUDENT_OTHER,
    parentProfileHub: CACHE_TTL_STUDENT_OTHER,
  },
};
