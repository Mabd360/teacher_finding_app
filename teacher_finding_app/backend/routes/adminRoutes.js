const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../db');

// Middleware: Check if user is admin
const adminOnly = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Only admins can access this' });
  }
  next();
};

// ============================================================================
// DASHBOARD STATISTICS
// ============================================================================

// GET /api/admin/dashboard - Get dashboard statistics
router.get('/dashboard', authMiddleware, adminOnly, async (req, res) => {
  try {
    const stats = await db.query(`
      SELECT
        (SELECT COUNT(*) FROM users WHERE role = 'teacher') as total_teachers,
        (SELECT COUNT(*) FROM users WHERE role = 'student') as total_students,
        (SELECT COUNT(*) FROM requests) as total_requests,
        (SELECT COUNT(*) FROM requests WHERE status = 'pending') as pending_requests,
        (SELECT COUNT(*) FROM requests WHERE status = 'accepted') as accepted_requests,
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'paid') as total_revenue,
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'unpaid') as pending_payments,
        (SELECT COUNT(*) FROM notifications WHERE is_read = false) as unread_notifications
    `);

    return res.json(stats.rows[0]);
  } catch (error) {
    console.error('Dashboard error:', error);
    return res.status(500).json({ error: 'Failed to load dashboard' });
  }
});

// ============================================================================
// TEACHERS MANAGEMENT
// ============================================================================

// GET /api/admin/teachers - Get all teachers with their profiles
router.get('/teachers', authMiddleware, adminOnly, async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        u.id,
        u.name,
        u.email,
        u.created_at,
        u.is_verified,
        u.phone,
        u.cnic_front,
        u.cnic_back,
        tp.subjects,
        tp.fee_per_hour,
        tp.bio,
        (SELECT COUNT(*) FROM requests WHERE teacher_id = u.id) as total_requests,
        (SELECT COUNT(*) FROM requests WHERE teacher_id = u.id AND status = 'accepted') as accepted_requests
      FROM users u
      LEFT JOIN teacher_profiles tp ON u.id = tp.user_id
      WHERE u.role = 'teacher'
      ORDER BY u.created_at DESC
    `);

    return res.json({ teachers: result.rows });
  } catch (error) {
    console.error('Teachers list error:', error);
    return res.status(500).json({ error: 'Failed to load teachers' });
  }
});

// ============================================================================
// STUDENTS MANAGEMENT
// ============================================================================

// GET /api/admin/students - Get all students
router.get('/students', authMiddleware, adminOnly, async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        u.id,
        u.name,
        u.email,
        u.created_at,
        u.is_verified,
        u.phone,
        u.cnic_front,
        u.cnic_back,
        (SELECT COUNT(*) FROM requests WHERE student_id = u.id) as total_requests,
        (SELECT COUNT(*) FROM requests WHERE student_id = u.id AND status = 'accepted') as accepted_requests,
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE student_id = u.id AND status = 'paid') as total_spent
      FROM users u
      WHERE u.role = 'student'
      ORDER BY u.created_at DESC
    `);

    return res.json({ students: result.rows });
  } catch (error) {
    console.error('Students list error:', error);
    return res.status(500).json({ error: 'Failed to load students' });
  }
});

// ============================================================================
// PAYMENTS MANAGEMENT
// ============================================================================

// GET /api/admin/payments - Get all payments with optional filters
router.get('/payments', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let statusFilter = '';
    const params = [];

    if (status) {
      statusFilter = 'WHERE p.status = $1';
      params.push(status);
    }

    const result = await db.query(`
      SELECT
        p.id,
        p.amount,
        p.duration_hours,
        p.status,
        p.payment_date,
        p.notes,
        p.created_at,
        u_student.name as student_name,
        u_student.email as student_email,
        u_teacher.name as teacher_name,
        u_teacher.email as teacher_email,
        r.id as request_id
      FROM payments p
      JOIN users u_student ON p.student_id = u_student.id
      JOIN users u_teacher ON p.teacher_id = u_teacher.id
      JOIN requests r ON p.request_id = r.id
      ${statusFilter}
      ORDER BY p.created_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `, [...params, limit, offset]);

    return res.json({ payments: result.rows });
  } catch (error) {
    console.error('Payments list error:', error);
    return res.status(500).json({ error: 'Failed to load payments' });
  }
});

