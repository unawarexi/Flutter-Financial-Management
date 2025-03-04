import 'package:flutter/material.dart';

// Model class for Transaction
class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final int quantity;
  final String category;
  final DateTime date;
  bool isExpense;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.quantity,
    required this.category,
    required this.date,
    required this.isExpense,
    required this.icon,
  });
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  final List<String> _categories = [
    'Food & Drinks',
    'Shopping',
    'Transportation',
    'Housing',
    'Entertainment',
    'Healthcare',
    'Education',
    'Freelance',
    'Salary',
    'Other Income',
    'Other Expense',
  ];

  // For multi-selection
  bool _isMultiSelectMode = false;
  final Set<String> _selectedTransactionIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSampleTransactions();
  }

  void _loadSampleTransactions() {
    _transactions = [
      Transaction(
        id: '1',
        title: 'Groceries',
        description: 'Food & Drinks',
        amount: 85.24,
        quantity: 1,
        category: 'Food & Drinks',
        date: DateTime.now(),
        isExpense: true,
        icon: Icons.shopping_bag_outlined,
      ),
      Transaction(
        id: '2',
        title: 'Restaurant',
        description: 'Lunch with colleagues',
        amount: 45.80,
        quantity: 1,
        category: 'Food & Drinks',
        date: DateTime.now(),
        isExpense: true,
        icon: Icons.local_dining_outlined,
      ),
      Transaction(
        id: '3',
        title: 'Client Payment',
        description: 'Freelance Project',
        amount: 850.00,
        quantity: 1,
        category: 'Freelance',
        date: DateTime.now(),
        isExpense: false,
        icon: Icons.payments_outlined,
      ),
      Transaction(
        id: '4',
        title: 'Rent Payment',
        description: 'Housing',
        amount: 1200.00,
        quantity: 1,
        category: 'Housing',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isExpense: true,
        icon: Icons.home_outlined,
      ),
      Transaction(
        id: '5',
        title: 'Gas Station',
        description: 'Transportation',
        amount: 48.55,
        quantity: 1,
        category: 'Transportation',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isExpense: true,
        icon: Icons.local_gas_station_outlined,
      ),
      Transaction(
        id: '6',
        title: 'Salary Deposit',
        description: 'Monthly Income',
        amount: 4200.00,
        quantity: 1,
        category: 'Salary',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isExpense: false,
        icon: Icons.work_outline,
      ),
      Transaction(
        id: '7',
        title: 'Online Shopping',
        description: 'Electronics',
        amount: 329.99,
        quantity: 1,
        category: 'Shopping',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isExpense: true,
        icon: Icons.shopping_cart_outlined,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.add(transaction);
    });
  }

  void _updateTransaction(Transaction updatedTransaction) {
    setState(() {
      final index = _transactions.indexWhere(
        (t) => t.id == updatedTransaction.id,
      );
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((transaction) => transaction.id == id);
    });
  }

  void _deleteSelectedTransactions() {
    setState(() {
      _transactions.removeWhere(
        (transaction) => _selectedTransactionIds.contains(transaction.id),
      );
      _selectedTransactionIds.clear();
      _isMultiSelectMode = false;
    });
  }

  void _toggleTransactionSelection(String id) {
    setState(() {
      if (_selectedTransactionIds.contains(id)) {
        _selectedTransactionIds.remove(id);
        if (_selectedTransactionIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedTransactionIds.add(id);
      }
    });
  }

  void _selectAllTransactions(List<Transaction> transactions) {
    setState(() {
      for (final transaction in transactions) {
        _selectedTransactionIds.add(transaction.id);
      }
    });
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionForm(),
    );
  }

  Widget _buildTransactionForm({Transaction? transaction}) {
    final isEditing = transaction != null;
    final formKey = GlobalKey<FormState>();

    String title = isEditing ? transaction.title : '';
    String description = isEditing ? transaction.description : '';
    double amount = isEditing ? transaction.amount : 0.0;
    int quantity = isEditing ? transaction.quantity : 1;
    String category = isEditing ? transaction.category : _categories.first;
    bool isExpense = isEditing ? transaction.isExpense : true;

    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);
    final amountController = TextEditingController(
      text: amount > 0 ? amount.toString() : '',
    );
    final quantityController = TextEditingController(text: quantity.toString());

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: ListView(
              controller: scrollController,
              children: [
                const Text(
                  'Add New Transaction',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3E5C),
                  ),
                ),
                const SizedBox(height: 24),

                // Type selection
                const Text(
                  'Transaction Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3E5C),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isExpense = true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isExpense
                                    ? const Color(0xFFFFE2E4)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isExpense
                                      ? Colors.redAccent
                                      : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  isExpense
                                      ? Colors.redAccent
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isExpense = false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                !isExpense
                                    ? const Color(0xFFE2FFE9)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  !isExpense
                                      ? Colors.green
                                      : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  !isExpense
                                      ? Colors.green
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: const TextStyle(color: Color(0xFF78839C)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4E74F9)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Color(0xFF78839C)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4E74F9)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: const TextStyle(color: Color(0xFF78839C)),
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4E74F9)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Quantity
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: const TextStyle(color: Color(0xFF78839C)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4E74F9)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Color(0xFF78839C)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4E74F9)),
                    ),
                  ),
                  items:
                      _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      category = newValue;
                    }
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Create or update transaction
                      final newTransaction = Transaction(
                        id:
                            isEditing
                                ? transaction.id
                                : DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        amount: double.parse(amountController.text),
                        quantity: int.parse(quantityController.text),
                        category: category,
                        date: isEditing ? transaction.date : DateTime.now(),
                        isExpense: isExpense,
                        icon: _getIconForCategory(category, isExpense),
                      );

                      if (isEditing) {
                        _updateTransaction(newTransaction);
                      } else {
                        _addTransaction(newTransaction);
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E74F9),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Transaction' : 'Create Transaction',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category, bool isExpense) {
    if (!isExpense) {
      if (category == 'Salary') return Icons.work_outline;
      if (category == 'Freelance') return Icons.payments_outlined;
      return Icons.account_balance_wallet_outlined;
    }

    switch (category) {
      case 'Food & Drinks':
        return Icons.restaurant_outlined;
      case 'Shopping':
        return Icons.shopping_cart_outlined;
      case 'Transportation':
        return Icons.directions_car_outlined;
      case 'Housing':
        return Icons.home_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Healthcare':
        return Icons.medical_services_outlined;
      case 'Education':
        return Icons.school_outlined;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Customize the icon here
          onPressed: () {
            // Handle navigation logic, for example:
            Navigator.pop(context); // Takes the user to the previous screen
            // or Navigator.pushNamed(context, '/previousScreen'); if you want to go to a specific screen.
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Transactions",
          style: TextStyle(
            color: Color(0xFF2E3E5C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteSelectedTransactions,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF2E3E5C)),
              onPressed: () {
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedTransactionIds.clear();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF2E3E5C)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF2E3E5C)),
              onPressed: () {},
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4E74F9),
          unselectedLabelColor: const Color(0xFF78839C),
          indicatorColor: const Color(0xFF4E74F9),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Income"),
            Tab(text: "Expenses"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(includeAll: true),
          _buildTransactionList(onlyIncome: true),
          _buildTransactionList(onlyExpenses: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: const Color(0xFF4E74F9),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList({
    bool includeAll = false,
    bool onlyIncome = false,
    bool onlyExpenses = false,
  }) {
    // Filter transactions based on tab
    final filteredTransactions =
        _transactions.where((transaction) {
          if (includeAll) return true;
          if (onlyIncome) return !transaction.isExpense;
          if (onlyExpenses) return transaction.isExpense;
          return false;
        }).toList();

    // Group transactions by date
    final Map<String, List<Transaction>> groupedTransactions = {};

    for (final transaction in filteredTransactions) {
      final date = transaction.date;
      final now = DateTime.now();

      String dateKey;
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dateKey = "Today, ${_formatDate(date)}";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        dateKey = "Yesterday, ${_formatDate(date)}";
      } else {
        dateKey = _formatDate(date);
      }

      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    if (groupedTransactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions found",
          style: TextStyle(fontSize: 16, color: Color(0xFF78839C)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isMultiSelectMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_selectedTransactionIds.length} selected",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => _selectAllTransactions(filteredTransactions),
                    child: const Text(
                      "Select All",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E74F9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ...groupedTransactions.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3E5C),
                  ),
                ),
                const SizedBox(height: 16),
                ...entry.value.map((transaction) {
                  return _buildTransactionItem(
                    transaction: transaction,
                    onTap: () => _navigateToDetailScreen(transaction),
                    onLongPress: () {
                      setState(() {
                        _isMultiSelectMode = true;
                        _toggleTransactionSelection(transaction.id);
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _navigateToDetailScreen(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TransactionDetailScreen(
              transaction: transaction,
              onDelete: _deleteTransaction,
              onUpdate: (transaction) {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) =>
                          _buildTransactionForm(transaction: transaction),
                );
              },
            ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required Transaction transaction,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    final isSelected = _selectedTransactionIds.contains(transaction.id);
    final formattedAmount =
        transaction.isExpense
            ? "-\$${transaction.amount.toStringAsFixed(2)}"
            : "+\$${transaction.amount.toStringAsFixed(2)}";

    return GestureDetector(
      onTap:
          _isMultiSelectMode
              ? () => _toggleTransactionSelection(transaction.id)
              : onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECF0FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border:
              isSelected
                  ? Border.all(color: const Color(0xFF4E74F9), width: 2)
                  : null,
        ),
        child: Row(
          children: [
            if (_isMultiSelectMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4E74F9),
                          size: 28,
                        )
                        : const Icon(
                          Icons.circle_outlined,
                          color: Color(0xFF78839C),
                          size: 28,
                        ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    transaction.isExpense
                        ? const Color(0xFFFFE2E4)
                        : const Color(0xFFE2FFE9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.icon,
                color: transaction.isExpense ? Colors.redAccent : Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF78839C),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedAmount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        transaction.isExpense ? Colors.redAccent : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(transaction.date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF78839C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }
}

// New screen for transaction details
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  final Function(String) onDelete;
  final Function(Transaction) onUpdate;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Transaction Details",
          style: TextStyle(
            color: Color(0xFF2E3E5C),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E5C)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF4E74F9)),
            onPressed: () => onUpdate(transaction),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header with transaction amount
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          transaction.isExpense
                              ? const Color(0xFFFFE2E4)
                              : const Color(0xFFE2FFE9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction.icon,
                      color:
                          transaction.isExpense
                              ? Colors.redAccent
                              : Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.isExpense
                        ? "-\$${transaction.amount.toStringAsFixed(2)}"
                        : "+\$${transaction.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          transaction.isExpense
                              ? Colors.redAccent
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF78839C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transaction details
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    title: "Category",
                    value: transaction.category,
                    icon: Icons.category_outlined,
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(
                    title: "Date",
                    value: _formatFullDate(transaction.date),
                    icon: Icons.calendar_today_outlined,
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(
                    title: "Time",
                    value: _formatDetailTime(transaction.date),
                    icon: Icons.access_time_outlined,
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(
                    title: "Quantity",
                    value: transaction.quantity.toString(),
                    icon: Icons.format_list_numbered_outlined,
                  ),
                  if (transaction.quantity > 1) ...[
                    const Divider(height: 32),
                    _buildDetailRow(
                      title: "Unit Price",
                      value:
                          "\$${(transaction.amount / transaction.quantity).toStringAsFixed(2)}",
                      icon: Icons.attach_money_outlined,
                    ),
                  ],
                  const Divider(height: 32),
                  _buildDetailRow(
                    title: "Transaction Type",
                    value: transaction.isExpense ? "Expense" : "Income",
                    icon:
                        transaction.isExpense
                            ? Icons.trending_down_outlined
                            : Icons.trending_up_outlined,
                    valueColor:
                        transaction.isExpense ? Colors.redAccent : Colors.green,
                    onTap:
                        () =>
                            transaction.isExpense =
                                !transaction
                                    .isExpense, // Add onTap to handle click events
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notes section (if available)
            if (transaction.description.isNotEmpty &&
                transaction.description != transaction.category)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3E5C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF78839C),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Delete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showDeleteConfirmationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Delete Transaction",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
    VoidCallback? onTap, // Add onTap to handle click events
  }) {
    return GestureDetector(
      onTap: onTap, // Enable clicking
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECF0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4E74F9), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF78839C)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF2E3E5C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayOfWeek = days[date.weekday - 1];
    return "$dayOfWeek, ${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _formatDetailTime(DateTime date) {
    final hour =
        date.hour > 12
            ? date.hour - 12
            : date.hour == 0
            ? 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Transaction"),
            content: const Text(
              "Are you sure you want to delete this transaction? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Color(0xFF78839C)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  onDelete(transaction.id);
                  Navigator.pop(context); // Return to transactions list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text("Delete"),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }
}
