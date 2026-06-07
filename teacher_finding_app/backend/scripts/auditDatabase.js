/**
 * DATABASE AUDIT SCRIPT
 * Safe read-only audit of database state
 * Reports on: tables, ENUM values, users, data integrity
 * Run: node scripts/auditDatabase.js
 */

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

async function auditDatabase() {
  try {
    console.log('\n=== DATABASE AUDIT REPORT ===\n');

    // 1. Check connection
    console.log('📡 Testing database connection...');
    const client = await pool.connect();
    console.log('✅ Connection successful\n');
    client.release();

    // 2. Check ENUM values for user_role
    console.log('📋 Checking user_role ENUM values...');
    const enumResult = await pool.query(`
      SELECT enum_range(NULL::user_role) as enum_values;
    `);
    const enumValues = enumResult.rows[0]?.enum_values || [];
    console.log(`   Values: ${enumValues || 'ENUM not found'}`);
    console.log(`   Has 'admin': ${enumValues?.includes('admin') ? '✅ YES' : '❌ NO'}`);
    console.log(`   Has 'teacher': ${enumValues?.includes('teacher') ? '✅ YES' : '❌ NO'}`);
    console.log(`   Has 'student': ${enumValues?.includes('student') ? '✅ YES' : '❌ NO'}\n`);

    // 3. List all tables
    console.log('📦 Checking existing tables...');
    const tableResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);
    const tables = tableResult.rows.map(r => r.table_name);
    console.log(`   Found ${tables.length} tables:`);
    tables.forEach(t => console.log(`   ✅ ${t}`));
    console.log();

    // 4. Check for required tables
    const requiredTables = ['users', 'teacher_profiles', 'requests', 'payments', 'notifications', 'class_sessions', 'reviews'];
    console.log('🔍 Checking for required tables...');
    for (const table of requiredTables) {
      const exists = tables.includes(table);
      console.log(`   ${exists ? '✅' : '❌'} ${table}`);
    }
    console.log();

    // 5. Count users by role
    console.log('👥 Users by role:');
    const usersResult = await pool.query(`
      SELECT role, COUNT(*) as count 
      FROM users 
      GROUP BY role 
      ORDER BY role;
    `);
    usersResult.rows.forEach(row => {
      console.log(`   ${row.role}: ${row.count} users`);
    });
    console.log();

    // 6. List all users
    console.log('📊 All users in database:');
    const allUsersResult = await pool.query(`
      SELECT id, name, email, role, created_at 
      FROM users 
      ORDER BY created_at DESC;
    `);
    if (allUsersResult.rows.length === 0) {
      console.log('   (No users found)');
    } else {
      allUsersResult.rows.forEach(user => {
        console.log(`   • ${user.name} (${user.email}) - ${user.role}`);
      });
    }
    console.log();

    // 7. Check for admin users (safe - won't error if admin role missing)
    console.log('🎛️  Admin users:');
    let adminResult = { rows: [] };
    try {
      adminResult = await pool.query(`
        SELECT id, name, email 
        FROM users 
        WHERE role = 'admin';
      `);
    } catch (e) {
      // Admin role doesn't exist in ENUM
      console.log('   ⚠️  Admin role not in ENUM yet');
    }
    if (adminResult.rows.length === 0) {
      console.log('   ❌ NO ADMIN USERS FOUND');
    } else {
      adminResult.rows.forEach(admin => {
        console.log(`   ✅ ${admin.name} (${admin.email})`);
      });
    }
    console.log();

    // 8. Check data integrity
    console.log('🔗 Data integrity checks:');
    
    // Orphaned teacher profiles (profiles without users)
    if (tables.includes('teacher_profiles')) {
      const orphanedProfiles = await pool.query(`
        SELECT tp.id, tp.user_id 
        FROM teacher_profiles tp 
        LEFT JOIN users u ON tp.user_id = u.id 
        WHERE u.id IS NULL;
      `);
      console.log(`   Orphaned teacher profiles: ${orphanedProfiles.rows.length}`);
    }

    // Teachers without profiles
    const teachersNoProfile = await pool.query(`
      SELECT COUNT(*) as count 
      FROM users u 
      WHERE u.role = 'teacher' 
      AND NOT EXISTS (
        SELECT 1 FROM teacher_profiles tp WHERE tp.user_id = u.id
      );
    `);
    console.log(`   Teachers without profiles: ${teachersNoProfile.rows[0].count}`);
    console.log();

    // 9. Table record counts
    console.log('📈 Record counts:');
    for (const table of tables) {
      const countResult = await pool.query(`SELECT COUNT(*) as count FROM ${table};`);
      const count = countResult.rows[0].count;
      console.log(`   ${table}: ${count} records`);
    }
    console.log();

    // 10. Check for triggers
    console.log('⏱️  Auto-update triggers:');
    const triggerResult = await pool.query(`
      SELECT trigger_name, event_object_table
      FROM information_schema.triggers
      WHERE event_object_schema = 'public'
      ORDER BY event_object_table;
    `);
    if (triggerResult.rows.length === 0) {
      console.log('   No triggers found');
    } else {
      triggerResult.rows.forEach(t => {
        console.log(`   ${t.trigger_name} on ${t.event_object_table}`);
      });
    }
    console.log();

    // Summary
    console.log('=== AUDIT SUMMARY ===');
    console.log(`✅ Database connection: OK`);
    console.log(`${enumValues?.includes('admin') ? '✅' : '❌'} Admin role in ENUM: ${enumValues?.includes('admin') ? 'YES' : 'MISSING'}`);
    console.log(`✅ Required tables: ${tables.filter(t => requiredTables.includes(t)).length}/${requiredTables.length}`);
    console.log(`${adminResult && adminResult.rows && adminResult.rows.length > 0 ? '✅' : '❌'} Admin accounts: ${adminResult && adminResult.rows ? adminResult.rows.length : 0} found`);
    console.log(`✅ Total users: ${allUsersResult.rows.length}`);
    console.log();

    process.exit(0);
  } catch (error) {
    console.error('❌ Audit error:', error.message);
    console.error('Details:', error);
    process.exit(1);
  }
}

auditDatabase();
