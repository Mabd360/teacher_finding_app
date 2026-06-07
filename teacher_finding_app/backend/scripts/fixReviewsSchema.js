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
    console.log('Ensuring reviews table has session_id column matching the endpoint logic...');
    
    // Drop reviews if it doesn't match the reviewRoutes.js design
    await client.query(`DROP TABLE IF EXISTS reviews CASCADE;`);
    
    await client.query(`
      CREATE TABLE reviews (
        id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
        session_id      UUID         NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
        student_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        teacher_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        rating          INTEGER      NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment         TEXT,
        created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
        updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
      );
    `);
    
    await client.query(`CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_unique_session ON reviews(session_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_reviews_teacher_id ON reviews(teacher_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_reviews_student_id ON reviews(student_id);`);

    console.log('✅ Reviews table schema resolved successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Reviews schema update failed:', error);
    process.exit(1);
  } finally {
    client.release();
    pool.end();
  }
}

runMigration();
