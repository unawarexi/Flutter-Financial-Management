require('dotenv').config(); // Load environment variables from .env file

module.exports = {
  development: {
    username: 'root',
    password: '0GM9qARUiyEs1KkmahDMj9LEPE7FJhhJ',
    database: 'flutterfinance',
    host: 'dpg-cv39lh3tq21c73bhka6g-a.oregon-postgres.render.com',
    port: "5432",
    dialect: 'postgres',
    url: 'postgresql://root:0GM9qARUiyEs1KkmahDMj9LEPE7FJhhJ@dpg-cv39lh3tq21c73bhka6g-a.oregon-postgres.render.com/flutterfinance', 
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false, 
      },
    },
  },
  test: {
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    url: process.env.DATABASE_URL, 
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    url: process.env.DATABASE_URL, 
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  },
};
