// =============================================================================
// authMiddleware.js — JWT Authentication Middleware
// =============================================================================
// Protects routes by requiring a valid JWT in the Authorization header.
//
// Usage:
//   const authMiddleware = require("./authMiddleware");
//   router.get("/profile", authMiddleware, (req, res) => { ... });
//
// Expected header format:
//   Authorization: Bearer <token>
//
// On success the decoded payload (id, role) is attached to req.user.
// On failure a 401 Unauthorized response is returned.
// =============================================================================

const jwt = require("jsonwebtoken");
require("dotenv").config();

const authMiddleware = (req, res, next) => {
  // --- 1. Read the Authorization header ---
  const authHeader = req.headers.authorization;

  // Check that the header exists and starts with "Bearer "
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Access denied. No token provided.",
    });
  }

  // Extract the token (everything after "Bearer ")
  const token = authHeader.split(" ")[1];

  try {
    // --- 2. Verify the token using the same secret that signed it ---
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // --- 3. Attach the decoded payload to the request object ---
    // Downstream route handlers can now access req.user.id and req.user.role
    req.user = decoded;

    // Continue to the next middleware / route handler
    next();
  } catch (error) {
    // Token is expired, malformed, or signed with a different secret
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};

module.exports = authMiddleware;
