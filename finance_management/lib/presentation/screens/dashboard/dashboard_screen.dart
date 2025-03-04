import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:financial_management/presentation/widgets/common/custom_nav_shape.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  int _selectedCardIndex = 0;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Food',
    'Shopping',
    'Transport',
    'Bills',
    'Entertainment',
  ];
  bool _showInsights = false;

  // Mock data for budget spending by category
  final Map<String, Map<String, dynamic>> _budgetData = {
    'Food': {'spent': 380, 'total': 500, 'color': Colors.orange},
    'Shopping': {'spent': 620, 'total': 750, 'color': Colors.blue},
    'Transport': {'spent': 120, 'total': 300, 'color': Colors.green},
    'Bills': {'spent': 450, 'total': 500, 'color': Colors.red},
    'Entertainment': {'spent': 180, 'total': 250, 'color': Colors.purple},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Simulate data loading and show insights after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showInsights = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 20),

            // Header with greeting, profile and notification
            _buildHeader(),

            const SizedBox(height: 24),

            // Multiple account cards
            _buildAccountCards(),

            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActions(),

            const SizedBox(height: 24),

            // Smart Insights section (animated entry)
            if (_showInsights) _buildSmartInsights(),

            const SizedBox(height: 24),

            // Expense breakdown tabs
            _buildExpenseAnalytics(),

            const SizedBox(height: 20),

            // Budget progress section
            _buildBudgetProgress(),

            const SizedBox(height: 20),

            // Recent transactions with category filter
            _buildRecentTransactions(),

            // Add space at bottom for nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good morning,",
                style: TextStyle(fontSize: 16, color: Color(0xFF78839C)),
              ),
              SizedBox(height: 4),
              Text(
                "John Smith",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E5C),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              iconSize: 28,
              color: const Color(0xFF2E3E5C),
            ),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {},
              iconSize: 28,
              color: const Color(0xFF2E3E5C),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4E74F9), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountCards() {
    final List<Map<String, dynamic>> accounts = [
      {
        'name': 'Main Account',
        'type': 'Checking',
        'balance': 12865.24,
        'income': 4582.55,
        'expenses': 2718.39,
        'cardNumber': '**** 4582',
        'color1': const Color(0xFF4A148C),
        'color2': const Color(0xFF4E74F9),
      },
      {
        'name': 'Savings Account',
        'type': 'Savings',
        'balance': 34750.00,
        'income': 2500.00,
        'expenses': 0.00,
        'cardNumber': '**** 7231',
        'color1': const Color(0xFF00897B),
        'color2': const Color(0xFF4DB6AC),
      },
      {
        'name': 'Investment Account',
        'type': 'Investment',
        'balance': 18325.67,
        'income': 1245.88,
        'expenses': 500.00,
        'cardNumber': '**** 9043',
        'color1': const Color(0xFFEF6C00),
        'color2': const Color(0xFFFFB74D),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider.builder(
          itemCount: accounts.length,
          options: CarouselOptions(
            height: 220,
            viewportFraction: 1,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _selectedCardIndex = index;
              });
            },
            initialPage: _selectedCardIndex,
          ),
          itemBuilder: (context, index, realIndex) {
            final account = accounts[index];
            return GestureDetector(
              onTap: () {
                // Navigate to account details
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [account['color1'], account['color2']],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: account['color2'].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account['type'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          account['cardNumber'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "\$${account['balance'].toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Use Flexible to allow both widgets to share space
                          Flexible(
                            child: _buildIncomeExpense(
                              icon: Icons.arrow_downward,
                              label: "Income",
                              amount:
                                  "\$${account['income'].toStringAsFixed(2)}",
                              iconColor: Colors.green,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ), // Add some space between the two columns
                          Flexible(
                            child: _buildIncomeExpense(
                              icon: Icons.arrow_upward,
                              label: "Expenses",
                              amount:
                                  "\$${account['expenses'].toStringAsFixed(2)}",
                              iconColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            accounts.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _selectedCardIndex == index
                        ? const Color(0xFF4E74F9)
                        : const Color(0xFFD8D8D8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.send, 'label': 'Send', 'color': const Color(0xFF4E74F9)},
      {
        'icon': Icons.account_balance,
        'label': 'Deposit',
        'color': const Color(0xFF00C853),
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Pay Bills',
        'color': const Color(0xFFFF6D00),
      },
      {
        'icon': Icons.more_horiz,
        'label': 'More',
        'color': const Color(0xFF78839C),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E5C),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              actions.map((action) {
                return GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: action['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          action['icon'],
                          color: action['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E3E5C),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSmartInsights() {
    return AnimatedOpacity(
      opacity: _showInsights ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Smart Insights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E5C),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {},
                color: const Color(0xFF78839C),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.trending_down, color: Colors.red),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Spending Alert",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3E5C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Food expenses are 25% higher this month",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF78839C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.savings_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Savings Opportunity",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3E5C),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "You could save \$85 by reducing subscription costs",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF78839C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E74F9),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View All Insights",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Expense Analytics",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E5C),
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4E74F9),
          unselectedLabelColor: const Color(0xFF78839C),
          indicatorColor: const Color(0xFF4E74F9),
          tabs: const [
            Tab(text: "Week"),
            Tab(text: "Month"),
            Tab(text: "Year"),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExpenseChart(), // Weekly chart
              _buildExpenseChart(), // Monthly chart
              _buildExpenseChart(), // Yearly chart
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Budget Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E5C),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "See All",
                style: TextStyle(
                  color: Color(0xFF4E74F9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _budgetData.length,
            itemBuilder: (context, index) {
              final category = _budgetData.keys.elementAt(index);
              final data = _budgetData[category]!;
              final percent = data['spent'] / data['total'];

              return Expanded(
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3E5C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: CircularPercentIndicator(
                          radius: 40,
                          lineWidth: 8,
                          percent: percent,
                          center: Text(
                            "${(percent * 100).toInt()}%",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progressColor: data['color'],
                          backgroundColor: data['color'].withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          "\$${data['spent']} / \$${data['total']}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF78839C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E5C),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Color(0xFF4E74F9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Category filter chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4E74F9) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.transparent
                              : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF78839C),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Transactions list
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildTransactionItem(
              icon: Icons.shopping_bag_outlined,
              title: "Groceries",
              subtitle: "Whole Foods",
              date: "Today, 4:35 PM",
              amount: "-\$85.24",
              isExpense: true,
            ),
            _buildTransactionItem(
              icon: Icons.home_outlined,
              title: "Rent Payment",
              subtitle: "Monthly Rent",
              date: "Yesterday, 9:15 AM",
              amount: "-\$1,200.00",
              isExpense: true,
            ),
            _buildTransactionItem(
              icon: Icons.work_outline,
              title: "Salary Deposit",
              subtitle: "Employer Inc.",
              date: "Mar 25, 10:00 AM",
              amount: "+\$4,200.00",
              isExpense: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeExpense({
    required IconData icon,
    required String label,
    required String amount,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Expenses",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3E5C),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "-\$2,718.39",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFF78839C),
                          fontSize: 12,
                        );
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = '\$0';
                            break;
                          case 500:
                            text = '\$500';
                            break;
                          case 1000:
                            text = '\$1k';
                            break;
                          case 1500:
                            text = '\$1.5k';
                            break;
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFF78839C),
                          fontSize: 12,
                        );
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'Mon';
                            break;
                          case 1:
                            text = 'Tue';
                            break;
                          case 2:
                            text = 'Wed';
                            break;
                          case 3:
                            text = 'Thu';
                            break;
                          case 4:
                            text = 'Fri';
                            break;
                          case 5:
                            text = 'Sat';
                            break;
                          case 6:
                            text = 'Sun';
                            break;
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 1500,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 400),
                      FlSpot(1, 850),
                      FlSpot(2, 620),
                      FlSpot(3, 950),
                      FlSpot(4, 1200),
                      FlSpot(5, 800),
                      FlSpot(6, 600),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF4E74F9)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4E74F9),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4E74F9).withOpacity(0.3),
                          const Color(0xFF4E74F9).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4E74F9)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3E5C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? Colors.redAccent : Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 14, color: Color(0xFF78839C)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
