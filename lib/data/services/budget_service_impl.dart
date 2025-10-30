import 'package:penpenny/core/logging/app_logger.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/services/budget_service.dart';

class BudgetServiceImpl implements BudgetService {
  final CategoryRepository categoryRepository;
  final PaymentRepository paymentRepository;
  
  const BudgetServiceImpl({
    required this.categoryRepository,
    required this.paymentRepository,
  });
  
  @override
  Future<BudgetAnalysis> analyzeBudgetHealth(int categoryId) async {
    try {
      final category = await categoryRepository.getCategoryById(categoryId);
      if (category == null) {
        throw Exception('Category not found');
      }
      
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final payments = await paymentRepository.getPaymentsByDateRange(startOfMonth, endOfMonth);
      final categoryPayments = payments
          .where((p) => p.category.id == categoryId && p.type == PaymentType.debit)
          .toList();
      
      final totalExpense = categoryPayments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );
      
      final remainingBudget = category.budget - totalExpense;
      final percentageUsed = category.budget > 0 ? (totalExpense / category.budget) * 100 : 0.0;
      final status = getBudgetStatus(totalExpense, category.budget);
      
      return BudgetAnalysis(
        category: category,
        totalBudget: category.budget,
        totalExpense: totalExpense,
        remainingBudget: remainingBudget,
        percentageUsed: percentageUsed,
        status: status,
        recentPayments: categoryPayments.take(5).toList(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error analyzing budget health', tag: 'BudgetService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<List<BudgetAlert>> getBudgetAlerts() async {
    final now = DateTime.now();
    return getBudgetAlertsForMonth(now);
  }
  
  @override
  Future<List<BudgetAlert>> getBudgetAlertsForMonth(DateTime month) async {
    try {
      final categories = await categoryRepository.getAllCategories();
      final alerts = <BudgetAlert>[];
      
      for (final category in categories) {
        if (category.budget <= 0) continue;
        
        final expense = await calculateCategoryExpenseForMonth(category.id!, month);
        final percentage = (expense / category.budget) * 100;
        final status = getBudgetStatus(expense, category.budget);
        
        // Only create alerts for categories that need attention
        if (status != BudgetStatus.onTrack && status != BudgetStatus.noBudget) {
          alerts.add(BudgetAlert(
            category: category,
            currentExpense: expense,
            budgetLimit: category.budget,
            percentage: percentage,
            status: status,
            message: _getBudgetMessage(status, category.name, percentage),
          ));
        }
      }
      
      // Sort by severity (overBudget first, then warning)
      alerts.sort((a, b) {
        if (a.status == BudgetStatus.overBudget && b.status != BudgetStatus.overBudget) {
          return -1;
        }
        if (b.status == BudgetStatus.overBudget && a.status != BudgetStatus.overBudget) {
          return 1;
        }
        return b.percentage.compareTo(a.percentage);
      });
      
      return alerts;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting budget alerts', tag: 'BudgetService', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  @override
  Future<double> calculateCategoryExpenseForMonth(int categoryId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      final payments = await paymentRepository.getPaymentsByDateRange(startOfMonth, endOfMonth);
      
      return payments
          .where((p) => p.category.id == categoryId && p.type == PaymentType.debit)
          .fold<double>(0.0, (sum, payment) => sum + payment.amount);
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating category expense', tag: 'BudgetService', error: e, stackTrace: stackTrace);
      return 0.0;
    }
  }
  
  @override
  BudgetStatus getBudgetStatus(double expense, double budget) {
    if (budget <= 0) return BudgetStatus.noBudget;
    
    final percentage = (expense / budget) * 100;
    
    if (percentage >= 100) return BudgetStatus.overBudget;
    if (percentage >= 70) return BudgetStatus.warning;
    return BudgetStatus.onTrack;
  }
  
  String _getBudgetMessage(BudgetStatus status, String categoryName, double percentage) {
    switch (status) {
      case BudgetStatus.overBudget:
        return '$categoryName is ${percentage.toStringAsFixed(1)}% over budget';
      case BudgetStatus.warning:
        return '$categoryName is ${percentage.toStringAsFixed(1)}% of budget used';
      case BudgetStatus.onTrack:
        return '$categoryName is on track';
      case BudgetStatus.noBudget:
        return '$categoryName has no budget set';
    }
  }
}