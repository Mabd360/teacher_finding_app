/**
 * fixAdmin.js
 * Ensures the admin user exists with role 'admin' and resets password to 'admin123'.
 * Run: node scripts/fixAdmin.js
 */

const bcrypt = require('bcrypt');
const db = require('../db');

async function fixAdmin() {
  try {
    const email = 'admin@teacherfinder.com';
    const password = 'admin123';

    console.log(`Searching for user with email: ${email}`);
    const res = await db.query('SELECT id, role FROM users WHERE email = $1', [email]);

    const hash = await bcrypt.hash(password, 10);

    if (res.rows.length > 0) {
      const user = res.rows[0];
      if (user.role === 'admin') {
        // Ensure password is updated to known value
        await db.query('UPDATE users SET password_hash = $1 WHERE id = $2', [hash, user.id]);
        console.log(`✅ Admin user already present (id=${user.id}). Password reset to default.`);
      } else {
        // Promote to admin and reset password
        await db.query('UPDATE users SET role = $1, password_hash = $2 WHERE id = $3', ['admin', hash, user.id]);
        console.log(`✅ User (id=${user.id}) promoted to admin and password reset.`);
      }
    } else {
      // Insert new admin user
      const name = 'Admin User';
      const insert = await db.query(
        `INSERT INTO users (name, email, password_hash, role)
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [name, email, hash, 'admin']
      );
      console.log(`✅ Admin user created (id=${insert.rows[0].id}).`);
    }

    console.log('\n⚠️  Important: change the admin password after first login.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error fixing admin user:', err);
    process.exit(1);
  }
}

fixAdmin();
