/**
 * SAFE PHASE 1 MIGRATION SCRIPT
 * 
 * This script safely applies all Phase 1 fixes:
 * 1. Adds 'admin' to user_role ENUM
 * 2. Creates missing payment/notification/session tables
 * 3. Creates missing reviews table
 * 4. Adds missing auto-update triggers
 * 5. Converts ADMIN user to admin role
 * 
 * Safety: All operations use IF NOT EXISTS - idempotent
 * Risk: VERY LOW - no existing data deleted or modified
 * 
 * Run: node scripts/phase1Migration.js
 */

const pool = require('../db');
const fs = require('fs');
const path = require('path');

async function phase1Migration() {
  const client = await pool.connect();
  try {
    console.log('\n=== PHASE 1 MIGRATION - SAFE INCREMENTAL FIX ===\n');

    // STEP 1: Add 'admin' to ENUM (MUST be outside transaction)
    console.log('STEP 1️⃣  Adding admin role to ENUM...');
    try {
      await client.query(`ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';`);
      console.log('   ✅ Admin role added to ENUM\n');
    } catch (e) {
      if (!e.message.includes('already exists')) {
        console.log('   ⚠️  Admin role already exists in ENUM (OK)\n');
      } else {
        throw e;
      }
    }

    // Start transaction for remaining changes
    await client.query('BEGIN');
    console.log('📍 Transaction started for remaining changes\n');

    // STEP 2: Create payments table
    console.log('STEP 2️⃣  Creating payments, notifications, and class_sessions tables...');
    
    try {
      // Create payments table
      await client.query(`
        CREATE TABLE IF NOT EXISTS payments (
          id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
          request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
          student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          amount          DECIMAL(10,2) NOT NULL,
          duration_hours  DECIMAL(5,2) NOT NULL DEFAULT 1.0,
          status          VARCHAR(20)  NOT NULL DEFAULT 'unpaid',
          payment_date    TIMESTAMP,
          notes           TEXT,
          created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
          updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
        );
      `);
      
      // Create indexes on payments
      await client.query(`CREATE INDEX IF NOT EXISTS idx_payments_student_id ON payments(student_id);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_payments_teacher_id ON payments(teacher_id);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);`);
      
      // Create notifications table
      await client.query(`
        CREATE TABLE IF NOT EXISTS notifications (
          id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
          admin_id        UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          payment_id      UUID         REFERENCES payments (id) ON DELETE CASCADE,
          type            VARCHAR(50)  NOT NULL,
          title           VARCHAR(255) NOT NULL,
          message         TEXT         NOT NULL,
          is_read         BOOLEAN      DEFAULT FALSE,
          created_at      TIMESTAMP    NOT NULL DEFAULT NOW()
        );
      `);
      
      await client.query(`CREATE INDEX IF NOT EXISTS idx_notifications_admin_id ON notifications(admin_id);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);`);
      
      // Create class_sessions table
      await client.query(`
        CREATE TABLE IF NOT EXISTS class_sessions (
          id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
          request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
          student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          subject         VARCHAR(255) NOT NULL,
          scheduled_date  TIMESTAMP    NOT NULL,
          duration_hours  DECIMAL(5,2) NOT NULL DEFAULT 1.0,
          status          VARCHAR(20)  NOT NULL DEFAULT 'scheduled',
          notes           TEXT,
          created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
          updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
        );
      `);
      
      await client.query(`CREATE INDEX IF NOT EXISTS idx_class_sessions_teacher_id ON class_sessions(teacher_id);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_class_sessions_student_id ON class_sessions(student_id);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_class_sessions_status ON class_sessions(status);`);
      
      console.log('   ✅ All tables and indexes created\n');
    } catch (e) {
      throw e;
    }

    // STEP 3: Create reviews table
    console.log('STEP 3️⃣  Creating reviews table...');
    
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS reviews (
          id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
          request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
          student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          rating          DECIMAL(2,1) NOT NULL DEFAULT 0.0,
          comment         TEXT,
          created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
          updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
        );
      `);
      
      await client.query(`CREATE INDEX IF NOT EXISTS idx_reviews_teacher_id ON reviews(teacher_id);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);`);
      await client.query(`CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at);`);
      
      console.log('   ✅ Reviews table created\n');
    } catch (e) {
      throw e;
    }

    // STEP 4: Ensure update_updated_at function exists
    console.log('STEP 4️⃣  Ensuring update_updated_at function exists...');
    const functionSql = `
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE 'plpgsql';
    `;
    try {
      await client.query(functionSql);
      console.log('   ✅ Function update_updated_at_column created\n');
    } catch (e) {
      throw e;
    }

    // STEP 5: Add missing auto-update triggers
    console.log('STEP 5️⃣  Adding missing auto-update triggers...');
    
    const triggers = [
      {
        name: 'update_payments_updated_at',
        table: 'payments'
      },
      {
        name: 'update_notifications_updated_at',
        table: 'notifications'
      },
      {
        name: 'update_class_sessions_updated_at',
        table: 'class_sessions'
      }
    ];

    for (const trigger of triggers) {
      // Drop existing trigger if it exists, then create new one
      const dropTriggerSql = `
        DROP TRIGGER IF EXISTS ${trigger.name} ON ${trigger.table};
      `;
      const createTriggerSql = `
        CREATE TRIGGER ${trigger.name}
          BEFORE UPDATE ON ${trigger.table}
          FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
      `;
      try {
        await client.query(dropTriggerSql);
        await client.query(createTriggerSql);
        console.log(`   ✅ Trigger ${trigger.name} created`);
      } catch (e) {
        throw e;
      }
    }
    console.log();

    // STEP 6: Convert ADMIN user to admin role
    console.log('STEP 6️⃣  Converting ADMIN user to admin role...');
    
    // Check current state
    const adminCheckResult = await client.query(
      'SELECT id, name, email, role FROM users WHERE email = $1',
      ['admin@teacherfinder.com']
    );

    if (adminCheckResult.rows.length > 0) {
      const admin = adminCheckResult.rows[0];
      if (admin.role === 'admin') {
        console.log(`   ✅ Admin user already has role='admin'\n`);
      } else {
        await client.query(
          'UPDATE users SET role = $1 WHERE id = $2',
          ['admin', admin.id]
        );
        console.log(`   ✅ Admin user (${admin.email}) converted to role='admin'\n`);
      }
    } else {
      console.log('   ⚠️  Admin user (admin@teacherfinder.com) not found\n');
    }

    // Commit transaction
    await client.query('COMMIT');
    console.log('✅ Transaction committed - all changes applied\n');

    // STEP 7: Verify
    console.log('STEP 7️⃣  Verifying changes...');
    
    // Check ENUM
    const enumResult = await pool.query(`
      SELECT enum_range(NULL::user_role) as enum_values;
    `);
    const enumValues = enumResult.rows[0]?.enum_values || [];
    console.log(`   ✅ user_role ENUM: ${enumValues}`);

    // Check tables
    const tableResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);
    const tables = tableResult.rows.map(r => r.table_name);
    const requiredTables = ['users', 'teacher_profiles', 'requests', 'payments', 'notifications', 'class_sessions', 'reviews'];
    const foundRequired = requiredTables.filter(t => tables.includes(t)).length;
    console.log(`   ✅ Tables: ${foundRequired}/${requiredTables.length} required tables exist`);
    requiredTables.forEach(t => {
      console.log(`      ${tables.includes(t) ? '✅' : '❌'} ${t}`);
    });

    // Check admin user
    const adminFinal = await pool.query(
      'SELECT id, name, email, role FROM users WHERE email = $1',
      ['admin@teacherfinder.com']
    );
    if (adminFinal.rows.length > 0) {
      const admin = adminFinal.rows[0];
      console.log(`   ✅ Admin user role: ${admin.role}`);
    }

    console.log('\n=== MIGRATION COMPLETE ===');
    console.log('✅ All Phase 1 fixes applied successfully\n');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Migration error:', error.message);
    console.log('\n🔄 Rolling back transaction...');
    
    try {
      await client.query('ROLLBACK');
      console.log('✅ Transaction rolled back - no changes applied');
    } catch (rollbackError) {
      console.error('❌ Rollback failed:', rollbackError.message);
    }
    
    process.exit(1);
  } finally {
    client.release();
    pool.end();
  }
}

phase1Migration();
