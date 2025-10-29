import 'dart:convert';
import 'dart:io';
import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:penpenny/data/datasources/database_helper.dart';
import 'package:penpenny/domain/entities/app_settings.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/widgets/common/app_button.dart';
import 'package:penpenny/presentation/widgets/common/confirm_dialog.dart';
import 'package:penpenny/presentation/widgets/common/loading_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<String> exportData() async {
    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }
      
      final db = await DatabaseHelper.database;
      
      // Get all data from database
      final accounts = await db.query('accounts');
      final categories = await db.query('categories');
      final payments = await db.query('payments');
      
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
        // Try Downloads directory first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to external storage
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Download');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('Could not access storage directory');
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
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString);
      
      final db = await DatabaseHelper.database;
      
      // Clear existing data
      await db.delete('payments');
      await db.delete('accounts');
      await db.delete('categories');
      
      // Import accounts
      if (backupData['accounts'] != null) {
        for (final account in backupData['accounts']) {
          await db.insert('accounts', Map<String, dynamic>.from(account));
        }
      }
      
      // Import categories
      if (backupData['categories'] != null) {
        for (final category in backupData['categories']) {
          await db.insert('categories', Map<String, dynamic>.from(category));
        }
      }
      
      // Import payments
      if (backupData['payments'] != null) {
        for (final payment in backupData['payments']) {
          await db.insert('payments', Map<String, dynamic>.from(payment));
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
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
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What should we call you?",
                          style: theme.textTheme.bodyLarge!.apply(
                            color: theme.textTheme.bodyLarge!.color!.withOpacity(0.8),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                          ),
                        )
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
                                    const SnackBar(content: Text("Please enter name")),
                                  );
                                } else {
                                  context.read<AppSettingsBloc>().add(UpdateUsername(controller.text));
                                  Navigator.of(context).pop();
                                }
                              },
                              height: 45,
                              label: "Save",
                            ),
                          )
                        ],
                      )
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
                  context.read<AppSettingsBloc>().add(UpdateCurrency(currency.code));
                },
              );
            },
            leading: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.settings.currency ?? 'USD');
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
                Currency? currency = CurrencyService().findByCode(state.settings.currency ?? 'USD');
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
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
                                  context.read<AppSettingsBloc>().add(UpdateThemeMode(value));
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
                LoadingDialog.show(context, message: "Exporting data please wait");
                try {
                  final filePath = await exportData();
                  LoadingDialog.hide(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("File has been saved in $filePath")),
                  );
                } catch (err) {
                  LoadingDialog.hide(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Something went wrong while exporting data")),
                  );
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
                  content: "All payment data, categories, and accounts will be erased and replaced with the information imported from the backup.",
                );

                if (confirmed == true) {
                  LoadingDialog.show(context, message: "Importing data please wait");
                  try {
                    await importData(file.path!);
                    LoadingDialog.hide(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Successfully imported.")),
                    );
                  } catch (err) {
                    LoadingDialog.hide(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Something went wrong while importing data")),
                    );
                  }
                }
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Something went wrong while importing data")),
                );
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