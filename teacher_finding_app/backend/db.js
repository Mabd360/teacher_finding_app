// Database connection module
// Save this as db.js in your backend root

const { Pool } = require('pg');
const dotenv = require('dotenv');

dotenv.config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

module.exports = pool;

// Test database connection on server startup
pool.connect()
  .then((client) => {
    console.log('Database connected successfully');
    client.release();
  })
  .catch((err) => {
    console.error('Database connection failed:', err);
  });
