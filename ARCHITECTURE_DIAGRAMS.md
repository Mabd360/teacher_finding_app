# Teacher Finder App - Architecture & Flow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     TEACHER FINDER APP                           │
└─────────────────────────────────────────────────────────────────┘

                          ╔════════════════════════════╗
                          ║   FLUTTER FRONTEND         ║
                          ║  (Mobile App)              ║
                          ╚════════════════════════════╝
                                     │
                                     │ HTTP/HTTPS
                                     │
                ┌────────────────────┼────────────────────┐
                │                    │                    │
       ┌────────▼────────┐  ┌─────────▼────────┐  ┌──────▼──────┐
       │  Auth Service   │  │ Teacher Profile  │  │ Student     │
       │  (http)         │  │ Service (http)   │  │ Service     │
       └────────┬────────┘  └─────────┬────────┘  └──────┬──────┘
                │                     │                   │
                │                     │                   │
                └────────────────────┬┼──────────────────┘
                                     ││
                                     ││ JSON
                                     ││
                    ╔═════════════════▼▼══════════════════╗
                    ║   NODE.JS + EXPRESS SERVER          ║
                    ║   (Backend API on port 5000)        ║
                    ╚═════════════════╤╤══════════════════╝
                                      ││
                    ┌─────────────────┼┼─────────────────┐
                    │                 ││                 │
            ┌───────▼────────┐  ┌────▼┴────────┐  ┌────▼────┐
            │ Auth Routes    │  │ Teacher      │  │ Student  │
            │ (register,     │  │ Routes       │  │ Routes   │
            │  login)        │  │ (profile)    │  │          │
            └───────┬────────┘  └────┬─────────┘  └────┬─────┘
                    │                 │                 │
                    │ authMiddleware  │ authMiddleware  │
                    │ (JWT verify)    │ (JWT verify)    │
                    │                 │                 │
                    └─────────────────┼────────────────┘
                                      │
                                      │ SQL
                                      │
                    ╔═════════════════▼══════════════════╗
                    ║   POSTGRESQL DATABASE              ║
                    ║                                     ║
                    ║   • users                           ║
                    ║   • teacher_profiles                ║
                    ║   • (bookings, messages, etc)       ║
                    ╚═════════════════════════════════════╝
```

---

## Authentication Flow

```
┌──────────────────────────────────────────────────────────┐
│              USER AUTHENTICATION FLOW                     │
└──────────────────────────────────────────────────────────┘

User (Flutter App)
    │
    ├─→ [Enter Email & Password]
    │
    └──→ POST /api/auth/register
        ├─ Validate fields
        ├─ Check email exists? NO
        ├─ Hash password with bcrypt
        ├─ INSERT into users table
        └─→ Response: User ID, name, email

User registers successfully ✓

User (Flutter App)
    │
    ├─→ [Enter Email & Password]
    │
    └──→ POST /api/auth/login
        ├─ Find user by email
        ├─ Compare password with bcrypt
        ├─ Password match? YES
        ├─ Generate JWT token (7 day expiry)
        └─→ Response: JWT token + user info

User receives token → Stored in app memory
    │
    └─→ Token attached to all protected requests:
        Authorization: Bearer <token>

JWT Token Used For:
• POST   /api/teacher/profile     (create profile)
• PUT    /api/teacher/profile     (update profile)
• GET    /api/teacher/profile     (get own profile)
```

---

## Teacher Profile Creation Flow

```
┌──────────────────────────────────────────────────────────┐
│          TEACHER PROFILE CREATION FLOW                    │
└──────────────────────────────────────────────────────────┘

Teacher (Flutter App)
    │
    ├─→ [View: TeacherProfileScreen]
    │   ├─ TextFormField: Subjects (array)
    │   ├─ TextFormField: Fee per hour (number)
    │   ├─ TextFormField: Availability (JSON)
    │   ├─ TextFormField: Bio (text)
    │   └─ Button: [Create Profile]
    │
    └──→ [Submit Form]
        │
        ├─→ Validate inputs
        │   ├─ Subjects: non-empty array? ✓
        │   ├─ Fee: positive number? ✓
        │   └─ Bio: optional ✓
        │
        ├─→ POST /api/teacher/profile
        │   ├─ Headers: Authorization: Bearer <token>
        │   ├─ Body: JSON with form data
        │   │
        │   └──→ Express Server
        │       ├─ authMiddleware
        │       │  └─ Verify JWT token ✓
        │       │
        │       ├─ Check role == 'teacher' ✓
        │       │
        │       ├─ teacherRoutes POST handler
        │       │  ├─ Validate all fields
        │       │  ├─ Check user_id not exists (unique)
        │       │  └─ INSERT teacher_profiles
        │       │      ├─ (user_id, subjects, fee_per_hour,
        │       │      │  availability, bio, created_at)
        │       │      └─ RETURNING all fields
        │       │
        │       └─→ Response (201 Created)
        │           └─ Profile data with ID
        │
        ├─→ Response received in Flutter
        │   ├─ Status 201? ✓
        │   ├─ Parse JSON response
        │   └─ Update TeacherProfile model
        │
        └─→ Show SnackBar: "✓ Profile created successfully"
            │
            └─→ Navigate back or show profile

