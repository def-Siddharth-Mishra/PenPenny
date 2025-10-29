import 'package:penpenny/domain/entities/app_settings.dart';
import 'package:penpenny/domain/repositories/app_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    return AppSettings(
      username: prefs.getString('username'),
      themeColor: prefs.getInt('themeColor') ?? 0xFF4CAF50,
      currency: prefs.getString('currency'),
      themeMode: AppThemeMode.values[themeModeIndex],
    );
  }

  @override
  Future<void> updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  @override
  Future<void> updateCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  @override
  Future<void> updateThemeColor(int color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color);
  }

  @override
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
  }

  @override
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('currency');
    await prefs.remove('themeColor');
    await prefs.remove('themeMode');
  }
}