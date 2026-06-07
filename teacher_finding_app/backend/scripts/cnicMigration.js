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

async function runMigration() {
  const client = await pool.connect();
  try {
    console.log('Running CNIC & Phone column migration...');
    await client.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS phone VARCHAR(20),
      ADD COLUMN IF NOT EXISTS cnic_pic TEXT;
    `);
    console.log('✅ Migration ran successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  } finally {
    client.release();
    pool.end();
  }
}

runMigration();
