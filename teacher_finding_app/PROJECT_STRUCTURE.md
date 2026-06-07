# Teacher Finding App - PROJECT STRUCTURE

## Complete Project Organization

```
teacher_finding_app/
│
├── README.md                          # Main project README
├── TEACHER_PROFILE_MODULE.md          # Module documentation
├── pubspec.yaml                       # Flutter dependencies
├── pubspec.lock
├── analysis_options.yaml              # Dart analysis config
│
├── backend/                           # ✨ NEW: Node.js/Express Backend
│   ├── server.js                      # Main Express server
│   ├── db.js                          # PostgreSQL connection
│   ├── package.json                   # NPM dependencies
│   ├── .env.example                   # Environment template
│   ├── README.md                      # Backend setup guide
│   │
│   ├── middleware/
│   │   └── authMiddleware.js          # JWT verification
│   │
│   └── routes/
│       └── teacherRoutes.js           # Teacher profile endpoints
│           ├── POST /api/teacher/profile (create)
│           ├── PUT /api/teacher/profile (update)
│           ├── GET /api/teacher/profile (own)
│           └── GET /api/teacher/profile/:id (public)
│
├── database/                          # Database scripts
│   └── schema.sql
│
├── lib/                               # Flutter app source
│   ├── main.dart
│   │
│   ├── models/
│   │   └── teacher_profile_model.dart
│   │       ├── TeacherProfile class
│   │       ├── fromJson() method
│   │       ├── toJson() method
│   │       └── copyWith() method
│   │
│   ├── screens/
│   │   └── teacher_profile_screen.dart
│   │       ├── TeacherProfileScreen (StatefulWidget)
│   │       ├── Form with validation
│   │       ├── Subjects (comma-separated)
│   │       ├── Fee per hour (numeric)
│   │       ├── Availability (text input)
│   │       └── Bio (multiline)
│   │
│   ├── services/
│   │   └── teacher_api_service.dart
│   │       ├── createProfile() - POST request
│   │       ├── updateProfile() - PUT request
│   │       ├── getMyProfile() - GET own profile
│   │       └── getTeacherProfile() - GET public profile
│   │
│   ├── utils/
│   │   └── api_constants.dart
│   │       ├── baseUrl
│   │       ├── endpoints
│   │       └── headers with JWT
│   │
│   └── examples/
│       └── integration_example.dart   # Usage examples
│           ├── TeacherProfileViewScreen
│           ├── Navigation examples
│           └── API usage patterns
│
├── test/
│   └── widget_test.dart
│
├── android/
│   └── (Android-specific files)
│
├── ios/
│   └── (iOS-specific files)
│
├── web/
│   └── (Web build files)
│
├── macos/
│   └── (macOS-specific files)
│
├── windows/
│   └── (Windows-specific files)
│
└── linux/
    └── (Linux-specific files)
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Frontend)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  TeacherProfileScreen                                        │
│  ├── Renders form with inputs                              │
│  ├── Validates form data                                    │
│  └── Calls TeacherApiService                               │
│                                                               │
│  TeacherApiService                                           │
│  ├── Serializes data to JSON                               │
│  ├── Adds JWT token to headers                             │
│  └── Makes HTTP requests                                    │
│                                                               │
│  API Endpoints Used:                                         │
│  • POST /api/teacher/profile                                │
│  • PUT /api/teacher/profile                                 │
│  • GET /api/teacher/profile                                 │
│  • GET /api/teacher/profile/:id                             │
│                                                               │
└─────────────────────────────────────────────────────────────┘
         ↓ HTTPS Requests with JWT Token ↓
┌─────────────────────────────────────────────────────────────┐
│               EXPRESS.JS SERVER (Backend)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Route: POST /api/teacher/profile                           │
│  ├── authMiddleware (verify JWT)                            │
│  ├── Check role === 'teacher'                               │
│  ├── Validate input fields                                  │
│  └── INSERT into teacher_profiles table                     │
│                                                               │
│  Route: PUT /api/teacher/profile                            │
│  ├── authMiddleware (verify JWT)                            │
│  ├── Check role === 'teacher'                               │
│  ├── Validate input fields                                  │
│  └── UPDATE teacher_profiles table                          │
│                                                               │
│  Route: GET /api/teacher/profile                            │
│  ├── authMiddleware (verify JWT)                            │
│  └── SELECT from teacher_profiles                           │
│      JOIN users ON user_id                                  │
│                                                               │
│  Route: GET /api/teacher/profile/:id (Public)               │
│  ├── No auth required                                        │
│  └── SELECT from teacher_profiles                           │
│      JOIN users ON user_id                                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
         ↓ SQL Queries ↓
┌─────────────────────────────────────────────────────────────┐
│           POSTGRESQL DATABASE                               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  users table                                                 │
│  ├── id (PK)                                                │
│  ├── name                                                    │
│  ├── email                                                   │
│  ├── password_hash                                           │
│  ├── role (teacher/student)                                │
│  └── timestamps                                              │
│                                                               │
│  teacher_profiles table                                      │
│  ├── id (PK)                                                │
│  ├── user_id (FK to users)                                  │
│  ├── subjects (JSONB array)                                 │
│  ├── fee_per_hour (decimal)                                 │
│  ├── availability (JSONB object)                            │
│  ├── bio (text)                                              │
│  └── timestamps                                              │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## API Specification Summary

| Method | Endpoint                 | Auth | Role    | Purpose            |
| ------ | ------------------------ | ---- | ------- | ------------------ |
| POST   | /api/teacher/profile     | Yes  | teacher | Create new profile |
| PUT    | /api/teacher/profile     | Yes  | teacher | Update own profile |
| GET    | /api/teacher/profile     | Yes  | any     | Get own profile    |
| GET    | /api/teacher/profile/:id | No   | none    | Get public profile |

## Key Features Implemented

### Backend (Node.js/Express)

- ✅ JWT authentication middleware
- ✅ Role-based access control (teacher only)
- ✅ CRUD operations for teacher profiles
- ✅ Data validation
- ✅ Error handling
- ✅ PostgreSQL integration
- ✅ CORS support

### Frontend (Flutter)

- ✅ Form validation
- ✅ Load existing profile on init
- ✅ Create new profile
- ✅ Update existing profile
- ✅ JWT token management
- ✅ Error/success messages
- ✅ Loading states
- ✅ Model with serialization

## Setup Timeline

### Phase 1: Backend Setup (15 minutes)

1. ✅ Create backend directory structure
2. ✅ Install Node.js dependencies
3. ✅ Configure environment variables
4. ✅ Setup PostgreSQL connection
5. ✅ Create database tables

### Phase 2: Backend Testing (10 minutes)

1. ✅ Start Express server
2. ✅ Test endpoints with Postman/cURL
3. ✅ Verify JWT authentication
4. ✅ Check error handling

### Phase 3: Flutter Integration (10 minutes)

1. ✅ Update API constants
2. ✅ Import TeacherProfileScreen
3. ✅ Add route to navigation
4. ✅ Test with valid JWT token

## File Dependencies

```
TeacherProfileScreen
├── TeacherApiService
│   ├── TeacherProfile model
│   └── ApiConstants
├── TeacherProfile model (for type safety)
└── Flutter Material package

