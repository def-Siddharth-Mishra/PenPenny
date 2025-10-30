import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';
import 'package:penpenny/presentation/screens/home/widgets/dismissible_payment_item.dart';
import 'package:penpenny/presentation/screens/payment_form/payment_form_screen.dart';
import 'package:penpenny/presentation/widgets/optimized/optimized_list_view.dart';

class RecentTransactions extends StatelessWidget {
  final List<Payment> payments;
  final int maxItems;

  const RecentTransactions({
    super.key,
    required this.payments,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final recentPayments = payments.take(maxItems).toList();

    return OptimizedListView<Payment>(
      items: recentPayments,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      addRepaintBoundaries: true,
      cacheExtent: 500, // Pre-cache items for smooth scrolling
      emptyWidget: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        alignment: Alignment.center,
        child: const Text("No payments!"),
      ),
      itemBuilder: (context, payment, index) {
        return DismissiblePaymentItem(
          payment: payment,
          onTap: () => _navigateToEditPayment(context, payment),
          onDelete: (payment) => _deletePayment(context, payment),
        );
      },
      separatorBuilder: (context, index) {
        return Container(
          width: double.infinity,
          color: Colors.grey.withAlpha(25),
          height: 1,
          margin: const EdgeInsets.only(left: 75, right: 20),
        );
      },
    );
  }

  void _navigateToEditPayment(BuildContext context, Payment payment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builder) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AccountsBloc>()),
            BlocProvider.value(value: context.read<CategoriesBloc>()),
            BlocProvider.value(value: context.read<PaymentsBloc>()),
          ],
          child: PaymentFormScreen(
            type: payment.type,
            payment: payment,
          ),
        ),
      ),
    );
  }

  void _deletePayment(BuildContext context, Payment payment) {
    context.read<PaymentsBloc>().add(DeletePayment(payment.id!));
  }
}