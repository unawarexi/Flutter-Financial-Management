'use strict';

const fs = require('fs');
const path = require('path');
const Sequelize = require('sequelize');
const process = require('process');
const basename = path.basename(__filename);
const env = process.env.NODE_ENV || 'development';
const config = require(__dirname + '/../config/config.js')[env];
const db = {};

let sequelize;
if (env === 'production' && config.url) {
  // Use the connection URL for production (Render)
  sequelize = new Sequelize(config.url, {
    dialect: 'postgres',
    dialectOptions: config.dialectOptions || {
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false
        }
      }
    },
  });
} else {
  // Use individual parameters for development/test
  sequelize = new Sequelize(
    config.database,
    config.username,
    config.password,
    {
      ...config,
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false
        }
      }
    }

  );
}

// Read all files in the models folder and require only model files
fs.readdirSync(__dirname)
  .filter((file) => {
    // Exclude non-JS files, index.js, and non-model files
    return (
      file.indexOf('.') !== 0 &&
      file !== basename &&
      file.slice(-3) === '.js' &&
      !file.endsWith('.test.js')
    );
  })
  .forEach((file) => {
    const model = require(path.join(__dirname, file));

    // Ensure the file exports a function that initializes the model
    if (typeof model === 'function') {
      const modelInstance = model(sequelize, Sequelize.DataTypes);
      db[modelInstance.name] = modelInstance;
    }
  });

Object.keys(db).forEach((modelName) => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

// Add a simple query method for health checks
db.query = async (text, params) => {
  try {
    const result = await sequelize.query(text, {
      replacements: params,
    });
    return { rows: result[0] };
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
};

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
