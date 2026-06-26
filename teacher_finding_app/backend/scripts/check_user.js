const db = require('../db');

async function checkUser() {
  try {
    const userRes = await db.query("SELECT id, name, email, role FROM users WHERE email = 'newstudent@gmail.com'");
    if (userRes.rows.length === 0) {
      console.log('No user with email newstudent@gmail.com found.');
      process.exit(0);
    }
    const user = userRes.rows[0];
    console.log(`User: ${user.name} | Email: ${user.email} | Role: ${user.role} | ID: ${user.id}`);

    // Query requests sent by this user
    const reqRes = await db.query("SELECT id, status, message FROM requests WHERE student_id = $1", [user.id]);
    console.log(`Number of requests sent: ${reqRes.rows.length}`);
    reqRes.rows.forEach(r => {
      console.log(`Request ID: ${r.id} | Status: ${r.status} | Message: ${r.message}`);
    });

    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

checkUser();
