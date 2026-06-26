const db = require('../db');

async function makeScheduled() {
  try {
    const res = await db.query(
      `UPDATE class_sessions 
       SET status = 'scheduled' 
       WHERE id = '033d3b03-3d14-444d-a4d9-d81b365e950d'`
    );
    console.log('✅ Updated class session status back to scheduled!');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

makeScheduled();
