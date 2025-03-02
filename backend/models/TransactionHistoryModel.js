const pool = require('../config/dbconfig');

const TransactionHistoryModel = {
  async logChange(transactionId, modifiedBy, changeType, previousState, newState) {
    const query = `
      INSERT INTO transaction_history 
      (transaction_id, modified_by, change_type, previous_state, new_state) 
      VALUES ($1, $2, $3, $4, $5) 
      RETURNING *;
    `;
    const values = [transactionId, modifiedBy, changeType, previousState, newState];
    const result = await pool.query(query, values);
    return result.rows[0];
  }
};

module.exports = TransactionHistoryModel;
