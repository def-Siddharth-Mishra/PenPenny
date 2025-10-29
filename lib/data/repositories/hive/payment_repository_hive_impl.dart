import 'package:penpenny/data/models/hive/payment_hive_model.dart';
import 'package:penpenny/data/services/hive_service.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';

class PaymentRepositoryHiveImpl implements PaymentRepository {
  @override
  Future<List<Payment>> getAllPayments() async {
    final paymentsBox = HiveService.paymentsBoxInstance;
    final accountsBox = HiveService.accountsBoxInstance;
    final categoriesBox = HiveService.categoriesBoxInstance;
    
    final payments = <Payment>[];
    
    for (final paymentModel in paymentsBox.values) {
      final account = accountsBox.values.firstWhere((a) => a.id == paymentModel.accountId).toEntity();
      final category = categoriesBox.values.firstWhere((c) => c.id == paymentModel.categoryId).toEntity();
      payments.add(paymentModel.toEntity(account, category));
    }
    
    // Sort by datetime descending
    payments.sort((a, b) => b.datetime.compareTo(a.datetime));
    return payments;
  }

  @override
  Future<Payment?> getPaymentById(int id) async {
    final paymentsBox = HiveService.paymentsBoxInstance;
    final accountsBox = HiveService.accountsBoxInstance;
    final categoriesBox = HiveService.categoriesBoxInstance;
    
    try {
      final paymentModel = paymentsBox.values.firstWhere((p) => p.id == id);
      final account = accountsBox.values.firstWhere((a) => a.id == paymentModel.accountId).toEntity();
      final category = categoriesBox.values.firstWhere((c) => c.id == paymentModel.categoryId).toEntity();
      return paymentModel.toEntity(account, category);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Payment>> getPaymentsByAccount(int accountId) async {
    final payments = await getAllPayments();
    return payments.where((payment) => payment.account.id == accountId).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByCategory(int categoryId) async {
    final payments = await getAllPayments();
    return payments.where((payment) => payment.category.id == categoryId).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByDateRange(DateTime start, DateTime end) async {
    final payments = await getAllPayments();
    return payments.where((payment) {
      return payment.datetime.isAfter(start.subtract(const Duration(days: 1))) &&
             payment.datetime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    final box = HiveService.paymentsBoxInstance;
    
    // Generate new ID
    final newId = box.values.isEmpty ? 1 : box.values.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    
    final model = PaymentHiveModel.fromEntity(payment.copyWith(id: newId));
    await box.add(model);
    
    return payment.copyWith(id: newId);
  }

  @override
  Future<Payment> updatePayment(Payment payment) async {
    final box = HiveService.paymentsBoxInstance;
    
    final index = box.values.toList().indexWhere((p) => p.id == payment.id);
    if (index == -1) throw StateError('Payment not found');
    
    final model = PaymentHiveModel.fromEntity(payment);
    await box.putAt(index, model);
    
    return payment;
  }

  @override
  Future<void> deletePayment(int id) async {
    final box = HiveService.paymentsBoxInstance;
    
    final index = box.values.toList().indexWhere((p) => p.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}