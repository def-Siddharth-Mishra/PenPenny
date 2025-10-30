import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Smart BLoC builder with built-in optimizations
class SmartBlocBuilder<B extends StateStreamable<S>, S> extends StatefulWidget {
  final B? bloc;
  final BlocWidgetBuilder<S> builder;
  final BlocBuilderCondition<S>? buildWhen;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final bool enableCaching;
  final Duration? cacheDuration;
  
  const SmartBlocBuilder({
    super.key,
    this.bloc,
    required this.builder,
    this.buildWhen,
    this.loadingBuilder,
    this.errorBuilder,
    this.enableCaching = true,
    this.cacheDuration,
  });

  @override
  State<SmartBlocBuilder<B, S>> createState() => _SmartBlocBuilderState<B, S>();
}

class _SmartBlocBuilderState<B extends StateStreamable<S>, S>
    extends State<SmartBlocBuilder<B, S>> with AutomaticKeepAliveClientMixin {
  
  Widget? _cachedWidget;
  S? _lastState;
  DateTime? _lastCacheTime;
  
  @override
  bool get wantKeepAlive => widget.enableCaching;

  bool _shouldRebuild(S state) {
    if (!widget.enableCaching) return true;
    
    // Check if cache is still valid
    if (widget.cacheDuration != null && _lastCacheTime != null) {
      final cacheExpired = DateTime.now().difference(_lastCacheTime!) > widget.cacheDuration!;
      if (cacheExpired) {
        _cachedWidget = null;
        _lastState = null;
        _lastCacheTime = null;
      }
    }
    
    // Check if state actually changed
    if (_lastState == state && _cachedWidget != null) {
      return false;
    }
    
    return widget.buildWhen?.call(_lastState as S, state) ?? true;
  }

  Widget _buildWithOptimizations(BuildContext context, S state) {
    if (!_shouldRebuild(state)) {
      return _cachedWidget!;
    }
    
    final widget = this.widget.builder(context, state);
    
    if (this.widget.enableCaching) {
      _cachedWidget = widget;
      _lastState = state;
      _lastCacheTime = DateTime.now();
    }
    
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocBuilder<B, S>(
      bloc: widget.bloc,
      buildWhen: (previous, current) {
        // Handle loading states
        if (current.toString().contains('Loading')) {
          return widget.loadingBuilder != null;
        }
        
        // Handle error states
        if (current.toString().contains('Error')) {
          return widget.errorBuilder != null;
        }
        
        return _shouldRebuild(current);
      },
      builder: (context, state) {
        // Handle loading states
        if (state.toString().contains('Loading') && widget.loadingBuilder != null) {
          return widget.loadingBuilder!(context);
        }
        
        // Handle error states
        if (state.toString().contains('Error') && widget.errorBuilder != null) {
          final errorMessage = _extractErrorMessage(state);
          return widget.errorBuilder!(context, errorMessage);
        }
        
        return _buildWithOptimizations(context, state);
      },
    );
  }
  
  String _extractErrorMessage(S state) {
    try {
      // Try to extract error message using reflection
      final stateString = state.toString();
      if (stateString.contains('message:')) {
        final start = stateString.indexOf('message:') + 8;
        final end = stateString.indexOf(',', start);
        if (end != -1) {
          return stateString.substring(start, end).trim();
        }
      }
      return 'An error occurred';
    } catch (e) {
      return 'An error occurred';
    }
  }
}

/// Multi-BLoC builder with optimizations
class SmartMultiBlocBuilder extends StatelessWidget {
  final List<BlocProvider> providers;
  final Widget Function(BuildContext context) builder;
  
  const SmartMultiBlocBuilder({
    super.key,
    required this.providers,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: Builder(builder: builder),
    );
  }
}

/// BLoC listener with error handling
class SmartBlocListener<B extends StateStreamable<S>, S> extends StatelessWidget {
  final B? bloc;
  final BlocWidgetListener<S> listener;
  final BlocListenerCondition<S>? listenWhen;
  final Widget child;
  final void Function(BuildContext context, String error)? onError;
  final void Function(BuildContext context)? onLoading;
  
  const SmartBlocListener({
    super.key,
    this.bloc,
    required this.listener,
    this.listenWhen,
    required this.child,
    this.onError,
    this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      bloc: bloc,
      listenWhen: listenWhen,
      listener: (context, state) {
        // Handle loading states
        if (state.toString().contains('Loading') && onLoading != null) {
          onLoading!(context);
          return;
        }
        
        // Handle error states
        if (state.toString().contains('Error') && onError != null) {
          final errorMessage = _extractErrorMessage(state);
          onError!(context, errorMessage);
          return;
        }
        
        listener(context, state);
      },
      child: child,
    );
  }
  
  String _extractErrorMessage(S state) {
    try {
      final stateString = state.toString();
      if (stateString.contains('message:')) {
        final start = stateString.indexOf('message:') + 8;
        final end = stateString.indexOf(',', start);
        if (end != -1) {
          return stateString.substring(start, end).trim();
        }
      }
      return 'An error occurred';
    } catch (e) {
      return 'An error occurred';
    }
  }
}