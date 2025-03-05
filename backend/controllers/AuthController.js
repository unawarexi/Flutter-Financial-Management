// controllers/AuthController.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const UserModel = require('../base/UserModel');
const db = require('../sequelize/models/index').default;
const redis = require('../cache/redis'); 

// Register new user
exports.register = async (req, res, next) => {
  try {
    const { 
      first_name, 
      last_name, 
      email, 
      phone_number, 
      date_of_birth, 
      password,
      monthly_income,
      financial_goal
    } = req.body;
    
    // Check if user already exists
    const existingUser = await UserModel.getUserByEmail(email);
    
    if (existingUser) {
      return res.status(409).json({
        status: "error",
        error: {
          message: 'User with this email already exists',
          code: 'USER_EXISTS'
        }
      });
    }
    
    // Hash password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Convert date_of_birth (string) to a Date object
    const dateOfBirth = new Date(date_of_birth);
    
    // Create new user
    const userData = {
      first_name,
      last_name,
      email,
      phone_number,
      date_of_birth: dateOfBirth,  
      password_hash,
      monthly_income,
      financial_goal
    };
    
    const newUser = await UserModel.createUser(userData);
    
    // Generate tokens
    const tokens = generateTokens(newUser);
    
    // Store refresh token
    await db.query(
      'INSERT INTO user_sessions (user_id, refresh_token, device_info, expires_at) VALUES ($1, $2, $3, $4)',
      [
        newUser.id, 
        tokens.refreshToken,
        req.headers['user-agent'] || 'unknown',
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
      ]
    );
    
    // Remove sensitive information
    delete newUser.password_hash;
    
    return res.status(201).json({
      status: "success",
      message: 'User registered successfully',
      user: newUser,
      tokens
    });
  } catch (err) {
    console.error('Registration error:', err);
    next(err);
  }
};


// Login user
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    // Find user
    const user = await UserModel.getUserByEmail(email);
    
    if (!user) {
      return res.status(401).json({
        status: "error",
        error: {
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS'
        }
      });
    }
    
    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({
        status: "error",
        error: {
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS'
        }
      });
    }
    
    // Generate tokens
    const tokens = generateTokens(user);
    
    // Store refresh token
    await db.query(
      'INSERT INTO user_sessions (user_id, refresh_token, device_info, expires_at) VALUES ($1, $2, $3, $4)',
      [
        user.id, 
        tokens.refreshToken,
        req.headers['user-agent'] || 'unknown',
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
      ]
    );
    
    // Cache user data in Redis for faster authentication checks
    await redis.set(`user:${user.id}`, JSON.stringify({
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    }), 'EX', 3600); // 1 hour expiry
    
    // Remove sensitive information
    delete user.password_hash;
    
    return res.status(200).json({
      status: "success",
      message: 'Login successful',
      user,
      tokens
    });
  } catch (err) {
    console.error('Login error:', err);
    next(err);
  }
};

// Refresh token
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({
        status: "error",
        error: {
          message: 'Refresh token is required',
          code: 'MISSING_TOKEN'
        }
      });
    }
    
    // Verify token in database
    const sessionResult = await db.query(
      'SELECT * FROM user_sessions WHERE refresh_token = $1 AND expires_at > NOW()',
      [refreshToken]
    );
    
    if (sessionResult.rows.length === 0) {
      return res.status(401).json({
        status: "error",
        error: {
          message: 'Invalid or expired refresh token',
          code: 'INVALID_TOKEN'
        }
      });
    }
    
    // Get user data
    const user = await UserModel.getUserById(sessionResult.rows[0].user_id);
    
    if (!user) {
      return res.status(404).json({
        status: "error",
        error: {
          message: 'User not found',
          code: 'USER_NOT_FOUND'
        }
      });
    }
    
    // Generate new tokens
    const tokens = generateTokens(user);
    
    // Update refresh token in database
    await db.query(
      'UPDATE user_sessions SET refresh_token = $1, expires_at = $2 WHERE refresh_token = $3',
      [
        tokens.refreshToken,
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
        refreshToken
      ]
    );
    
    return res.status(200).json({
      status: "success",
      message: 'Token refreshed successfully',
      tokens
    });
  } catch (err) {
    console.error('Token refresh error:', err);
    next(err);
  }
};

