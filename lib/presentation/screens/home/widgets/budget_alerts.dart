import 'package:flutter/material.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/presentation/widgets/common/currency_text.dart';

class BudgetAlerts extends StatelessWidget {
  final List<Category> categories;
  final List<Payment> payments;

  const BudgetAlerts({
    super.key,
    required this.categories,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final alertCategories = _getBudgetAlertCategories();
    
    if (alertCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Alerts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...alertCategories.map((alert) => _buildAlertCard(context, alert)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, BudgetAlert alert) {
    Color alertColor;
    IconData alertIcon;
    String alertText;

    if (alert.isOverBudget) {
      alertColor = Colors.red;
      alertIcon = Icons.error;
      alertText = 'Over budget';
    } else if (alert.isNearBudget) {
      alertColor = Colors.orange;
      alertIcon = Icons.warning;
      alertText = 'Near budget limit';
    } else {
      alertColor = Colors.blue;
      alertIcon = Icons.info;
      alertText = 'Budget on track';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: alertColor.withOpacity(0.1),
        border: Border.all(color: alertColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            alertIcon,
            color: alertColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  alertText,
                  style: TextStyle(
                    color: alertColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                alert.spent,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: alertColor,
                ),
              ),
              Text(
                'of ${alert.category.budget.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BudgetAlert> _getBudgetAlertCategories() {
    final Map<int, double> categoryExpenses = {};
    
    // Calculate current month expenses by category
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    
    for (final payment in payments) {
      if (payment.type == PaymentType.debit &&
          payment.datetime.isAfter(currentMonthStart) &&
          payment.datetime.isBefore(currentMonthEnd.add(const Duration(days: 1)))) {
        final categoryId = payment.category.id!;
        categoryExpenses[categoryId] = (categoryExpenses[categoryId] ?? 0) + payment.amount;
      }
    }

    final List<BudgetAlert> alerts = [];
    
    for (final category in categories) {
      if (category.budget > 0) {
        final spent = categoryExpenses[category.id] ?? 0;
        final budgetUsagePercentage = (spent / category.budget) * 100;
        
        // Show alerts for categories that are over 70% of budget or over budget
        if (budgetUsagePercentage >= 70) {
          alerts.add(BudgetAlert(
            category: category,
            spent: spent,
            budgetUsagePercentage: budgetUsagePercentage,
          ));
        }
      }
    }

    // Sort by budget usage percentage (highest first)
    alerts.sort((a, b) => b.budgetUsagePercentage.compareTo(a.budgetUsagePercentage));
    
    return alerts;
  }
}

class BudgetAlert {
  final Category category;
  final double spent;
  final double budgetUsagePercentage;

  BudgetAlert({
    required this.category,
    required this.spent,
    required this.budgetUsagePercentage,
  });

  bool get isOverBudget => budgetUsagePercentage > 100;
  bool get isNearBudget => budgetUsagePercentage >= 80 && budgetUsagePercentage <= 100;
}