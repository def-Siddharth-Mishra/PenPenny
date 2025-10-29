part of 'app_settings_bloc.dart';

abstract class AppSettingsState {
  AppSettings get settings => const AppSettings();
}

class AppSettingsInitial extends AppSettingsState {}

class AppSettingsLoading extends AppSettingsState {}

class AppSettingsLoaded extends AppSettingsState {
  @override
  final AppSettings settings;
  AppSettingsLoaded(this.settings);
}

class AppSettingsError extends AppSettingsState {
  final String message;
  AppSettingsError(this.message);
}