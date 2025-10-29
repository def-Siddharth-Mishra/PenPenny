import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/screens/main/main_screen.dart';

class PenPennyApp extends StatelessWidget {
  const PenPennyApp({super.key});

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
          theme: ThemeData(
            useMaterial3: true,
            brightness: MediaQuery.of(context).platformBrightness,
            colorScheme: ColorScheme.fromSeed(
              seedColor: state.settings.themeColorValue,
              brightness: MediaQuery.of(context).platformBrightness,
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
          ),
          home: const MainScreen(),
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
        );
      },
    );
  }
}