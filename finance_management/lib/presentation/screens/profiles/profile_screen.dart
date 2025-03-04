import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  bool isBiometricEnabled = true;
  bool isAutoSaveEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6E8EFB)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF6E8EFB),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6E8EFB), Color(0xFFA777E3)],
                  ),
                ),
                child: Column(
                  children: [
                    // User Image with Edit Button
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Image selection logic would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Change profile picture'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://via.placeholder.com/150',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Color(0xFF6E8EFB),
                            ),
                            onPressed: () {
                              // Image selection logic would go here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Change profile picture'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // User Name
                    const Text(
                      'Alex Johnson',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // User Email
                    const Text(
                      'alex.johnson@example.com',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 15),
                    // Premium Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.diamond_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Premium Member',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Options
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    _buildSectionTitle('Account'),
                    _buildOptionItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () {
                        _showActionSnackBar('Personal Information');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.credit_card,
                      title: 'Payment Methods',
                      onTap: () {
                        _showActionSnackBar('Payment Methods');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.security,
                      title: 'Security',
                      onTap: () {
                        _showActionSnackBar('Security');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.monetization_on_outlined,
                      title: 'Subscription',
                      onTap: () {
                        _showActionSnackBar('Subscription');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Preferences Section
                    _buildSectionTitle('Preferences'),
                    _buildSwitchItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                        _showActionSnackBar(
                          'Dark Mode: ${value ? 'Enabled' : 'Disabled'}',
                        );
                      },
                    ),
                    _buildSwitchItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      value: isNotificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          isNotificationsEnabled = value;
                        });
                        _showActionSnackBar(
                          'Notifications: ${value ? 'Enabled' : 'Disabled'}',
                        );
                      },
                    ),
                    _buildSwitchItem(
                      icon: Icons.fingerprint,
                      title: 'Biometric Authentication',
                      value: isBiometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          isBiometricEnabled = value;
                        });
                        _showActionSnackBar(
                          'Biometric: ${value ? 'Enabled' : 'Disabled'}',
                        );
                      },
                    ),
                    _buildSwitchItem(
                      icon: Icons.savings_outlined,
                      title: 'Auto-save Goals',
                      value: isAutoSaveEnabled,
                      onChanged: (value) {
                        setState(() {
                          isAutoSaveEnabled = value;
                        });
                        _showActionSnackBar(
                          'Auto-save: ${value ? 'Enabled' : 'Disabled'}',
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Additional Features Section
                    _buildSectionTitle('Features'),
                    _buildOptionItem(
                      icon: Icons.card_giftcard,
                      title: 'Referrals',
                      badge: '3',
                      onTap: () {
                        _showActionSnackBar('Referrals');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        _showActionSnackBar('Help & Support');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.settings_outlined,
                      title: 'Advanced Settings',
                      onTap: () {
                        _showActionSnackBar('Advanced Settings');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _showActionSnackBar('Logged Out');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // Option Item Widget
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6E8EFB), Color(0xFFA777E3)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E8EFB),
                      ),
                    ),
                  ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Switch Item Widget
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6E8EFB), Color(0xFFA777E3)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CupertinoSwitch(
              value: value,
              activeColor: const Color(0xFF6E8EFB),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show action feedback
  void _showActionSnackBar(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: $action'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
