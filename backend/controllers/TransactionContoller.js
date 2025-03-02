// controllers/transactionController.js
const pool = require('../db');
const redis = require('../redis');
const { io } = require('../socket');

// Get all transactions with pagination, filtering and sorting
exports.getTransactions = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      search = '',
      category = '',
      type = '',
      startDate = '',
      endDate = '',
      sortBy = 'transaction_date',
      sortOrder = 'DESC'
    } = req.query;
    
    const offset = (page - 1) * limit;
    
    // Build query conditions
    let queryConditions = ['is_deleted = FALSE'];
    const queryParams = [];
    let paramCounter = 1;
    
    if (search) {
      queryConditions.push(`(title ILIKE $${paramCounter} OR description ILIKE $${paramCounter})`);
      queryParams.push(`%${search}%`);
      paramCounter++;
    }
    
    if (category) {
      queryConditions.push(`category = $${paramCounter}`);
      queryParams.push(category);
      paramCounter++;
    }
    
    if (type) {
      queryConditions.push(`transaction_type = $${paramCounter}`);
      queryParams.push(type);
      paramCounter++;
    }
    
    if (startDate) {
      queryConditions.push(`transaction_date >= $${paramCounter}`);
      queryParams.push(startDate);
      paramCounter++;
    }
    
    if (endDate) {
      queryConditions.push(`transaction_date <= $${paramCounter}`);
      queryParams.push(endDate);
      paramCounter++;
    }
    
    // Check cache before querying database
    const cacheKey = `transactions:${search}:${category}:${type}:${startDate}:${endDate}:${sortBy}:${sortOrder}:${page}:${limit}`;
    const cachedData = await redis.get(cacheKey);
    
    if (cachedData && process.env.NODE_ENV !== 'development') {
      return res.status(200).json(JSON.parse(cachedData));
    }
    
    // Get transactions count
    const countQuery = `
      SELECT COUNT(*) FROM transactions
      WHERE ${queryConditions.join(' AND ')}
    `;
    
    const countResult = await pool.query(countQuery, queryParams);
    const totalCount = parseInt(countResult.rows[0].count, 10);
    
    // Get transactions
    const query = `
      SELECT t.*, 
             u1.full_name AS created_by_name,
             u2.full_name AS modified_by_name
      FROM transactions t
      LEFT JOIN users u1 ON t.created_by = u1.id
      LEFT JOIN users u2 ON t.last_modified_by = u2.id
      WHERE ${queryConditions.join(' AND ')}
      ORDER BY ${sortBy} ${sortOrder}
      LIMIT $${paramCounter} OFFSET $${paramCounter + 1}
    `;
    
    const result = await pool.query(
      query,
      [...queryParams, limit, offset]
    );
    
    const response = {
      transactions: result.rows,
      pagination: {
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
        currentPage: parseInt(page, 10),
        limit: parseInt(limit, 10)
      }
    };
    
    // Cache result for 5 minutes
    await redis.set(cacheKey, JSON.stringify(response), 'EX', 300);
    
    return res.status(200).json(response);
  } catch (err) {
    next(err);
  }
};

// Get transaction by ID
exports.getTransactionById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Check cache
    const cacheKey = `transaction:${id}`;
    const cachedData = await redis.get(cacheKey);
    
    if (cachedData && process.env.NODE_ENV !== 'development') {
      return res.status(200).json(JSON.parse(cachedData));
    }
    
    const result = await pool.query(
      `SELECT t.*, 
              u1.full_name AS created_by_name,
              u2.full_name AS modified_by_name
       FROM transactions t
       LEFT JOIN users u1 ON t.created_by = u1.id
       LEFT JOIN users u2 ON t.last_modified_by = u2.id
       WHERE t.id = $1 AND t.is_deleted = FALSE`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: {
          message: 'Transaction not found',
          code: 'TRANSACTION_NOT_FOUND'
        }
      });
    }
    
    // Get transaction history
    const historyResult = await pool.query(
      `SELECT th.*, u.full_name AS modified_by_name
       FROM transaction_history th
       LEFT JOIN users u ON th.modified_by = u.id
       WHERE th.transaction_id = $1
       ORDER BY th.modified_at DESC`,
      [id]
    );
    
    const transaction = {
      ...result.rows[0],
      history: historyResult.rows
    };
    
    // Cache for 5 minutes
    await redis.set(cacheKey, JSON.stringify(transaction), 'EX', 300);
    
    return res.status(200).json(transaction);
  } catch (err) {
    next(err);
  }
};

