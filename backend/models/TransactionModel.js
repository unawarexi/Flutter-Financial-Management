const pool = require('../config/dbconfig');

const TransactionModel = {
  async createTransaction(title, amount, category, type, date, description, userId) {
    const query = `
      INSERT INTO transactions 
      (title, amount, category, transaction_type, transaction_date, description, created_by) 
      VALUES ($1, $2, $3, $4, $5, $6, $7) 
      RETURNING *;
    `;
    const values = [title, amount, category, type, date, description, userId];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  async updateTransaction(id, newValues) {
    const query = `
      UPDATE transactions 
      SET title = $1, amount = $2, category = $3, transaction_type = $4, transaction_date = $5, 
          description = $6, updated_at = CURRENT_TIMESTAMP 
      WHERE id = $7 RETURNING *;
    `;
    const values = [
      newValues.title, newValues.amount, newValues.category, 
      newValues.type, newValues.date, newValues.description, id
    ];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  async deleteTransaction(id) {
    const query = 'UPDATE transactions SET is_deleted = true WHERE id = $1 RETURNING *;';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }
};

module.exports = TransactionModel;
