import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/theme/theme_colors.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';
import 'package:penpenny/presentation/widgets/common/currency_text.dart';

class IncomeExpenseCards extends StatelessWidget {
  const IncomeExpenseCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildIncomeCard(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildExpenseCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildExpenseCard(BuildContext context) {
    return Container(
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
    );
  }
}