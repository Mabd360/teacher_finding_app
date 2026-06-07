/**
 * Seed Admin User Script
 * Creates an admin user account
 * Run: node scripts/seedAdmin.js
 */

const bcrypt = require('bcrypt');
const db = require('../db');

async function seedAdmin() {
  try {
    console.log('🌱 Creating admin user...\n');

    const adminData = {
      name: 'Admin User',
      email: 'admin@teacherfinder.com',
      password: 'admin123', // Change this in production!
      role: 'admin'
    };

    // Check if user with this email already exists
    const existingAdmin = await db.query(
      'SELECT id, role FROM users WHERE email = $1',
      [adminData.email]
    );

    // If user exists, promote to admin and reset password_hash to the seed password
    if (existingAdmin.rows.length > 0) {
      const user = existingAdmin.rows[0];
      const passwordHash = await bcrypt.hash(adminData.password, 10);

      await db.query(
        'UPDATE users SET role = $1, password_hash = $2 WHERE id = $3',
        [adminData.role, passwordHash, user.id]
      );

      console.log(`✓ Existing user (id=${user.id}) updated to role 'admin' and password reset.`);
      console.log(`  Email: ${adminData.email}`);
      process.exit(0);
    }

    // Hash password
    const passwordHash = await bcrypt.hash(adminData.password, 10);

    // Insert admin user
    const result = await db.query(
      `INSERT INTO users (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role`,
      [adminData.name, adminData.email, passwordHash, adminData.role]
    );

    console.log('✅ Admin user created successfully!');
    console.log(`\n📋 Admin Credentials:`);
    console.log(`   Email: ${result.rows[0].email}`);
    console.log(`   Password: ${adminData.password}`);
    console.log(`\n⚠️  IMPORTANT: Change the password after first login!\n`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin:', error);
    process.exit(1);
  }
}

seedAdmin();