// Create transaction
exports.createTransaction = async (req, res, next) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const {
      title,
      amount,
      category,
      transactionType,
      transactionDate,
      description
    } = req.body;
    
    // Create transaction
    const result = await client.query(
      `INSERT INTO transactions 
         (title, amount, category, transaction_type, transaction_date, description, created_by, last_modified_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $7)
       RETURNING *`,
      [title, amount, category, transactionType, transactionDate, description, req.user.id]
    );
    
    const transaction = result.rows[0];
    
    // Add to transaction history
    await client.query(
      `INSERT INTO transaction_history 
         (transaction_id, modified_by, change_type, previous_state, new_state)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        transaction.id,
        req.user.id,
        'create',
        null,
        JSON.stringify(transaction)
      ]
    );
    
    // Create notifications for all users except creator
    const usersResult = await client.query(
      `SELECT id FROM users WHERE id <> $1`,
      [req.user.id]
    );
    
    for (const user of usersResult.rows) {
      await client.query(
        `INSERT INTO notifications
           (user_id, transaction_id, message)
         VALUES ($1, $2, $3)`,
        [
          user.id,
          transaction.id,
          `New transaction "${title}" was created by ${req.user.name || 'another user'}`
        ]
      );
    }
    
    await client.query('COMMIT');
    
    // Clear cache
    await redis.del('transactions:*');
    
    // Get user details for response
    const userResult = await pool.query(
      'SELECT full_name FROM users WHERE id = $1',
      [req.user.id]
    );
    
    transaction.created_by_name = userResult.rows[0].full_name;
    transaction.modified_by_name = userResult.rows[0].full_name;
    
    // Send real-time update to all connected clients
    io.emit('transaction:created', {
      transaction,
      by: {
        id: req.user.id,
        name: userResult.rows[0].full_name
      }
    });
    
    return res.status(201).json(transaction);
  } catch (err) {
    await client.query('ROLLBACK');
    next(err);
  } finally {
    client.release();
  }
};

// Update transaction
exports.updateTransaction = async (req, res, next) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { id } = req.params;
    const {
      title,
      amount,
      category,
      transactionType,
      transactionDate,
      description
    } = req.body;
    
    // Check if transaction exists and get current state
    const currentTransaction = await client.query(
      'SELECT * FROM transactions WHERE id = $1 AND is_deleted = FALSE',
      [id]
    );
    
    if (currentTransaction.rows.length === 0) {
      return res.status(404).json({
        error: {
          message: 'Transaction not found',
          code: 'TRANSACTION_NOT_FOUND'
        }
      });
    }
    
    // Check for conflict - if transaction was modified within last 5 seconds by another user
    const lastModification = await client.query(
      `SELECT * FROM transaction_history 
       WHERE transaction_id = $1 
       AND modified_by <> $2
       AND modified_at > NOW() - INTERVAL '5 seconds'
       ORDER BY modified_at DESC
       LIMIT 1`,
      [id, req.user.id]
    );
    
    if (lastModification.rows.length > 0) {
      // Handle conflict by returning warning but still perform update
      const conflict = {
        isConflict: true,
        message: 'This transaction was recently modified by another user',
        lastModifiedBy: lastModification.rows[0].modified_by,
        lastModifiedAt: lastModification.rows[0].modified_at
      };
      
      // Get user name for the conflict message
      const userResult = await client.query(
        'SELECT full_name FROM users WHERE id = $1',
        [lastModification.rows[0].modified_by]
      );
      
      if (userResult.rows.length > 0) {
        conflict.lastModifiedByName = userResult.rows[0].full_name;
      }
      
      // Update still proceeds, but with warning
      res.locals.conflict = conflict;
    }
    
    // Update transaction
    const result = await client.query(
      `UPDATE transactions 
       SET title = $1, 
           amount = $2, 
           category = $3, 
           transaction_type = $4, 
           transaction_date = $5, 
           description = $6,
           last_modified_by = $7,
           updated_at = NOW()
       WHERE id = $8
       RETURNING *`,
      [
        title, 
        amount, 
        category, 
        transactionType, 
        transactionDate, 
        description, 
        req.user.id, 
        id
      ]
    );
    
    const updatedTransaction = result.rows[0];
    
    // Add to transaction history
    await client.query(
      `INSERT INTO transaction_history 
         (transaction_id, modified_by, change_type, previous_state, new_state)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        id,
        req.user.id,
        'update',
        JSON.stringify(currentTransaction.rows[0]),
        JSON.stringify(updatedTransaction)
      ]
    );
    
    // Create notifications for all users except updater
    const usersResult = await client.query(
      `SELECT id FROM users WHERE id <> $1`,
      [req.user.id]
    );
    
    for (const user of usersResult.rows) {
      await client.query(
        `INSERT INTO notifications
           (user_id, transaction_id, message)
         VALUES ($1, $2, $3)`,
        [
          user.id,
          id,
          `Transaction "${title}" was updated by ${req.user.name || 'another user'}`
        ]
      );
    }
    
    await client.query('COMMIT');
    
    // Clear cache
    await redis.del(`transaction:${id}`);
    await redis.del('transactions:*');
    
    // Get user details for response
    const userResult = await pool.query(
      'SELECT full_name FROM users WHERE id = $1',
      [req.user.id]
    );
    
    updatedTransaction.modified_by_name = userResult.rows[0].full_name;
    
    // Add conflict information if present
    if (res.locals.conflict) {
      updatedTransaction.conflict = res.locals.conflict;
    }
    
    // Send real-time update to all connected clients
    io.emit('transaction:updated', {
      transaction: updatedTransaction,
      by: {
        id: req.user.id,
        name: userResult.rows[0].full_name
      },
      conflict: res.locals.conflict
    });
    
    return res.status(200).json(updatedTransaction);
  } catch (err) {
    await client.query('ROLLBACK');
    next(err);
  } finally {
    client.release();
  }
};

