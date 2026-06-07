# Teacher Profile Module - Backend Setup Guide

## Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Setup Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your database credentials
nano .env
```

### 3. Database Setup

Make sure PostgreSQL is running and create the database:

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE teacher_finder_db;

# Run the schema (execute the SQL commands in database/schema.sql)
```

### 4. Start the Server

```bash
# Development mode (with auto-reload)
npm run dev

# OR production mode
npm start
```

The server will start on `http://localhost:5000`

## API Routes

### Protected Routes (Require JWT Token)

#### 1. Create Teacher Profile

- **URL**: `POST /api/teacher/profile`
- **Authorization**: Bearer Token (teacher role only)
- **Body**:

```json
{
  "subjects": ["Math", "Physics"],
  "fee_per_hour": 25.5,
  "availability": {
    "days": ["Monday", "Tuesday"],
    "times": "9AM-5PM"
  },
  "bio": "Experienced math teacher"
}
```

- **Success Response**: 201 Created
- **Error Responses**: 400, 403, 409

#### 2. Update Teacher Profile

- **URL**: `PUT /api/teacher/profile`
- **Authorization**: Bearer Token (teacher role only)
- **Body** (all fields optional):

```json
{
  "fee_per_hour": 30.0,
  "bio": "Updated bio"
}
```

- **Success Response**: 200 OK
- **Error Responses**: 400, 403, 404

#### 3. Get Own Profile

- **URL**: `GET /api/teacher/profile`
- **Authorization**: Bearer Token
- **Success Response**: 200 OK
  - Includes teacher's name and email from users table
- **Error Responses**: 404

### Public Routes (No Authentication)

#### 4. Get Teacher Profile by ID

- **URL**: `GET /api/teacher/profile/:id`
- **Authorization**: None required
- **Success Response**: 200 OK
  - Returns public profile info (name, subjects, fee, bio)
- **Error Responses**: 400, 404

## Request/Response Examples

### Create Profile - Request

```bash
curl -X POST http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.50,
    "availability": {
      "days": ["Mon", "Wed", "Fri"],
      "times": "2PM-6PM"
    },
    "bio": "I have 10 years of teaching experience"
  }'
```

### Create Profile - Response (201 Created)

```json
{
  "message": "Teacher profile created successfully",
  "profile": {
    "id": 12,
    "user_id": 5,
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.5,
    "availability": {
      "days": ["Mon", "Wed", "Fri"],
      "times": "2PM-6PM"
    },
    "bio": "I have 10 years of teaching experience",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Own Profile - Response (200 OK)

```json
{
  "message": "Teacher profile retrieved successfully",
  "profile": {
    "id": 12,
    "user_id": 5,
    "name": "John Doe",
    "email": "john@example.com",
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.50,
    "availability": {...},
    "bio": "I have 10 years of teaching experience",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Public Profile - Response (200 OK)

```json
{
  "message": "Teacher profile retrieved successfully",
  "profile": {
    "id": 12,
    "user_id": 5,
    "name": "John Doe",
    "subjects": ["Mathematics", "Physics"],
    "fee_per_hour": 25.5,
    "bio": "I have 10 years of teaching experience",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

## Error Responses

### 400 Bad Request

```json
{
  "error": "Subjects array is required and cannot be empty"
}
```

### 403 Forbidden

```json
{
  "error": "Only teachers can create profiles"
}
```

### 404 Not Found

```json
{
  "error": "Teacher profile not found"
}
```

### 409 Conflict

```json
{
  "error": "Profile already exists for this teacher"
}
```

### 401 Unauthorized

```json
{
  "error": "Invalid token"
}
```

## Testing with Postman

1. Import collection from `postman_collection.json` (if provided)
2. Set Postman environment variable:
   - `token`: Your JWT token from login
3. Test each endpoint:
   - POST /api/teacher/profile (Create)
   - GET /api/teacher/profile (Get own)
   - PUT /api/teacher/profile (Update)
   - GET /api/teacher/profile/5 (Get by ID)

## Troubleshooting

### Connection Refused

- Ensure PostgreSQL is running: `psql --version`
- Check DB credentials in .env file
- Verify database exists: `psql -l`

### JWT Token Errors

- Token must be in format: `Authorization: Bearer <token>`
- Check that JWT_SECRET in .env matches your login module
- Verify token is not expired

### Profile Already Exists Error

- Each teacher can only have one profile
- Use PUT endpoint to update existing profile

### CORS Errors

- Check frontend URL in CORS configuration
- Update CORS settings in server.js if needed

## File Descriptions

- **server.js**: Express server setup and middleware configuration
- **db.js**: PostgreSQL connection pool
- **middleware/authMiddleware.js**: JWT token verification
- **routes/teacherRoutes.js**: All teacher profile endpoints
- **.env**: Environment variables (create from .env.example)
- **package.json**: Node.js dependencies

## Next Steps

1. Frontend integration with Flutter
2. Add teacher profile picture upload
3. Implement advanced scheduling
4. Add rating system
5. Implement search functionality
