// socket.js
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const Redis = require('ioredis');

// Database and Redis clients
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});
const redis = new Redis(process.env.REDIS_URL);

// Active users tracking
const activeUsers = new Map();

let io;

module.exports = function(socketIo, dbPool, redisClient) {
  io = socketIo;
  
  // Authentication middleware for socket connections
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication token is required'));
      }
      
      // Verify JWT token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Get user from Redis cache or database
      let user = null;
      const cachedUser = await redis.get(`user:${decoded.id}`);
      
      if (cachedUser) {
        user = JSON.parse(cachedUser);
      } else {
        const userResult = await pool.query(
          'SELECT id, email, full_name FROM users WHERE id = $1',
          [decoded.id]
        );
        
        if (userResult.rows.length === 0) {
          return next(new Error('User not found'));
        }
        
        user = {
          id: userResult.rows[0].id,
          email: userResult.rows[0].email,
          fullName: userResult.rows[0].full_name
        };
        
        // Cache user data
        await redis.set(`user:${user.id}`, JSON.stringify(user), 'EX', 3600);
      }
      
      // Attach user to socket
      socket.user = user;
      next();
    } catch (error) {
      return next(new Error('Invalid authentication token'));
    }
  });
  
  io.on('connection', async (socket) => {
    console.log(`User connected: ${socket.user.id} (${socket.user.fullName})`);
    
    // Add user to active users
    activeUsers.set(socket.user.id, {
      socketId: socket.id,
      user: socket.user,
      lastActive: new Date()
    });
    
    // Broadcast user online status
    io.emit('user:online', {
      userId: socket.user.id,
      userName: socket.user.fullName,
      timestamp: new Date()
    });
    
    // Join user-specific room for targeted notifications
    socket.join(`user:${socket.user.id}`);
    
    // Send unread notifications
    const notifications = await pool.query(
      `SELECT n.*, t.title as transaction_title
       FROM notifications n
       LEFT JOIN transactions t ON n.transaction_id = t.id
       WHERE n.user_id = $1 AND n.is_read = FALSE
       ORDER BY n.created_at DESC
       LIMIT 20`,
      [socket.user.id]
    );
    
    if (notifications.rows.length > 0) {
      socket.emit('notifications:unread', notifications.rows);
    }
    
    // Handle client events
    
    // Client is viewing a transaction
    socket.on('transaction:viewing', async (transactionId) => {
      // Broadcast to other users that this user is viewing the transaction
      socket.to('transactions').emit('transaction:user-viewing', {
        transactionId,
        user: {
          id: socket.user.id,
          name: socket.user.fullName
        }
      });
      
      // Track in Redis that user is viewing this transaction (expires after 1 minute)
      await redis.set(`viewing:${transactionId}:${socket.user.id}`, socket.user.fullName, 'EX', 60);
      
      // Join transaction-specific room
      socket.join(`transaction:${transactionId}`);
    });
    
    // Client stopped viewing a transaction
    socket.on('transaction:stop-viewing', async (transactionId) => {
      // Remove from Redis
      await redis.del(`viewing:${transactionId}:${socket.user.id}`);
      
      // Leave transaction-specific room
      socket.leave(`transaction:${transactionId}`);
      
      // Broadcast to other users
      socket.to('transactions').emit('transaction:user-left', {
        transactionId,
        userId: socket.user.id
      });
    });
    
    // User acknowledges notification
    socket.on('notification:read', async (notificationId) => {
      await pool.query(
        'UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2',
        [notificationId, socket.user.id]
      );
    });
    
    // User read all notifications
    socket.on('notifications:read-all', async () => {
      await pool.query(
        'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE',
        [socket.user.id]
      );
    });
    
    // User typing in a transaction form
    socket.on('transaction:typing', (transactionId) => {
      socket.to(`transaction:${transactionId}`).emit('transaction:user-typing', {
        transactionId,
        user: {
          id: socket.user.id,
          name: socket.user.fullName
        },
        timestamp: new Date()
      });
    });
    
    // Handle disconnection
    socket.on('disconnect', async () => {
      console.log(`User disconnected: ${socket.user.id} (${socket.user.fullName})`);
      
      // Remove from active users
      activeUsers.delete(socket.user.id);
      
      // Broadcast user offline status
      io.emit('user:offline', {
        userId: socket.user.id,
        timestamp: new Date()
      });
      
      // Clean up any viewing status in Redis
      const keys = await redis.keys(`viewing:*:${socket.user.id}`);
      if (keys.length > 0) {
        await redis.del(keys);
      }
    });
  });
  
  // Export the io instance to be used in other parts of the application
  module.exports.io = io;
  
  return io;
};