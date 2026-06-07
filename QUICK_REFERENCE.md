# Quick Reference - Teacher Profile Module

## 🚀 Quick Start (Copy & Paste)

### 1. Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your database credentials
# DB_HOST=localhost
# DB_PORT=5432
# DB_USER=postgres
# DB_PASSWORD=your_password
# DB_NAME=teacher_finder_db
# JWT_SECRET=your_secret_key

# Start server
npm start
```

### 2. Database Setup

```bash
# Create PostgreSQL database
psql -U postgres -f ../database/schema.sql
```

### 3. Flutter Setup

```bash
cd teacher_finding_app

# Get dependencies
flutter pub get

# Update API URL if needed (android emulator)
# Edit lib/utils/api_constants.dart
# Change: static const String baseUrl = 'http://10.0.2.2:5000';
```

---

## 📝 Code Snippets

### Backend: Mount Teacher Routes (already done in server.js)

```javascript
const teacherRoutes = require("./teacherRoutes");

app.use("/api/teacher", teacherRoutes);
```

### Flutter: Navigate to Profile Screen

```dart
import 'package:teacher_finding_app/screens/teacher_profile_screen.dart';

// In your navigation code
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TeacherProfileScreen(
      token: jwtToken,
      existingProfile: null,  // null for create, or TeacherProfile for edit
    ),
  ),
);
```

### Flutter: Get Token from Login

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teacher_finding_app/utils/api_constants.dart';

Future<void> loginTeacher(String email, String password) async {
  final response = await http.post(
    Uri.parse(ApiConstants.loginEndpoint),
    headers: ApiConstants.jsonHeaders,
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final token = jsonResponse['token'];
    final role = jsonResponse['user']['role'];

    if (role == 'teacher') {
      // Navigate to teacher profile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TeacherProfileScreen(token: token),
        ),
      );
    }
  }
}
```

### Flutter: Store Token Securely (Optional)

```dart
// Add to pubspec.yaml:
// flutter_secure_storage: ^9.0.0

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Store token after login
await storage.write(key: 'jwt_token', value: token);

// Retrieve token when needed
final token = await storage.read(key: 'jwt_token');

// Delete token on logout
await storage.delete(key: 'jwt_token');
```

---

## 🧪 Testing with Postman

### 1. Setup Environment

- Name: "Teacher Finder"
- Variables:
  - `base_url`: `http://localhost:5000`
  - `token`: (empty, will fill after login)

### 2. Register as Teacher

```
POST {{base_url}}/api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "teacher"
}
```

### 3. Login

```
POST {{base_url}}/api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Save token from response!**

### 4. Create Profile

```
POST {{base_url}}/api/teacher/profile
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "subjects": ["Math", "Physics"],
  "fee_per_hour": 25.50,
  "availability": {
    "Monday": ["9:00-12:00", "14:00-17:00"],
    "Wednesday": ["10:00-13:00"]
  },
  "bio": "Experienced math tutor"
}
```

### 5. Get Own Profile

```
GET {{base_url}}/api/teacher/profile
Authorization: Bearer {{token}}
```

### 6. Update Profile

```
PUT {{base_url}}/api/teacher/profile
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "fee_per_hour": 30.00,
  "subjects": ["Math", "Physics", "Chemistry"]
}
```

### 7. Get Public Profile

```
GET {{base_url}}/api/teacher/profile/550e8400-e29b-41d4-a716-446655440000
```

---

## 🔐 Authorization Header Format

**For Protected Routes:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJyb2xlIjoidGVhY2hlciIsImlhdCI6MTcxNjIwMDYwMCwiZXhwIjoxNzE2ODA1NDAwfQ.signature
```

**For Public Routes:**

```
(No Authorization header needed)
```

---

## 📊 Response Examples

### Success: Create Profile (201)

```json
{
  "success": true,
  "message": "Teacher profile created successfully",
  "profile": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "subjects": ["Math", "Physics"],
    "fee_per_hour": 25.5,
    "availability": { "Monday": ["9:00-12:00"] },
    "bio": "Experienced tutor",
    "created_at": "2026-05-20T10:30:00.000Z",
    "updated_at": "2026-05-20T10:30:00.000Z"
  }
}
```

### Error: Forbidden (403)

```json
{
  "success": false,
  "message": "Only teachers can create a teacher profile"
}
```

### Error: Unauthorized (401)

