import 'package:flutter/foundation.dart';
import 'package:penpenny/core/logging/app_logger.dart';

class AppDebug {
  static void logAppState(String context, dynamic state) {
    if (kDebugMode) {
      AppLogger.debug('[$context] State: ${state.runtimeType}', tag: 'AppDebug');
      if (state.toString().length < 200) {
        AppLogger.debug('[$context] Details: $state', tag: 'AppDebug');
      }
    }
  }
  
  static void logNavigation(String from, String to) {
    if (kDebugMode) {
      AppLogger.debug('Navigation: $from -> $to', tag: 'AppDebug');
    }
  }
  
  static void logUserAction(String action, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      AppLogger.debug('User Action: $action${data != null ? ' - $data' : ''}', tag: 'AppDebug');
    }
  }
}