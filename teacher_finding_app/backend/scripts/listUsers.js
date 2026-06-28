const db = require('../db');

async function run() {
  try {
    const result = await db.query("SELECT id, name, email, role, is_verified FROM users ORDER BY created_at DESC");
    console.log("--- Registered Users in Neon ---");
    result.rows.forEach(u => {
      console.log(`- ${u.name} (${u.email}) | Role: ${u.role} | Verified: ${u.is_verified}`);
    });
    process.exit(0);
  } catch (err) {
    console.error("Failed to query users:", err);
    process.exit(1);
  }
}

run();
