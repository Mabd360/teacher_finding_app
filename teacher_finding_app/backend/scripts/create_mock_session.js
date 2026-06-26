const db = require('../db');

async function createMockSession() {
  try {
    console.log('🌱 Starting mock session creation...');

    // 1. Get first teacher
    const teacherResult = await db.query(
      "SELECT id, name, email FROM users WHERE role = 'teacher' LIMIT 1"
    );

    if (teacherResult.rows.length === 0) {
      console.log('❌ No teacher found in database. Please register a teacher first.');
      process.exit(1);
    }
    const teacher = teacherResult.rows[0];
    console.log(`👨‍🏫 Found Teacher: ${teacher.name} (${teacher.email})`);

    // Ensure teacher profile exists
    const profileResult = await db.query(
      "SELECT id FROM teacher_profiles WHERE user_id = $1",
      [teacher.id]
    );
    if (profileResult.rows.length === 0) {
      console.log('🛠 Profile missing. Seeding basic profile...');
      await db.query(
        `INSERT INTO teacher_profiles (user_id, subjects, fee_per_hour, availability, bio)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          teacher.id,
          ['Flutter', 'Web Development'],
          30.00,
          JSON.stringify({ note: 'Flexible availability' }),
          'Mock profile for testing'
        ]
      );
    }

    // 2. Get or create first student
    let studentResult = await db.query(
      "SELECT id, name, email FROM users WHERE role = 'student' LIMIT 1"
    );

    let student;
    if (studentResult.rows.length === 0) {
      console.log('🛠 No student found. Creating a test student...');
      const userRes = await db.query(
        `INSERT INTO users (name, email, password_hash, role, is_verified)
         VALUES ($1, $2, $3, $4, true)
         RETURNING id, name, email`,
        ['Test Student', 'student@test.com', 'passwordhash', 'student']
      );
      student = userRes.rows[0];
    } else {
      student = studentResult.rows[0];
    }
    console.log(`🎓 Found/Created Student: ${student.name} (${student.email})`);

    // 3. Insert mock request
    const requestResult = await db.query(
      `INSERT INTO requests (student_id, teacher_id, message, status)
       VALUES ($1, $2, 'I would love a lesson on Flutter UI styling!', 'accepted')
       RETURNING id`,
      [student.id, teacher.id]
    );
    const requestId = requestResult.rows[0].id;
    console.log(`📝 Created accepted request: ${requestId}`);

    // 4. Insert class session (scheduled, for today)
    const sessionResult = await db.query(
      `INSERT INTO class_sessions (request_id, student_id, teacher_id, subject, scheduled_date, duration_hours, status, notes)
       VALUES ($1, $2, $3, 'Flutter Responsive UI Class', NOW(), 1.5, 'scheduled', 'Let us learn to build responsive views!')
       RETURNING id`,
      [requestId, student.id, teacher.id]
    );
    const sessionId = sessionResult.rows[0].id;
    console.log(`📅 Created class session: ${sessionId}`);

    // 5. Insert paid payment
    const paymentResult = await db.query(
      `INSERT INTO payments (request_id, student_id, teacher_id, amount, duration_hours, status, payment_date)
       VALUES ($1, $2, $3, 45.00, 1.5, 'paid', NOW())
       RETURNING id`,
      [requestId, student.id, teacher.id]
    );
    const paymentId = paymentResult.rows[0].id;
    console.log(`💳 Created paid payment record: ${paymentId}`);

    console.log('\n✅ Mock session and paid payment created successfully!');
    console.log('You can now refresh the "My Sessions" tab on the teacher dashboard to test joining the call.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating mock session:', error);
    process.exit(1);
  }
}

createMockSession();
