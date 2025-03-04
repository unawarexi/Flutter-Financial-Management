// models/UserModel.js

const User = require('./User');

const UserModel = {
  // Create a new user
  async createUser(userData) {
    return await User.create(userData);
  },
  
  // Get user by email (for authentication)
  async getUserByEmail(email) {
    return await User.findOne({ where: { email } });
  },
  
  // Get user by ID
  async getUserById(id) {
    return await User.findByPk(id);
  },
  
  // Get all users
  async getAllUsers() {
    return await User.findAll({
      attributes: ['id', 'first_name', 'last_name', 'email', 'phone_number', 'date_of_birth', 'financial_goal', 'createdAt'],
    });
  },
  
  // Update user
  async updateUser(id, userData) {
    await User.update(userData, { where: { id } });
    return await User.findByPk(id);  // Return the updated user
  },
  
  // Delete user
  async deleteUser(id) {
    const user = await User.findByPk(id);
    if (user) {
      await user.destroy();
      return user;
    }
    return null;
  },
  
  // Update password
  async updatePassword(id, password_hash) {
    await User.update({ password_hash }, { where: { id } });
    return await User.findByPk(id, { attributes: ['id'] });
  },
  
  // Search users
  async searchUsers(searchTerm) {
    return await User.findAll({
      where: {
        [Sequelize.Op.or]: [
          { first_name: { [Sequelize.Op.iLike]: `%${searchTerm}%` } },
          { last_name: { [Sequelize.Op.iLike]: `%${searchTerm}%` } },
          { email: { [Sequelize.Op.iLike]: `%${searchTerm}%` } },
          { phone_number: { [Sequelize.Op.iLike]: `%${searchTerm}%` } }
        ]
      },
      attributes: ['id', 'first_name', 'last_name', 'email', 'phone_number'],
    });
  }
};

module.exports = UserModel;
