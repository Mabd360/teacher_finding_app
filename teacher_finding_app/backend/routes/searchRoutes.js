const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/search?subject=math&max_fee=50
// Returns teacher profiles filtered by subject and optional maximum fee.
router.get('/search', async (req, res) => {
  try {
    const { subject, max_fee } = req.query;

    if (!subject || typeof subject !== 'string' || subject.trim() === '') {
      return res.status(400).json({ error: 'Subject query parameter is required' });
    }

    const subjectPattern = `%${subject.trim()}%`;
    const queryParams = [subjectPattern];
    let maxFeeCondition = '';

    if (max_fee !== undefined) {
      const parsedMaxFee = Number(max_fee);

      if (Number.isNaN(parsedMaxFee) || parsedMaxFee < 0) {
        return res.status(400).json({ error: 'max_fee must be a valid non-negative number' });
      }

      maxFeeCondition = 'AND tp.fee_per_hour <= $2';
      queryParams.push(parsedMaxFee);
    }

    const query = `
      SELECT
        tp.user_id,
        u.name,
        tp.subjects,
        tp.fee_per_hour,
        tp.availability,
        tp.bio,
        COALESCE(r.avg_rating, 0) AS average_rating,
        COALESCE(r.total_reviews, 0) AS total_reviews
      FROM teacher_profiles tp
      JOIN users u ON tp.user_id = u.id
      LEFT JOIN (
        SELECT teacher_id, ROUND(AVG(rating)::numeric, 1) AS avg_rating, COUNT(*) AS total_reviews
        FROM reviews GROUP BY teacher_id
      ) r ON r.teacher_id = tp.user_id
      WHERE u.is_verified = true AND EXISTS (
        SELECT 1
        FROM unnest(tp.subjects) AS subject
        WHERE subject ILIKE $1
      )
      ${maxFeeCondition}
      ORDER BY tp.fee_per_hour ASC
    `;

    const result = await db.query(query, queryParams);
    return res.json(result.rows);
  } catch (error) {
    console.error('Search route error:', error);
    return res.status(500).json({ error: 'Failed to search teachers' });
  }
});

// GET /api/teachers - Browse all teachers (public)
// Returns all teacher profiles with average rating.
router.get('/teachers', async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    const query = `
      SELECT
        tp.user_id,
        u.name,
        tp.subjects,
        tp.fee_per_hour,
        tp.availability,
        tp.bio,
        COALESCE(r.avg_rating, 0) AS average_rating,
        COALESCE(r.total_reviews, 0) AS total_reviews
      FROM teacher_profiles tp
      JOIN users u ON tp.user_id = u.id
      LEFT JOIN (
        SELECT teacher_id, ROUND(AVG(rating)::numeric, 1) AS avg_rating, COUNT(*) AS total_reviews
        FROM reviews GROUP BY teacher_id
      ) r ON r.teacher_id = tp.user_id
      WHERE u.is_verified = true
      ORDER BY r.avg_rating DESC NULLS LAST, u.name ASC
      LIMIT $1 OFFSET $2
    `;

    const result = await db.query(query, [limit, offset]);
    return res.json({ teachers: result.rows });
  } catch (error) {
    console.error('Browse teachers error:', error);
    return res.status(500).json({ error: 'Failed to load teachers' });
  }
});

module.exports = router;
