import 'package:get_it/get_it.dart';
import 'package:penpenny/data/datasources/database_helper.dart';
import 'package:penpenny/data/repositories/account_repository_impl.dart';
import 'package:penpenny/data/repositories/app_settings_repository_impl.dart';
import 'package:penpenny/data/repositories/category_repository_impl.dart';
import 'package:penpenny/data/repositories/payment_repository_impl.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';
import 'package:penpenny/domain/repositories/app_settings_repository.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/usecases/account/create_account.dart' as account_usecase;
import 'package:penpenny/domain/usecases/account/get_all_accounts.dart';
import 'package:penpenny/domain/usecases/payment/create_payment.dart' as payment_usecase;
import 'package:penpenny/domain/usecases/payment/get_all_payments.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize database
  await DatabaseHelper.database;

  // Repositories
  sl.registerLazySingleton<AppSettingsRepository>(
    () => AppSettingsRepositoryImpl(),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllAccounts(sl()));
  sl.registerLazySingleton(() => account_usecase.CreateAccount(sl()));
  sl.registerLazySingleton(() => GetAllPayments(sl()));
  sl.registerLazySingleton(() => payment_usecase.CreatePayment(sl()));

  // Blocs
  sl.registerFactory(() => AppSettingsBloc(sl()));
  sl.registerFactory(() => AccountsBloc(sl()));
  sl.registerFactory(() => CategoriesBloc(sl()));
  sl.registerFactory(() => PaymentsBloc(sl()));
}