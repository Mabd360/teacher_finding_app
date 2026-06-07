const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../db');

// POST /api/reviews - Student submits a review for a completed session
router.post('/', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'student') {
      return res.status(403).json({ error: 'Only students can submit reviews' });
    }

    const { session_id, rating, comment } = req.body;

    if (!session_id) {
      return res.status(400).json({ error: 'session_id is required' });
    }

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ error: 'rating must be between 1 and 5' });
    }

    // Verify session exists, belongs to this student, and is completed
    const session = await db.query(
      'SELECT * FROM class_sessions WHERE id = $1',
      [session_id]
    );

    if (session.rows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const sessionData = session.rows[0];

    if (sessionData.student_id !== req.user.id) {
      return res.status(403).json({ error: 'This session does not belong to you' });
    }

    if (sessionData.status !== 'completed') {
      return res.status(400).json({ error: 'Only completed sessions can be reviewed' });
    }

    // Check if already reviewed
    const existing = await db.query(
      'SELECT id FROM reviews WHERE session_id = $1',
      [session_id]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'You have already reviewed this session' });
    }

    const result = await db.query(
      `INSERT INTO reviews (session_id, student_id, teacher_id, rating, comment)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [session_id, req.user.id, sessionData.teacher_id, rating, comment || null]
    );

    return res.status(201).json({
      message: 'Review submitted successfully',
      review: result.rows[0]
    });
  } catch (error) {
    console.error('Submit review error:', error);
    return res.status(500).json({ error: 'Failed to submit review' });
  }
});

// GET /api/reviews/teacher/:id - Get all reviews for a teacher (public)
router.get('/teacher/:id', async (req, res) => {
  try {
    const teacherId = req.params.id;

    const result = await db.query(`
      SELECT
        rv.id,
        rv.rating,
        rv.comment,
        rv.created_at,
        u.name AS student_name,
        cs.subject
      FROM reviews rv
      JOIN users u ON rv.student_id = u.id
      JOIN class_sessions cs ON rv.session_id = cs.id
      WHERE rv.teacher_id = $1
      ORDER BY rv.created_at DESC
    `, [teacherId]);

    // Also get average
    const avgResult = await db.query(
      'SELECT ROUND(AVG(rating)::numeric, 1) AS average_rating, COUNT(*) AS total_reviews FROM reviews WHERE teacher_id = $1',
      [teacherId]
    );

    return res.json({
      reviews: result.rows,
      average_rating: parseFloat(avgResult.rows[0].average_rating) || 0,
      total_reviews: parseInt(avgResult.rows[0].total_reviews) || 0
    });
  } catch (error) {
    console.error('Get reviews error:', error);
    return res.status(500).json({ error: 'Failed to load reviews' });
  }
});

module.exports = router;
