# Flutter Financial Management Backend

This is the backend for the Flutter Financial Management application. It is built using Node.js and connects to a PostgreSQL database. Below you will find instructions on how to set up, clone, and connect to the PostgreSQL database, as well as a description of each folder in the project.

## Table of Contents

- [Setup](#setup)
- [Clone](#clone)
- [Connect to PostgreSQL](#connect-to-postgresql)
- [Folder Structure](#folder-structure)

## Setup

1. Ensure you have Node.js and npm installed on your machine.
2. Install PostgreSQL and Redis on your machine.
3. Create a `.env` file in the root directory of the project and add the following environment variables:

```
DB_USER=
DB_HOST=
DB_NAME=
DB_PASS=
DB_PORT=
DATABASE_URL=
REDIS_URL=
REDIS_PASSWORD=
REDIS_DB=
JWT_SECRET=
JWT_EXPIRE=
JWT_COOKIE_EXPIRE=
CLIENT_URL=
PORT=
NODE_ENV=
```

## Clone

To clone the repository, run the following command:

```bash
git clone https://github.com/yourusername/flutter-financial-management-backend.git
cd flutter-financial-management-backend
```

## Connect to PostgreSQL

1. Start PostgreSQL and Redis services on your machine.
2. Ensure the environment variables in your `.env` file are correctly set to match your PostgreSQL and Redis configurations.
3. Run the following command to install the necessary dependencies:

```bash
npm install
```

4. Run the following command to start the server:

```bash
npm run dev
```

## Folder Structure

- `controllers/`: Contains the logic for handling requests and responses.
- `models/`: Contains the database models.
- `routes/`: Contains the route definitions for the API endpoints.
- `config/`: Contains configuration files, including database and server configurations.
- `middleware/`: Contains middleware functions for request processing.
- `utils/`: Contains utility functions and helpers.
- `tests/`: Contains test files for the application.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contact

For any questions or inquiries, please contact [yourname@yourdomain.com](mailto:yourname@yourdomain.com).
