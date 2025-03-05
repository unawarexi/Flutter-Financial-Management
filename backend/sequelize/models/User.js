// Do not destructure `sequelize` and `DataTypes` directly from 'sequelize'

module.exports = (sequelize, DataTypes) => {
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
      type: DataTypes.STRING,
      allowNull: true,
    },
    financial_goal: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  }, {
    tableName: 'users', 
    timestamps: true,   
  });

  return User;
};
