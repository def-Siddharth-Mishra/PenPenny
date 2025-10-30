import 'package:flutter/material.dart';
import 'package:penpenny/presentation/widgets/common/app_button.dart';

class LandingWidget extends StatelessWidget {
  final VoidCallback onGetStarted;
  const LandingWidget({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PenPenny",
                style: theme.textTheme.headlineLarge!.apply(
                  color: theme.colorScheme.primary,
                  fontWeightDelta: 1,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Easy method to manage your savings",
                style: theme.textTheme.headlineMedium!.apply(
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 15),
                  const Expanded(child: Text("Using our app, manage your finances."))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 15),
                  const Expanded(child: Text("Simple expense monitoring for more accurate budgeting"))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 15),
                  const Expanded(child: Text("Keep track of your spending whenever and wherever you are.")),
                ],
              ),
              const Expanded(child: SizedBox()),
              
              // Progress indicator
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Step 1 of 3",
                    style: theme.textTheme.bodySmall!.apply(
                      color: theme.textTheme.bodySmall!.color!.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("*Since this application is currently in beta, be prepared for UI changes and unexpected behaviours."),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomRight,
                child: AppButton(
                  color: theme.colorScheme.inversePrimary,
                  isFullWidth: true,
                  onPressed: onGetStarted,
                  size: AppButtonSize.large,
                  label: "Get Started",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}