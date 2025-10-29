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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
    end: DateTime.now(),
  );

  void openAddPaymentPage(PaymentType type) async {
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
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
      });
      context.read<PaymentsBloc>().add(LoadPaymentsByDateRange(_range));
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen to global events
    globalEventEmitter.on(GlobalEventType.accountUpdate.name, (data) {
      debugPrint("accounts are changed");
      context.read<AccountsBloc>().add(LoadAccounts());
    });

    globalEventEmitter.on(GlobalEventType.categoryUpdate.name, (data) {
      debugPrint("categories are changed");
      context.read<CategoriesBloc>().add(LoadCategories());
    });

    globalEventEmitter.on(GlobalEventType.paymentUpdate.name, (data) {
      debugPrint("payments are changed");
      context.read<PaymentsBloc>().add(LoadPayments());
      context.read<AccountsBloc>().add(LoadAccounts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi! Good ${greeting()}"),
                  BlocConsumer<AppSettingsBloc, AppSettingsState>(
                    listener: (context, state) {},
                    builder: (context, state) => Text(
                      state.settings.username ?? "Guest",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            
            // Accounts Slider
            BlocBuilder<AccountsBloc, AccountsState>(
              builder: (context, state) {
                if (state is AccountsLoaded) {
                  return AccountsSlider(accounts: state.accounts);
                }
                return AccountsSlider(accounts: const []);
              },
            ),
            
            const SizedBox(height: 15),
            
            // Income/Expense Cards
            const IncomeExpenseCards(),
            
            // Budget Alerts
            BlocBuilder<CategoriesBloc, CategoriesState>(
              builder: (context, categoriesState) {
                return BlocBuilder<PaymentsBloc, PaymentsState>(
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
            ),
            
            // Expense Chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, categoriesState) {
                  return BlocBuilder<PaymentsBloc, PaymentsState>(
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
            ),
            
            const SizedBox(height: 15),
            
            // Recent Transactions Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  const Expanded(child: SizedBox()),
                  MaterialButton(
                    onPressed: () {
                      handleChooseDateRange();
                    },
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
            ),
            
            // Recent Transactions List
            BlocBuilder<PaymentsBloc, PaymentsState>(
              builder: (context, state) {
                if (state is PaymentsLoaded) {
                  return RecentTransactions(
                    payments: state.payments,
                    maxItems: 10,
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    alignment: Alignment.center,
                    child: const Text("No payments!"),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddPaymentPage(PaymentType.credit),
        child: const Icon(Icons.add),
      ),
    );
  }
}