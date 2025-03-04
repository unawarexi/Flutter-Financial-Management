require('dotenv').config(); // Load environment variables

module.exports = {
  development: {
    username: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || null, // Changed from DB_PASSWORD to DB_PASS
    database: process.env.DB_NAME || 'database_development',
    host: process.env.DB_HOST || '127.0.0.1',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    dialectOptions: {
      ssl: process.env.NODE_ENV === 'production' ? {
        require: true,
        rejectUnauthorized: false
      } : false
    }
  },
  test: {
    username: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || null, // Changed from DB_PASSWORD to DB_PASS
    database: process.env.DB_NAME || 'database_test',
    host: process.env.DB_HOST || '127.0.0.1',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres'
  },
  production: {
    // Option 1: Use DATABASE_URL (recommended for Render)
    url: process.env.DATABASE_URL,
    dialect: 'postgres',
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false
      }
    }
  }
};