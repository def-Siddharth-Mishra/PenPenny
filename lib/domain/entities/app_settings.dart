import 'package:flutter/material.dart';

class AppSettings {
  final String? username;
  final int themeColor;
  final String? currency;

  const AppSettings({
    this.username,
    this.themeColor = 0xFF4CAF50, // Default green color
    this.currency,
  });

  AppSettings copyWith({
    String? username,
    int? themeColor,
    String? currency,
  }) {
    return AppSettings(
      username: username ?? this.username,
      themeColor: themeColor ?? this.themeColor,
      currency: currency ?? this.currency,
    );
  }

  Color get themeColorValue => Color(themeColor);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.username == username &&
        other.themeColor == themeColor &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(username, themeColor, currency);
}