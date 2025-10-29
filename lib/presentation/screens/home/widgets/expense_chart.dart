import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';

class ExpenseChart extends StatefulWidget {
  final List<Payment> payments;
  final List<Category> categories;

  const ExpenseChart({
    super.key,
    required this.payments,
    required this.categories,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = _calculateExpensesByCategory();
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (expenseData.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
            child: const Center(
              child: Text(
                'No expense data to display',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expenses by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sections: expenseData.map((data) {
                            return PieChartSectionData(
                              value: data.amount * _animation.value,
                              title: _animation.value > 0.8 
                                  ? '${(data.percentage).toStringAsFixed(1)}%'
                                  : '',
                              color: data.category.color,
                              radius: 50 * _animation.value,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: expenseData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final delay = index * 0.1;
                          final itemAnimation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(delay, 1.0, curve: Curves.easeOut),
                          ));
                          
                          return AnimatedBuilder(
                            animation: itemAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(50 * (1 - itemAnimation.value), 0),
                                child: Opacity(
                                  opacity: itemAnimation.value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: data.category.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            data.category.name,
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ExpenseData> _calculateExpensesByCategory() {
    final Map<int, double> categoryExpenses = {};
    double totalExpense = 0;

    // Calculate expenses by category
    for (final payment in widget.payments) {
      if (payment.type == PaymentType.debit) {
        final categoryId = payment.category.id!;
        categoryExpenses[categoryId] = (categoryExpenses[categoryId] ?? 0) + payment.amount;
        totalExpense += payment.amount;
      }
    }

    if (totalExpense == 0) return [];

    // Create expense data with percentages
    final List<ExpenseData> expenseData = [];
    for (final category in widget.categories) {
      final expense = categoryExpenses[category.id] ?? 0;
      if (expense > 0) {
        expenseData.add(ExpenseData(
          category: category,
          amount: expense,
          percentage: (expense / totalExpense) * 100,
        ));
      }
    }

    // Sort by amount descending
    expenseData.sort((a, b) => b.amount.compareTo(a.amount));
    return expenseData;
  }
}

class ExpenseData {
  final Category category;
  final double amount;
  final double percentage;

  ExpenseData({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}