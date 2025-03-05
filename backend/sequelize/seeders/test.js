const { sequelize } = require('./models');  // Import your sequelize instance

async function listTables() {
  const [results, metadata] = await sequelize.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
  );
  console.log('Tables in the database:', results);
}

listTables();
