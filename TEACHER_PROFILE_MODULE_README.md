# Teacher Profile Module - Integration Guide

## Overview

This module provides complete teacher profile management for the Teacher Finder app with:

- Backend API routes (Node.js/Express)
- Flutter UI with form validation
- JWT authentication and authorization
- Database integration (PostgreSQL)

---

## Folder Structure

```
teacher_finding_app/
├── backend/
│   ├── db.js                          # PostgreSQL connection pool
│   ├── authRoutes.js                  # Authentication endpoints
│   ├── authMiddleware.js              # JWT verification middleware
│   ├── teacherRoutes.js               # Teacher profile routes ✨ NEW
│   ├── server.js                      # Main Express app (updated)
│   ├── package.json                   # Dependencies
│   ├── .env.example                   # Environment variables template
│   └── POSTMAN_TESTING_GUIDE.md       # API testing guide
│
├── database/
│   └── schema.sql                     # PostgreSQL schema with users & teacher_profiles tables
│
└── teacher_finding_app/               # Flutter App
    ├── lib/
    │   ├── main.dart                  # App entry point
    │   ├── screens/
    │   │   └── teacher_profile_screen.dart     # ✨ NEW - Profile form UI
    │   ├── services/
    │   │   └── teacher_api_service.dart        # ✨ NEW - API calls
    │   ├── models/
    │   │   └── teacher_profile_model.dart      # ✨ NEW - Data model
    │   ├── utils/
    │   │   └── api_constants.dart              # ✨ NEW - API endpoints
    │   └── examples/
    │       └── integration_example.dart        # ✨ NEW - Usage examples
    └── pubspec.yaml                   # Dependencies (updated with http)
```

---

## Setup Instructions

### Step 1: Install Backend Dependencies

```bash
cd backend
npm install
```

### Step 2: Create .env File

```bash
cp .env.example .env
```

Edit `.env` with your PostgreSQL credentials:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=teacher_finder_db
JWT_SECRET=your_secret_key_here
PORT=5000
```

### Step 3: Setup Database

```bash
psql -U postgres -f ../database/schema.sql
```

### Step 4: Start Backend Server

```bash
npm start
# Server runs on http://localhost:5000
```

### Step 5: Update Flutter pubspec.yaml

Already done! The `http` package has been added. Run:

```bash
flutter pub get
```

### Step 6: Update API_BASE_URL in Flutter

Edit `lib/utils/api_constants.dart` if your backend is on a different host:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:5000';
```

For Android emulator (connects to host machine):

```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

---

## Backend API Endpoints

### Create Teacher Profile

```
POST /api/teacher/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "subjects": ["Math", "Physics"],
  "fee_per_hour": 25.50,
  "availability": {
    "Monday": ["9:00-12:00", "14:00-17:00"],
    "Wednesday": ["10:00-13:00"]
  },
  "bio": "Experienced tutor with 10 years of teaching"
}
```

### Update Teacher Profile

```
PUT /api/teacher/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "subjects": ["Math", "Physics", "Chemistry"],
  "fee_per_hour": 30.00
}
```

### Get Own Profile

```
GET /api/teacher/profile
Authorization: Bearer <jwt_token>
```

### Get Any Teacher's Profile (Public)

```
GET /api/teacher/profile/{user_id}
```

---

## Flutter Integration

### 1. Import Required Classes

```dart
import 'package:teacher_finding_app/screens/teacher_profile_screen.dart';
import 'package:teacher_finding_app/services/teacher_api_service.dart';
import 'package:teacher_finding_app/models/teacher_profile_model.dart';
```

### 2. Navigate to Profile Screen

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TeacherProfileScreen(
      token: jwtToken,
      existingProfile: null,  // null for new profile, or TeacherProfile for edit
    ),
  ),
);
```

### 3. Handle Navigation Route (in main.dart)

```dart
routes: {
  '/teacher-profile': (context) => TeacherProfileScreen(
    token: ModalRoute.of(context)!.settings.arguments as String,
  ),
}
```

### 4. Get Token from Authentication

After login, store the JWT token:

```dart
// In your login method
final response = await http.post(...);
final token = jsonResponse['token'];

// Store token (consider using secure_storage)
// Then navigate to profile screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TeacherProfileScreen(token: token),
  ),
);
```

---

## Error Handling

### Common Errors and Solutions

| Error              | Cause                  | Solution                                           |
| ------------------ | ---------------------- | -------------------------------------------------- |
| Connection refused | Backend not running    | Run `npm start` in backend folder                  |
| 403 Forbidden      | User is not a teacher  | Check user role in JWT token                       |
| 409 Conflict       | Profile already exists | Use PUT to update or create new user               |
| 401 Unauthorized   | Invalid/expired token  | Login again to get new token                       |
| Invalid JSON       | Malformed request data | Check field types (subjects = array, fee = number) |

---

## Testing

### Option 1: Postman

1. Use `POSTMAN_TESTING_GUIDE.md` in backend folder
2. Create a new request with your JWT token from login

### Option 2: Flutter App

1. Implement a login screen first to get JWT token
2. Navigate to TeacherProfileScreen
3. Fill in the form and submit
4. Check SnackBar for success/error message

### Option 3: cURL (Command Line)

```bash
# Create profile (requires valid JWT token)
curl -X POST http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subjects": ["Math", "Physics"],
    "fee_per_hour": 25.50,
    "availability": {"Monday": ["9:00-12:00"]},
    "bio": "Experienced teacher"
  }'

# Get profile
curl -X GET http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get public teacher profile (no auth needed)
curl -X GET http://localhost:5000/api/teacher/profile/550e8400-e29b-41d4-a716-446655440000
```

---

## Security Considerations

1. **JWT Token Storage** - Currently token is passed via arguments
   - Consider using `flutter_secure_storage` to persist securely
   - Or use provider/state management to store in memory

2. **Environment Variables** - Never commit .env file
   - .env.example shows required variables
   - Each developer creates their own .env

3. **CORS Configuration** - Backend allows all origins in development
   - In production, set specific frontend URL:

   ```javascript
   origin: "https://yourdomain.com";
   ```

4. **Password & Tokens** - All passwords are hashed with bcrypt
   - JWT tokens expire after 7 days
   - Implement token refresh mechanism for long sessions

---

## File Descriptions

### Backend Files

- **teacherRoutes.js** - Express router with 4 protected routes for teacher profiles
- **server.js** (updated) - Now mounts teacherRoutes at `/api/teacher`

### Flutter Files

- **teacher_profile_screen.dart** - Main UI widget with form validation
- **teacher_api_service.dart** - HTTP client for API calls
- **teacher_profile_model.dart** - Data model with JSON serialization
- **api_constants.dart** - Centralized API endpoints and headers
- **integration_example.dart** - Example of how to use the module

---

## Next Steps

1. Implement student browsing/search functionality
2. Add ratings and reviews for teachers
3. Implement booking/session management
4. Add payment integration
5. Push notifications for messages
6. Teacher availability calendar with date picker
7. Advanced search with filters

---

## Support Files

- See `POSTMAN_TESTING_GUIDE.md` for complete API testing examples
- See `database/schema.sql` for database schema details
- See `backend/.env.example` for all required environment variables
