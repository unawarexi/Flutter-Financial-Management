const fs = require('fs');
const path = require('path');
const Sequelize = require('sequelize');
const process = require('process');
const basename = path.basename(__filename);
const env = process.env.NODE_ENV || 'production';
const config = require(__dirname + '/../config/config.js')[env];

const db = {};

let sequelize;

if (process.env.DATABASE_URL) {
  sequelize = new Sequelize(process.env.DATABASE_URL, {
    dialect: 'postgres',
    dialectOptions:  {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  });
} else {
  sequelize = new Sequelize(config.database, config.username, config.password, config);
}

db.User = require('./User')(sequelize, Sequelize.DataTypes);

// More robust model loading
// fs.readdirSync(__dirname)
//   .filter(file => {
//     return (
//       file.indexOf('.') !== 0 &&
//       file !== basename &&
//       file.slice(-3) === '.js' &&
//       file.indexOf('.test.js') === -1
//     );
//   })
//   .forEach(file => {
//     // Use default import if available, otherwise try function call
//     const modelModule = require(path.join(__dirname, file));
//     const model = typeof modelModule === 'function' 
//       ? modelModule(sequelize, Sequelize.DataTypes)
//       : modelModule.default(sequelize, Sequelize.DataTypes);
    
//     // Use the model name or filename (without extension) as the key
//     const modelName = model.name || path.basename(file, '.js');
//     db[modelName] = model;
//   });

// Object.keys(db).forEach(modelName => {
//   if (db[modelName].associate) {
//     db[modelName].associate(db);
//   }
// });

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;