Database State:
┌─────────────────────────────────────────┐
│ teacher_profiles table                  │
├─────────────────────────────────────────┤
│ id: 660e8400-...                        │
│ user_id: 550e8400-... (FK)              │
│ subjects: ["Math", "Physics"]           │
│ fee_per_hour: 25.50                     │
│ availability: {...}                     │
│ bio: "Experienced tutor"                │
│ created_at: 2026-05-20 10:30:00         │
│ updated_at: 2026-05-20 10:30:00         │
└─────────────────────────────────────────┘
```

---

## Get Public Profile Flow

```
┌──────────────────────────────────────────────────────────┐
│          GET PUBLIC TEACHER PROFILE FLOW                  │
└──────────────────────────────────────────────────────────┘

Student (Any User)
    │
    ├─→ [Browse Teachers]
    │   └─ List of teachers with IDs
    │
    ├─→ [Click Teacher Card]
    │   └─ user_id: 550e8400-...
    │
    └──→ GET /api/teacher/profile/550e8400-...
        │
        ├─→ No Authorization needed (PUBLIC)
        │
        ├─→ Express Server
        │   ├─ No authMiddleware
        │   │
        │   ├─ teacherRoutes GET handler
        │   │  ├─ Validate user_id format
        │   │  ├─ SELECT teacher_profiles
        │   │  │  JOIN users ON user_id
        │   │  │  WHERE user_id = $1
        │   │  └─ RETURNING: id, name, subjects,
        │   │              fee_per_hour, availability, bio
        │   │
        │   └─→ Response (200 OK)
        │       └─ Teacher profile (no email)
        │
        ├─→ Response received in Flutter
        │   ├─ Status 200? ✓
        │   ├─ Parse JSON response
        │   └─ Display profile
        │
        └─→ Show Teacher Details:
            ├─ Name: "John Doe"
            ├─ Subjects: Math, Physics
            ├─ Fee: $25.50/hour
            ├─ Bio: "Experienced..."
            └─ [Send Message] / [Book Session]

Database Query:
┌─────────────────────────────────────────┐
│ SELECT tp.*, u.name FROM teacher_profiles tp
│ JOIN users u ON tp.user_id = u.id
│ WHERE tp.user_id = '550e8400-...'
│
│ Result:
│ • id, user_id, subjects, fee_per_hour
│ • availability, bio, created_at, updated_at
│ • name (from users table)
│ • (email NOT returned - privacy)
└─────────────────────────────────────────┘
```

---

## Error Handling Flow

```
┌──────────────────────────────────────────────────────────┐
│           ERROR HANDLING FLOW                             │
└──────────────────────────────────────────────────────────┘

Create Profile Request
    │
    ├─→ Network Error
    │   └─→ Flutter catches exception
    │       └─→ SnackBar: "✗ Network error: ..."
    │
    ├─→ 400 Bad Request
    │   └─→ JSON response: {message: "..."}
    │       └─→ SnackBar: "✗ Error: Subjects must be array"
    │
    ├─→ 401 Unauthorized
    │   └─→ JSON response: {message: "..."}
    │       └─→ SnackBar: "✗ Error: Unauthorized..."
    │       └─→ Clear token and navigate to login
    │
    ├─→ 403 Forbidden
    │   └─→ JSON response: {message: "..."}
    │       └─→ SnackBar: "✗ Only teachers can..."
    │
    ├─→ 409 Conflict
    │   └─→ JSON response: {message: "..."}
    │       └─→ SnackBar: "✗ Profile already exists"
    │
    ├─→ 500 Server Error
    │   └─→ JSON response: {message: "..."}
    │       └─→ SnackBar: "✗ Server error..."
    │
    └─→ 200 OK / 201 Created
        └─→ JSON response: {success: true, profile: {...}}
            └─→ SnackBar: "✓ Success!"
                └─→ Update UI / Navigate
