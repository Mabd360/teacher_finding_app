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
    console.log('Running Features Migration...');
    
    // Add is_verified column
    await client.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;
    `);
    
    // Auto verify existing/seed accounts so they are immediately usable
    await client.query(`
      UPDATE users 
      SET is_verified = TRUE 
      WHERE email IN ('admin@teacherfinder.com', 'ali.khan@example.com', 'sara.ahmed@example.com') 
         OR role = 'admin';
    `);

    // Create messages table
    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        message TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      );
    `);
    
    // Create indexes on messages
    await client.query(`CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiver_id);`);

    console.log('✅ Features migration executed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Features migration failed:', error);
    process.exit(1);
  } finally {
    client.release();
    pool.end();
  }
}

runMigration();
