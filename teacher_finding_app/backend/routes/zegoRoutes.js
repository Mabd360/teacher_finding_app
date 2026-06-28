const express = require('express');
const router = express.Router();
const { generateToken04 } = require('../utils/zegoServerAssistant');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/token', authMiddleware, (req, res) => {
  // Set CORS header for web origin
  res.setHeader('Access-Control-Allow-Origin', '*');
  console.log('Zego token request for userId:', req.body.userId);
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const appId = 2009635202;
    const appSign = '173bc3746e38c8503f6bf5817972c5e9463ac439082c9f65ec4de64c5e03f253';
    
    // Convert 64-character hex appSign to 32-character binary string
    const secret = Buffer.from(appSign, 'hex').toString('binary');
    
    const effectiveTimeInSeconds = 7200; // Valid for 2 hours
    const payload = ''; // General token for video/audio call

    const token = generateToken04(appId, userId, secret, effectiveTimeInSeconds, payload);

    return res.json({ token });
  } catch (error) {
    console.error('Zego token generation error:', error);
    return res.status(500).json({ 
      error: 'Failed to generate token', 
      details: error.message || error 
    });
  }
});

module.exports = router;
