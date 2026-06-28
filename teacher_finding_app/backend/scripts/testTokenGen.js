const { generateToken04 } = require('../utils/zegoServerAssistant');

try {
  const appId = 2009635202;
  const appSign = '173bc3746e38c8503f6bf5817972c5e9463ac439082c9f65ec4de64c5e03f253';
  const secret = Buffer.from(appSign, 'hex').toString('binary');
  const token = generateToken04(appId, 'test_user', secret, 7200, '');
  console.log("Token generated successfully:", token);
  process.exit(0);
} catch (err) {
  console.error("Token generation failed:", err);
  process.exit(1);
}
