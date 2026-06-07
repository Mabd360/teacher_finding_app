const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../db'); // Assuming you have a database connection module

// POST /api/teacher/profile - Create a new teacher profile (protected, teacher only)
router.post('/profile', authMiddleware, async (req, res) => {
  try {
    // Check if user is a teacher
    if (req.user.role !== 'teacher') {
      return res.status(403).json({ error: 'Only teachers can create profiles' });
    }

    const { subjects, fee_per_hour, availability, bio } = req.body;
    const userId = req.user.id;

    // Validate required fields
    if (!subjects || !Array.isArray(subjects) || subjects.length === 0) {
      return res.status(400).json({ error: 'Subjects array is required and cannot be empty' });
    }
    if (!fee_per_hour || fee_per_hour <= 0) {
      return res.status(400).json({ error: 'Fee per hour is required and must be positive' });
    }
    if (!availability || typeof availability !== 'object') {
      return res.status(400).json({ error: 'Availability object is required' });
    }

    // Check if profile already exists
    const existingProfile = await db.query(
      'SELECT id FROM teacher_profiles WHERE user_id = $1',
      [userId]
    );

    if (existingProfile.rows.length > 0) {
      return res.status(409).json({ error: 'Profile already exists for this teacher' });
    }

    // Insert new teacher profile
    const query = `
      INSERT INTO teacher_profiles (user_id, subjects, fee_per_hour, availability, bio)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, user_id, subjects, fee_per_hour, availability, bio, created_at, updated_at
    `;

    const result = await db.query(query, [
      userId,
      subjects,
      fee_per_hour,
      JSON.stringify(availability),
      bio || null
    ]);

    res.status(201).json({
      message: 'Teacher profile created successfully',
      profile: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating teacher profile:', error);
    res.status(500).json({ error: 'Failed to create teacher profile' });
  }
});

// PUT /api/teacher/profile - Update logged-in teacher's profile (protected)
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    // Check if user is a teacher
    if (req.user.role !== 'teacher') {
      return res.status(403).json({ error: 'Only teachers can update profiles' });
    }

    const userId = req.user.id;
    const { subjects, fee_per_hour, availability, bio } = req.body;

    // Check if profile exists
    const profileResult = await db.query(
      'SELECT id FROM teacher_profiles WHERE user_id = $1',
      [userId]
    );

    if (profileResult.rows.length === 0) {
      return res.status(404).json({ error: 'Teacher profile not found' });
    }

    // Build dynamic update query based on provided fields
    const updates = [];
    const values = [userId];
    let paramCount = 2;

    if (subjects !== undefined) {
      if (!Array.isArray(subjects) || subjects.length === 0) {
        return res.status(400).json({ error: 'Subjects must be a non-empty array' });
      }
      updates.push(`subjects = $${paramCount}`);
      values.push(subjects);
      paramCount++;
    }

    if (fee_per_hour !== undefined) {
      if (fee_per_hour <= 0) {
        return res.status(400).json({ error: 'Fee per hour must be positive' });
      }
      updates.push(`fee_per_hour = $${paramCount}`);
      values.push(fee_per_hour);
      paramCount++;
    }

    if (availability !== undefined) {
      if (typeof availability !== 'object') {
        return res.status(400).json({ error: 'Availability must be an object' });
      }
      updates.push(`availability = $${paramCount}`);
      values.push(JSON.stringify(availability));
      paramCount++;
    }

    if (bio !== undefined) {
      updates.push(`bio = $${paramCount}`);
      values.push(bio || null);
      paramCount++;
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push(`updated_at = NOW()`);

    const query = `
      UPDATE teacher_profiles
      SET ${updates.join(', ')}
      WHERE user_id = $1
      RETURNING id, user_id, subjects, fee_per_hour, availability, bio, created_at, updated_at
    `;

    const result = await db.query(query, values);

    res.json({
      message: 'Teacher profile updated successfully',
      profile: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating teacher profile:', error);
    res.status(500).json({ error: 'Failed to update teacher profile' });
  }
});

// GET /api/teacher/profile - Get logged-in teacher's own profile (protected)
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const query = `
      SELECT tp.id, tp.user_id, tp.subjects, tp.fee_per_hour, tp.availability, tp.bio, 
             tp.created_at, tp.updated_at, u.name, u.email
      FROM teacher_profiles tp
      JOIN users u ON tp.user_id = u.id
      WHERE tp.user_id = $1
    `;

    const result = await db.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Teacher profile not found' });
    }

    res.json({
      message: 'Teacher profile retrieved successfully',
      profile: result.rows[0]
    });
  } catch (error) {
    console.error('Error retrieving teacher profile:', error);
    res.status(500).json({ error: 'Failed to retrieve teacher profile' });
  }
});

// GET /api/teacher/profile/:id - Get any teacher's profile by user_id (public)
router.get('/profile/:id', async (req, res) => {
  try {
    const userId = req.params.id;

    // The app uses UUID user IDs, so do not validate with numeric checks.
    if (!userId || typeof userId !== 'string') {
      return res.status(400).json({ error: 'Invalid user ID format' });
    }

    const query = `
      SELECT tp.id, tp.user_id, tp.subjects, tp.fee_per_hour, tp.availability, tp.bio, 
             tp.created_at, u.name,
             COALESCE(r.avg_rating, 0) AS average_rating,
             COALESCE(r.total_reviews, 0) AS total_reviews
      FROM teacher_profiles tp
      JOIN users u ON tp.user_id = u.id
      LEFT JOIN (
        SELECT teacher_id, ROUND(AVG(rating)::numeric, 1) AS avg_rating, COUNT(*) AS total_reviews
        FROM reviews GROUP BY teacher_id
      ) r ON r.teacher_id = tp.user_id
      WHERE tp.user_id = $1
    `;

    const result = await db.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Teacher profile not found' });
    }

    res.json({
      message: 'Teacher profile retrieved successfully',
      profile: result.rows[0]
    });
  } catch (error) {
    console.error('Error retrieving teacher profile:', error);
    res.status(500).json({ error: 'Failed to retrieve teacher profile' });
  }
});

module.exports = router;
