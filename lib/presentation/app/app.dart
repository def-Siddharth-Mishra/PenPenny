import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:penpenny/core/debug/app_debug.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:penpenny/presentation/screens/onboard/onboard_screen.dart';

class PenPennyApp extends StatelessWidget {
  const PenPennyApp({super.key});

  Widget _getHomeScreen(AppSettingsState state) {
    AppDebug.logAppState('App', state);
    
    // Handle different states
    if (state is AppSettingsLoading) {
      AppDebug.logNavigation('App', 'LoadingScreen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (state is AppSettingsError) {
      AppDebug.logNavigation('App', 'ErrorScreen');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load app settings'),
              const SizedBox(height: 16),
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    // Retry loading settings
                    context.read<AppSettingsBloc>().add(LoadAppSettings());
                  },
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show onboarding if user hasn't completed setup
    if (state is AppSettingsLoaded && 
        (state.settings.username == null || 
         state.settings.username!.isEmpty ||
         state.settings.currency == null ||
         state.settings.currency!.isEmpty)) {
      AppDebug.logNavigation('App', 'OnboardScreen');
      return const OnboardScreen();
    }
    
    // Show dashboard for existing users or initial state
    AppDebug.logNavigation('App', 'DashboardScreen');
    return const DashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: MediaQuery.of(context).platformBrightness,
      ),
    );

    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'PenPenny',
          themeMode: state.settings.flutterThemeMode,
          theme: _buildLightTheme(state.settings.themeColorValue),
          darkTheme: _buildDarkTheme(state.settings.themeColorValue),
          home: _getHomeScreen(state),
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          builder: (context, child) {
            // Add global error handling
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return _buildErrorWidget(errorDetails);
            };
            
            return child!;
          },
        );
      },
    );
  }
  
  ThemeData _buildLightTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      navigationBarTheme: _buildNavigationBarTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  ThemeData _buildDarkTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      navigationBarTheme: _buildNavigationBarTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  NavigationBarThemeData _buildNavigationBarTheme() {
    return NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
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
      }),
    );
  }
  
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please restart the app',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
