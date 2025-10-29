// This is a basic Flutter widget test for PenPenny app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penpenny/domain/entities/app_settings.dart';

void main() {
  group('PenPenny App Tests', () {
    testWidgets('App settings entity should work correctly', (WidgetTester tester) async {
      // Test AppSettings entity
      const settings = AppSettings(
        username: 'Test User',
        themeColor: 0xFF4CAF50,
        currency: 'USD',
        themeMode: AppThemeMode.light,
      );

      expect(settings.username, equals('Test User'));
      expect(settings.themeColor, equals(0xFF4CAF50));
      expect(settings.currency, equals('USD'));
      expect(settings.themeMode, equals(AppThemeMode.light));
      expect(settings.flutterThemeMode, equals(ThemeMode.light));
    });

    testWidgets('App settings copyWith should work correctly', (WidgetTester tester) async {
      const originalSettings = AppSettings(
        username: 'Test User',
        themeColor: 0xFF4CAF50,
        currency: 'USD',
        themeMode: AppThemeMode.light,
      );

      final updatedSettings = originalSettings.copyWith(
        username: 'Updated User',
        themeMode: AppThemeMode.dark,
      );

      expect(updatedSettings.username, equals('Updated User'));
      expect(updatedSettings.themeMode, equals(AppThemeMode.dark));
      expect(updatedSettings.themeColor, equals(originalSettings.themeColor));
      expect(updatedSettings.currency, equals(originalSettings.currency));
    });

    testWidgets('Theme mode conversion should work correctly', (WidgetTester tester) async {
      const lightSettings = AppSettings(themeMode: AppThemeMode.light);
      const darkSettings = AppSettings(themeMode: AppThemeMode.dark);
      const systemSettings = AppSettings(themeMode: AppThemeMode.system);

      expect(lightSettings.flutterThemeMode, equals(ThemeMode.light));
      expect(darkSettings.flutterThemeMode, equals(ThemeMode.dark));
      expect(systemSettings.flutterThemeMode, equals(ThemeMode.system));
    });

    testWidgets('Basic MaterialApp should render', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'PenPenny Test',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          home: const Scaffold(
            body: Center(
              child: Text('PenPenny'),
            ),
          ),
        ),
      );

      expect(find.text('PenPenny'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    test('AppThemeMode enum should have correct values', () {
      expect(AppThemeMode.values.length, equals(3));
      expect(AppThemeMode.values, contains(AppThemeMode.system));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
    });
  });
}
