const pool = require('../db');
const fs = require('fs');
const path = require('path');

async function run() {
  try {
    const schemaPath = path.join(__dirname, '../../database/schema.sql');
    console.log('Reading schema from:', schemaPath);
    const sql = fs.readFileSync(schemaPath, 'utf8');

    console.log('Executing schema...');
    await pool.query(sql);
    console.log('Database schema initialized successfully!');
  } catch (err) {
    console.error('Error initializing schema:', err);
  } finally {
    await pool.end();
  }
}

run();
