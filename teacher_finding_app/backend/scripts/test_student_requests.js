const db = require('../db');

async function testStudentRequests() {
  try {
    // 1. Get Tony Stark's ID
    const userRes = await db.query("SELECT id, name FROM users WHERE name = 'Tony Stark'");
    if (userRes.rows.length === 0) {
      console.log('No user Tony Stark found.');
      process.exit(0);
    }
    const user = userRes.rows[0];
    console.log(`User found: ${user.name} (ID: ${user.id})`);

    // 2. Query requests for this user exactly like backend routes do
    const query = `
      SELECT
        r.id,
        r.teacher_id,
        u.name AS teacher_name,
        CASE WHEN r.status = 'accepted' THEN u.email ELSE NULL END AS teacher_email,
        CASE WHEN r.status = 'accepted' THEN u.phone ELSE NULL END AS teacher_phone,
        tp.subjects,
        r.message,
        r.status,
        r.created_at,
        r.updated_at
      FROM requests r
      JOIN users u ON r.teacher_id = u.id
      LEFT JOIN teacher_profiles tp ON tp.user_id = u.id
      WHERE r.student_id = $1
      ORDER BY r.created_at DESC
    `;

    const result = await db.query(query, [user.id]);
    console.log('\n--- Student Request Rows ---');
    console.log(JSON.stringify(result.rows, null, 2));
    
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

testStudentRequests();
