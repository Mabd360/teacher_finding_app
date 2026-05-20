// =============================================================================
// server.js — Main Express Application
// =============================================================================
// Entry point for the Teacher Finder backend API.
// Sets up middleware (CORS, JSON parsing) and mounts route modules.
// =============================================================================

const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./authRoutes");
const authMiddleware = require("./authMiddleware");

const app = express();
const PORT = process.env.PORT || 5000;

// ---------------------------------------------------------------------------
// Middleware
// ---------------------------------------------------------------------------

// Enable Cross-Origin Resource Sharing so the Flutter frontend (or Postman)
// can make requests to this API from a different origin.
app.use(cors());

// Parse incoming JSON request bodies (req.body will be a JS object).
app.use(express.json());

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

// Public auth routes — no token required
app.use("/api/auth", authRoutes);

// Example protected route — requires a valid JWT
app.get("/api/protected", authMiddleware, (req, res) => {
  res.json({
    success: true,
    message: "You have access to this protected route",
    user: req.user, // decoded JWT payload (id, role)
  });
});

// Health check endpoint
app.get("/", (req, res) => {
  res.json({ message: "Teacher Finder API is running" });
});

// ---------------------------------------------------------------------------
// Start the server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
