# Teacher Finder App - Complete Project Structure

## Full Directory Tree

```
teacher_finding_app/
├── teacher_finding_app/                    # Flutter Frontend
│   ├── android/                            # Android build files
│   ├── ios/                                # iOS build files
│   ├── linux/                              # Linux build files
│   ├── macos/                              # macOS build files
│   ├── windows/                            # Windows build files
│   ├── web/                                # Web build files
│   ├── test/
│   │   └── widget_test.dart                # Widget tests
│   ├── lib/
│   │   ├── main.dart                       # App entry point
│   │   │
│   │   ├── screens/                        # UI Screens
│   │   │   ├── auth_screen.dart            # (TODO) Login/Register
│   │   │   ├── dashboard_screen.dart       # (TODO) Main dashboard
│   │   │   └── teacher_profile_screen.dart # ✨ MODULE 2 - Teacher profile form
│   │   │
│   │   ├── services/                       # API Service Layer
│   │   │   ├── auth_service.dart           # (TODO) Auth API calls
│   │   │   └── teacher_api_service.dart    # ✨ MODULE 2 - Teacher profile API
│   │   │
│   │   ├── models/                         # Data Models
│   │   │   ├── user_model.dart             # (TODO) User data model
│   │   │   └── teacher_profile_model.dart  # ✨ MODULE 2 - Profile model
│   │   │
│   │   ├── utils/                          # Utilities & Constants
│   │   │   ├── api_constants.dart          # ✨ MODULE 2 - API endpoints
│   │   │   ├── theme.dart                  # (TODO) App theming
│   │   │   └── validators.dart             # (TODO) Form validation
│   │   │
│   │   ├── widgets/                        # Reusable Widgets
│   │   │   └── custom_button.dart          # (TODO) Custom button
│   │   │
│   │   └── examples/
│   │       └── integration_example.dart    # ✨ MODULE 2 - Usage examples
│   │
│   ├── pubspec.yaml                        # Dependencies (updated with http)
│   ├── pubspec.lock
│   ├── analysis_options.yaml
│   ├── teacher_finding_app.iml
│   ├── README.md
│   └── .gitignore
│
├── backend/                                # Node.js/Express Backend
│   ├── db.js                               # PostgreSQL connection pool
│   ├── authRoutes.js                       # ✨ MODULE 1 - Auth endpoints
│   ├── authMiddleware.js                   # ✨ MODULE 1 - JWT middleware
│   ├── teacherRoutes.js                    # ✨ MODULE 2 - Teacher profile routes
│   ├── server.js                           # Express app (updated with teacher routes)
│   ├── package.json                        # Node.js dependencies
│   ├── .env                                # Environment variables (add after copying .env.example)
│   ├── .env.example                        # Environment template
│   ├── .gitignore                          # Ignore node_modules, .env
│   ├── POSTMAN_TESTING_GUIDE.md            # API testing guide (updated with teacher endpoints)
│   └── node_modules/                       # Dependencies (after npm install)
│
├── database/
│   └── schema.sql                          # PostgreSQL schema
│       ├── users table
│       ├── teacher_profiles table
│       └── (TODO) bookings, reviews, payments
│
├── TEACHER_PROFILE_MODULE_README.md        # ✨ MODULE 2 - Integration guide
├── README.md                               # Project overview
└── .gitignore                              # Git ignore file
```

---

## Files Created in MODULE 2 (Teacher Profile)

### Backend Files (Node.js)

✨ **New Files:**

- `backend/teacherRoutes.js` - Teacher profile API routes
- `backend/POSTMAN_TESTING_GUIDE.md` - Updated with teacher endpoints

🔄 **Modified Files:**

- `backend/server.js` - Added teacher routes mount
- `backend/package.json` - Already had all dependencies

### Flutter Files (Dart)

✨ **New Files:**

- `lib/screens/teacher_profile_screen.dart` - Main UI component
- `lib/services/teacher_api_service.dart` - API service
- `lib/models/teacher_profile_model.dart` - Data model
- `lib/utils/api_constants.dart` - API endpoints
- `lib/examples/integration_example.dart` - Integration examples

🔄 **Modified Files:**

- `pubspec.yaml` - Added `http: ^1.1.0` dependency

### Documentation

✨ **New Files:**

- `TEACHER_PROFILE_MODULE_README.md` - Complete integration guide

---

## Module Breakdown

### MODULE 1: Authentication ✅ COMPLETE

**Backend:**

- `authRoutes.js` - Register & Login
- `authMiddleware.js` - JWT verification
- `db.js` - Database connection

**Features:**

- User registration with bcrypt hashing
- JWT login (7-day expiry)
- Protected routes with middleware

