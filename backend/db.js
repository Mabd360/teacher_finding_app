// =============================================================================
// db.js — PostgreSQL Connection Pool
// =============================================================================
// Uses the `pg` package to create a reusable connection pool.
// All connection parameters are read from environment variables so that
// credentials are never hard-coded in source control.
// =============================================================================

const { Pool } = require("pg");
require("dotenv").config();

// Create a connection pool.  The pool automatically manages multiple clients
// and reuses idle connections, which is much more efficient than opening a new
// connection for every query.
const pool = new Pool({
  host: process.env.DB_HOST, // PostgreSQL server hostname (e.g. "localhost")
  port: process.env.DB_PORT, // PostgreSQL port (default 5432)
  user: process.env.DB_USER, // Database username
  password: process.env.DB_PASSWORD, // Database password
  database: process.env.DB_NAME, // Database name (e.g. "teacher_finder")
});

// Verify the connection on startup so we fail fast if the DB is unreachable.
pool
  .connect()
  .then((client) => {
    console.log("Connected to PostgreSQL");
    client.release(); // return the client back to the pool
  })
  .catch((err) => {
    console.error("Failed to connect to PostgreSQL:", err.message);
  });

// Export the pool so other modules can run queries with pool.query(...)
module.exports = pool;
