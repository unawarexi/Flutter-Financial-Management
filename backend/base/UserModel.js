// models/UserModel.js
const db = require('../sequelize/models/index').default;
const { Op } = require('sequelize');

const UserModel = {
  // Create a new user
  async createUser(userData) {
    return await db.User.create(userData);
  },
  
  // Get user by email (for authentication)
  async getUserByEmail(email) {
    return await db.User.findOne({ where: { email } });
  },
  
  // Get user by ID
  async getUserById(id) {
    return await db.User.findByPk(id);
  },
  
  // Get all users
  async getAllUsers() {
    return await db.User.findAll({
      attributes: ['id', 'first_name', 'last_name', 'email', 'phone_number', 'date_of_birth', 'monthly_income', 'financial_goal', 'createdAt'],
    });
  },
  
  // Update user
  async updateUser(id, userData) {
    await db.User.update(userData, { where: { id } });
    return await db.User.findByPk(id);  // Return the updated user
  },
  
  // Delete user
  async deleteUser(id) {
    const user = await db.User.findByPk(id);
    if (user) {
      await user.destroy();
      return user;
    }
    return null;
  },
  
  // Update password
  async updatePassword(id, password_hash) {
    await db.User.update({ password_hash }, { where: { id } });
    return await db.User.findByPk(id, { attributes: ['id'] });
  },
  
  // Search users
  async searchUsers(searchTerm) {
    return await db.User.findAll({
      where: {
        [Op.or]: [
          { first_name: { [Op.iLike]: `%${searchTerm}%` } },
          { last_name: { [Op.iLike]: `%${searchTerm}%` } },
          { email: { [Op.iLike]: `%${searchTerm}%` } },
          { phone_number: { [Op.iLike]: `%${searchTerm}%` } }
        ]
      },
      attributes: ['id', 'first_name', 'last_name', 'email', 'phone_number'],
    });
  }
};

module.exports = UserModel;