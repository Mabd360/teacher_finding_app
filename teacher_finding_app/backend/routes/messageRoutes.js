const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../db');

// GET /api/messages/:otherUserId - Get messages between current user and other user
router.get('/:otherUserId', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const { otherUserId } = req.params;

    const result = await db.query(`
      SELECT m.*, u_sender.name AS sender_name
      FROM messages m
      JOIN users u_sender ON m.sender_id = u_sender.id
      WHERE (m.sender_id = $1 AND m.receiver_id = $2)
         OR (m.sender_id = $2 AND m.receiver_id = $1)
      ORDER BY m.created_at ASC
    `, [userId, otherUserId]);

    return res.json({ messages: result.rows });
  } catch (error) {
    console.error('Fetch messages error:', error);
    return res.status(500).json({ error: 'Failed to load messages' });
  }
});

// POST /api/messages - Send a message
router.post('/', authMiddleware, async (req, res) => {
  try {
    const senderId = req.user.id;
    const { receiver_id: receiverId, message } = req.body;

    if (!receiverId || !message || message.trim() === '') {
      return res.status(400).json({ error: 'receiver_id and message are required' });
    }

    const result = await db.query(`
      INSERT INTO messages (sender_id, receiver_id, message)
      VALUES ($1, $2, $3)
      RETURNING *
    `, [senderId, receiverId, message]);

    return res.status(201).json({ message: result.rows[0] });
  } catch (error) {
    console.error('Send message error:', error);
    return res.status(500).json({ error: 'Failed to send message' });
  }
});

module.exports = router;
