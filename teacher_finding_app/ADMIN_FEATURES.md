# 🎛️ ADMIN DASHBOARD FEATURES

## 📊 Overview

The admin dashboard provides comprehensive management and monitoring of the Teacher Finder platform including statistics, user management, payment tracking, and notifications.

---

## 🔑 Access

### Admin Login

- **Route**: `/login` → Login Screen
- **Email**: `admin@teacherfinder.com`
- **Password**: `admin123` ⚠️ _Change after first login!_
- **Auto-redirect**: After login, admin users are automatically routed to `/admin` dashboard

---

## 📋 Dashboard Tabs

### 1️⃣ Dashboard (Statistics Tab)

**Displays Real-Time Platform Statistics:**

| Stat             | Icon | Purpose                                         |
| ---------------- | ---- | ----------------------------------------------- |
| Total Teachers   | 🏫   | Count of all registered teachers                |
| Total Students   | 👥   | Count of all registered students                |
| Total Requests   | 📋   | All lesson requests ever made                   |
| Pending Requests | ⏳   | Requests awaiting teacher response              |
| Total Revenue    | 💰   | Sum of all PAID payments                        |
| Pending Payments | ⚠️   | Sum of UNPAID payments (admin needs to confirm) |

**Statistics are calculated from:**

- `users` table (counting by role)
- `requests` table (grouping by status)
- `payments` table (summing by status)

**Data is fresh on:** Page load or manual refresh

---

### 2️⃣ Teachers Tab

**Manage and Monitor All Teachers**

#### Features:

- ✅ View all registered teachers
- ✅ Expandable teacher cards with details
- ✅ See teacher bio/specialization
- ✅ See hourly fee rate
- ✅ Track total requests received
- ✅ Track accepted requests

#### Teacher Information Displayed:

```
Name: Dr. Sarah Ahmed
Email: sarah.ahmed@teacherfinder.com
Bio: Experienced database specialist with 10+ years
Fee: $35/hour
Total Requests: 15
Accepted Requests: 12
```

#### Data Source:

- Joins `users` and `teacher_profiles` tables
- Gets request stats from `requests` table
- **Endpoint**: `GET /api/admin/teachers`

---

### 3️⃣ Students Tab

**Monitor Student Activity and Spending**

#### Features:

- ✅ View all registered students
- ✅ See total amount spent
- ✅ Track total requests sent
- ✅ Monitor accepted requests

#### Student Information Displayed:

```
Name: Ahmed Hassan
Email: ahmed.hassan@student.com
Amount Spent: $425.50
Total Requests: 8
Accepted: 6
```

#### Data Source:

- User accounts with `role = 'student'`
- Spending calculated from paid payments
- Request stats from `requests` table
- **Endpoint**: `GET /api/admin/students`

---

### 4️⃣ Payments Tab

**Complete Payment Management System**

#### Features:

- ✅ View all payments
- ✅ **Filter by Status**:
  - All Payments
  - Paid (Status = 'paid')
  - Unpaid (Status = 'unpaid')
- ✅ See payment details:
  - Student name
  - Teacher name
  - Amount
  - Current status (badge)
- ✅ **Confirm Payment** button (for unpaid items)
- ✅ Add notes when confirming

#### Payment Status Badges:

| Badge  | Color     | Meaning                        |
| ------ | --------- | ------------------------------ |
| PAID   | 🟢 Green  | Payment confirmed by admin     |
| UNPAID | 🟠 Orange | Waiting for admin confirmation |

#### Confirming a Payment:

1. Find payment in "Unpaid" filter
2. Click "Confirm Payment" button
3. (Optional) Add notes
4. Status changes to "PAID"
5. Admin receives notification
6. Teacher is notified

#### Payment Data:

```
From: Student Name (student email)
To: Teacher Name (teacher email)
Amount: $40.00
Status: UNPAID → PAID (after confirmation)
```

#### Data Source:

- `payments` table joins:
  - `requests` (for lesson info)
  - `users` (student details)
  - `users` (teacher details)
- **Endpoint**: `GET /api/admin/payments?status=unpaid`
- **Update Endpoint**: `PUT /api/admin/payments/{id}/confirm`

---

## 🔄 Real-Time Data Flow

### When Admin Confirms a Payment:

```
1. Admin clicks "Confirm Payment"
   ↓
2. API call: PUT /api/admin/payments/{id}/confirm
   ↓
3. Backend updates payment.status = 'paid'
   ↓
4. Notification created for admin
   ↓
5. Payment appears as PAID
   ↓
6. Revenue totals update
```

---

## 🔐 Admin Endpoints

### Get Dashboard Stats

```
GET /api/admin/dashboard
Authorization: Bearer {token}

Response:
{
  "total_teachers": 3,
  "total_students": 5,
  "total_requests": 12,
  "pending_requests": 3,
  "accepted_requests": 9,
  "total_revenue": 425.50,
  "pending_payments": 120.00
}
```

### Get All Teachers

```
GET /api/admin/teachers
Authorization: Bearer {token}

Response:
{
  "teachers": [
    {
      "id": "uuid",
      "name": "Dr. Sarah Ahmed",
      "email": "sarah@example.com",
      "bio": "...",
      "fee_per_hour": 35,
      "total_requests": 15,
      "accepted_requests": 12
    }
  ]
}
```

### Get All Students