TeacherApiService
├── TeacherProfile model
├── ApiConstants
└── http package

TeacherProfile model
└── (No dependencies)

ApiConstants
└── (No dependencies)
```

## Environment Setup

### Backend .env

```
PORT=5000
DB_USER=postgres
DB_HOST=localhost
DB_NAME=teacher_finder_db
DB_PASSWORD=your_password
DB_PORT=5432
JWT_SECRET=your_secret_key
```

### Flutter pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.0 # Already included usually
```

## Database Schema

### users table

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) CHECK (role IN ('student', 'teacher')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### teacher_profiles table

```sql
CREATE TABLE teacher_profiles (
  id SERIAL PRIMARY KEY,
  user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  subjects JSONB NOT NULL,
  fee_per_hour DECIMAL(10, 2) NOT NULL,
  availability JSONB,
  bio TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## HTTP Status Codes Used

- **201 Created**: Profile successfully created
- **200 OK**: Request successful
- **400 Bad Request**: Invalid input data
- **401 Unauthorized**: Missing/invalid JWT token
- **403 Forbidden**: User doesn't have permission
- **404 Not Found**: Profile doesn't exist
- **409 Conflict**: Profile already exists
- **500 Internal Server Error**: Server error

## Security Features

1. **JWT Token Verification**: All protected routes require valid JWT
2. **Role-Based Access**: Only teachers can create/update profiles
3. **Input Validation**: All fields validated before processing
4. **Parameterized Queries**: Protection against SQL injection
5. **CORS Configuration**: Restrict cross-origin requests
6. **Environment Variables**: Sensitive data not hardcoded

## Next Steps for Enhancement

- [ ] Add profile picture upload
- [ ] Implement advanced scheduling UI
- [ ] Add ratings and reviews
- [ ] Create search and filtering
- [ ] Add profile verification workflow
- [ ] Implement activity logging
- [ ] Create admin dashboard
- [ ] Add analytics

---

**Module Status**: ✅ Complete - Ready for Production
**Last Updated**: January 2024
