const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../db');

// POST /api/bookings - Student creates a booking from an accepted request
router.post('/', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'student') {
      return res.status(403).json({ error: 'Only students can create bookings' });
    }

    const { request_id, subject, scheduled_date, duration_hours = 1, notes } = req.body;

    if (!request_id) {
      return res.status(400).json({ error: 'request_id is required' });
    }
    if (!subject || typeof subject !== 'string') {
      return res.status(400).json({ error: 'subject is required' });
    }
    if (!scheduled_date) {
      return res.status(400).json({ error: 'scheduled_date is required' });
    }

    // Verify the request exists, belongs to this student, and is accepted
    const requestResult = await db.query(
      'SELECT r.*, tp.fee_per_hour FROM requests r JOIN teacher_profiles tp ON tp.user_id = r.teacher_id WHERE r.id = $1',
      [request_id]
    );

    if (requestResult.rows.length === 0) {
      return res.status(404).json({ error: 'Request not found' });
    }

    const request = requestResult.rows[0];

    if (request.student_id !== req.user.id) {
      return res.status(403).json({ error: 'This request does not belong to you' });
    }

    if (request.status !== 'accepted') {
      return res.status(400).json({ error: 'Only accepted requests can be booked' });
    }

    const parsedDuration = parseFloat(duration_hours);
    if (isNaN(parsedDuration) || parsedDuration <= 0) {
      return res.status(400).json({ error: 'duration_hours must be a positive number' });
    }

    const amount = parseFloat(request.fee_per_hour) * parsedDuration;

    // Use a transaction to create both session and payment
    const client = await db.connect();
    try {
      await client.query('BEGIN');

      // Create the session
      const sessionResult = await client.query(
        `INSERT INTO class_sessions (request_id, student_id, teacher_id, subject, scheduled_date, duration_hours, notes)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [request_id, req.user.id, request.teacher_id, subject, scheduled_date, parsedDuration, notes || null]
      );

      // Create the payment record
      await client.query(
        `INSERT INTO payments (request_id, student_id, teacher_id, amount, duration_hours, status)
         VALUES ($1, $2, $3, $4, $5, 'unpaid')`,
        [request_id, req.user.id, request.teacher_id, amount, parsedDuration]
      );

      await client.query('COMMIT');

      return res.status(201).json({
        message: 'Booking created successfully',
        booking: sessionResult.rows[0],
        amount: amount
      });
    } catch (txError) {
      await client.query('ROLLBACK');
      throw txError;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Create booking error:', error);
    return res.status(500).json({ error: 'Failed to create booking' });
  }
});

// GET /api/bookings/student - Get student's bookings
router.get('/student', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'student') {
      return res.status(403).json({ error: 'Only students can view their bookings' });
    }

    const result = await db.query(`
      SELECT
        cs.*,
        u.name AS teacher_name,
        tp.fee_per_hour,
        p.status AS payment_status,
        CASE WHEN rv.id IS NOT NULL THEN true ELSE false END AS has_review
      FROM class_sessions cs
      JOIN users u ON cs.teacher_id = u.id
      LEFT JOIN teacher_profiles tp ON tp.user_id = cs.teacher_id
      LEFT JOIN reviews rv ON rv.session_id = cs.id
      LEFT JOIN payments p ON p.request_id = cs.request_id
      WHERE cs.student_id = $1
      ORDER BY cs.scheduled_date DESC
    `, [req.user.id]);

    return res.json({ bookings: result.rows });
  } catch (error) {
    console.error('Student bookings error:', error);
    return res.status(500).json({ error: 'Failed to load bookings' });
  }
});

// GET /api/bookings/teacher - Get teacher's bookings
router.get('/teacher', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'teacher') {
      return res.status(403).json({ error: 'Only teachers can view their sessions' });
    }

    const result = await db.query(`
      SELECT
        cs.*,
        u.name AS student_name,
        p.status AS payment_status
      FROM class_sessions cs
      JOIN users u ON cs.student_id = u.id
      LEFT JOIN payments p ON p.request_id = cs.request_id
      WHERE cs.teacher_id = $1
      ORDER BY cs.scheduled_date DESC
    `, [req.user.id]);

    return res.json({ bookings: result.rows });
  } catch (error) {
    console.error('Teacher bookings error:', error);
    return res.status(500).json({ error: 'Failed to load sessions' });
  }
});

// PUT /api/bookings/:id/complete - Teacher marks session as completed
router.put('/:id/complete', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'teacher') {
      return res.status(403).json({ error: 'Only teachers can complete sessions' });
    }

    const session = await db.query('SELECT * FROM class_sessions WHERE id = $1', [req.params.id]);

    if (session.rows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    if (session.rows[0].teacher_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not authorized to modify this session' });
    }

    if (session.rows[0].status !== 'scheduled') {
      return res.status(400).json({ error: 'Only scheduled sessions can be completed' });
    }

    const result = await db.query(
      `UPDATE class_sessions SET status = 'completed', updated_at = NOW() WHERE id = $1 RETURNING *`,
      [req.params.id]
    );

    return res.json({ message: 'Session marked as completed', booking: result.rows[0] });
  } catch (error) {
    console.error('Complete session error:', error);
    return res.status(500).json({ error: 'Failed to complete session' });
  }
});

// PUT /api/bookings/:id/cancel - Cancel a session
router.put('/:id/cancel', authMiddleware, async (req, res) => {
  try {
    const session = await db.query('SELECT * FROM class_sessions WHERE id = $1', [req.params.id]);

    if (session.rows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const sessionData = session.rows[0];

    // Both teacher and student can cancel their own sessions
    if (sessionData.teacher_id !== req.user.id && sessionData.student_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not authorized to cancel this session' });
    }

    if (sessionData.status !== 'scheduled') {
      return res.status(400).json({ error: 'Only scheduled sessions can be cancelled' });
    }

    const client = await db.connect();
    try {
      await client.query('BEGIN');

      await client.query(
        `UPDATE class_sessions SET status = 'cancelled', updated_at = NOW() WHERE id = $1`,
        [req.params.id]
      );

      // Cancel the associated payment
      await client.query(
        `UPDATE payments SET status = 'cancelled', updated_at = NOW() WHERE request_id = $1 AND student_id = $2 AND teacher_id = $3 AND status = 'unpaid'`,
        [sessionData.request_id, sessionData.student_id, sessionData.teacher_id]
      );

      await client.query('COMMIT');

      return res.json({ message: 'Session cancelled successfully' });
    } catch (txError) {
      await client.query('ROLLBACK');
      throw txError;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Cancel session error:', error);
    return res.status(500).json({ error: 'Failed to cancel session' });
  }
});

// PUT /api/bookings/:id/pay - Simulates payment for a class session
router.put('/:id/pay', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const studentId = req.user.id;

    if (req.user.role !== 'student') {
      return res.status(403).json({ error: 'Only students can pay for bookings' });
    }

    // Verify session belongs to this student
    const sessionCheck = await db.query(
      'SELECT request_id FROM class_sessions WHERE id = $1 AND student_id = $2',
      [id, studentId]
    );

    if (sessionCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Session not found or not belonging to you' });
    }

    const requestId = sessionCheck.rows[0].request_id;

    const paymentCheck = await db.query(
      'SELECT * FROM payments WHERE request_id = $1 AND student_id = $2',
      [requestId, studentId]
    );

    if (paymentCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Payment record not found for this session' });
    }

    const payment = paymentCheck.rows[0];
    if (payment.status === 'paid') {
      return res.status(400).json({ error: 'This booking is already paid' });
    }

    // Update payment record to paid
    const updatedPayment = await db.query(
      `UPDATE payments 
       SET status = 'paid', payment_date = NOW(), updated_at = NOW() 
       WHERE id = $1 RETURNING *`,
      [payment.id]
    );

    return res.json({ 
      message: 'Payment completed successfully (Simulated)', 
      payment: updatedPayment.rows[0] 
    });
  } catch (error) {
    console.error('Pay session error:', error);
    return res.status(500).json({ error: 'Failed to process payment' });
  }
});

module.exports = router;