// Logout
exports.logout = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({
        status: "error",
        error: {
          message: 'Refresh token is required',
          code: 'MISSING_TOKEN'
        }
      });
    }
    
    // Remove session from database
    await db.query(
      'DELETE FROM user_sessions WHERE refresh_token = $1',
      [refreshToken]
    );
    
    // Remove cached user data if it exists
    if (req.user) {
      await redis.del(`user:${req.user.id}`);
    }
    
    return res.status(200).json({
      status: "success",
      message: 'Logged out successfully'
    });
  } catch (err) {
    console.error('Logout error:', err);
    next(err);
  }
};

// Verify email with token
exports.verifyEmail = async (req, res, next) => {
  try {
    const { token } = req.params;
    
    // Find verification token
    const tokenResult = await db.query(
      'SELECT * FROM email_verification_tokens WHERE token = $1 AND expires_at > NOW()',
      [token]
    );
    
    if (tokenResult.rows.length === 0) {
      return res.status(400).json({
        status: "error",
        error: {
          message: 'Invalid or expired verification token',
          code: 'INVALID_TOKEN'
        }
      });
    }
    
    // Update user's email verification status
    await db.query(
      'UPDATE users SET email_verified = TRUE, updated_at = NOW() WHERE id = $1',
      [tokenResult.rows[0].user_id]
    );
    
    // Delete the used token
    await db.query(
      'DELETE FROM email_verification_tokens WHERE token = $1',
      [token]
    );
    
    return res.status(200).json({
      status: "success",
      message: 'Email verified successfully'
    });
  } catch (err) {
    console.error('Email verification error:', err);
    next(err);
  }
};

// Request password reset
exports.requestPasswordReset = async (req, res, next) => {
  try {
    const { email } = req.body;
    
    // Find user
    const user = await UserModel.getUserByEmail(email);
    
    // We don't want to reveal if the email exists in our system
    if (!user) {
      return res.status(200).json({
        status: "success",
        message: 'If your email is registered, you will receive a password reset link'
      });
    }
    
    // Generate reset token
    const resetToken = uuidv4();
    const expiresAt = new Date(Date.now() + 1 * 60 * 60 * 1000); // 1 hour
    
    // Store token in database
    await db.query(
      'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES ($1, $2, $3)',
      [user.id, resetToken, expiresAt]
    );
    
    // In a real application, send email with reset link
    // For this example, we'll just return success
    
    return res.status(200).json({
      status: "success",
      message: 'If your email is registered, you will receive a password reset link'
    });
  } catch (err) {
    console.error('Password reset request error:', err);
    next(err);
  }
};

// Reset password with token
exports.resetPassword = async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    
    // Find reset token
    const tokenResult = await db.query(
      'SELECT * FROM password_reset_tokens WHERE token = $1 AND expires_at > NOW()',
      [token]
    );
    
    if (tokenResult.rows.length === 0) {
      return res.status(400).json({
        status: "error",
        error: {
          message: 'Invalid or expired reset token',
          code: 'INVALID_TOKEN'
        }
      });
    }
    
    // Hash new password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(newPassword, saltRounds);
    
    // Update user's password
    await UserModel.updatePassword(tokenResult.rows[0].user_id, password_hash);
    
    // Delete all refresh tokens for this user (force logout from all devices)
    await db.query(
      'DELETE FROM user_sessions WHERE user_id = $1',
      [tokenResult.rows[0].user_id]
    );
    
    // Delete the used token
    await db.query(
      'DELETE FROM password_reset_tokens WHERE token = $1',
      [token]
    );
    
    return res.status(200).json({
      status: "success",
      message: 'Password has been reset successfully'
    });
  } catch (err) {
    console.error('Password reset error:', err);
    next(err);
  }
};

// Helper function to generate tokens
function generateTokens(user) {
  const accessToken = jwt.sign(
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
  
  const refreshToken = uuidv4();
  
  return {
    accessToken,
    refreshToken
  };
}