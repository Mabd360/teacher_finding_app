const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');

const fs = require('fs');
const path = require('path');

// Helper to save base64 image to file or fallback to base64 string in serverless environments
function saveCnicImage(base64Data) {
  if (!base64Data) return null;

  // In production (Vercel serverless functions), the filesystem is read-only.
  // We fall back to storing the raw base64 string directly in the database.
  if (process.env.NODE_ENV === 'production' || !process.env.PORT) {
    return base64Data;
  }

  // Clean base64 data prefix if present (e.g. data:image/png;base64,)
  const matches = base64Data.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
  let imageBuffer;
  let extension = 'png'; // default
  
  if (matches && matches.length === 3) {
    const type = matches[1];
    extension = type.split('/')[1] || 'png';
    imageBuffer = Buffer.from(matches[2], 'base64');
  } else {
    // If no prefix, check if it's a raw base64 string
    try {
      imageBuffer = Buffer.from(base64Data, 'base64');
    } catch (e) {
      return null;
    }
  }
  
  try {
    const uploadDir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    const filename = `cnic_${Date.now()}_${Math.floor(Math.random() * 1000)}.${extension}`;
    const filePath = path.join(uploadDir, filename);
    fs.writeFileSync(filePath, imageBuffer);
    
    return `/uploads/${filename}`;
  } catch (err) {
    console.warn('Fs write failed, falling back to base64 storage:', err.message);
    return base64Data;
  }
}

// POST /api/auth/register - Register a new user
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role, phone, cnic_front, cnic_back } = req.body;

    // Validate required fields
    if (!name || !email || !password || !role || !phone || !cnic_front || !cnic_back) {
      return res.status(400).json({ error: 'All fields (name, email, password, role, phone, cnic_front, cnic_back) are required' });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Validate role
    if (!['student', 'teacher'].includes(role)) {
      return res.status(400).json({ error: 'Role must be either "student" or "teacher"' });
    }

    // Validate password strength
    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters long' });
    }

    // Check if user already exists
    const existingUser = await db.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }

    // Save CNIC images
    let relativeFrontCnicPath;
    let relativeBackCnicPath;
    try {
      relativeFrontCnicPath = saveCnicImage(cnic_front);
      relativeBackCnicPath = saveCnicImage(cnic_back);
      if (!relativeFrontCnicPath || !relativeBackCnicPath) {
        return res.status(400).json({ error: 'Invalid CNIC image format' });
      }
    } catch (uploadErr) {
      console.error('Failed to save CNIC images:', uploadErr);
      return res.status(500).json({ error: 'Failed to save CNIC image files' });
    }

    // Hash password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Insert new user
    const query = `
      INSERT INTO users (name, email, password_hash, role, phone, cnic_front, cnic_back, cnic_pic)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $6)
      RETURNING id, name, email, role, phone, cnic_front, cnic_back, created_at
    `;

    const result = await db.query(query, [name, email, password_hash, role, phone, relativeFrontCnicPath, relativeBackCnicPath]);

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: result.rows[0].id, 
        email: result.rows[0].email, 
        role: result.rows[0].role 
      },
      process.env.JWT_SECRET || 'your_jwt_secret_key',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      user: result.rows[0],
      token: token
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

// POST /api/auth/login - Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await db.query(query, [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result.rows[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        role: user.role 
      },
      process.env.JWT_SECRET || 'your_jwt_secret_key',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        created_at: user.created_at
      },
      token: token
    });
  } catch (error) {
    console.error('Error logging in user:', error);
    res.status(500).json({ error: 'Failed to login user' });
  }
});

// GET /api/auth/me - Get current user details and verification status
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, name, email, role, phone, cnic_front, cnic_back, is_verified, created_at FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Error in /me:', error);
    return res.status(500).json({ error: 'Failed to fetch user data' });
  }
});

// PUT /api/auth/complete-verification - Complete verification data for older accounts
router.put('/complete-verification', authMiddleware, async (req, res) => {
  try {
    const { phone, cnic_front, cnic_back } = req.body;

    if (!phone || !cnic_front || !cnic_back) {
      return res.status(400).json({ error: 'Phone number and CNIC front & back images are required' });
    }

    // Save base64 images
    const relativeFrontCnicPath = saveCnicImage(cnic_front);
    const relativeBackCnicPath = saveCnicImage(cnic_back);

    if (!relativeFrontCnicPath || !relativeBackCnicPath) {
      return res.status(400).json({ error: 'Invalid CNIC image format' });
    }

    // Update user details and reset verification state to await admin review
    const query = `
      UPDATE users
      SET phone = $1, cnic_front = $2, cnic_back = $3, cnic_pic = $2, is_verified = false
      WHERE id = $4
      RETURNING id, name, email, role, phone, cnic_front, cnic_back, is_verified
    `;

    const result = await db.query(query, [phone, relativeFrontCnicPath, relativeBackCnicPath, req.user.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json({
      message: 'Verification details updated successfully and pending admin review',
      user: result.rows[0]
    });
  } catch (error) {
    console.error('Error in complete-verification:', error);
    return res.status(500).json({ error: 'Failed to update verification details' });
  }
});

module.exports = router;