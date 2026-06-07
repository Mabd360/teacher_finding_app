const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../db');

// POST /api/requests - student sends a request to a teacher
router.post('/', authMiddleware, async (req, res) => {
  try {
    const studentId = req.user.id;
    const { teacher_id: teacherId, message } = req.body;

    if (req.user.role !== 'student') {
      return res.status(403).json({ error: 'Only students can send requests' });
    }

    // Check if student is verified
    const studentCheck = await db.query(
      'SELECT is_verified FROM users WHERE id = $1',
      [studentId]
    );
    if (studentCheck.rows.length === 0 || !studentCheck.rows[0].is_verified) {
      return res.status(403).json({ error: 'Your account must be approved/verified by the admin before you can book a session' });
    }

    if (!teacherId || typeof teacherId !== 'string') {
      return res.status(400).json({ error: 'teacher_id is required' });
    }

    if (teacherId === studentId) {
      return res.status(400).json({ error: 'Students cannot request themselves' });
    }

    const teacherResult = await db.query(
      'SELECT id, role, is_verified FROM users WHERE id = $1',
      [teacherId]
    );

    if (teacherResult.rows.length === 0 || teacherResult.rows[0].role !== 'teacher') {
      return res.status(404).json({ error: 'Teacher not found' });
    }

    if (!teacherResult.rows[0].is_verified) {
      return res.status(403).json({ error: 'This teacher is not verified/approved yet by the admin' });
    }

    const duplicateCheck = await db.query(
      'SELECT id FROM requests WHERE student_id = $1 AND teacher_id = $2 AND status = $3',
      [studentId, teacherId, 'pending']
    );

    if (duplicateCheck.rows.length > 0) {
      return res.status(409).json({ error: 'You already have a pending request with this teacher' });
    }

    const insertResult = await db.query(
      `INSERT INTO requests (student_id, teacher_id, message)
       VALUES ($1, $2, $3)
       RETURNING id, student_id, teacher_id, message, status, created_at, updated_at`,
      [studentId, teacherId, message || null]
    );

    return res.status(201).json({ request: insertResult.rows[0] });
  } catch (error) {
    console.error('Request creation error:', error);
    return res.status(500).json({ error: 'Failed to create request' });
  }
});

// GET /api/requests/student - requests sent by the student
router.get('/student', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'student') {
      return res.status(403).json({ error: 'Only students can view their requests' });
    }

    const query = `
      SELECT
        r.id,
        r.teacher_id,
        u.name AS teacher_name,
        CASE WHEN r.status = 'accepted' THEN u.email ELSE NULL END AS teacher_email,
        CASE WHEN r.status = 'accepted' THEN u.phone ELSE NULL END AS teacher_phone,
        tp.subjects,
        r.message,
        r.status,
        r.created_at,
        r.updated_at
      FROM requests r
      JOIN users u ON r.teacher_id = u.id
      LEFT JOIN teacher_profiles tp ON tp.user_id = u.id
      WHERE r.student_id = $1
      ORDER BY r.created_at DESC
    `;

    const result = await db.query(query, [req.user.id]);
    return res.json({ requests: result.rows });
  } catch (error) {
    console.error('Student requests error:', error);
    return res.status(500).json({ error: 'Failed to load student requests' });
  }
});

// GET /api/requests/teacher - incoming requests for the teacher
router.get('/teacher', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'teacher') {
      return res.status(403).json({ error: 'Only teachers can view incoming requests' });
    }

    const query = `
      SELECT
        r.id,
        r.student_id,
        u.name AS student_name,
        CASE WHEN r.status = 'accepted' THEN u.email ELSE NULL END AS student_email,
        CASE WHEN r.status = 'accepted' THEN u.phone ELSE NULL END AS student_phone,
        r.message,
        r.status,
        r.created_at,
        r.updated_at
      FROM requests r
      JOIN users u ON r.student_id = u.id
      WHERE r.teacher_id = $1
      ORDER BY r.created_at DESC
    `;

    const result = await db.query(query, [req.user.id]);
    return res.json({ requests: result.rows });
  } catch (error) {
    console.error('Teacher requests error:', error);
    return res.status(500).json({ error: 'Failed to load teacher requests' });
  }
});

// PUT /api/requests/:id - teacher updates request status
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'teacher') {
      return res.status(403).json({ error: 'Only teachers can update request status' });
    }

    // Check if the teacher is verified
    const teacherCheck = await db.query(
      'SELECT is_verified FROM users WHERE id = $1',
      [req.user.id]
    );
    if (teacherCheck.rows.length === 0 || !teacherCheck.rows[0].is_verified) {
      return res.status(403).json({ error: 'Your account must be approved/verified by the admin before you can accept requests' });
    }

    const requestId = req.params.id;
    const { status } = req.body;

    if (!['accepted', 'rejected'].includes(status)) {
      return res.status(400).json({ error: "Status must be 'accepted' or 'rejected'" });
    }

    const requestResult = await db.query(
      'SELECT teacher_id FROM requests WHERE id = $1',
      [requestId]
    );

    if (requestResult.rows.length === 0) {
      return res.status(404).json({ error: 'Request not found' });
    }

    if (requestResult.rows[0].teacher_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not authorized to update this request' });
    }

    const updateResult = await db.query(
      `UPDATE requests
       SET status = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING id, student_id, teacher_id, message, status, created_at, updated_at`,
      [status, requestId]
    );

    return res.json({ request: updateResult.rows[0] });
  } catch (error) {
    console.error('Update request status error:', error);
    return res.status(500).json({ error: 'Failed to update request status' });
  }
});

module.exports = router;