```json
{
  "success": false,
  "message": "Authorization header missing. Please provide a Bearer token."
}
```

---

## 🛠️ Environment Variables

Create `backend/.env`:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_secure_password_here
DB_NAME=teacher_finder_db

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRY=7d

# Server
PORT=5000
NODE_ENV=development
```

---

## 📁 File Paths

| Purpose         | Path                                      |
| --------------- | ----------------------------------------- |
| Teacher Routes  | `backend/teacherRoutes.js`                |
| Main Server     | `backend/server.js`                       |
| API Service     | `lib/services/teacher_api_service.dart`   |
| Profile Screen  | `lib/screens/teacher_profile_screen.dart` |
| Data Model      | `lib/models/teacher_profile_model.dart`   |
| API Constants   | `lib/utils/api_constants.dart`            |
| Database Schema | `database/schema.sql`                     |
| .env Template   | `backend/.env.example`                    |
| Postman Guide   | `backend/POSTMAN_TESTING_GUIDE.md`        |

---

## 🚨 Common Mistakes

### ❌ Wrong: Missing Bearer in Authorization

```
Authorization: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

✅ Correct:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### ❌ Wrong: Not a teacher role

```json
{ "role": "student" }
```

✅ Correct:

```json
{ "role": "teacher" }
```

### ❌ Wrong: Subjects not an array

```json
{ "subjects": "Math, Physics" }
```

✅ Correct:

```json
{ "subjects": ["Math", "Physics"] }
```

### ❌ Wrong: Fee as string

```json
{ "fee_per_hour": "25.50" }
```

✅ Correct:

```json
{ "fee_per_hour": 25.5 }
```

### ❌ Wrong: Missing BASE_URL in Flutter

```dart
// Will fail!
http.post(Uri.parse('/api/teacher/profile'), ...)
```

✅ Correct:

```dart
http.post(
  Uri.parse(ApiConstants.createProfileEndpoint),
  ...
)
```

---

## 🔍 Debugging

### Check Backend Running

```bash
curl http://localhost:5000/health
```

### Check Database Connection

```bash
psql -U postgres -d teacher_finder_db -c "SELECT COUNT(*) FROM users;"
```

### View Backend Logs

```bash
# Terminal should show:
✓ Connected to PostgreSQL database
Teacher Finder API Server running on: http://localhost:5000
```

### Test Flutter API Call

```dart
// Add to Flutter to test
import 'package:teacher_finding_app/services/teacher_api_service.dart';

// In your test widget
ElevatedButton(
  onPressed: () async {
    try {
      final profile = await TeacherApiService.getTeacherProfile(
        userId: '550e8400-e29b-41d4-a716-446655440000'
      );
      print('Success: $profile');
    } catch (e) {
      print('Error: $e');
    }
  },
  child: const Text('Test API'),
)
```

---

## 📚 Documentation

| File                                    | Purpose                         |
| --------------------------------------- | ------------------------------- |
| `TEACHER_PROFILE_MODULE_README.md`      | Complete integration guide      |
| `PROJECT_STRUCTURE.md`                  | Folder structure & organization |
| `MODULE_2_SUMMARY.md`                   | What was built summary          |
| `backend/POSTMAN_TESTING_GUIDE.md`      | API testing with examples       |
| `backend/teacherRoutes.js`              | Inline code comments            |
| `lib/examples/integration_example.dart` | Flutter usage examples          |

---

## ⏱️ Estimated Time

| Task                  | Time       |
| --------------------- | ---------- |
| Backend setup         | 5 min      |
| Database setup        | 2 min      |
| Flutter setup         | 3 min      |
| Test register/login   | 5 min      |
| Test profile creation | 5 min      |
| **Total**             | **20 min** |

---

## ✅ Verification Checklist

- [ ] Backend running on http://localhost:5000
- [ ] Database schema imported successfully
- [ ] Can register as teacher via API
- [ ] Can login and receive JWT token
- [ ] Can create teacher profile with token
- [ ] Can get own profile
- [ ] Can get public profile without auth
- [ ] Flutter app compiles without errors
- [ ] http package installed
- [ ] TeacherProfileScreen navigates and shows form
- [ ] Form submits and shows SnackBar

---

## 🎯 Next Features to Build

1. **Student Search** - Search teachers by subject
2. **Booking System** - Schedule sessions
3. **Messaging** - Real-time chat
4. **Payments** - Process payments
5. **Reviews** - Rating system
