# Teacher Profile Module - Complete Implementation Guide

## Backend Structure

```
backend/
├── server.js                 # Main Express server
├── db.js                     # PostgreSQL connection pool
├── middleware/
│   └── authMiddleware.js     # JWT token verification
├── routes/
│   └── teacherRoutes.js      # Teacher profile routes
└── .env                      # Environment variables
```

## Backend Setup

### 1. Environment Variables (.env)

```env
# Database
DB_USER=your_db_user
DB_HOST=localhost
DB_NAME=teacher_finder_db
DB_PASSWORD=your_password
DB_PORT=5432

# Server
PORT=5000

# JWT
JWT_SECRET=your_super_secret_jwt_key_here_change_this_in_production
```

### 2. Database Schema (PostgreSQL)

The following tables should already exist:

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL CHECK (role IN ('student', 'teacher')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Teacher profiles table
CREATE TABLE teacher_profiles (
  id SERIAL PRIMARY KEY,
  user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  subjects JSONB NOT NULL,              -- Array of subject strings
  fee_per_hour DECIMAL(10, 2) NOT NULL,
  availability JSONB,                   -- Schedule/availability info
  bio TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_teacher_profiles_user_id ON teacher_profiles(user_id);
```

### 3. API Endpoints

#### POST /api/teacher/profile - Create Profile (Protected)

**Authentication**: Required (Bearer Token)
**Authorization**: User must have role = 'teacher'

**Request Body**:

```json
{
  "subjects": ["Mathematics", "Physics"],
  "fee_per_hour": 25.5,
  "availability": {
    "days": ["Monday", "Tuesday", "Wednesday"],
    "times": "9AM-5PM"
  },
  "bio": "Experienced teacher with 5 years..."
}
```

**Response** (201 Created):

```json
{
  "message": "Teacher profile created successfully",
  "profile": {
    "id": 1,
    "user_id": 5,
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.50,
    "availability": {...},
    "bio": "Experienced teacher with 5 years...",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
}
```

#### PUT /api/teacher/profile - Update Profile (Protected)

**Authentication**: Required (Bearer Token)
**Authorization**: User must have role = 'teacher'

**Request Body** (all fields optional):

```json
{
  "subjects": ["Mathematics"],
  "fee_per_hour": 30.0
}
```

**Response** (200 OK):

```json
{
  "message": "Teacher profile updated successfully",
  "profile": { ...updated profile... }
}
```

#### GET /api/teacher/profile - Get Own Profile (Protected)

**Authentication**: Required (Bearer Token)

**Response** (200 OK):

```json
{
  "message": "Teacher profile retrieved successfully",
  "profile": {
    "id": 1,
    "user_id": 5,
    "name": "John Doe",
    "email": "john@example.com",
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.5,
    "bio": "..."
  }
}
```

#### GET /api/teacher/profile/:id - Get Public Profile (Public)

**Authentication**: Not required

**Response** (200 OK):

```json
{
  "message": "Teacher profile retrieved successfully",
  "profile": {
    "id": 1,
    "user_id": 5,
    "name": "John Doe",
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.5,
    "bio": "..."
  }
}
```

## Flutter Structure

```
lib/
├── main.dart
├── models/
│   └── teacher_profile_model.dart
├── screens/
│   └── teacher_profile_screen.dart
├── services/
│   └── teacher_api_service.dart
├── utils/
│   └── api_constants.dart
└── examples/
    └── integration_example.dart
```

## Flutter Implementation Details

### 1. TeacherProfileScreen Widget

- **Type**: StatefulWidget
- **Features**:
  - Form validation
  - Load existing profile on init
  - Create new profile
  - Update existing profile
  - Success/Error snackbars
  - Loading states

### 2. TeacherApiService

- Static methods for all API operations
- JWT token handling in headers
- Proper error handling and status codes
- Parses JSON responses

### 3. TeacherProfile Model

- `fromJson()`: Converts API response to model
- `toJson()`: Converts model to request body
- `copyWith()`: Create modified copies

## Usage Example in Flutter

```dart
// Navigate to profile screen with token
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TeacherProfileScreen(
      token: 'jwt_token_here',
      userName: 'John Doe',
    ),
  ),
);
```

## Integration Checklist

### Backend

- [ ] Create `backend/` directory structure
- [ ] Copy `server.js`, `db.js` to backend root
- [ ] Copy `middleware/authMiddleware.js`
- [ ] Copy `routes/teacherRoutes.js`
- [ ] Create `.env` file with database credentials
- [ ] Install dependencies: `npm install express cors dotenv pg jsonwebtoken`
- [ ] Ensure PostgreSQL is running
- [ ] Create database tables with provided schema
- [ ] Test endpoints with Postman/Insomnia

### Frontend (Flutter)

- [ ] Update `pubspec.yaml` if needed (http package should be included)
- [ ] Verify API constants point to correct backend URL
- [ ] Update `TeacherProfileScreen` usage in your main navigation
- [ ] Test with a valid JWT token
- [ ] Handle network errors gracefully

## Testing API Endpoints

### Using cURL

Create profile:

```bash
curl -X POST http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subjects": ["Math", "Physics"],
    "fee_per_hour": 25.50,
    "availability": {"days": ["Mon-Fri"]},
    "bio": "Experienced teacher"
  }'
```

Get own profile:

```bash
curl -X GET http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

Get public profile:

```bash
curl -X GET http://localhost:5000/api/teacher/profile/5
```

## Error Handling

All endpoints return appropriate HTTP status codes:

- **201**: Profile created successfully
- **200**: Request successful
- **400**: Bad request (validation error)
- **401**: Unauthorized (invalid/missing token)
- **403**: Forbidden (insufficient permissions)
- **404**: Not found (profile doesn't exist)
- **500**: Server error

## Security Considerations

1. **JWT Validation**: authMiddleware verifies and decodes JWT tokens
2. **Role-based Access**: Only users with role='teacher' can create/update profiles
3. **Data Validation**: Input validation on all fields
4. **SQL Injection Prevention**: Using parameterized queries
5. **CORS Configuration**: Restrict to frontend origin in production
6. **Environment Variables**: Sensitive data stored in .env file

## Future Enhancements

1. Add file upload for teacher profile picture
2. Implement advanced availability scheduling
3. Add ratings/reviews system
4. Implement search and filtering
5. Add profile verification/approval workflow
6. Implement soft deletes for profiles
7. Add activity logging/audit trail
