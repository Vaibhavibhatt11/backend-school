# 🎓 School ERP Backend

Production-ready backend system for the School ERP Admin Panel.

This backend is built using **Node.js, Express, Prisma, and PostgreSQL**.  
It includes secure authentication (JWT), role-based access control, rate limiting, and API documentation.

---

## 🚀 Tech Stack

- Node.js
- Express.js
- Prisma ORM
- PostgreSQL
- JWT (Access + Refresh Tokens)
- Docker (for local database)
- Swagger (API Documentation)

---

## 📂 Project Setup (Local Development)

Follow these steps to run the project locally:

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd backend
```

---

### 2️⃣ Install Dependencies

```bash
npm install
```

---

### 3️⃣ Start Local Database (Docker)

Make sure Docker is installed and running.

```bash
docker compose up -d
```

---

### 4️⃣ Setup Environment Variables

- Copy `.env.example`
- Create a new file named `.env`
- Add your actual values in `.env`

Example:

```
DATABASE_URL=your_database_url
JWT_ACCESS_SECRET=your_secret
JWT_REFRESH_SECRET=your_secret
PORT=5000
```

⚠ Important: Never push `.env` to GitHub.

---

### 5️⃣ Run Database Migrations & Seed

```bash
npm run prisma:deploy
npm run prisma:seed
```

---

### 6️⃣ Start the Server

```bash
npm start
```

Server will run at:

```
http://localhost:5000
```

---

## ✅ Health Check

```
GET http://localhost:5000/api/v1/health
```

---

## 📘 API Documentation (Swagger)

Open in browser:

```
http://localhost:5000/api/docs
```

Swagger UI allows you to test all endpoints directly.

---

## 🔐 Authentication Flow

1. Login → Receive Access Token + Refresh Token  
2. Use Access Token for protected routes  
3. Use Refresh Token to generate new Access Token  

---

## 👤 Demo Users (After Seeding)

You can log in with:

| Role        | Email              | Password    |
|------------|--------------------|------------|
| Super Admin | super@school.edu  | Admin123!  |
| Admin       | admin@school.edu  | Admin123!  |
| Accountant  | acc@school.edu    | Admin123!  |
| HR          | hr@school.edu     | Admin123!  |

---

## 🌍 Deploying on Render

### 1️⃣ Create Web Service

- Go to Render
- Click `New +`
- Select `Web Service`
- Connect your GitHub repository

---

### 2️⃣ Use These Settings

**Build Command**
```bash
npm ci && npx prisma generate && npx prisma migrate deploy
```

**Start Command**
```bash
npm start
```

---

### 3️⃣ Create PostgreSQL Database

- Create a Render PostgreSQL instance
- Copy the **Internal Database URL**
- Add it as:

```
DATABASE_URL=<render-internal-db-url>
```

---

### 4️⃣ Add Environment Variables in Render

Required:

```
NODE_ENV=production
PORT=10000
DATABASE_URL=<render-db-url>
JWT_ACCESS_SECRET=<min-16-chars>
JWT_REFRESH_SECRET=<min-16-chars>
PASSWORD_RESET_SECRET=<min-16-chars>
ACCESS_TOKEN_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d
CORS_ORIGIN=<frontend-url>
SWAGGER_ENABLED=false
LOGIN_RATE_LIMIT_WINDOW_MS=900000
LOGIN_RATE_LIMIT_MAX=5
```

Optional (if using Redis / Email):

```
REDIS_URL=
SMTP_HOST=
SMTP_USER=
SMTP_PASS=
```

---

## 🧪 Smoke Testing

Before deployment or handoff:

```bash
npm run smoke:full
```

This verifies that all critical APIs are working correctly.

---

## 📁 Folder Structure

```
src/
 ├── controllers/
 ├── middleware/
 ├── routes/
 ├── services/
 ├── prisma/
 ├── utils/
 └── server.js
```

---

## 🛡 Security Features

- JWT Authentication
- Refresh Token Rotation
- Role-Based Access Control
- Rate Limiting (Login protection)
- Secure Environment Configuration
- CORS Protection

---

## 📌 Production Notes

- Always use strong secrets in production.
- Never commit `.env` file.
- Disable Swagger in production using:
  ```
  SWAGGER_ENABLED=false
  ```

---

## 👩‍💻 Author

**Vaibhavi Bhatt**  
Computer Engineering Student  
School ERP Backend Project
## Postman 30 API Pack

Generate ready-to-import Postman files:

```bash
node scripts/generate-postman-30.js
```

Import in Postman:
- `postman/School-ERP-30.postman_collection.json`
- `postman/School-ERP-Local.postman_environment.json`

Run folders in sequence:
1. `01 Auth (7 + optional change-password)`
2. `02 Dashboard (1)`
3. `03 Staff (4)`
4. `04 Classes (4)`
5. `05 Subjects (4)`
6. `06 Students (6)`
7. `07 Attendance (2)`
8. `08 Finance (1)`
9. `09 Cleanup (5)` (includes `POST /auth/logout`)

Notes:
- Tokens and entity IDs are auto-saved in collection variables.
- `POST /auth/change-password` needs valid values for `changeCurrentPassword` and `changeNewPassword`.

## AWS Production Deployment (Recommended)

Use this setup for higher traffic:

1. Compute: ECS Fargate (or EKS) with multiple backend tasks.
2. Load Balancer: ALB in front of backend tasks.
3. Database: RDS PostgreSQL + RDS Proxy (for pooled DB connections).
4. Cache/Rate limit: ElastiCache Redis (set `REDIS_URL`).
5. Secrets: AWS Secrets Manager or SSM Parameter Store.

Required runtime env values:

```env
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://<user>:<pass>@<rds-proxy-endpoint>:5432/<db>?schema=public&connection_limit=30&pool_timeout=20
REDIS_URL=redis://<elasticache-endpoint>:6379
TRUST_PROXY=1
CORS_ORIGIN=https://<frontend-domain>
PUBLIC_BASE_URL=https://<api-domain>
SWAGGER_ENABLED=false
REQUEST_BODY_LIMIT=2mb
LOGIN_RATE_LIMIT_WINDOW_MS=900000
LOGIN_RATE_LIMIT_MAX=5
HEALTHCHECK_DB_TIMEOUT_MS=2000
SERVER_KEEP_ALIVE_TIMEOUT_MS=65000
SERVER_HEADERS_TIMEOUT_MS=66000
SERVER_REQUEST_TIMEOUT_MS=120000
```

Health endpoints for ALB:

- Liveness: `GET /api/v1/health`
- Readiness: `GET /api/v1/ready`

Deploy order:

1. Run migrations once: `npm run prisma:deploy`
2. Seed once (only initial): `npm run prisma:seed`
3. Start app: `npm run start`