---

### MODULE 2: Teacher Profile ✅ COMPLETE

**Backend:**

- `teacherRoutes.js` - Create/Update/Get profiles
- Protected routes with role-based access
- Database joins for user info

**Flutter:**

- `TeacherProfileScreen` - Form with validation
- `TeacherApiService` - HTTP client
- `TeacherProfileModel` - Data serialization
- Full error handling with SnackBars

**Features:**

- Create teacher profile (teacher role only)
- Update profile (partial updates supported)
- Get own profile with user details
- Get public teacher profiles

---

### MODULE 3: Student Search & Browse (TODO)

**Would Include:**

- Search/filter teachers by subject
- Teacher browsing page
- Rating/review display
- Student profile

---

### MODULE 4: Booking & Scheduling (TODO)

**Would Include:**

- View teacher availability
- Book sessions
- Calendar view
- Session history

---

### MODULE 5: Messaging (TODO)

**Would Include:**

- Real-time chat
- WebSocket integration
- Message history
- Notifications

---

## Database Schema

### Users Table

```sql
CREATE TABLE users (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role         user_role NOT NULL,  -- 'student' or 'teacher'
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Teacher Profiles Table

```sql
CREATE TABLE teacher_profiles (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID NOT NULL UNIQUE REFERENCES users(id),
    subjects     TEXT[] NOT NULL DEFAULT '{}',
    fee_per_hour DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    availability JSONB,
    bio          TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## Environment Setup

### Backend .env

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=teacher_finder_db
JWT_SECRET=your_secret_key
PORT=5000
NODE_ENV=development
```

### Flutter API Constants

Edit `lib/utils/api_constants.dart`:

```dart
static const String baseUrl = 'http://localhost:5000';  // Change to your backend URL
```

For Android emulator:

```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

---

## Dependencies

### Backend (Node.js)

```json
{
  "express": "^4.18.2",
  "pg": "^8.11.3",
  "bcrypt": "^5.1.1",
  "jsonwebtoken": "^9.1.2",
  "cors": "^2.8.5",
  "dotenv": "^16.3.1"
}
```

### Frontend (Flutter)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
```

---

## Quick Start Commands

### Backend

```bash
cd backend
npm install
npm start
# Server runs on http://localhost:5000
```

### Frontend

```bash
cd teacher_finding_app
flutter pub get
flutter run
```

### Database

```bash
psql -U postgres -f database/schema.sql
```

---

## Testing

### API Testing (Postman)

See `backend/POSTMAN_TESTING_GUIDE.md` for:

- Complete workflow with screenshots
- All endpoint examples
- Error cases
- cURL commands

### Flutter Testing

1. Implement login screen first
2. Navigate to `TeacherProfileScreen` with JWT token
3. Fill form and submit
4. Check SnackBar for success/error

---

## File Size Reference

```
backend/
├── db.js                          ~2 KB
├── authRoutes.js                  ~7 KB
├── authMiddleware.js              ~3 KB
├── teacherRoutes.js               ~12 KB  ✨ NEW
├── server.js                      ~3 KB (updated)
└── package.json                   ~1 KB

lib/
├── screens/teacher_profile_screen.dart     ~14 KB  ✨ NEW
├── services/teacher_api_service.dart       ~8 KB   ✨ NEW
├── models/teacher_profile_model.dart       ~2 KB   ✨ NEW
└── utils/api_constants.dart                ~1 KB   ✨ NEW
```

---

## Next Development Steps

1. **Authentication UI** - Login/Register screens
2. **State Management** - Provider/Riverpod for token storage
3. **Student Search** - Search & filter teachers
4. **Booking System** - Session scheduling
5. **Payments** - Stripe integration
6. **Reviews** - Rating and feedback system
7. **Messaging** - Real-time chat
8. **Notifications** - Push notifications
9. **Admin Panel** - Dashboard and moderation
10. **Mobile App Store** - Publishing to App Store/Play Store

---

## Security Checklist

- ✅ Passwords hashed with bcrypt (salt 10)
- ✅ JWT tokens with 7-day expiry
- ✅ Protected routes with middleware
- ✅ Role-based access control (teacher/student)
- ✅ Environment variables for secrets
- ⚠️ CORS configured for development (restrict in production)
- ⚠️ HTTPS should be enabled in production
- ⚠️ Secure token storage needed (use flutter_secure_storage)

---

## Support & Documentation

- **Backend API**: `backend/POSTMAN_TESTING_GUIDE.md`
- **Integration Guide**: `TEACHER_PROFILE_MODULE_README.md`
- **Database Schema**: `database/schema.sql`
- **Flutter Examples**: `lib/examples/integration_example.dart`