// PUT /api/admin/payments/:id/confirm - Mark payment as paid
router.put('/payments/:id/confirm', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;

    const result = await db.query(`
      UPDATE payments
      SET status = 'paid',
          payment_date = NOW(),
          notes = COALESCE($2, notes),
          updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [id, notes || null]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    const payment = result.rows[0];

    // Create notification for admin
    const admin = await db.query('SELECT id FROM users WHERE role = $1 LIMIT 1', ['admin']);
    if (admin.rows.length > 0) {
      await db.query(`
        INSERT INTO notifications (admin_id, payment_id, type, title, message)
        VALUES ($1, $2, 'payment_confirmed', 'Payment Confirmed', $3)
      `, [
        admin.rows[0].id,
        id,
        `Payment of $${payment.amount} from student confirmed for teacher`
      ]);
    }

    return res.json({ message: 'Payment confirmed', payment: result.rows[0] });
  } catch (error) {
    console.error('Payment confirm error:', error);
    return res.status(500).json({ error: 'Failed to confirm payment' });
  }
});

// ============================================================================
// NOTIFICATIONS
// ============================================================================

// GET /api/admin/notifications - Get admin notifications
router.get('/notifications', authMiddleware, adminOnly, async (req, res) => {
  try {
    const result = await db.query(`
      SELECT *
      FROM notifications
      WHERE admin_id = $1
      ORDER BY created_at DESC
      LIMIT 50
    `, [req.user.id]);

    return res.json({ notifications: result.rows });
  } catch (error) {
    console.error('Notifications error:', error);
    return res.status(500).json({ error: 'Failed to load notifications' });
  }
});

// PUT /api/admin/notifications/:id/read - Mark notification as read
router.put('/notifications/:id/read', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;

    await db.query(`
      UPDATE notifications
      SET is_read = true
      WHERE id = $1
    `, [id]);

    return res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Notification update error:', error);
    return res.status(500).json({ error: 'Failed to update notification' });
  }
});

// GET /api/admin/unverified - Get all unverified users (teachers and students)
router.get('/unverified', authMiddleware, adminOnly, async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        u.id, 
        u.name, 
        u.email, 
        u.role, 
        u.phone, 
        u.cnic_front, 
        u.cnic_back, 
        u.created_at,
        tp.subjects,
        tp.fee_per_hour,
        tp.bio
      FROM users u
      LEFT JOIN teacher_profiles tp ON u.id = tp.user_id
      WHERE u.is_verified = false
      ORDER BY u.created_at ASC
    `);
    return res.json({ users: result.rows });
  } catch (error) {
    console.error('Unverified users error:', error);
    return res.status(500).json({ error: 'Failed to load unverified users' });
  }
});


// PUT /api/admin/users/:id/verify - Verify a user
router.put('/users/:id/verify', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    const { is_verified } = req.body;
    const targetStatus = is_verified !== false;

    const result = await db.query(`
      UPDATE users
      SET is_verified = $2
      WHERE id = $1
      RETURNING id, name, email, role, is_verified
    `, [id, targetStatus]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json({ 
      message: targetStatus ? 'User verified successfully' : 'User verification status updated', 
      user: result.rows[0] 
    });
  } catch (error) {
    console.error('Verify user error:', error);
    return res.status(500).json({ error: 'Failed to update user verification' });
  }
});

// DELETE /api/admin/users/:id - Reject/Delete user
router.delete('/users/:id', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if user exists
    const userCheck = await db.query('SELECT id, role FROM users WHERE id = $1', [id]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userCheck.rows[0];

    // If teacher, delete teacher profile first
    if (user.role === 'teacher') {
      await db.query('DELETE FROM teacher_profiles WHERE user_id = $1', [id]);
    }

    // Delete any pending requests
    await db.query('DELETE FROM requests WHERE student_id = $1 OR teacher_id = $1', [id]);

    // Finally delete the user
    const result = await db.query('DELETE FROM users WHERE id = $1 RETURNING id, name, email', [id]);
    
    return res.json({ 
      message: 'User rejected and deleted successfully', 
      user: result.rows[0] 
    });
  } catch (error) {
    console.error('Delete/reject user error:', error);
    return res.status(500).json({ error: 'Failed to reject and delete user' });
  }
});

module.exports = router;
