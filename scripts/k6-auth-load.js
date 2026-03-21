import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://localhost:5000/api/v1";
const EMAIL = __ENV.LOAD_EMAIL || "admin@school.edu";
const PASSWORD = __ENV.LOAD_PASSWORD || "Admin123!";

export const options = {
  stages: [
    { duration: "30s", target: 25 },
    { duration: "60s", target: 50 },
    { duration: "30s", target: 0 },
  ],
  thresholds: {
    http_req_failed: ["rate<0.05"],
    http_req_duration: ["p(95)<1200"],
  },
};

export default function () {
  const payload = JSON.stringify({
    email: EMAIL,
    password: PASSWORD,
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
  };

  const loginRes = http.post(`${BASE_URL}/auth/login`, payload, params);
  check(loginRes, {
    "login status is 200": (r) => r.status === 200,
    "login returns access token": (r) => {
      try {
        const body = r.json();
        return Boolean(body?.data?.accessToken);
      } catch {
        return false;
      }
    },
  });

  sleep(1);
}
