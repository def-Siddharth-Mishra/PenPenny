import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';

enum BudgetStatus {
  onTrack,
  warning,
  overBudget,
  noBudget,
}

class BudgetAlert {
  final Category category;
  final double currentExpense;
  final double budgetLimit;
  final double percentage;
  final BudgetStatus status;
  final String message;
  
  const BudgetAlert({
    required this.category,
    required this.currentExpense,
    required this.budgetLimit,
    required this.percentage,
    required this.status,
    required this.message,
  });
}

class BudgetAnalysis {
  final Category category;
  final double totalBudget;
  final double totalExpense;
  final double remainingBudget;
  final double percentageUsed;
  final BudgetStatus status;
  final List<Payment> recentPayments;
  
  const BudgetAnalysis({
    required this.category,
    required this.totalBudget,
    required this.totalExpense,
    required this.remainingBudget,
    required this.percentageUsed,
    required this.status,
    required this.recentPayments,
  });
}

abstract class BudgetService {
  Future<BudgetAnalysis> analyzeBudgetHealth(int categoryId);
  Future<List<BudgetAlert>> getBudgetAlerts();
  Future<List<BudgetAlert>> getBudgetAlertsForMonth(DateTime month);
  Future<double> calculateCategoryExpenseForMonth(int categoryId, DateTime month);
  BudgetStatus getBudgetStatus(double expense, double budget);
}