```

---

## Database Schema Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    USERS TABLE                            │
├──────────────────────────────────────────────────────────┤
│ id (UUID) ◄─────── Primary Key                           │
│ name (VARCHAR)                                            │
│ email (VARCHAR) ◄── Unique constraint                    │
│ password_hash (TEXT)                                      │
│ role (ENUM) ◄────── 'student' or 'teacher'              │
│ created_at (TIMESTAMP)                                    │
└──────────────────────────────────────────────────────────┘
            │
            │ 1 (one user)
            │
            ▼
┌──────────────────────────────────────────────────────────┐
│              TEACHER_PROFILES TABLE                      │
├──────────────────────────────────────────────────────────┤
│ id (UUID) ◄────────── Primary Key                        │
│ user_id (UUID) ◄───── FK → users.id                      │
│                       (Unique, Cascade Delete)           │
│ subjects (TEXT[]) ◄── Array of strings                   │
│ fee_per_hour (DECIMAL) ◄── Hourly rate                   │
│ availability (JSONB) ◄──── {"Mon": ["9-12"]}            │
│ bio (TEXT)                                                │
│ created_at (TIMESTAMP)                                    │
│ updated_at (TIMESTAMP)                                    │
└──────────────────────────────────────────────────────────┘

Relationship: ONE-TO-ONE
• 1 User → 0 or 1 Teacher Profile
• Each teacher has max 1 profile
• Cannot exist without user
• Delete user → delete profile (cascade)
```

---

## JWT Token Lifecycle

```
┌──────────────────────────────────────────────────────────┐
│              JWT TOKEN LIFECYCLE                          │
└──────────────────────────────────────────────────────────┘

1. LOGIN
   └─→ POST /api/auth/login
       └─→ Check password ✓
           └─→ Generate JWT:
               {
                 userId: "550e8400-...",
                 email: "john@example.com",
                 role: "teacher",
                 iat: 1716200600,
                 exp: 1716805400  (7 days later)
               }
               └─→ Signed with JWT_SECRET
                   └─→ eyJhbGc... (encoded token)

2. STORE IN APP
   └─→ Save token in variable/state
       (Consider using flutter_secure_storage)

3. USE IN REQUESTS
   └─→ Include Authorization header:
       Authorization: Bearer eyJhbGc...
       └─→ For protected routes:
           POST /api/teacher/profile
           PUT  /api/teacher/profile
           GET  /api/teacher/profile

4. SERVER VERIFIES
   └─→ authMiddleware:
       ├─ Extract token from header
       ├─ Verify signature with JWT_SECRET
       ├─ Check expiration (iat, exp)
       └─ Attach user to req.user
           ├─ userId
           ├─ email
           └─ role

5. REQUEST PROCEEDS
   └─→ If verified: Continue to route handler
   └─→ If invalid/expired: Return 401

6. TOKEN EXPIRES
   └─→ After 7 days (exp timestamp)
   └─→ authMiddleware rejects token
   └─→ User must login again
   └─→ New token generated

Timeline:
├─ T+0 seconds    : Token created (iat)
├─ T+0..7 days    : Token valid ✓
├─ T+7 days       : Token expires (exp reached)
└─ T+7 days+      : Token invalid ✗
```

---

## Request/Response Cycle

