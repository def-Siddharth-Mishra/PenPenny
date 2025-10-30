import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'PenPenny';
  static const String version = '1.0.0';
  
  // Performance settings
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Validation limits
  static const double maxAmount = 1000000.0;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNameLength = 50;
  
  // Date limits
  static const int maxFutureDays = 365;
  static const int maxPastYears = 10;
  
  // Budget settings
  static const double budgetWarningThreshold = 0.7; // 70%
  static const double budgetDangerThreshold = 1.0; // 100%
  
  // UI settings
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  
  // Development settings
  static bool get isDebugMode => kDebugMode;
  static bool get enableDetailedLogging => kDebugMode;
  
  // Feature flags
  static const bool enableBudgetAlerts = true;
  static const bool enableExportFeature = true;
  static const bool enableDarkMode = true;
  static const bool enableAnimations = true;
  
  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 1000;
}