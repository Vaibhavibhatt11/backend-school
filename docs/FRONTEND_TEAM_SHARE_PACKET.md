# Frontend Team Share Packet (Render Deployment)

## Production Base URL

`https://backend-school-app.onrender.com/api/v1`

---

## Integration Decision (IMPORTANT)

- App uses **single login flow** for both Student and Parent users.
- App uses **unified app endpoints** under `/app/*`.
- Backend resolves context by logged-in user and optional `childId`.

Use this contract file as source of truth:

- `backend/docs/APP_MODULE_APIS.json`

---

## Auth Flow

1. Login:

- `POST /auth/login`
- Body:

```json
{
  "email": "user@example.com",
  "password": "your-password"
}
```

2. Save:
- `accessToken`
- `refreshToken`
- `user.role`

3. Send this header on protected APIs:

`Authorization: Bearer <accessToken>`

---

## API Order For App Boot

1. `GET /app/children`
2. `GET /app/dashboard` (or `GET /app/dashboard?childId=<id>`)
3. Optional tabs:
   - `GET /app/attendance?childId=<id>&month=YYYY-MM`
   - `GET /app/fees?childId=<id>`
   - `GET /app/announcements?childId=<id>`

---

## Response Standard

Success:

```json
{
  "success": true,
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "error": {
    "code": "STRING_CODE",
    "message": "Human readable message"
  }
}
```

---

## Child Context Rules

- `childId` is optional on `/app/*`.
- If provided, backend verifies user has access to that child.
- If not provided, backend auto-selects:
  - own student profile (if available), else
  - first linked child.

If child is not accessible, backend returns `403`.

---

## Legacy Notes

- Legacy `/student/*` and `/parent/*` APIs still exist.
- For current app architecture, frontend should integrate with `/app/*` only.

