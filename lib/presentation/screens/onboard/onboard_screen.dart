import 'package:flutter/material.dart';
import 'package:penpenny/presentation/screens/onboard/widgets/currency_picker_widget.dart';
import 'package:penpenny/presentation/screens/onboard/widgets/landing_widget.dart';
import 'package:penpenny/presentation/screens/onboard/widgets/profile_widget.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LandingWidget(
            onGetStarted: () {
              pageController.jumpToPage(1);
            },
          ),
          ProfileWidget(
            onGetStarted: () {
              pageController.jumpToPage(2);
            },
          ),
          const CurrencyPickerWidget()
        ],
      ),
    );
  }
}