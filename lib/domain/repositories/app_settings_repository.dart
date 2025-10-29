import 'package:penpenny/domain/entities/app_settings.dart';

abstract class AppSettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> updateUsername(String? username);
  Future<void> updateCurrency(String? currency);
  Future<void> updateThemeColor(int color);
  Future<void> updateThemeMode(AppThemeMode themeMode);
  Future<void> resetSettings();
}