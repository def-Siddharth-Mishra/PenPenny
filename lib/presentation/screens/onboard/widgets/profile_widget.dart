import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/widgets/forms/smart_form.dart';

class ProfileWidget extends StatefulWidget {
  final VoidCallback onGetStarted;
  const ProfileWidget({super.key, required this.onGetStarted});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save the username
      context.read<AppSettingsBloc>().add(UpdateUsername(name));
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nice to meet you, $name!"),
          backgroundColor: Colors.green,
        ),
      );

      // Wait a moment for the success message, then proceed
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        widget.onGetStarted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save your name. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
          child: SmartForm(
            formKey: _formKey,
            autovalidateMode: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_balance_wallet, size: 70),
                const SizedBox(height: 25),
                Text(
                  "Hi! Welcome to PenPenny",
                  style: theme.textTheme.headlineMedium!.apply(
                    color: theme.colorScheme.primary,
                    fontWeightDelta: 1,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "What should we call you?",
                  style: theme.textTheme.bodyLarge!.apply(
                    color: theme.textTheme.bodyLarge!.color!.withOpacity(0.8),
                    fontWeightDelta: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This will be used to personalize your experience",
                  style: theme.textTheme.bodySmall!.apply(
                    color: theme.textTheme.bodySmall!.color!.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 25),
                SmartTextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  label: "Name",
                  hint: "Enter your name",
                  prefixIcon: const Icon(Icons.account_circle),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (value.trim().length > 50) {
                      return 'Name cannot exceed 50 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Real-time validation feedback
                    if (_formKey.currentState?.validate() == true) {
                      // Form is valid, could show success indicator
                    }
                  },
                ),
                const SizedBox(height: 20),
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
                    const SizedBox(width: 12),
                    Text(
                      "Step 2 of 3",
                      style: theme.textTheme.bodySmall!.apply(
                        color: theme.textTheme.bodySmall!.color!.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _handleNext,
        label: _isLoading
            ? const Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text("Saving..."),
                ],
              )
            : const Row(
                children: <Widget>[
                  Text("Next"),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward)
                ],
              ),
      ),
    );
  }
}