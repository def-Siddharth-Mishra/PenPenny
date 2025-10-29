import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

class AppSettings {
  final String? username;
  final int themeColor;
  final String? currency;
  final AppThemeMode themeMode;

  const AppSettings({
    this.username,
    this.themeColor = 0xFF4CAF50, // Default green color
    this.currency,
    this.themeMode = AppThemeMode.system,
  });

  AppSettings copyWith({
    String? username,
    int? themeColor,
    String? currency,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      username: username ?? this.username,
      themeColor: themeColor ?? this.themeColor,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Color get themeColorValue => Color(themeColor);

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.username == username &&
        other.themeColor == themeColor &&
        other.currency == currency &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(username, themeColor, currency, themeMode);
}