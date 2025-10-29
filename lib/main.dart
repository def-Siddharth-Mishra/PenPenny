import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/di/injection_container.dart' as di;
import 'package:penpenny/data/services/hive_service.dart';
import 'package:penpenny/presentation/app/app.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  // Initialize dependencies
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AppSettingsBloc>()..add(LoadAppSettings()),
        ),
        BlocProvider(create: (_) => di.sl<AccountsBloc>()..add(LoadAccounts())),
        BlocProvider(
          create: (_) => di.sl<CategoriesBloc>()..add(LoadCategories()),
        ),
        BlocProvider(create: (_) => di.sl<PaymentsBloc>()..add(LoadPayments())),
      ],
      child: const PenPennyApp(),
    ),
  );
}
