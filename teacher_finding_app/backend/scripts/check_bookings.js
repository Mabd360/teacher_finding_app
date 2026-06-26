const db = require('../db');

async function checkBookings() {
  try {
    const result = await db.query(`
      SELECT 
        cs.id,
        cs.status,
        cs.subject,
        u1.name as student_name,
        u2.name as teacher_name,
        p.status as payment_status
      FROM class_sessions cs
      JOIN users u1 ON cs.student_id = u1.id
      JOIN users u2 ON cs.teacher_id = u2.id
      LEFT JOIN payments p ON p.request_id = cs.request_id
    `);
    
    console.log('--- Database Bookings ---');
    if (result.rows.length === 0) {
      console.log('No bookings found.');
    } else {
      result.rows.forEach(row => {
        console.log(`ID: ${row.id}`);
        console.log(`Student: ${row.student_name}`);
        console.log(`Teacher: ${row.teacher_name}`);
        console.log(`Subject: ${row.subject}`);
        console.log(`Session Status: ${row.status}`);
        console.log(`Payment Status: ${row.payment_status}`);
        console.log('-------------------------');
      });
    }
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

checkBookings();
