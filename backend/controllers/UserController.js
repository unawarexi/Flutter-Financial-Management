const UserModel = require('../base/UserModel');
const bcrypt = require('bcrypt');

const UserController = {
  // Get all users
  getAllUsers: async (req, res, next) => {
    try {
      const users = await UserModel.getAllUsers();
      res.status(200).json({ 
        status: "success", 
        count: users.length,
        users 
      });
    } catch (error) {
      console.error('Error fetching users:', error);
      next(error);
    }
  },
  
  // Get user by ID
  getUserById: async (req, res, next) => {
    try {
      const { id } = req.params;
      const user = await UserModel.getUserById(id);
      
      if (!user) {
        return res.status(404).json({ 
          status: "error",
          message: "User not found" 
        });
      }
      
      // Remove sensitive information
      delete user.password_hash;
      
      res.status(200).json({ 
        status: "success", 
        user 
      });
    } catch (error) {
      console.error('Error fetching user:', error);
      next(error);
    }
  },
  
  // Update user
  updateUser: async (req, res, next) => {
    try {
      const { id } = req.params;
      const userData = req.body;
      
      // Prevent updating password through this endpoint
      delete userData.password_hash;
      delete userData.password;
      
      const user = await UserModel.updateUser(id, userData);
      
      if (!user) {
        return res.status(404).json({ 
          status: "error",
          message: "User not found" 
        });
      }
      
      // Remove sensitive information
      delete user.password_hash;
      
      res.status(200).json({ 
        status: "success", 
        message: "User updated successfully",
        user 
      });
    } catch (error) {
      console.error('Error updating user:', error);
      next(error);
    }
  },
  
  // Delete user
  deleteUser: async (req, res, next) => {
    try {
      const { id } = req.params;
      const user = await UserModel.deleteUser(id);
      
      if (!user) {
        return res.status(404).json({ 
          status: "error",
          message: "User not found" 
        });
      }
      
      res.status(200).json({ 
        status: "success", 
        message: "User deleted successfully"
      });
    } catch (error) {
      console.error('Error deleting user:', error);
      next(error);
    }
  },
  
  // Update password
  updatePassword: async (req, res, next) => {
    try {
      const { id } = req.params;
      const { currentPassword, newPassword } = req.body;
      
      // Get user with password hash
      const user = await UserModel.getUserById(id);
      
      if (!user) {
        return res.status(404).json({ 
          status: "error",
          message: "User not found" 
        });
      }
      
      // Verify current password
      const isPasswordValid = await bcrypt.compare(currentPassword, user.password_hash);
      
      if (!isPasswordValid) {
        return res.status(401).json({ 
          status: "error",
          message: "Current password is incorrect" 
        });
      }
      
      // Hash new password
      const saltRounds = 10;
      const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);
      
      // Update password
      await UserModel.updatePassword(id, newPasswordHash);
      
      res.status(200).json({ 
        status: "success", 
        message: "Password updated successfully"
      });
    } catch (error) {
      console.error('Error updating password:', error);
      next(error);
    }
  },
  
  // Search users
  searchUsers: async (req, res, next) => {
    try {
      const { query } = req.query;
      
      if (!query) {
        return res.status(400).json({
          status: "error",
          message: "Search query is required"
        });
      }
      
      const users = await UserModel.searchUsers(query);
      
      res.status(200).json({ 
        status: "success", 
        count: users.length,
        users 
      });
    } catch (error) {
      console.error('Error searching users:', error);
      next(error);
    }
  },
  
  // Get user profile (for authenticated user)
  getProfile: async (req, res, next) => {
    try {
      // req.user would be set by authentication middleware
      const user = await UserModel.getUserById(req.user.id);
      
      if (!user) {
        return res.status(404).json({ 
          status: "error",
          message: "User not found" 
        });
      }
      
      // Remove sensitive information
      delete user.password_hash;
      
      res.status(200).json({ 
        status: "success", 
        user 
      });
    } catch (error) {
      console.error('Error fetching profile:', error);
      next(error);
    }
  }
};

module.exports = UserController;