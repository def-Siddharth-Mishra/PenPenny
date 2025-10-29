import 'package:penpenny/data/models/hive/app_settings_hive_model.dart';
import 'package:penpenny/data/services/hive_service.dart';
import 'package:penpenny/domain/entities/app_settings.dart';
import 'package:penpenny/domain/repositories/app_settings_repository.dart';

class AppSettingsRepositoryHiveImpl implements AppSettingsRepository {
  @override
  Future<AppSettings> getSettings() async {
    final box = HiveService.settingsBoxInstance;
    final settingsModel = box.get(HiveService.settingsKey);
    
    if (settingsModel != null) {
      return settingsModel.toEntity();
    }
    
    // Return default settings if none exist
    return const AppSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final box = HiveService.settingsBoxInstance;
    final model = AppSettingsHiveModel.fromEntity(settings);
    await box.put(HiveService.settingsKey, model);
  }

  @override
  Future<void> updateUsername(String? username) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(username: username);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateThemeColor(int color) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(themeColor: color);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateCurrency(String? currency) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(currency: currency);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> resetSettings() async {
    final box = HiveService.settingsBoxInstance;
    await box.delete(HiveService.settingsKey);
  }
}