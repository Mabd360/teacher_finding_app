// =============================================================================
// authRoutes.js — Authentication Routes (Register & Login)
// =============================================================================
// POST /api/auth/register — create a new user account
// POST /api/auth/login    — authenticate and receive a JWT
// =============================================================================

const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const pool = require("./db");

const router = express.Router();

// ---------------------------------------------------------------------------
// POST /api/auth/register
// ---------------------------------------------------------------------------
// Accepts: { name, email, password, role }
// Steps:
//   1. Validate that all required fields are present
//   2. Check if a user with the same email already exists
//   3. Hash the password with bcrypt (10 salt rounds)
//   4. Insert the new user into the `users` table
//   5. Return success with the new user's id
// ---------------------------------------------------------------------------
router.post("/register", async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    // --- 1. Validate required fields ---
    if (!name || !email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: "All fields are required: name, email, password, role",
      });
    }

    // Validate that role is either 'student' or 'teacher'
    if (!["student", "teacher"].includes(role)) {
      return res.status(400).json({
        success: false,
        message: "Role must be either 'student' or 'teacher'",
      });
    }

    // --- 2. Check if email already exists ---
    const existingUser = await pool.query(
      "SELECT id FROM users WHERE email = $1",
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "A user with this email already exists",
      });
    }

    // --- 3. Hash the password (salt rounds = 10) ---
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // --- 4. Insert into the users table ---
    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role, created_at`,
      [name, email, passwordHash, role]
    );

    const newUser = result.rows[0];

    // --- 5. Return success ---
    return res.status(201).json({
      success: true,
      message: "User registered successfully",
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role,
        created_at: newUser.created_at,
      },
    });
  } catch (error) {
    console.error("Register error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
});

// ---------------------------------------------------------------------------
// POST /api/auth/login
// ---------------------------------------------------------------------------
// Accepts: { email, password }
// Steps:
//   1. Validate that email and password are provided
//   2. Find the user by email in the database
//   3. Compare the submitted password with the stored hash using bcrypt
//   4. If valid, generate a JWT (expires in 7 days) with user id and role
//   5. Return the token and user info
// ---------------------------------------------------------------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // --- 1. Validate required fields ---
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    // --- 2. Find user by email ---
    const result = await pool.query(
      "SELECT id, name, email, password_hash, role FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const user = result.rows[0];

    // --- 3. Compare passwords ---
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // --- 4. Generate JWT (expires in 7 days) ---
    const token = jwt.sign(
      { id: user.id, role: user.role }, // payload
      process.env.JWT_SECRET, // secret key from .env
      { expiresIn: "7d" } // token expires in 7 days
    );

    // --- 5. Return token and user info ---
    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Login error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
});

module.exports = router;
