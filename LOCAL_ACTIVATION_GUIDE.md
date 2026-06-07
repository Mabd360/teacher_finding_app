# 🚀 LOCAL PROJECT ACTIVATION GUIDE

**Teacher Finder App - Complete Step-by-Step Setup**

Save this guide and follow it each time you want to run the project locally or after making improvements.

---

## 📋 TABLE OF CONTENTS

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Database Configuration](#database-configuration)
4. [Backend Setup & Running](#backend-setup--running)
5. [Frontend Setup & Running](#frontend-setup--running)
6. [Verification & Testing](#verification--testing)
7. [Common Commands](#common-commands)
8. [Troubleshooting](#troubleshooting)
9. [After Making Changes](#after-making-changes)

---

## 📦 PREREQUISITES

Before starting, make sure you have these installed:

### Required Software

1. **Node.js** (v16 or higher)
   - Download: https://nodejs.org/
   - Verify: `node --version` and `npm --version`

2. **PostgreSQL** (v12 or higher)
   - Download: https://www.postgresql.org/download/
   - Verify: `psql --version`
   - Should be running as a service

3. **Flutter SDK** (v3.11 or higher)
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`

4. **Git** (optional, for version control)
   - Download: https://git-scm.com/

5. **VS Code** or **Android Studio**
   - For Flutter development and debugging

### System Requirements

- **Windows 10/11** or **macOS** or **Linux**
- **4GB RAM** minimum (8GB recommended)
- **10GB free disk space**

---

## 🔧 ENVIRONMENT SETUP

### Step 1: Verify All Tools Are Installed

Open PowerShell/Terminal and run these commands:

```powershell
# Check Node.js
node --version
npm --version

# Check PostgreSQL
psql --version

# Check Flutter
flutter --version

# Check Dart
dart --version
```

✅ You should see version numbers for all of these.

### Step 2: Navigate to Project Folder

```powershell
# Navigate to the project root
cd "d:\Teacher finding app"

# Verify you see these folders
dir

# You should see:
# - teacher_finding_app/
# - backend/
# - database/
# - (various .md files)
```

### Step 3: Create Environment Variables File

```powershell
# Navigate to backend
cd teacher_finding_app\backend

# Check if .env.example exists
dir | findstr ".env"

# Copy example to .env (if .env doesn't exist)
# Windows PowerShell:
Copy-Item .env.example .env

# Or manually create .env file with same content as .env.example
```

### Step 4: Edit .env File

Open `teacher_finding_app/backend/.env` in VS Code:

```
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=teacher_finder_db
PORT=5000
JWT_SECRET=your_secret_key_here_change_this
NODE_ENV=development
```

⚠️ **IMPORTANT**: Change `your_postgres_password` to your actual PostgreSQL password!

---

## 🗄️ DATABASE CONFIGURATION

### Step 1: Ensure PostgreSQL is Running

```powershell
# Windows: Check if PostgreSQL service is running
Get-Service postgresql* | Select-Object Status, DisplayName

# If not running, start it
Start-Service postgresql-x64-15  # (version number may vary)
```

### Step 2: Create Database

```powershell
# Navigate to database folder
cd "d:\Teacher finding app\teacher_finding_app\database"

# Connect to PostgreSQL and create database
psql -U postgres -c "CREATE DATABASE teacher_finder_db;"

# You'll be prompted for PostgreSQL password
```

### Step 3: Run Database Schema

```powershell
# Still in database folder
# Run the schema to create tables
psql -U postgres -d teacher_finder_db -f schema.sql

# You should see output like:
# CREATE TABLE
# CREATE INDEX
# CREATE TRIGGER
```

### Step 4: Add Admin & Payment Features

```powershell
# Run the admin/payment schema
psql -U postgres -d teacher_finder_db -f add_payments_and_admin.sql

# You should see similar CREATE/ALTER output
```

### Step 5: Seed Test Data (Optional)

```powershell
# Navigate back to backend
cd "..\backend"

# Create admin user
node scripts/seedAdmin.js

# Create test teachers
node scripts/seedTeachers.js

# You should see console output like:
# "Admin created: admin@teacherfinder.com"
# "Teachers seeded successfully"
```

✅ **Database is now ready!**

---

## 🔌 BACKEND SETUP & RUNNING

### Step 1: Install Dependencies

```powershell
# Navigate to backend (if not already there)
cd "d:\Teacher finding app\teacher_finding_app\backend"

# Install all npm packages
npm install

# This will create node_modules folder and install:
# - express, cors, dotenv, pg, jsonwebtoken, bcrypt, etc.
```

### Step 2: Verify .env Configuration

```powershell
# Double-check .env file has correct settings
cat .env

# Should show something like:
# DB_USER=postgres
# DB_PASSWORD=password
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=teacher_finder_db
```

### Step 3: Start Backend Server

```powershell
# Development mode (with auto-restart on file changes)
npm run dev

# OR production mode:
# npm start
```

✅ **You should see:**

```
Server running on port 5000
Database connected successfully
```

### Step 4: Keep Backend Running

**Important**: Keep this PowerShell window/terminal open and running!

Open a **new PowerShell window** for the next steps.

### Step 5: Test Backend (Optional)

In a new PowerShell window:

```powershell
# Test if backend is responding
curl http://localhost:5000/api/auth/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"test@test.com","password":"test"}'

# You should get a response (may be error about invalid credentials, but server responded)
```

---

## 🎨 FRONTEND SETUP & RUNNING

### Step 1: Navigate to Flutter Project

```powershell
# Open a NEW PowerShell window (keep backend running in other window)
cd "d:\Teacher finding app\teacher_finding_app"

# Verify main.dart exists
dir lib | findstr main.dart
```

### Step 2: Get Flutter Dependencies

```powershell
# Download all Flutter packages
flutter pub get

# This will download:
# - http package
# - cupertino_icons
# - Other dependencies from pubspec.yaml
```

### Step 3: Configure API URL (Important!)

Open `lib/utils/api_constants.dart` and verify:

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:5000';
  // or if on Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:5000';
}
```

⚠️ **For different platforms:**

- **Windows/macOS**: `http://localhost:5000`
- **Android Emulator**: `http://10.0.2.2:5000`
- **Physical Android Device**: `http://YOUR_COMPUTER_IP:5000` (e.g., 192.168.1.100)

### Step 4: Run Flutter App

```powershell
# List available devices
flutter devices

# You should see:
# - Windows (if running on Windows)
# - Android Emulator (if open)
# - Chrome (if you want web)

# Run on the desired device
flutter run

# For specific device:
flutter run -d windows
# OR
flutter run -d chrome

# The app will compile and launch automatically
```

✅ **Flutter app is now running!**

### Step 5: App Startup Flow

Once the app opens:

1. **Splash Screen** appears (2 seconds)
2. **Login Screen** appears
3. Enter test credentials (see below)
4. App navigates based on role

---

## ✅ VERIFICATION & TESTING

### Test Accounts

**Option A: If you ran seed scripts**

```
ADMIN:
  Email: admin@teacherfinder.com
  Password: admin123
  Role: admin

TEACHER:
  Email: sara.ahmed@example.com
  Password: password123
  Role: teacher

STUDENT:
  Email: ali.khan@example.com
  Password: password123
  Role: student
```

**Option B: Create New Account**

1. Click "Don't have an account? Register"
2. Fill in name, email, password
3. Select role (Student/Teacher)
4. Click Register
5. App auto-navigates to login
6. Login with new credentials

### Test User Workflows

**Student Workflow:**

1. Login as student
2. Click "Find Teachers" tab
3. Search for teachers by subject
4. Click on teacher card
5. Click "Send Request"
6. View in "My Requests" tab

**Teacher Workflow:**

1. Login as teacher
2. Click "My Profile" to complete profile
3. Add subjects, fee, availability, bio
4. Go to "Requests" tab to see incoming requests
5. Accept/reject requests

**Admin Workflow:**

1. Login as admin
2. View dashboard statistics
3. Click on tabs: Teachers, Students, Payments
4. Manage users and confirm payments

### Database Verification

```powershell
# Connect to database
psql -U postgres -d teacher_finder_db

# View tables
\dt

# You should see:
# - users
# - teacher_profiles
# - requests
# - payments
# - notifications
# - class_sessions

# View sample users
SELECT id, name, email, role FROM users;

# Exit
\q
```

---

## 📝 COMMON COMMANDS

### Backend Commands

```powershell
# Navigate to backend
cd "d:\Teacher finding app\teacher_finding_app\backend"

# Install dependencies
npm install

# Start development server (with auto-reload)
npm run dev

# Start production server
npm start

# Check if server is running
curl http://localhost:5000/api/auth/login

# View logs
npm run dev 2>&1 | Tee-Object -FilePath server.log
```

### Flutter Commands

```powershell
# Navigate to flutter project
cd "d:\Teacher finding app\teacher_finding_app"

# Get dependencies
flutter pub get

# Run on specific device
flutter run -d windows
flutter run -d chrome

# Clean build
flutter clean

# Run with verbose output
flutter run -v

# Build for release
flutter build windows
flutter build web
```

### Database Commands

```powershell
# Connect to database
psql -U postgres -d teacher_finder_db

# List all tables
\dt

# View users
SELECT * FROM users;

# View teacher profiles
SELECT * FROM teacher_profiles;

# Delete all data (reset database)
psql -U postgres -d teacher_finder_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Backup database
pg_dump -U postgres teacher_finder_db > backup.sql

# Restore database
psql -U postgres -d teacher_finder_db < backup.sql
```

---

## 🐛 TROUBLESHOOTING

### Problem: "Database connection failed"

**Cause:** PostgreSQL not running or wrong credentials

**Solution:**

```powershell
# Check if PostgreSQL is running
Get-Service postgresql* | Select-Object Status, DisplayName

# If not running, start it
Start-Service postgresql-x64-15

# Verify .env has correct password
cat backend\.env

# Try connecting manually
psql -U postgres -h localhost -d teacher_finder_db
```

### Problem: "Port 5000 already in use"

**Cause:** Another app is using port 5000

**Solution:**

```powershell
# Find what's using port 5000
netstat -ano | findstr :5000

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F

# Or use different port in .env
# Change: PORT=5001
```

### Problem: "Flutter app won't connect to backend"

**Cause:** Wrong API URL or backend not running

**Solution:**

1. Check backend is running: `curl http://localhost:5000/api/auth/login`
2. Check API URL in `lib/utils/api_constants.dart`
3. For Android emulator, use `http://10.0.2.2:5000`
4. For Android phone, use your computer's IP address

### Problem: "npm install fails"

**Cause:** Node.js version issue or corrupted node_modules

**Solution:**

```powershell
# Delete node_modules
Remove-Item -Recurse node_modules

# Delete package-lock.json
Remove-Item package-lock.json

# Reinstall
npm install

# Verify Node version
node --version  # Should be v16+
```

### Problem: "Flutter pub get fails"

**Cause:** Internet connection or corrupt pubspec.lock

**Solution:**

```powershell
# Delete pubspec.lock and cache
Remove-Item pubspec.lock
flutter clean

# Reinstall
flutter pub get

# If still failing, upgrade Flutter
flutter upgrade
```

### Problem: "Login fails with 'Invalid credentials'"

**Cause:** Test account doesn't exist

**Solution:**

```powershell
# Reseed test data
cd backend/scripts
node seedAdmin.js
node seedTeachers.js

# Or create new account via Register screen in app
```

### Problem: "CORS error in frontend"

**Cause:** Backend CORS not configured properly

**Solution:**
Check `backend/server.js` has:

```javascript
app.use(cors());
```

If missing, add it before routes.

### Problem: "SSL certificate error"

**Cause:** Self-signed certificate issue

**Solution:**

```powershell
# For development, disable SSL verification (NOT for production!)
# In Flutter, use http instead of https
# Make sure API URL is http:// not https://
```

---

## 🔄 AFTER MAKING CHANGES

### Changes to Backend

```powershell
# 1. Stop backend (Ctrl+C in backend terminal)

# 2. Make your code changes

# 3. If you changed dependencies:
npm install

# 4. Restart backend
npm run dev
```

**Note:** With `npm run dev`, changes to code files are auto-reloaded (nodemon).

### Changes to Database Schema

```powershell
# 1. Create a new SQL file with your schema changes
# Example: database/migration_2024_05_22.sql

# 2. Apply the migration
psql -U postgres -d teacher_finder_db -f database/migration_2024_05_22.sql

# 3. Verify changes
psql -U postgres -d teacher_finder_db -c "\dt"
```

### Changes to Flutter UI

```powershell
# 1. Make your Dart code changes

# 2. Hot reload (auto-applies changes)
# Press 'r' in terminal where flutter run is active

# 3. Hot restart (if hot reload doesn't work)
# Press 'R' in terminal

# 4. Full rebuild if needed
flutter clean
flutter pub get
flutter run
```

### Changes to API Endpoints

```powershell
# 1. Update backend routes (e.g., backend/routes/teacherRoutes.js)

# 2. Backend will auto-reload with npm run dev

# 3. Update Flutter service if calling new endpoint
# (e.g., lib/services/teacher_api_service.dart)

# 4. Hot reload in Flutter app
```

### Testing After Changes

```powershell
# Test backend
curl http://localhost:5000/api/auth/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@teacherfinder.com","password":"admin123"}'

# Test in Flutter app UI
# Login -> Test the feature you changed
```

---

## 🔑 QUICK START (After First Setup)

Once you've done the full setup above, here's the quick way to start each time:

### Every Time You Want to Run Project

**Terminal 1 (Backend):**

```powershell
cd "d:\Teacher finding app\teacher_finding_app\backend"
npm run dev
```

**Terminal 2 (Frontend):**

```powershell
cd "d:\Teacher finding app\teacher_finding_app"
flutter run -d windows  # or -d chrome, or -d android
```

**That's it!** Both should be running now.

### To Stop Everything

```powershell
# Backend: Press Ctrl+C in backend terminal
# Frontend: Press 'q' in Flutter terminal
```

---

## 📊 FULL STARTUP CHECKLIST

Use this checklist each time you start the project:

```
DATABASE
[ ] PostgreSQL service is running
[ ] Database teacher_finder_db exists
[ ] Tables created (run schema.sql)
[ ] Admin/payment tables created (run add_payments_and_admin.sql)

BACKEND
[ ] Navigate to teacher_finding_app/backend
[ ] .env file exists and has correct credentials
[ ] npm install completed (node_modules exists)
[ ] Backend server started with npm run dev
[ ] Backend listening on http://localhost:5000
[ ] Can reach http://localhost:5000/api/auth/login

FRONTEND
[ ] Navigate to teacher_finding_app folder
[ ] API URL in lib/utils/api_constants.dart is correct
[ ] Flutter pub get completed
[ ] Flutter app running with flutter run
[ ] App displays login screen

VERIFICATION
[ ] Test login with admin@teacherfinder.com
[ ] Navigate to at least one dashboard
[ ] Make a test request (if student)
[ ] Close app and reopen to verify persistence
```

---

## 📞 NEED HELP?

### Common Issues & Quick Fixes

| Issue                         | Quick Fix                                                  |
| ----------------------------- | ---------------------------------------------------------- |
| "Port 5000 in use"            | `taskkill /PID <number> /F` or use different port          |
| "Database doesn't exist"      | `psql -U postgres -c "CREATE DATABASE teacher_finder_db;"` |
| "Can't connect to PostgreSQL" | Check password in .env, start PostgreSQL service           |
| "Flutter won't compile"       | `flutter clean && flutter pub get && flutter run`          |
| "App can't reach backend"     | Verify backend running, check API URL, use correct IP      |
| "Seed data not in DB"         | Run `node scripts/seedAdmin.js` from backend folder        |

---

## 🎯 NEXT STEPS

After confirming everything works:

1. **Make Improvements** - Follow "After Making Changes" section
2. **Add Features** - Extend routes, screens, or database
3. **Test Thoroughly** - Use all user roles
4. **Document Changes** - Update this guide as needed
5. **Backup Database** - Use `pg_dump` command above

---

## 💾 PROJECT DIRECTORY STRUCTURE

```
d:\Teacher finding app\
├── teacher_finding_app\              ← Main project folder
│   ├── lib\                          ← Flutter source code
│   │   ├── screens\                  ← All UI screens
│   │   ├── services\                 ← API integration
│   │   ├── models\                   ← Data models
│   │   ├── utils\                    ← Utilities & constants
│   │   └── main.dart                 ← Entry point
│   │
│   ├── backend\                      ← Node.js server
│   │   ├── routes\                   ← API endpoints
│   │   ├── middleware\               ← Auth middleware
│   │   ├── scripts\                  ← Seed data
│   │   ├── server.js                 ← Express app
│   │   ├── db.js                     ← Database connection
│   │   ├── package.json              ← Dependencies
│   │   └── .env                      ← Environment (create this)
│   │
│   ├── database\                     ← Database schemas
│   │   ├── schema.sql                ← Main schema
│   │   └── add_payments_and_admin.sql ← Admin features
│   │
│   ├── pubspec.yaml                  ← Flutter config
│   └── [other config files]
│
└── [documentation files]             ← Guides & READMEs
    ├── LOCAL_ACTIVATION_GUIDE.md     ← THIS FILE
    ├── PROJECT_STATUS_ANALYSIS.md
    ├── SETUP_GUIDE.md
    └── [others]
```

---

## ✅ YOU'RE ALL SET!

You now have a complete guide to:

- ✅ Set up the project locally
- ✅ Run backend and frontend
- ✅ Set up database
- ✅ Test the application
- ✅ Troubleshoot common issues
- ✅ Make changes and improvements
- ✅ Quick start for future sessions

**Save this file and follow it each time you want to work on the project!**

---

**Last Updated:** May 21, 2026  
**Version:** 1.0  
**Status:** Complete & Ready to Use
