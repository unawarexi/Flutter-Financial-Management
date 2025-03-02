const pool = require('../config/dbconfig');

const UserModel = {
  // Create a new user with all fields from signup form
  async createUser(userData) {
    const { 
      first_name, 
      last_name, 
      email, 
      phone_number, 
      date_of_birth, 
      password_hash,
      monthly_income,
      financial_goal
    } = userData;
    
    const query = `
      INSERT INTO users (
        first_name, 
        last_name, 
        email, 
        phone_number, 
        date_of_birth, 
        password_hash,
        monthly_income,
        financial_goal,
        created_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
      RETURNING *;
    `;
    
    const values = [
      first_name, 
      last_name, 
      email, 
      phone_number, 
      date_of_birth, 
      password_hash,
      monthly_income || null,
      financial_goal || null
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },
  
  // Get user by email (for authentication)
  async getUserByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1;';
    const result = await pool.query(query, [email]);
    return result.rows[0];
  },
  
  // Get user by ID
  async getUserById(id) {
    const query = 'SELECT * FROM users WHERE id = $1;';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  },
  
  // Get all users
  async getAllUsers() {
    const query = 'SELECT id, first_name, last_name, email, phone_number, date_of_birth, financial_goal, created_at FROM users;';
    const result = await pool.query(query);
    return result.rows;
  },
  
  // Update user
  async updateUser(id, userData) {
    const { 
      first_name, 
      last_name, 
      email, 
      phone_number, 
      date_of_birth,
      monthly_income,
      financial_goal
    } = userData;
    
    const query = `
      UPDATE users
      SET 
        first_name = COALESCE($1, first_name),
        last_name = COALESCE($2, last_name),
        email = COALESCE($3, email),
        phone_number = COALESCE($4, phone_number),
        date_of_birth = COALESCE($5, date_of_birth),
        monthly_income = COALESCE($6, monthly_income),
        financial_goal = COALESCE($7, financial_goal),
        updated_at = NOW()
      WHERE id = $8
      RETURNING *;
    `;
    
    const values = [
      first_name, 
      last_name, 
      email, 
      phone_number, 
      date_of_birth,
      monthly_income,
      financial_goal,
      id
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },
  
  // Delete user
  async deleteUser(id) {
    const query = 'DELETE FROM users WHERE id = $1 RETURNING *;';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  },
  
  // Update password
  async updatePassword(id, password_hash) {
    const query = `
      UPDATE users
      SET password_hash = $1, updated_at = NOW()
      WHERE id = $2
      RETURNING id;
    `;
    
    const result = await pool.query(query, [password_hash, id]);
    return result.rows[0];
  },
  
  // Search users
  async searchUsers(searchTerm) {
    const query = `
      SELECT id, first_name, last_name, email, phone_number 
      FROM users
      WHERE 
        first_name ILIKE $1 OR
        last_name ILIKE $1 OR
        email ILIKE $1 OR
        phone_number ILIKE $1
    `;
    
    const result = await pool.query(query, [`%${searchTerm}%`]);
    return result.rows;
  }
};

module.exports = UserModel;