/**
 * Seed Teachers Script
 * Creates 3 teacher profiles with test data
 * Run: node scripts/seedTeachers.js
 */

const bcrypt = require('bcrypt');
const db = require('../db');

async function seedTeachers() {
  try {
    console.log('🌱 Starting teacher seed...\n');

    // Teacher data
    const teachers = [
      {
        name: 'Dr. Sarah Ahmed',
        email: 'sarah.ahmed@teacherfinder.com',
        password: 'password123', // will be hashed
        role: 'teacher',
        subjects: ['Database', 'SQL', 'PostgreSQL', 'MySQL'],
        fee_per_hour: 35.00,
        availability: { note: 'Mon-Fri 9AM-5PM, Sat 10AM-2PM' },
        bio: 'Expert in database design and optimization with 10+ years experience. Specializing in relational databases and data modeling.'
      },
      {
        name: 'Muhammad Hassan',
        email: 'muhammad.hassan@teacherfinder.com',
        password: 'password123',
        role: 'teacher',
        subjects: ['Mobile Application Development', 'Flutter', 'Android', 'iOS'],
        fee_per_hour: 40.00,
        availability: { note: 'Tue-Thu 4PM-8PM, Sat-Sun 2PM-6PM' },
        bio: 'Full-stack mobile developer with expertise in Flutter and native development. Built 50+ production apps.'
      },
      {
        name: 'Prof. Fatima Khan',
        email: 'fatima.khan@teacherfinder.com',
        password: 'password123',
        role: 'teacher',
        subjects: ['Machine Learning', 'Python', 'Data Science', 'AI'],
        fee_per_hour: 50.00,
        availability: { note: 'Mon, Wed, Fri 6PM-9PM, Weekends flexible' },
        bio: 'Ph.D. in Machine Learning. Worked at tech companies on ML systems. Passion for teaching AI concepts.'
      }
    ];

    // Create teachers
    for (const teacher of teachers) {
      // Check if teacher already exists
      const existingTeacher = await db.query(
        'SELECT id FROM users WHERE email = $1',
        [teacher.email]
      );

      if (existingTeacher.rows.length > 0) {
        console.log(`✓ ${teacher.name} already exists. Skipping...`);
        continue;
      }

      // Hash password
      const passwordHash = await bcrypt.hash(teacher.password, 10);

      // Insert user
      const userResult = await db.query(
        `INSERT INTO users (name, email, password_hash, role)
         VALUES ($1, $2, $3, $4)
         RETURNING id`,
        [teacher.name, teacher.email, passwordHash, teacher.role]
      );

      const userId = userResult.rows[0].id;

      // Insert teacher profile
      await db.query(
        `INSERT INTO teacher_profiles (user_id, subjects, fee_per_hour, availability, bio)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          userId,
          teacher.subjects,
          teacher.fee_per_hour,
          JSON.stringify(teacher.availability),
          teacher.bio
        ]
      );

      console.log(`✅ Created teacher: ${teacher.name}`);
      console.log(`   Email: ${teacher.email}`);
      console.log(`   Subjects: ${teacher.subjects.join(', ')}`);
      console.log(`   Fee: $${teacher.fee_per_hour}/hour\n`);
    }

    console.log('✅ Teacher seeding completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding teachers:', error);
    process.exit(1);
  }
}

seedTeachers();