// Delete transaction (soft delete)
exports.deleteTransaction = async (req, res, next) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { id } = req.params;
    
    // Check if transaction exists and get current state
    const currentTransaction = await client.query(
      'SELECT * FROM transactions WHERE id = $1 AND is_deleted = FALSE',
      [id]
    );
    
    if (currentTransaction.rows.length === 0) {
      return res.status(404).json({
        error: {
          message: 'Transaction not found',
          code: 'TRANSACTION_NOT_FOUND'
        }
      });
    }
    
    // Soft delete transaction
    const result = await client.query(
      `UPDATE transactions 
       SET is_deleted = TRUE,
           last_modified_by = $1,
           updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
      [req.user.id, id]
    );
    
    // Add to transaction history
    await client.query(
      `INSERT INTO transaction_history 
         (transaction_id, modified_by, change_type, previous_state, new_state)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        id,
        req.user.id,
        'delete',
        JSON.stringify(currentTransaction.rows[0]),
        JSON.stringify(result.rows[0])
      ]
    );
    
    // Create notifications for all users except deleter
    const usersResult = await client.query(
      `SELECT id FROM users WHERE id <> $1`,
      [req.user.id]
    );
    
    for (const user of usersResult.rows) {
      await client.query(
        `INSERT INTO notifications
           (user_id, transaction_id, message)
         VALUES ($1, $2, $3)`,
        [
          user.id,
          id,
          `Transaction "${currentTransaction.rows[0].title}" was deleted by ${req.user.name || 'another user'}`
        ]
      );
    }
    
    await client.query('COMMIT');
    
    // Clear cache
    await redis.del(`transaction:${id}`);
    await redis.del('transactions:*');
    
    // Get user details for response
    const userResult = await pool.query(
      'SELECT full_name FROM users WHERE id = $1',
      [req.user.id]
    );
    
    // Send real-time update to all connected clients
    io.emit('transaction:deleted', {
      transactionId: id,
      transactionTitle: currentTransaction.rows[0].title,
      by: {
        id: req.user.id,
        name: userResult.rows[0].full_name
      }
    });
    
    return res.status(200).json({
      message: 'Transaction deleted successfully',
      transactionId: id
    });
  } catch (err) {
    await client.query('ROLLBACK');
    next(err);
  } finally {
    client.release();
  }
};