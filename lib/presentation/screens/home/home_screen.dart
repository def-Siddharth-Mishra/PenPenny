import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:penpenny/core/events/global_events.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';
import 'package:penpenny/presentation/screens/home/widgets/account_slider.dart';
import 'package:penpenny/presentation/screens/home/widgets/budget_alerts.dart';
import 'package:penpenny/presentation/screens/home/widgets/expense_chart.dart';
import 'package:penpenny/presentation/screens/home/widgets/income_expense_cards.dart';
import 'package:penpenny/presentation/screens/home/widgets/recent_transactions.dart';
import 'package:penpenny/presentation/screens/payment_form/payment_form_screen.dart';
import 'package:penpenny/presentation/widgets/base/base_screen.dart';
import 'package:penpenny/presentation/widgets/optimized/smart_bloc_builder.dart';


String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  @override
  String get screenName => 'HomeScreen';
  
  @override
  bool get wantKeepAlive => true;
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
    end: DateTime.now(),
  );

  void openAddPaymentPage(PaymentType type) async {
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builder) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AccountsBloc>()),
            BlocProvider.value(value: context.read<CategoriesBloc>()),
            BlocProvider.value(value: context.read<PaymentsBloc>()),
          ],
          child: PaymentFormScreen(type: type),
        ),
      ),
    );
  }

  void handleChooseDateRange() async {
    if (!mounted) return;
    
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) {
      setState(() {
        _range = selected;
      });
      context.read<PaymentsBloc>().add(LoadPaymentsByDateRange(_range));
    }
  }

  @override
  void onInitState() {
    super.onInitState();

    // Listen to global events with proper cleanup
    globalEventEmitter.on(GlobalEventType.accountUpdate.name, _onAccountUpdate);
    globalEventEmitter.on(GlobalEventType.categoryUpdate.name, _onCategoryUpdate);
    globalEventEmitter.on(GlobalEventType.paymentUpdate.name, _onPaymentUpdate);
  }
  
  @override
  void onDispose() {
    // Clean up event listeners - events_emitter doesn't have off method, so we skip cleanup
    super.onDispose();
  }
  
  void _onAccountUpdate(dynamic data) {
    if (mounted) {
      context.read<AccountsBloc>().add(LoadAccounts());
    }
  }
  
  void _onCategoryUpdate(dynamic data) {
    if (mounted) {
      context.read<CategoriesBloc>().add(LoadCategories());
    }
  }
  
  void _onPaymentUpdate(dynamic data) {
    if (mounted) {
      context.read<PaymentsBloc>().add(LoadPayments());
      context.read<AccountsBloc>().add(LoadAccounts());
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return SmartBlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        // Handle category updates
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildAccountsSection(),
                const SizedBox(height: 15),
                _buildIncomeExpenseCards(),
                _buildBudgetAlerts(),
                _buildExpenseChart(),
                const SizedBox(height: 15),
                _buildRecentTransactionsHeader(),
                _buildRecentTransactionsList(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openAddPaymentPage(PaymentType.credit),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  
  Future<void> _onRefresh() async {
    // Trigger all data loads
    context.read<AccountsBloc>().add(LoadAccounts());
    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<PaymentsBloc>().add(LoadPayments());
    
    // Wait for all BLoCs to finish loading
    await Future.wait([
      context.read<AccountsBloc>().stream.firstWhere(
        (state) => state is! AccountsLoading,
      ),
      context.read<CategoriesBloc>().stream.firstWhere(
        (state) => state is! CategoriesLoading,
      ),
      context.read<PaymentsBloc>().stream.firstWhere(
        (state) => state is! PaymentsLoading,
      ),
    ]);
  }
  
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hi! Good ${greeting()}"),
          SmartBlocBuilder<AppSettingsBloc, AppSettingsState>(
            enableCaching: false, // Disable caching for faster refresh
            builder: (context, state) => Text(
              state.settings.username ?? "Guest",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountsSection() {
    return SmartBlocBuilder<AccountsBloc, AccountsState>(
      enableCaching: false, // Disable caching for faster refresh
      builder: (context, state) {
        if (state is AccountsLoaded) {
          return AccountsSlider(accounts: state.accounts);
        }
        return const AccountsSlider(accounts: []);
      },
      loadingBuilder: (context) => const SizedBox(
        height: 170,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
  
  Widget _buildIncomeExpenseCards() {
    return const IncomeExpenseCards();
  }
  
  Widget _buildBudgetAlerts() {
    return SmartBlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, categoriesState) {
        return SmartBlocBuilder<PaymentsBloc, PaymentsState>(
          builder: (context, paymentsState) {
            if (categoriesState is CategoriesLoaded && paymentsState is PaymentsLoaded) {
              return BudgetAlerts(
                categories: categoriesState.categories,
                payments: paymentsState.payments,
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
  
  Widget _buildExpenseChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SmartBlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, categoriesState) {
          return SmartBlocBuilder<PaymentsBloc, PaymentsState>(
            builder: (context, paymentsState) {
              if (categoriesState is CategoriesLoaded && paymentsState is PaymentsLoaded) {
                return ExpenseChart(
                  payments: paymentsState.payments,
                  categories: categoriesState.categories,
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
  
  Widget _buildRecentTransactionsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
          const Expanded(child: SizedBox()),
          MaterialButton(
            onPressed: handleChooseDateRange,
            height: double.minPositive,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Row(
              children: [
                Text(
                  "${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Icon(Icons.arrow_drop_down_outlined)
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentTransactionsList() {
    return SmartBlocBuilder<PaymentsBloc, PaymentsState>(
      enableCaching: false, // Disable caching for faster refresh
      builder: (context, state) {
        if (state is PaymentsLoaded) {
          return RecentTransactions(
            payments: state.payments,
            maxItems: 10,
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          alignment: Alignment.center,
          child: const Text("No payments!"),
        );
      },
      loadingBuilder: (context) => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}