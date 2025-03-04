// models/User.js

const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    first_name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    last_name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    phone_number: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    date_of_birth: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    password_hash: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    monthly_income: {
      type: DataTypes.FLOAT,
      allowNull: true,
    },
    financial_goal: {
      type: DataTypes.FLOAT,
      allowNull: true,
    },
  }, {
    tableName: 'users', // Ensures Sequelize matches the existing table name
    timestamps: true,   // Automatically manages createdAt/updatedAt fields
  });

  return User;
};
