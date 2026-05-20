# Postman Testing Guide — Teacher Finder Auth API

## Prerequisites

1. PostgreSQL is running and a database named `teacher_finder` exists
2. The schema from `database/schema.sql` has been applied
3. The backend is running: `npm start` (or `npm run dev` for auto-reload)

---

## 1. Test: Register a Student

| Field   | Value                                      |
|---------|--------------------------------------------|
| Method  | `POST`                                     |
| URL     | `http://localhost:5000/api/auth/register`   |
| Headers | `Content-Type: application/json`           |

**Body (raw JSON):**
```json
{
  "name": "Ahmad Raza",
  "email": "ahmad.raza@example.com",
  "password": "mypassword123",
  "role": "student"
}
```

**Expected Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": "<uuid>",
    "name": "Ahmad Raza",
    "email": "ahmad.raza@example.com",
    "role": "student",
    "created_at": "<timestamp>"
  }
}
```

---

## 2. Test: Register a Teacher

| Field   | Value                                      |
|---------|--------------------------------------------|
| Method  | `POST`                                     |
| URL     | `http://localhost:5000/api/auth/register`   |
| Headers | `Content-Type: application/json`           |

**Body (raw JSON):**
```json
{
  "name": "Fatima Noor",
  "email": "fatima.noor@example.com",
  "password": "teacherpass456",
  "role": "teacher"
}
```

**Expected Response (201):** Same structure as above with role `"teacher"`.

---

## 3. Test: Duplicate Email (should fail)

Send the **same register request** from Step 1 again.

**Expected Response (409):**
```json
{
  "success": false,
  "message": "A user with this email already exists"
}
```

---

## 4. Test: Missing Fields (should fail)

| Field   | Value                                      |
|---------|--------------------------------------------|
| Method  | `POST`                                     |
| URL     | `http://localhost:5000/api/auth/register`   |

**Body (raw JSON):**
```json
{
  "name": "Test User",
  "email": "test@example.com"
}
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "All fields are required: name, email, password, role"
}
```

---

## 5. Test: Login

| Field   | Value                                      |
|---------|--------------------------------------------|
| Method  | `POST`                                     |
| URL     | `http://localhost:5000/api/auth/login`      |
| Headers | `Content-Type: application/json`           |

**Body (raw JSON):**
```json
{
  "email": "ahmad.raza@example.com",
  "password": "mypassword123"
}
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "<jwt_token>",
  "user": {
    "id": "<uuid>",
    "name": "Ahmad Raza",
    "email": "ahmad.raza@example.com",
    "role": "student"
  }
}
```

> **Copy the `token` value** — you will need it for the next test.

---

## 6. Test: Wrong Password (should fail)

| Field   | Value                                      |
|---------|--------------------------------------------|
| Method  | `POST`                                     |
| URL     | `http://localhost:5000/api/auth/login`      |

**Body (raw JSON):**
```json
{
  "email": "ahmad.raza@example.com",
  "password": "wrongpassword"
}
```

**Expected Response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

## 7. Test: Protected Route (with token)

| Field   | Value                                                  |
|---------|--------------------------------------------------------|
| Method  | `GET`                                                  |
| URL     | `http://localhost:5000/api/protected`                   |
| Headers | `Authorization: Bearer <paste_your_token_here>`        |

**Expected Response (200):**
```json
{
  "success": true,
  "message": "You have access to this protected route",
  "user": {
    "id": "<uuid>",
    "role": "student",
    "iat": 1234567890,
    "exp": 1234567890
  }
}
```

---

## 8. Test: Protected Route Without Token (should fail)

| Field   | Value                                      |
|---------|--------------------------------------------|
| Method  | `GET`                                      |
| URL     | `http://localhost:5000/api/protected`       |

**No Authorization header.**

**Expected Response (401):**
```json
{
  "success": false,
  "message": "Access denied. No token provided."
}
```

---

## Quick Setup Recap

```bash
cd backend
cp .env.example .env        # edit with your real DB credentials and JWT secret
npm install                  # install all dependencies
npm run dev                  # start with auto-reload (or npm start)
```
