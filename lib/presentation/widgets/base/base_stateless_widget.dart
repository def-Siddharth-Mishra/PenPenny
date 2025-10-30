import 'package:flutter/material.dart';

/// Base class for optimized stateless widgets
abstract class BaseStatelessWidget extends StatelessWidget {
  const BaseStatelessWidget({super.key});
  
  /// Override this to provide the widget content
  Widget buildContent(BuildContext context);
  
  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }
}

/// Mixin for widgets that need performance optimization
mixin PerformanceOptimizedWidget {
  /// Cache for expensive computations
  static final Map<String, dynamic> _cache = {};
  
  /// Get cached value or compute and cache it
  T getCachedValue<T>(String key, T Function() computation) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    
    final value = computation();
    _cache[key] = value;
    return value;
  }
  
  /// Clear cache for specific key
  void clearCache(String key) {
    _cache.remove(key);
  }
  
  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
  }
}

/// Mixin for widgets that need responsive design
mixin ResponsiveWidget {
  /// Get screen size category
  ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) return ScreenSize.mobile;
    if (width < 1024) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }
  
  /// Get responsive value based on screen size
  T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

enum ScreenSize { mobile, tablet, desktop }