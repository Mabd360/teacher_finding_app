const db = require('../db');

async function checkRequests() {
  try {
    const result = await db.query(`
      SELECT 
        r.id,
        r.status,
        r.message,
        u1.name as student_name,
        u2.name as teacher_name
      FROM requests r
      JOIN users u1 ON r.student_id = u1.id
      JOIN users u2 ON r.teacher_id = u2.id
    `);
    
    console.log('--- Database Requests ---');
    if (result.rows.length === 0) {
      console.log('No requests found.');
    } else {
      result.rows.forEach(row => {
        console.log(`ID: ${row.id}`);
        console.log(`From Student: ${row.student_name}`);
        console.log(`To Teacher: ${row.teacher_name}`);
        console.log(`Status: ${row.status}`);
        console.log(`Message: ${row.message}`);
        console.log('-------------------------');
      });
    }
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

checkRequests();
