import 'package:penpenny/domain/entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAllPayments();
  Future<Payment?> getPaymentById(int id);
  Future<List<Payment>> getPaymentsByAccount(int accountId);
  Future<List<Payment>> getPaymentsByCategory(int categoryId);
  Future<List<Payment>> getPaymentsByDateRange(DateTime start, DateTime end);
  Future<Payment> createPayment(Payment payment);
  Future<Payment> updatePayment(Payment payment);
  Future<void> deletePayment(int id);
}