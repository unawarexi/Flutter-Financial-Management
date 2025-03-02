// redis.js
const Redis = require('ioredis');
const { promisify } = require('util');

// Environment variables with fallbacks
const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const REDIS_PORT = process.env.REDIS_PORT || 6379;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD || null;
const REDIS_DB = process.env.REDIS_DB || 0;

// Create Redis client
const redisClient = new Redis({
  host: REDIS_HOST,
  port: REDIS_PORT,
  password: REDIS_PASSWORD,
  db: REDIS_DB,
  // Retry strategy on connection failures
  retryStrategy: (times) => {
    // Exponential backoff with a cap
    const delay = Math.min(times * 50, 2000);
    return delay;
  }
});

// Connection events for better error handling
redisClient.on('connect', () => {
  console.log('Redis client connected');
});

redisClient.on('error', (err) => {
  console.error('Redis client error:', err);
});

redisClient.on('reconnecting', () => {
  console.log('Redis client reconnecting');
});

// Create simplified API
const redis = {
  // Get a value (with optional expiry)
  get: async (key) => {
    try {
      const value = await redisClient.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Redis GET error:', error);
      return null;
    }
  },

  // Set a value (with optional expiry)
  set: async (key, value, ...args) => {
    try {
      return await redisClient.set(key, JSON.stringify(value), ...args);
    } catch (error) {
      console.error('Redis SET error:', error);
      return false;
    }
  },

  // Delete a key
  del: async (key) => {
    try {
      return await redisClient.del(key);
    } catch (error) {
      console.error('Redis DEL error:', error);
      return 0;
    }
  },

  // Set a hash
  hset: async (key, field, value) => {
    try {
      return await redisClient.hset(key, field, JSON.stringify(value));
    } catch (error) {
      console.error('Redis HSET error:', error);
      return false;
    }
  },

  // Get a hash
  hget: async (key, field) => {
    try {
      const value = await redisClient.hget(key, field);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Redis HGET error:', error);
      return null;
    }
  },

  // Get all hash fields
  hgetall: async (key) => {
    try {
      const result = await redisClient.hgetall(key);
      if (!result) return null;
      
      // Parse all values
      Object.keys(result).forEach(field => {
        try {
          result[field] = JSON.parse(result[field]);
        } catch (e) {
          // Keep as is if not valid JSON
        }
      });
      
      return result;
    } catch (error) {
      console.error('Redis HGETALL error:', error);
      return null;
    }
  },

  // Check if key exists
  exists: async (key) => {
    try {
      return await redisClient.exists(key);
    } catch (error) {
      console.error('Redis EXISTS error:', error);
      return 0;
    }
  },

  // Set expiration on key
  expire: async (key, seconds) => {
    try {
      return await redisClient.expire(key, seconds);
    } catch (error) {
      console.error('Redis EXPIRE error:', error);
      return 0;
    }
  },

  // Access the raw Redis client for advanced operations
  client: redisClient
};

module.exports = redis;