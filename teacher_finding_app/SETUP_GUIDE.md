# 🎯 COMPLETE SETUP GUIDE - Teacher Finder App

## 📋 Table of Contents

1. [Database Setup](#database-setup)
2. [Backend Setup](#backend-setup)
3. [Seed Data](#seed-data)
4. [Flutter Setup](#flutter-setup)
5. [Testing](#testing)

---

## 🗄️ Database Setup

### Step 1: Ensure PostgreSQL is Running

```powershell
# Check if PostgreSQL service is running
Get-Service postgresql* | Select-Object Status

# Should show: Status: Running
```

### Step 2: Create Database & Tables

```powershell
# Open PostgreSQL shell
psql -U postgres
```

**Inside PostgreSQL shell:**

```sql
-- Create database
CREATE DATABASE teacher_finder_db;

-- Connect to database
\c teacher_finder_db

-- Create UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM type for roles (includes admin role)
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');

-- Create USERS table
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    role          user_role    NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Create TEACHER_PROFILES table
CREATE TABLE teacher_profiles (
    id           UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID          NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    subjects     TEXT[]        NOT NULL DEFAULT '{}',
    fee_per_hour DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    availability JSONB,
    bio          TEXT,
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- Create REQUESTS table
CREATE TABLE requests (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    message         TEXT,
    status          VARCHAR(20)  NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Create PAYMENTS table
CREATE TABLE payments (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
    student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    amount          DECIMAL(10,2) NOT NULL,
    duration_hours  DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    status          VARCHAR(20)  NOT NULL DEFAULT 'unpaid',
    payment_date    TIMESTAMP,
    notes           TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Create NOTIFICATIONS table
CREATE TABLE notifications (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id        UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    payment_id      UUID         REFERENCES payments (id) ON DELETE CASCADE,
    type            VARCHAR(50)  NOT NULL,
    title           VARCHAR(255) NOT NULL,
    message         TEXT         NOT NULL,
    is_read         BOOLEAN      DEFAULT FALSE,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Create CLASSES table
CREATE TABLE class_sessions (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
    student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    subject         VARCHAR(255) NOT NULL,
    scheduled_date  TIMESTAMP    NOT NULL,
    duration_hours  DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    status          VARCHAR(20)  NOT NULL DEFAULT 'scheduled',
    notes           TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_teacher_profiles_user_id ON teacher_profiles(user_id);
CREATE INDEX idx_requests_student_id ON requests(student_id);
CREATE INDEX idx_requests_teacher_id ON requests(teacher_id);
CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_teacher_id ON payments(teacher_id);
CREATE INDEX idx_notifications_admin_id ON notifications(admin_id);

-- Exit PostgreSQL
\q
```

✅ **Database is now ready!**

---

## ⚙️ Backend Setup

### Step 1: Navigate to Backend

```powershell
cd "d:\Teacher finding app\teacher_finding_app\backend"
```

### Step 2: Install Dependencies

```powershell
npm install
```

### Step 3: Create .env File

Create `.env` file in backend folder:

```
PORT=5000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_NAME=teacher_finder_db
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRY=7d
```

### Step 4: Start Backend

```powershell
npm start
```

**Expected Output:**

```
╔════════════════════════════════════════════════════════════╗
║       Teacher Finder API Server                            ║
║       Server running on: http://localhost:5000             ║
║       Environment: development                             ║
╚════════════════════════════════════════════════════════════╝
```

✅ **Backend is running!**

---

## 🌱 Seed Data (Create Admin, Teachers, Students)

**Keep backend running, open NEW terminal:**

### Step 1: Create Admin User

```powershell
cd "d:\Teacher finding app\teacher_finding_app\backend"
node scripts/seedAdmin.js
```

**Output:**

```
✅ Admin user created successfully!

📋 Admin Credentials:
   Email: admin@teacherfinder.com
   Password: admin123

⚠️  IMPORTANT: Change the password after first login!
```

### Step 2: Create 3 Teachers

```powershell
node scripts/seedTeachers.js
```

**Output:**

```
✅ Created teacher: Dr. Sarah Ahmed
   Email: sarah.ahmed@teacherfinder.com
   Subjects: Database, SQL, PostgreSQL, MySQL
   Fee: $35/hour

✅ Created teacher: Muhammad Hassan
   Email: muhammad.hassan@teacherfinder.com
   Subjects: Mobile Application Development, Flutter, Android, iOS
   Fee: $40/hour

✅ Created teacher: Prof. Fatima Khan
   Email: fatima.khan@teacherfinder.com
   Subjects: Machine Learning, Python, Data Science, AI
   Fee: $50/hour

✅ Teacher seeding completed!
```

✅ **Data is seeded!**

---

## 📱 Flutter Setup

### Step 1: Navigate to Flutter Project

```powershell
cd "d:\Teacher finding app\teacher_finding_app"
```

### Step 2: Get Dependencies

```powershell
flutter pub get
```

### Step 3: Run Flutter App

```powershell
flutter run
```

**Or from VS Code:**

- Press `F5` or
- Go to Run → Start Debugging

✅ **Flutter app is running!**

---

## 🧪 Testing

### Test 1: Register as Student

1. Open Flutter app
2. Click "Don't have an account? Sign up"
3. Fill in:
   - Name: Test Student
   - Email: student@test.com
   - Password: password123
   - Role: Student
4. Click "Create Account"

### Test 2: Search Teachers

1. Login as student
2. Go to "Find Teachers" tab
3. Search for:
   - "Database" → Should show Dr. Sarah Ahmed
   - "Flutter" → Should show Muhammad Hassan
   - "Machine Learning" → Should show Prof. Fatima Khan

### Test 3: Send Request

1. Find a teacher
2. Click "Send Request"
3. Confirm message sent

### Test 4: Admin Dashboard

1. Open browser: `http://localhost:5757/#/login`
2. Login as admin:
   - Email: `admin@teacherfinder.com`
   - Password: `admin123`
3. View:
   - **Dashboard Tab**: Statistics (teachers, students, revenue)
   - **Teachers Tab**: List of all teachers
   - **Students Tab**: List of all students
   - **Payments Tab**: Payment status and confirmation

### Test 5: Mark Payment as Paid

1. Go to Admin Dashboard → Payments tab
2. Find an unpaid payment
3. Click "Confirm Payment"
4. Payment status changes to PAID

---

## 📊 Admin Features

### Dashboard Statistics

- ✅ Total Teachers Count
- ✅ Total Students Count
- ✅ Total Requests
- ✅ Pending Requests
- ✅ Accepted Requests
- ✅ Total Revenue (Sum of paid payments)
- ✅ Pending Payments (Sum of unpaid payments)
- ✅ Unread Notifications

### Teachers Management

- ✅ View all teachers
- ✅ See their subjects
- ✅ See their hourly fee
- ✅ View total requests received
- ✅ View accepted requests

### Students Management

- ✅ View all students
- ✅ See total amount spent
- ✅ See total requests sent
- ✅ See accepted requests

### Payments Management

- ✅ View all payments
- ✅ Filter by status (All/Paid/Unpaid)
- ✅ Confirm payment as paid
- ✅ Add notes to payment
- ✅ See student and teacher info

### Notifications

- ✅ Admin receives notifications when payment confirmed
- ✅ Mark notifications as read
- ✅ View notification history

---

## 🔐 Default Test Accounts

### Admin Account

```
Email: admin@teacherfinder.com
Password: admin123
Role: Admin
```

### 3 Teachers Created

1. **Dr. Sarah Ahmed** (Database Expert)
   - Email: sarah.ahmed@teacherfinder.com
   - Password: password123
   - Subjects: Database, SQL, PostgreSQL, MySQL
   - Fee: $35/hour

2. **Muhammad Hassan** (Mobile Developer)
   - Email: muhammad.hassan@teacherfinder.com
   - Password: password123
   - Subjects: Mobile Application Development, Flutter, Android, iOS
   - Fee: $40/hour

3. **Prof. Fatima Khan** (ML Expert)
   - Email: fatima.khan@teacherfinder.com
   - Password: password123
   - Subjects: Machine Learning, Python, Data Science, AI
   - Fee: $50/hour

### Student Test Account (Create yourself)

```
Name: Test Student
Email: student@test.com
Password: password123
Role: Student
```

---

## 🚀 Quick Start Checklist

- [x] PostgreSQL installed and running
- [x] Database created with all tables
- [x] Backend running on port 5000
- [x] Admin user created
- [x] 3 Teachers created
- [x] Flutter app running
- [x] Can register as student
- [x] Can search teachers
- [x] Can send requests
- [x] Can login as admin
- [x] Can view admin dashboard
- [x] Can confirm payments

---

## 🔧 Troubleshooting

### Backend won't start

```powershell
# Check if port 5000 is in use
Get-NetTCPConnection -LocalPort 5000

# Kill process using port 5000
Stop-Process -Id <PID> -Force

# Restart backend
npm start
```

### Database connection error

- Check PostgreSQL is running: `Get-Service postgresql*`
- Verify .env file has correct password
- Test connection: `psql -U postgres -d teacher_finder_db`

### Teacher search returns no results

- Run: `node scripts/seedTeachers.js` again
- Verify teachers exist: `SELECT * FROM teacher_profiles;` (in psql)

### Admin login doesn't work

- Run: `node scripts/seedAdmin.js` again
- Check admin exists: `SELECT * FROM users WHERE role = 'admin';` (in psql)

---

## 📞 Support

For issues or questions, check:

1. Backend console for errors
2. Flutter debug console
3. Database directly with psql
4. Postman to test API endpoints

---

**✅ All setup complete! Your Teacher Finder app is ready to use!**