```
┌──────────────────────────────────────────────────────────┐
│         HTTP REQUEST/RESPONSE CYCLE                       │
└──────────────────────────────────────────────────────────┘

FLUTTER APP
    │
    ├─ Prepare Request
    │  ├─ HTTP Method: POST
    │  ├─ URL: http://localhost:5000/api/teacher/profile
    │  ├─ Headers: {
    │  │    'Content-Type': 'application/json',
    │  │    'Authorization': 'Bearer token...'
    │  │  }
    │  └─ Body: {
    │      'subjects': ['Math', 'Physics'],
    │      'fee_per_hour': 25.50,
    │      'availability': {...},
    │      'bio': '...'
    │    }
    │
    └──→ Network ──────────────────────────────┐
                                                │
NODE.JS SERVER                                  │
    │                                           │
    ├─ Receive Request ◄─────────────────────────┘
    │
    ├─ Parse Request
    │  ├─ Extract HTTP method: POST
    │  ├─ Extract path: /api/teacher/profile
    │  ├─ Extract headers
    │  └─ Parse JSON body
    │
    ├─ Route Matching
    │  └─ Matches: POST /api/teacher/profile
    │     └─ Handler: teacherRoutes.post('/profile')
    │
    ├─ Run Middleware
    │  └─ authMiddleware
    │     ├─ Get Authorization header
    │     ├─ Extract Bearer token
    │     ├─ Verify JWT signature
    │     ├─ Check expiration
    │     ├─ Attach to req.user ✓
    │     └─ Call next()
    │
    ├─ Route Handler Executes
    │  ├─ Validate inputs
    │  ├─ Check role == 'teacher'
    │  ├─ Query database
    │  ├─ INSERT new profile
    │  └─ Prepare response object
    │
    ├─ Prepare Response
    │  ├─ Status Code: 201
    │  ├─ Headers: {
    │  │    'Content-Type': 'application/json',
    │  │    'Content-Length': '...'
    │  │  }
    │  └─ Body: {
    │      'success': true,
    │      'message': '...',
    │      'profile': {...}
    │    }
    │
    └──→ Network ──────────────────────────────┐
                                                │
FLUTTER APP                                     │
    │                                           │
    ├─ Receive Response ◄─────────────────────────┘
    │
    ├─ Check Status Code
    │  └─ 201 Created? ✓
    │
    ├─ Parse Response
    │  └─ JSON decode
    │
    ├─ Handle Result
    │  ├─ Update UI
    │  ├─ Update state
    │  ├─ Show SnackBar
    │  └─ Navigate (optional)
    │
    └─ End
```

---

## File Dependencies Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                   BACKEND DEPENDENCIES                         │
└────────────────────────────────────────────────────────────────┘

server.js (entry point)
    ├─ require('./db.js')
    │   └─ pg (package)
    │       └─ PostgreSQL connection
    │
    ├─ require('./authRoutes.js')
    │   ├─ require('./db.js')
    │   ├─ bcrypt (package)
    │   └─ jsonwebtoken (package)
    │
    ├─ require('./teacherRoutes.js')  ◄─── MODULE 2
    │   ├─ require('./db.js')
    │   └─ require('./authMiddleware.js')
    │
    ├─ require('./authMiddleware.js')
    │   └─ jsonwebtoken (package)
    │
    ├─ express (package)
    ├─ cors (package)
    └─ dotenv (package)

┌────────────────────────────────────────────────────────────────┐
│                   FLUTTER DEPENDENCIES                         │
└────────────────────────────────────────────────────────────────┘

main.dart (entry point)
    └─ screens/teacher_profile_screen.dart  ◄─── MODULE 2
        ├─ services/teacher_api_service.dart
        │   ├─ models/teacher_profile_model.dart
        │   ├─ utils/api_constants.dart
        │   └─ http (package)
        │
        ├─ models/teacher_profile_model.dart
        │   └─ dart:convert
        │
        ├─ utils/api_constants.dart
        │   └─ (constants only)
        │
        ├─ Material (package)
        └─ flutter (package)
```

---

## Deployment Architecture

```
┌────────────────────────────────────────────────────────────────┐
│               PRODUCTION DEPLOYMENT                            │
└────────────────────────────────────────────────────────────────┘

USERS (Global)
    │
    ├─→ iOS Users
    │   └─ App Store → Download Flutter App
    │
    ├─→ Android Users
    │   └─ Play Store → Download Flutter App
    │
    └─→ Web Users
        └─ Web Browser → Flutter Web App

         All connect to ↓

┌─────────────────────────────────────────────┐
│  LOAD BALANCER (nginx or cloud provider)    │
└──────────────────┬──────────────────────────┘
                   │ HTTPS/TLS
                   │
┌──────────────────▼──────────────────────────┐
│  NODE.JS API SERVER (Multiple instances)    │
│  ├─ Instance 1 (port 5000)                  │
│  ├─ Instance 2 (port 5001)                  │
│  └─ Instance 3 (port 5002)                  │
└──────────────────┬──────────────────────────┘
                   │ SQL
                   │
┌──────────────────▼──────────────────────────┐
│  PostgreSQL DATABASE                        │
│  ├─ users table                             │
│  ├─ teacher_profiles table                  │
│  └─ Backups & Replicas                      │
└─────────────────────────────────────────────┘

Additional Services:
├─ Redis (caching)
├─ S3 (file storage)
├─ CDN (static files)
├─ Monitoring (Sentry, New Relic)
├─ Logging (ELK Stack)
└─ CI/CD (GitHub Actions)
```
