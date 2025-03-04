import 'dart:async';
import 'package:financial_management/presentation/screens/auth/login.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      image: 'assets/images/onboarding1.png',
      title: 'Real-time Financial Tracking',
      description:
          'Monitor your expenses and income in real-time with our powerful dashboard. Never miss a transaction again.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding2.png',
      title: 'Collaborative Budgeting',
      description:
          'Create and manage budgets together with family or teammates. Share goals and track progress collectively.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding3.png',
      title: 'Smart Insights',
      description:
          'Leverage AI-powered insights to optimize your spending habits and identify saving opportunities.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding4.png',
      title: 'Secure & Private',
      description:
          'Your financial data is protected with bank-level encryption. Control who has access to your information.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Setup timer for auto sliding
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _onboardingItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen PageView for background images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingItems.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _onboardingItems[index].image,
                fit: BoxFit.cover,
              );
            },
          ),

          // Purple to white gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A148C), // Dark purple at top
                  const Color(0xFF4A148C).withOpacity(0.7),
                  const Color(0xFF4A148C).withOpacity(0.3),
                  Colors.white.withOpacity(0.9),
                  Colors.white,
                ],
                stops: const [0.0, 0.15, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 6),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingItems.length,
                    (index) => buildPageIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 40),

                // Title and description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        _onboardingItems[_currentPage].title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3E5C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _onboardingItems[_currentPage].description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF78839C),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Buttons at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Row(
                    children: [
                      if (_currentPage < _onboardingItems.length - 1)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E74F9),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _navigateToLoginScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E74F9),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4E74F9) : const Color(0xFFD8DAE5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
