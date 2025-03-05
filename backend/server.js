// server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const Redis = require('ioredis');
const dotenv = require('dotenv');
const {sequelize} = require('./sequelize/models');

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.CLIENT_URL || '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Redis for caching - with more robust connection options
let redis;
try {
  const redisConfig = {
    host: process.env.REDIS_URL ? new URL(process.env.REDIS_URL).hostname : 'localhost',
    port: process.env.REDIS_URL ? new URL(process.env.REDIS_URL).port : 6379,
    password: process.env.REDIS_PASSWORD || undefined,
    db: parseInt(process.env.REDIS_DB || '0'),
    maxRetriesPerRequest: 3,
    retryStrategy: (times) => {
      return Math.min(times * 100, 3000);
    }
  };
  
  redis = new Redis(redisConfig);
  
  redis.on('error', (err) => {
    console.error('Redis connection error:', err);
  });
} catch (error) {
  console.error('Redis initialization error:', error);
  // Continue without Redis if there's an error
  redis = {
    set: () => Promise.resolve(),
    get: () => Promise.resolve(null)
  };
}

// Middleware
app.use(cors({ 
  origin: process.env.CLIENT_URL || '*', 
  credentials: true 
}));
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
    const dbResult = await sequelize.query('SELECT NOW()');
    
    // Test Redis connection (with error handling)
    let redisStatus = 'Not connected';
    try {
      await redis.set('test', 'success');
      const redisResult = await redis.get('test');
      redisStatus = redisResult === 'success' ? 'Connected' : 'Error';
    } catch (redisError) {
      console.error('Redis health check failed:', redisError);
    }
    
    res.status(200).json({
      status: 'OK',
      database: dbResult && dbResult.rows ? 'Connected' : 'Error',
      redis: redisStatus
    });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(500).json({
      status: 'Error',
      message: error.message,
      database: 'Error',
      redis: 'Unknown'
    });
  }
});

// Socket.IO connection handler
if (typeof require('./websocket/Socket') === 'function') {
  require('./websocket/Socket')(io, sequelize, redis);
}

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
const connectDb = async () => {
  console.log('Checking database connection...');

  try {
      await sequelize.authenticate();
      console.log('Database connection established.');
  } catch(e) {
      console.log('Database connection failed', e);
      process.exit(1);
  }
};

(async () => {
  await connectDb();

  console.log(`Attempting to run server on port ${PORT}`);

  app.listen(PORT, () => {
      console.log(`Listening on port ${PORT}`);
  });
})();

module.exports = { app, server };