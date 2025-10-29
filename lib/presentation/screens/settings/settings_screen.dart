import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:penpenny/data/datasources/database_helper.dart';
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
    // TODO: Implement export functionality
    await Future.delayed(const Duration(seconds: 2)); // Simulate export
    return "/storage/emulated/0/Download/penpenny-backup-${DateTime.now().millisecondsSinceEpoch}.json";
  }

  Future<void> importData(String path) async {
    // TODO: Implement import functionality
    await Future.delayed(const Duration(seconds: 2)); // Simulate import
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