import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';

class GetAllPayments {
  final PaymentRepository repository;

  GetAllPayments(this.repository);

  Future<List<Payment>> call() async {
    return await repository.getAllPayments();
  }
}