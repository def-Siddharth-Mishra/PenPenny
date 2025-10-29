part of 'app_settings_bloc.dart';

abstract class AppSettingsEvent {}

class LoadAppSettings extends AppSettingsEvent {}

class UpdateUsername extends AppSettingsEvent {
  final String username;
  UpdateUsername(this.username);
}

class UpdateCurrency extends AppSettingsEvent {
  final String currency;
  UpdateCurrency(this.currency);
}

class UpdateThemeColor extends AppSettingsEvent {
  final int color;
  UpdateThemeColor(this.color);
}

class UpdateThemeMode extends AppSettingsEvent {
  final AppThemeMode themeMode;
  UpdateThemeMode(this.themeMode);
}

class ResetSettings extends AppSettingsEvent {}