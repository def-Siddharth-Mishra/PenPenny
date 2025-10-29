import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/app_settings.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...AppThemeMode.values.map((mode) {
                  return RadioListTile<AppThemeMode>(
                    title: Text(_getThemeModeLabel(mode)),
                    subtitle: Text(_getThemeModeDescription(mode)),
                    value: mode,
                    groupValue: state.settings.themeMode,
                    onChanged: (AppThemeMode? value) {
                      if (value != null) {
                        context.read<AppSettingsBloc>().add(UpdateThemeMode(value));
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getThemeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  String _getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Follow system settings';
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
    }
  }
}