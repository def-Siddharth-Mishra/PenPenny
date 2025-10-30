import 'package:flutter/material.dart';
import 'package:penpenny/core/logging/app_logger.dart';
import 'package:penpenny/presentation/widgets/common/error_widget.dart';

/// Base class for all screens with common functionality
abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseScreenState<T extends BaseScreen> extends State<T>
    with AutomaticKeepAliveClientMixin {
  
  /// Override to keep the screen alive in tab views
  @override
  bool get wantKeepAlive => false;
  
  /// Screen name for logging and analytics
  String get screenName => runtimeType.toString();
  
  /// Whether to show loading indicator
  bool get showLoadingIndicator => true;
  
  @override
  void initState() {
    super.initState();
    AppLogger.info('Screen initialized: $screenName', tag: 'Navigation');
    onInitState();
  }
  
  @override
  void dispose() {
    AppLogger.info('Screen disposed: $screenName', tag: 'Navigation');
    onDispose();
    super.dispose();
  }
  
  /// Override for custom initialization
  void onInitState() {}
  
  /// Override for custom disposal
  void onDispose() {}
  
  /// Build the main content
  Widget buildContent(BuildContext context);
  
  /// Build loading state
  Widget buildLoading(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// Build error state
  Widget buildError(BuildContext context, String message, {VoidCallback? onRetry}) {
    return Scaffold(
      body: AppErrorWidget(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildContent(context);
  }
  
  /// Safe navigation helper
  void navigateTo(Widget screen, {bool replace = false}) {
    if (!mounted) return;
    
    if (replace) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }
  
  /// Safe pop helper
  void navigateBack([dynamic result]) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }
  
  /// Show snackbar helper
  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}