import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/debug/app_debug.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';

class CurrencyPickerWidget extends StatefulWidget {
  final VoidCallback? onCompleted;
  
  const CurrencyPickerWidget({super.key, this.onCompleted});

  @override
  State<StatefulWidget> createState() => _CurrencyPickerWidgetState();
}

class _CurrencyPickerWidgetState extends State<CurrencyPickerWidget> {
  final CurrencyService _currencyService = CurrencyService();
  String? _currency;
  String _keyword = "";
  bool _isLoading = false;

  // Popular currencies to show first
  final List<String> _popularCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'KRW'
  ];

  List<Currency> filter() {
    List<Currency> allCurrencies = _currencyService.getAll();
    
    if (_keyword.isEmpty) {
      // Show popular currencies first, then others
      List<Currency> popular = [];
      List<Currency> others = [];
      
      for (Currency currency in allCurrencies) {
        if (_popularCurrencies.contains(currency.code)) {
          popular.add(currency);
        } else {
          others.add(currency);
        }
      }
      
      // Sort popular currencies by the order in _popularCurrencies
      popular.sort((a, b) {
        int indexA = _popularCurrencies.indexOf(a.code);
        int indexB = _popularCurrencies.indexOf(b.code);
        return indexA.compareTo(indexB);
      });
      
      return [...popular, ...others];
    }
    
    return allCurrencies
        .where(
          (element) =>
              element.name.toLowerCase().contains(_keyword.toLowerCase()) ||
              element.code.toLowerCase().contains(_keyword.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AppSettingsBloc>().state;
    if (state is AppSettingsLoaded) {
      setState(() {
        _currency = state.settings.currency;
      });
    }
    
    // Set USD as default if no currency is selected
    if (_currency == null) {
      setState(() {
        _currency = 'USD';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.currency_exchange, size: 40),
              const SizedBox(height: 15),
              Text(
                "Select Your Currency",
                style: theme.textTheme.headlineMedium!.apply(
                  color: theme.colorScheme.primary,
                  fontWeightDelta: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose your preferred currency for transactions",
                style: theme.textTheme.bodySmall!.apply(
                  color: theme.textTheme.bodySmall!.color!.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                onChanged: (text) {
                  setState(() {
                    _keyword = text;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search",
                ),
              ),
              const SizedBox(height: 25),
              
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
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Step 3 of 3",
                    style: theme.textTheme.bodySmall!.apply(
                      color: theme.textTheme.bodySmall!.color!.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_keyword.isEmpty) ...[
                        Text(
                          "Popular Currencies",
                          style: theme.textTheme.titleSmall!.apply(
                            fontWeightDelta: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(filter().length, (index) {
                          Currency currency = filter()[index];
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width / 2) - 20,
                            child: MaterialButton(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  width: 1.5,
                                  color: _currency == currency.code
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 20,
                              ),
                              elevation: 0,
                              focusElevation: 0,
                              hoverElevation: 0,
                              highlightElevation: 0,
                              disabledElevation: 0,
                              onPressed: () {
                                setState(() {
                                  _currency = currency.code;
                                });
                                AppDebug.logUserAction('SelectCurrency', {'currency': currency.code});
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      child: Text(currency.symbol),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currency.name,
                                      style: Theme.of(context).textTheme.bodyMedium?.apply(fontWeightDelta: 2),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      currency.code,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () async {
          if (_currency == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please select a currency"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          setState(() {
            _isLoading = true;
          });

          try {
            // Save currency and complete onboarding
            context.read<AppSettingsBloc>().add(UpdateCurrency(_currency!));
            AppDebug.logUserAction('CompleteOnboarding', {'currency': _currency});
            
            // Show success message
            if (mounted) {
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text("🎉 Welcome to PenPenny! Setup completed successfully."),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
            
            // Complete onboarding after a short delay to show the success message
            await Future.delayed(const Duration(milliseconds: 1500));
            
            if (mounted && widget.onCompleted != null) {
              widget.onCompleted!();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to save currency. Please try again."),
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
        },
        label: _isLoading
            ? const Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text("Completing..."),
                ],
              )
            : const Row(
                children: <Widget>[
                  Text("Complete Setup"),
                  SizedBox(width: 10),
                  Icon(Icons.check),
                ],
              ),
      ),
    );
  }
}