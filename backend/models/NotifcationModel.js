const pool = require('../config/dbconfig');

const NotificationModel = {
  async createNotification(userId, transactionId, message) {
    const query = `
      INSERT INTO notifications (user_id, transaction_id, message, is_read) 
      VALUES ($1, $2, $3, false) 
      RETURNING *;
    `;
    const result = await pool.query(query, [userId, transactionId, message]);
    return result.rows[0];
  }
};

module.exports = NotificationModel;
