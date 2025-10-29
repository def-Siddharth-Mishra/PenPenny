import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            TextStyle style = const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            );
            if (states.contains(WidgetState.selected)) {
              style = style.merge(
                const TextStyle(fontWeight: FontWeight.w600),
              );
            }
            return style;
          },
        ),
      ),
    );
  }

  static ThemeData darkTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            TextStyle style = const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            );
            if (states.contains(WidgetState.selected)) {
              style = style.merge(
                const TextStyle(fontWeight: FontWeight.w600),
              );
            }
            return style;
          },
        ),
      ),
    );
  }
}