```
GET /api/admin/students
Authorization: Bearer {token}

Response:
{
  "students": [
    {
      "id": "uuid",
      "name": "Ahmed Hassan",
      "email": "ahmed@example.com",
      "total_spent": 425.50,
      "total_requests": 8
    }
  ]
}
```

### Get Payments (with filtering)

```
GET /api/admin/payments?status=unpaid&page=1&limit=20
Authorization: Bearer {token}

Response:
{
  "payments": [
    {
      "id": "uuid",
      "student_name": "Ahmed Hassan",
      "teacher_name": "Dr. Sarah Ahmed",
      "amount": 40.00,
      "status": "unpaid",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Confirm Payment

```
PUT /api/admin/payments/{id}/confirm
Authorization: Bearer {token}
Content-Type: application/json

{
  "notes": "Optional notes about this payment"
}

Response:
{
  "message": "Payment confirmed successfully",
  "payment": {
    "id": "uuid",
    "status": "paid",
    "paid_at": "2024-01-15T11:00:00Z"
  }
}
```

---

## 📊 Admin Analytics

### Dashboard Cards Show:

1. **Teacher Metrics**
   - Count: `SELECT COUNT(*) WHERE role = 'teacher'`
   - Active: `SELECT COUNT(*) WHERE role = 'teacher' AND is_active = true`

2. **Student Metrics**
   - Count: `SELECT COUNT(*) WHERE role = 'student'`
   - Spending: `SELECT SUM(amount) FROM payments WHERE status = 'paid'`

3. **Request Metrics**
   - Total: `SELECT COUNT(*) FROM requests`
   - Pending: `SELECT COUNT(*) FROM requests WHERE status = 'pending'`
   - Accepted: `SELECT COUNT(*) FROM requests WHERE status = 'accepted'`

4. **Payment Metrics**
   - Total Revenue: `SELECT SUM(amount) FROM payments WHERE status = 'paid'`
   - Pending: `SELECT SUM(amount) FROM payments WHERE status = 'unpaid'`

---

## 🎯 Common Admin Tasks

### Task 1: Check Platform Health

1. Go to Dashboard tab
2. Review all statistics
3. Check pending requests and payments

### Task 2: Review Teacher Performance

1. Go to Teachers tab
2. Expand teacher card
3. Review request/acceptance metrics

### Task 3: Monitor Student Activity

1. Go to Students tab
2. Review spending and request counts
3. Identify most active students

### Task 4: Process Payments

1. Go to Payments tab
2. Filter by "Unpaid"
3. For each payment:
   - Review amount and parties
   - Click "Confirm Payment"
   - Add notes if needed
4. Monitor "Total Revenue" update

### Task 5: Identify Issues

1. Dashboard: High pending requests → Teachers not responding
2. Students: High requests → Popular teachers
3. Payments: High pending → Focus on confirmations
4. Teachers: Zero requests → May need assistance

---

## 📱 Mobile Responsiveness

The admin dashboard is fully responsive:

- ✅ Desktop: All 4 tabs with full information
- ✅ Tablet: Tabs stack nicely with good spacing
- ✅ Mobile: Bottom navigation for tab switching, card-based layout

---

## 🔒 Security

### Admin-Only Access

- ✅ All admin endpoints require `role = 'admin'`
- ✅ JWT authentication required
- ✅ `adminOnly` middleware validates role
- ✅ Unauthorized access returns 403 Forbidden

### What Admins CAN see:

- All teachers with all details
- All students with all details
- All payments
- All requests

### What Admins CANNOT do:

- Delete users (only database admin can)
- Modify teacher fees (through dashboard)
- View other admin accounts
- Access teacher's actual availability

---

## 🚀 Performance Optimization

### Queries Optimized With Indexes:

- `idx_teacher_profiles_user_id`
- `idx_payments_student_id`
- `idx_payments_teacher_id`
- `idx_requests_student_id`
- `idx_requests_teacher_id`

### Pagination Support:

- All list endpoints support `page` and `limit` parameters
- Default limit: 20 items per page
- Reduces loading time on large datasets

---

## ✅ Checklist for Admin

- [ ] Check dashboard stats on login
- [ ] Review pending requests
- [ ] Process unpaid payments
- [ ] Monitor teacher activity
- [ ] Track revenue
- [ ] Read notifications
- [ ] Review student activity

---

## 🆘 Troubleshooting

### Dashboard shows "0" everywhere

- **Cause**: No seeded data
- **Fix**: Run `node scripts/seedTeachers.js`

### Can't login as admin

- **Cause**: Admin not created
- **Fix**: Run `node scripts/seedAdmin.js`

### Payments tab is empty

- **Cause**: No payments created (students haven't sent requests)
- **Fix**: Create a student account and test the request flow

### Stats not updating

- **Cause**: Page not refreshed
- **Fix**: Pull down to refresh or go back and return to dashboard

---

## 📈 Future Enhancements

- [ ] Chart visualizations for revenue trends
- [ ] Export data to CSV
- [ ] Bulk operations (confirm multiple payments)
- [ ] Admin user management
- [ ] Activity logs
- [ ] Email notifications to admin
- [ ] Dispute resolution interface
- [ ] Commission management
- [ ] Promo codes and discounts
- [ ] Report generation

---

**✅ Admin Dashboard Ready for Use!**
