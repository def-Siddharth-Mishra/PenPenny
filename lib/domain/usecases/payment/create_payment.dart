import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';

class CreatePayment {
  final PaymentRepository repository;

  CreatePayment(this.repository);

  Future<Payment> call(Payment payment) async {
    return await repository.createPayment(payment);
  }
}