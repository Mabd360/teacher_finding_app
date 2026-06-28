const db = require('../db');

async function run() {
  try {
    const result = await db.query("SELECT email, cnic_front, cnic_back FROM users WHERE email = 'student1@gmail.com'");
    if (result.rows.length === 0) {
      console.log("User not found!");
      process.exit(0);
    }
    const user = result.rows[0];
    console.log("Email:", user.email);
    console.log("cnic_front (length):", user.cnic_front ? user.cnic_front.length : 0);
    console.log("cnic_front (first 100 chars):", user.cnic_front ? user.cnic_front.substring(0, 100) : "null");
    console.log("cnic_back (length):", user.cnic_back ? user.cnic_back.length : 0);
    console.log("cnic_back (first 100 chars):", user.cnic_back ? user.cnic_back.substring(0, 100) : "null");
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

run();
