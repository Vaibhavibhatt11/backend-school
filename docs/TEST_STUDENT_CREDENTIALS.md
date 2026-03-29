# Test Student Login – Frontend Development

## Credentials

| Field | Value |
|-------|-------|
| **Email** | `student@school.edu` |
| **Password** | `Student123!` |

---

## Running Steps

### 1. Run the database seed

From the backend folder:

```bash
cd backend
npx prisma db seed
```

Or:

```bash
npm run prisma:seed
```

This creates (or updates) the test student user and links it to a Student profile in Demo School.

### 2. Login

```bash
POST https://backend-school-app.onrender.com/api/v1/auth/login
Content-Type: application/json

{
  "email": "student@school.edu",
  "password": "Student123!"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "<token>",
    "refreshToken": "<refresh>",
    "user": {
      "id": "...",
      "fullName": "Demo Student",
      "email": "student@school.edu",
      "role": "STUDENT",
      "schoolId": "..."
    }
  }
}
```

### 3. Call student APIs

Use the `accessToken` in the header:

```
Authorization: Bearer <accessToken>
```

Example:

```
GET https://backend-school-app.onrender.com/api/v1/student/dashboard
Authorization: Bearer <accessToken>
```

---

## Summary for Frontend Team

> **Test student login**  
> - Email: `student@school.edu`  
> - Password: `Student123!`  
> - Login URL: `POST https://backend-school-app.onrender.com/api/v1/auth/login`  
> - Use the returned `accessToken` in `Authorization: Bearer <token>` for all `/student/*` APIs.

**Note:** The seed must be run at least once on the backend database. Ask the backend team to run `npx prisma db seed` if the credentials do not work.
