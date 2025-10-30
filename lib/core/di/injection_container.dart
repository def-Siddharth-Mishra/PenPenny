import 'package:get_it/get_it.dart';
import 'package:penpenny/data/repositories/hive/account_repository_hive_impl.dart';
import 'package:penpenny/data/repositories/hive/app_settings_repository_hive_impl.dart';
import 'package:penpenny/data/repositories/hive/category_repository_hive_impl.dart';
import 'package:penpenny/data/repositories/hive/payment_repository_hive_impl.dart';
import 'package:penpenny/data/services/budget_service_impl.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';
import 'package:penpenny/domain/repositories/app_settings_repository.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/services/budget_service.dart';
import 'package:penpenny/domain/usecases/account/create_account.dart' as account_usecase;
import 'package:penpenny/domain/usecases/account/delete_account.dart' as account_delete_usecase;
import 'package:penpenny/domain/usecases/account/get_all_accounts.dart';
import 'package:penpenny/domain/usecases/account/update_account.dart' as account_update_usecase;
import 'package:penpenny/domain/usecases/category/create_category.dart' as category_create_usecase;
import 'package:penpenny/domain/usecases/category/delete_category.dart' as category_delete_usecase;
import 'package:penpenny/domain/usecases/category/get_all_categories.dart';
import 'package:penpenny/domain/usecases/category/update_category.dart' as category_update_usecase;
import 'package:penpenny/domain/usecases/payment/create_payment.dart' as payment_usecase;
import 'package:penpenny/domain/usecases/payment/delete_payment.dart' as payment_delete_usecase;
import 'package:penpenny/domain/usecases/payment/get_all_payments.dart';
import 'package:penpenny/domain/usecases/payment/update_payment.dart' as payment_update_usecase;
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  sl.registerLazySingleton<AppSettingsRepository>(
    () => AppSettingsRepositoryHiveImpl(),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryHiveImpl(),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryHiveImpl(),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryHiveImpl(),
  );

  // Services
  sl.registerLazySingleton<BudgetService>(
    () => BudgetServiceImpl(
      categoryRepository: sl(),
      paymentRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllAccounts(sl()));
  sl.registerLazySingleton(() => account_usecase.CreateAccount(sl()));
  sl.registerLazySingleton(() => account_update_usecase.UpdateAccount(sl()));
  sl.registerLazySingleton(() => account_delete_usecase.DeleteAccount(sl()));
  
  sl.registerLazySingleton(() => GetAllCategories(sl()));
  sl.registerLazySingleton(() => category_create_usecase.CreateCategory(sl()));
  sl.registerLazySingleton(() => category_update_usecase.UpdateCategory(sl()));
  sl.registerLazySingleton(() => category_delete_usecase.DeleteCategory(sl()));
  
  sl.registerLazySingleton(() => GetAllPayments(sl()));
  sl.registerLazySingleton(() => payment_usecase.CreatePayment(sl(), sl()));
  sl.registerLazySingleton(() => payment_update_usecase.UpdatePayment(sl(), sl()));
  sl.registerLazySingleton(() => payment_delete_usecase.DeletePayment(sl(), sl()));

  // Blocs
  sl.registerFactory(() => AppSettingsBloc(sl()));
  sl.registerFactory(() => AccountsBloc(
    getAllAccounts: sl(),
    createAccount: sl(),
    updateAccount: sl(),
    deleteAccount: sl(),
  ));
  sl.registerFactory(() => CategoriesBloc(
    getAllCategories: sl(),
    createCategory: sl(),
    updateCategory: sl(),
    deleteCategory: sl(),
  ));
  sl.registerFactory(() => PaymentsBloc(
    getAllPayments: sl(),
    createPayment: sl(),
    updatePayment: sl(),
    deletePayment: sl(),
  ));
}