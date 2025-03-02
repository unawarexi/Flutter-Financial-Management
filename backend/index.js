// server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const { Pool } = require('pg');
const Redis = require('ioredis');
const dotenv = require('dotenv');
const pool = require('./config/dbconfig');

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.CLIENT_URL,
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// // Database connection
// const pool = new Pool({
//   connectionString: process.env.DATABASE_URL,
//   ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
// });

// Redis for caching
const redis = new Redis(process.env.REDIS_URL);

// Middleware
app.use(cors({ origin: process.env.CLIENT_URL, credentials: true }));
app.use(helmet());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false
});
app.use('/api/', apiLimiter);

// Import routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
// const transactionRoutes = require('./routes/transactions');
// const notificationRoutes = require('./routes/notifications');

// Register routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
// app.use('/api/transactions', transactionRoutes);
// app.use('/api/notifications', notificationRoutes);



// Health check endpoint with DB check
app.get('/health', async (req, res) => {
  try {
    // Test database connection
    const dbResult = await pool.query('SELECT NOW()');
    
    // Test Redis connection
    await redis.set('test', 'success');
    const redisResult = await redis.get('test');
    
    res.status(200).json({
      status: 'OK',
      database: dbResult.rows ? 'Connected' : 'Error',
      redis: redisResult === 'success' ? 'Connected' : 'Error'
    });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(500).json({
      status: 'Error',
      message: error.message
    });
  }
});

// Socket.IO connection handler
require('./websocket/Socket')(io, pool, redis);

// Error handler middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      code: err.code || 'SERVER_ERROR'
    }
  });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = { app, server };