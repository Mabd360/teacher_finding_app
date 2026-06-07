# Teacher Profile Module - Quick Start Guide

## 📦 What's Included

This module provides a **complete teacher profile management system** with:

- ✅ **Backend (Node.js/Express)**: 4 REST API endpoints with JWT authentication
- ✅ **Frontend (Flutter)**: Complete profile creation/edit screen
- ✅ **Database Schema**: PostgreSQL table design
- ✅ **Authentication**: JWT token-based security
- ✅ **Error Handling**: Comprehensive error messages

---

## 🚀 Backend Setup (5 minutes)

### Step 1: Install Dependencies

```bash
cd backend
npm install
```

### Step 2: Configure Environment

```bash
cp .env.example .env
# Edit .env with your database credentials
```

### Step 3: Setup Database

```bash
# Create PostgreSQL database
createdb teacher_finder_db

# Run schema.sql to create tables
psql -U postgres -d teacher_finder_db -f ../database/schema.sql
```

### Step 4: Start Server

```bash
npm run dev    # Development with auto-reload
# OR
npm start      # Production mode
```

✅ Backend running on `http://localhost:5000`

---

## 🎨 Flutter Integration (5 minutes)

### Step 1: Update API URL

Edit `lib/utils/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:5000';
```

### Step 2: Add Route

In your main app navigation, add:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TeacherProfileScreen(
      token: jwtToken,
      userName: 'John Doe',
    ),
  ),
);
```

### Step 3: Test with Valid JWT Token

The teacher must have a valid JWT token from login with `role: 'teacher'`

---

## 📡 API Endpoints

### 1️⃣ Create Profile

```http
POST /api/teacher/profile
Authorization: Bearer {JWT_TOKEN}

{
  "subjects": ["Math", "Physics"],
  "fee_per_hour": 25.50,
  "availability": { "days": ["Mon-Fri"], "times": "9AM-5PM" },
  "bio": "Optional bio"
}
```

**Response**: 201 Created

### 2️⃣ Update Profile

```http
PUT /api/teacher/profile
Authorization: Bearer {JWT_TOKEN}

{
  "fee_per_hour": 30.00
}
```

**Response**: 200 OK (only update provided fields)

### 3️⃣ Get Own Profile

```http
GET /api/teacher/profile
Authorization: Bearer {JWT_TOKEN}
```

**Response**: 200 OK (includes name and email)

### 4️⃣ Get Public Profile

```http
GET /api/teacher/profile/5
```

**Response**: 200 OK (no auth required, public info only)

---

## ✨ Features

### Form Validation

- ✅ Subjects required (comma-separated)
- ✅ Fee must be positive number
- ✅ Availability required
- ✅ Bio optional

### Smart Loading

- ✅ Loads existing profile on init
- ✅ Auto-fills form for editing
- ✅ Shows "Create" or "Update" mode

### User Feedback

- ✅ Success/error snackbars
- ✅ Loading spinner during submit
- ✅ Form validation errors
- ✅ Network error handling

### Security

- ✅ JWT token in Authorization header
- ✅ Role-based access (teacher only)
- ✅ Input validation on both sides
- ✅ Secure database queries

---

## 🔍 Testing Guide

### Using cURL

**Create Profile**:

```bash
curl -X POST http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subjects": ["Math", "Physics"],
    "fee_per_hour": 25.50,
    "availability": {"days": ["Mon-Fri"]},
    "bio": "Test"
  }'
```

**Get Profile**:

```bash
curl -X GET http://localhost:5000/api/teacher/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Get Public Profile** (no auth):

```bash
curl -X GET http://localhost:5000/api/teacher/profile/5
```

### Using Postman

1. Create a new collection
2. Set environment variable: `token = YOUR_JWT_TOKEN`
3. Import endpoints from the module documentation
4. Test each endpoint

---

## 📁 File Structure Created

```
backend/
├── server.js                 # Express app
├── db.js                     # Database connection
├── package.json              # Dependencies
├── .env.example              # Config template
├── README.md                 # Backend guide
├── middleware/
│   └── authMiddleware.js     # JWT verification
└── routes/
    └── teacherRoutes.js      # All 4 endpoints

lib/
├── models/
│   └── teacher_profile_model.dart
├── screens/
│   └── teacher_profile_screen.dart
├── services/
│   └── teacher_api_service.dart
└── utils/
    └── api_constants.dart
```

---

## 🐛 Troubleshooting

| Issue                 | Solution                                          |
| --------------------- | ------------------------------------------------- |
| `ECONNREFUSED`        | PostgreSQL not running or wrong credentials       |
| `401 Unauthorized`    | JWT token invalid or missing                      |
| `403 Forbidden`       | User role is not 'teacher'                        |
| `409 Conflict`        | Teacher already has a profile (use PUT to update) |
| Flutter can't connect | Check baseUrl in api_constants.dart               |
| Form validation fails | Ensure all required fields are filled             |

---

## 🔐 Security Checklist

- [ ] Change JWT_SECRET in .env to strong random string
- [ ] Ensure PostgreSQL is password protected
- [ ] Use HTTPS in production (not HTTP)
- [ ] Enable CORS only for your frontend domain
- [ ] Keep .env file out of version control
- [ ] Validate all user inputs
- [ ] Use parameterized queries (already done)
- [ ] Implement rate limiting for API endpoints

---

## 📚 Additional Documentation

- **Backend Details**: See `backend/README.md`
- **Full Module Guide**: See `TEACHER_PROFILE_MODULE.md`
- **Project Structure**: See `PROJECT_STRUCTURE.md`
- **Integration Examples**: See `lib/examples/integration_example.dart`

---

## 🎯 Next Steps

1. ✅ Backend is ready to use
2. ✅ Flutter screen is ready to integrate
3. 🔄 Test endpoints locally
4. 🚀 Deploy to production

---

## 📞 Support

For issues or questions:

1. Check the error message carefully
2. Review the troubleshooting section
3. Check database connections
4. Verify JWT tokens
5. Review the detailed documentation

---

**Status**: ✅ Ready for Production Use
**Version**: 1.0.0
