// This is a basic Flutter widget test for PenPenny app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/di/injection_container.dart' as di;
import 'package:penpenny/presentation/app/app.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';

void main() {
  testWidgets('PenPenny app smoke test', (WidgetTester tester) async {
    // Initialize dependencies
    await di.init();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<AppSettingsBloc>()..add(LoadAppSettings()),
          ),
        ],
        child: const PenPennyApp(),
      ),
    );

    // Verify that the app loads
    expect(find.byType(PenPennyApp), findsOneWidget);
  });
}
