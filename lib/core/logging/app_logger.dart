import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  static const String _name = 'PenPenny';
  
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Only log in debug mode or for errors/warnings
    if (!kDebugMode && level != LogLevel.error && level != LogLevel.warning) {
      return;
    }
    
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final logMessage = '$tagPrefix$message';
    
    switch (level) {
      case LogLevel.debug:
        developer.log(
          logMessage,
          name: _name,
          level: 500, // Debug level
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case LogLevel.info:
        developer.log(
          logMessage,
          name: _name,
          level: 800, // Info level
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case LogLevel.warning:
        developer.log(
          logMessage,
          name: _name,
          level: 900, // Warning level
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case LogLevel.error:
        developer.log(
          logMessage,
          name: _name,
          level: 1000, // Error level
          error: error,
          stackTrace: stackTrace,
        );
        break;
    }
  }
}