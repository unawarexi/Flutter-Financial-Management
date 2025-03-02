import 'package:financial_management/presentation/screens/budget/budget_screen.dart';
import 'package:financial_management/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:financial_management/presentation/screens/scan/scan_screen.dart';
import 'package:financial_management/presentation/screens/transactions/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:financial_management/presentation/widgets/common/custom_nav_shape.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const ScanScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true, // This allows the body to extend behind the navbar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main bottom navigation bar
        ClipPath(
          clipper: CustomNavBarShape(),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, "Bill"),
                _buildNavItem(1, Icons.bar_chart, "Chart"),
                const SizedBox(width: 70), // Space for the floating button
                _buildNavItem(3, Icons.account_balance_wallet, "Budget"),
                _buildNavItem(4, Icons.person, "Account"),
              ],
            ),
          ),
        ),

        // Floating center button
        Positioned(
          top: -20, // Position the button to overflow from the navbar
          child: GestureDetector(
            onTap: () => onItemTapped(2),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF0047BA),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        width: 70,
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0047BA) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF0047BA) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
