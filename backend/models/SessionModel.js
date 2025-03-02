const pool = require('../config/dbconfig');

const SessionModel = {
  async createSession(userId, refreshToken, deviceInfo, expiresAt) {
    const query = `
      INSERT INTO user_sessions (user_id, refresh_token, device_info, expires_at) 
      VALUES ($1, $2, $3, $4) 
      RETURNING *;
    `;
    const result = await pool.query(query, [userId, refreshToken, deviceInfo, expiresAt]);
    return result.rows[0];
  }
};

module.exports = SessionModel;
