import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:penpenny/core/events/global_events.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';
import 'package:penpenny/presentation/screens/home/widgets/account_slider.dart';
import 'package:penpenny/presentation/screens/home/widgets/payment_list_item.dart';
import 'package:penpenny/presentation/screens/payment_form/payment_form_screen.dart';
import 'package:penpenny/presentation/widgets/common/currency_text.dart';
import 'package:penpenny/core/theme/theme_colors.dart';

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
            BlocBuilder<AccountsBloc, AccountsState>(
              builder: (context, state) {
                if (state is AccountsLoaded) {
                  return AccountsSlider(accounts: state.accounts);
                }
                return AccountsSlider(accounts: const []);
              },
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "Payments",
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: ThemeColors.success.withOpacity(0.2),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Income",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            BlocBuilder<PaymentsBloc, PaymentsState>(
                              builder: (context, state) {
                                double income = 0;
                                if (state is PaymentsLoaded) {
                                  income = state.income;
                                }
                                return CurrencyText(
                                  income,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeColors.success,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: ThemeColors.error.withOpacity(0.2),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Expense",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            BlocBuilder<PaymentsBloc, PaymentsState>(
                              builder: (context, state) {
                                double expense = 0;
                                if (state is PaymentsLoaded) {
                                  expense = state.expense;
                                }
                                return CurrencyText(
                                  expense,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeColors.error,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<PaymentsBloc, PaymentsState>(
              builder: (context, state) {
                if (state is PaymentsLoaded && state.payments.isNotEmpty) {
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, index) {
                      return PaymentListItem(
                        payment: state.payments[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: context.read<AccountsBloc>()),
                                  BlocProvider.value(value: context.read<CategoriesBloc>()),
                                  BlocProvider.value(value: context.read<PaymentsBloc>()),
                                ],
                                child: PaymentFormScreen(
                                  type: state.payments[index].type,
                                  payment: state.payments[index],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        width: double.infinity,
                        color: Colors.grey.withAlpha(25),
                        height: 1,
                        margin: const EdgeInsets.only(left: 75, right: 20),
                      );
                    },
                    itemCount: state.payments.length,
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