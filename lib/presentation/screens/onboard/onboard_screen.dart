import 'package:flutter/material.dart';
import 'package:penpenny/core/debug/app_debug.dart';
import 'package:penpenny/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:penpenny/presentation/screens/onboard/widgets/currency_picker_widget.dart';
import 'package:penpenny/presentation/screens/onboard/widgets/landing_widget.dart';
import 'package:penpenny/presentation/screens/onboard/widgets/profile_widget.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    AppDebug.logUserAction('CompleteOnboarding');
    // Navigate to dashboard and remove onboarding from stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          LandingWidget(
            onGetStarted: _nextPage,
          ),
          ProfileWidget(
            onGetStarted: _nextPage,
          ),
          CurrencyPickerWidget(
            onCompleted: _completeOnboarding,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}