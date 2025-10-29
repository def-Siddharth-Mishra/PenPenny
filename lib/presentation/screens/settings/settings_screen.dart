import 'dart:convert';
import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:penpenny/data/models/hive/account_hive_model.dart';
import 'package:penpenny/data/models/hive/category_hive_model.dart';
import 'package:penpenny/data/models/hive/payment_hive_model.dart';
import 'package:penpenny/data/services/hive_service.dart';
import 'package:penpenny/domain/entities/app_settings.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/widgets/common/app_button.dart';
import 'package:penpenny/presentation/widgets/common/confirm_dialog.dart';
import 'package:penpenny/presentation/widgets/common/loading_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<String> exportData() async {
    try {
      // For Android 11+ (API 30+), we need to handle scoped storage differently
      if (Platform.isAndroid) {
        // Try to request manage external storage permission for Android 11+
        if (await Permission.manageExternalStorage.isGranted) {
          // Already granted
        } else if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            // Fallback to using app-specific directory
            debugPrint('Using app-specific directory for export');
          }
        }
      }

      // Get all data from Hive
      final accountsBox = HiveService.accountsBoxInstance;
      final categoriesBox = HiveService.categoriesBoxInstance;
      final paymentsBox = HiveService.paymentsBoxInstance;

      final accounts = accountsBox.values
          .map(
            (a) => {
              'id': a.id,
              'name': a.name,
              'holderName': a.holderName,
              'accountNumber': a.accountNumber,
              'icon': a.iconCodePoint,
              'color': a.colorValue,
              'isDefault': a.isDefault ? 1 : 0,
              'balance': a.balance,
            },
          )
          .toList();

      final categories = categoriesBox.values
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'icon': c.iconCodePoint,
              'color': c.colorValue,
              'budget': c.budget,
            },
          )
          .toList();

      final payments = paymentsBox.values
          .map(
            (p) => {
              'id': p.id,
              'title': p.title,
              'description': p.description,
              'account': p.accountId,
              'category': p.categoryId,
              'amount': p.amount,
              'type': p.paymentType == 0 ? 'DR' : 'CR',
              'datetime': p.datetime.toIso8601String(),
            },
          )
          .toList();

      // Create backup data structure
      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'accounts': accounts,
        'categories': categories,
        'payments': payments,
      };

      // Convert to JSON
      final jsonString = jsonEncode(backupData);

      // Save to file
      Directory? directory;
      if (Platform.isAndroid) {
        try {
          // Try Downloads directory first
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            throw Exception('Downloads directory not accessible');
          }

          // Test write access
          final testFile = File('${directory.path}/.test_write');
          await testFile.writeAsString('test');
          await testFile.delete();
        } catch (e) {
          // Fallback to app-specific external directory
          directory = await getExternalStorageDirectory();
          directory ??= await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/penpenny_backup_$timestamp.json');

      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> importData(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString);

      // Validate backup data structure
      if (backupData is! Map<String, dynamic>) {
        throw Exception('Invalid backup file format');
      }

      final accountsBox = HiveService.accountsBoxInstance;
      final categoriesBox = HiveService.categoriesBoxInstance;
      final paymentsBox = HiveService.paymentsBoxInstance;

      // Create ID mapping for proper relationships
      Map<int, int> accountsMap = {};
      Map<int, int> categoriesMap = {};

      // Clear existing data
      await accountsBox.clear();
      await categoriesBox.clear();
      await paymentsBox.clear();

      // Import accounts first
      if (backupData['accounts'] != null && backupData['accounts'] is List) {
        for (final accountData in backupData['accounts']) {
          try {
            final oldId = accountData['id'] as int;
            final account = AccountHiveModel(
              name: accountData['name'] ?? 'Unknown Account',
              holderName: accountData['holderName'] ?? '',
              accountNumber: accountData['accountNumber'] ?? '',
              iconCodePoint: accountData['icon'] ?? Icons.wallet.codePoint,
              colorValue: accountData['color'] ?? Colors.teal.value,
              isDefault: accountData['isDefault'] == 1,
              balance: (accountData['balance'] ?? 0.0).toDouble(),
            );

            final newIndex = accountsBox.length;
            await accountsBox.add(account);

            // Update the account with proper ID
            account.id = newIndex + 1;
            await accountsBox.putAt(newIndex, account);

            accountsMap[oldId] = account.id!;
          } catch (e) {
            debugPrint('Error importing account: $e');
            // Continue with other accounts
          }
        }
      }

      // Import categories
      if (backupData['categories'] != null &&
          backupData['categories'] is List) {
        for (final categoryData in backupData['categories']) {
          try {
            final oldId = categoryData['id'] as int;
            final category = CategoryHiveModel(
              name: categoryData['name'] ?? 'Unknown Category',
              iconCodePoint: categoryData['icon'] ?? Icons.category.codePoint,
              colorValue: categoryData['color'] ?? Colors.blue.value,
              budget: (categoryData['budget'] ?? 0.0).toDouble(),
            );

            final newIndex = categoriesBox.length;
            await categoriesBox.add(category);

            // Update the category with proper ID
            category.id = newIndex + 1;
            await categoriesBox.putAt(newIndex, category);

            categoriesMap[oldId] = category.id!;
          } catch (e) {
            debugPrint('Error importing category: $e');
            // Continue with other categories
          }
        }
      }

      // Import payments with mapped IDs
      if (backupData['payments'] != null && backupData['payments'] is List) {
        for (final paymentData in backupData['payments']) {
          try {
            final oldAccountId = paymentData['account'] as int;
            final oldCategoryId = paymentData['category'] as int;

            // Skip if referenced account or category doesn't exist
            if (!accountsMap.containsKey(oldAccountId) ||
                !categoriesMap.containsKey(oldCategoryId)) {
              debugPrint(
                'Skipping payment due to missing account or category reference',
              );
              continue;
            }

            final payment = PaymentHiveModel(
              title: paymentData['title'] ?? '',
              description: paymentData['description'] ?? '',
              accountId: accountsMap[oldAccountId]!,
              categoryId: categoriesMap[oldCategoryId]!,
              amount: (paymentData['amount'] ?? 0.0).toDouble(),
              paymentType: paymentData['type'] == 'CR' ? 1 : 0,
              datetime: DateTime.parse(
                paymentData['datetime'] ?? DateTime.now().toIso8601String(),
              ),
            );

            final newIndex = paymentsBox.length;
            await paymentsBox.add(payment);

            // Update the payment with proper ID
            payment.id = newIndex + 1;
            await paymentsBox.putAt(newIndex, payment);
          } catch (e) {
            debugPrint('Error importing payment: $e');
            // Continue with other payments
          }
        }
      }

      // Recalculate account balances after import
      await HiveService.recalculateAccountBalances();
    } catch (e) {
      throw Exception('Failed to import data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  final currentState = context.read<AppSettingsBloc>().state;
                  TextEditingController controller = TextEditingController(
                    text: currentState.settings.username ?? '',
                  );
                  return AlertDialog(
                    title: const Text(
                      "Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What should we call you?",
                          style: theme.textTheme.bodyLarge!.apply(
                            color: theme.textTheme.bodyLarge!.color!
                                .withOpacity(0.8),
                            fontWeightDelta: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            label: const Text("Name"),
                            hintText: "Enter your name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              onPressed: () {
                                if (controller.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please enter name"),
                                    ),
                                  );
                                } else {
                                  context.read<AppSettingsBloc>().add(
                                    UpdateUsername(controller.text),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                              height: 45,
                              label: "Save",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
            leading: const CircleAvatar(child: Icon(Symbols.person)),
            title: Text(
              'Name',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, state) {
                return Text(
                  state.settings.username ?? 'Guest',
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          ListTile(
            dense: true,
            onTap: () {
              showCurrencyPicker(
                context: context,
                onSelect: (Currency currency) {
                  context.read<AppSettingsBloc>().add(
                    UpdateCurrency(currency.code),
                  );
                },
              );
            },
            leading: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(
                  state.settings.currency ?? 'USD',
                );
                return CircleAvatar(child: Text(currency!.symbol));
              },
            ),
            title: Text(
              'Currency',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(
                  state.settings.currency ?? 'USD',
                );
                return Text(
                  currency!.name,
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          ListTile(
            dense: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BlocBuilder<AppSettingsBloc, AppSettingsState>(
                    builder: (context, state) {
                      return AlertDialog(
                        title: const Text(
                          "Theme Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: AppThemeMode.values.map((mode) {
                            String title;
                            IconData icon;
                            switch (mode) {
                              case AppThemeMode.system:
                                title = 'System';
                                icon = Icons.brightness_auto;
                                break;
                              case AppThemeMode.light:
                                title = 'Light';
                                icon = Icons.brightness_7;
                                break;
                              case AppThemeMode.dark:
                                title = 'Dark';
                                icon = Icons.brightness_2;
                                break;
                            }

                            return RadioListTile<AppThemeMode>(
                              title: Row(
                                children: [
                                  Icon(icon, size: 20),
                                  const SizedBox(width: 12),
                                  Text(title),
                                ],
                              ),
                              value: mode,
                              groupValue: state.settings.themeMode,
                              onChanged: (AppThemeMode? value) {
                                if (value != null) {
                                  context.read<AppSettingsBloc>().add(
                                    UpdateThemeMode(value),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              );
            },
            leading: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, state) {
                IconData icon;
                switch (state.settings.themeMode) {
                  case AppThemeMode.system:
                    icon = Icons.brightness_auto;
                    break;
                  case AppThemeMode.light:
                    icon = Icons.brightness_7;
                    break;
                  case AppThemeMode.dark:
                    icon = Icons.brightness_2;
                    break;
                }
                return CircleAvatar(child: Icon(icon));
              },
            ),
            title: Text(
              'Theme',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, state) {
                String subtitle;
                switch (state.settings.themeMode) {
                  case AppThemeMode.system:
                    subtitle = 'System';
                    break;
                  case AppThemeMode.light:
                    subtitle = 'Light';
                    break;
                  case AppThemeMode.dark:
                    subtitle = 'Dark';
                    break;
                }
                return Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          ListTile(
            dense: true,
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: "Are you sure?",
                content: "want to export all the data to a file",
              );

              if (confirmed == true) {
                LoadingDialog.show(
                  context,
                  message: "Exporting data please wait",
                );
                try {
                  final filePath = await exportData();
                  LoadingDialog.hide(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("File has been saved in $filePath")),
                  );
                } catch (err) {
                  LoadingDialog.hide(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Export failed: ${err.toString()}"),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              }
            },
            leading: const CircleAvatar(child: Icon(Symbols.download)),
            title: Text(
              'Export',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: Text(
              "Export to file",
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: Colors.grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ListTile(
            dense: true,
            onTap: () async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  dialogTitle: "Pick file",
                  allowMultiple: false,
                  allowCompression: false,
                  type: FileType.custom,
                  allowedExtensions: ["json"],
                );

                if (result == null || result.files.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select file")),
                  );
                  return;
                }

                PlatformFile file = result.files.first;
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: "Are you sure?",
                  content:
                      "All payment data, categories, and accounts will be erased and replaced with the information imported from the backup.",
                );

                if (confirmed == true) {
                  LoadingDialog.show(
                    context,
                    message: "Importing data please wait",
                  );
                  try {
                    await importData(file.path!);
                    LoadingDialog.hide(context);

                    // Refresh all blocs after successful import
                    if (context.mounted) {
                      context.read<AppSettingsBloc>().add(LoadAppSettings());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Successfully imported. Please restart the app to see all changes.",
                          ),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  } catch (err) {
                    LoadingDialog.hide(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Import failed: ${err.toString()}"),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                }
              } catch (err) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("File selection failed: ${err.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            leading: const CircleAvatar(child: Icon(Symbols.upload)),
            title: Text(
              'Import',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: Text(
              "Import from backup file",
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: Colors.grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
