const pool = require('../db');

async function run() {
  try {
    console.log('Altering users table to add missing columns...');
    await pool.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS phone VARCHAR(20),
      ADD COLUMN IF NOT EXISTS cnic_pic TEXT,
      ADD COLUMN IF NOT EXISTS cnic_front TEXT,
      ADD COLUMN IF NOT EXISTS cnic_back TEXT;
    `);
    console.log('✅ Columns added successfully!');
  } catch (err) {
    console.error('Error modifying table:', err);
  } finally {
    await pool.end();
  }
}

run();
