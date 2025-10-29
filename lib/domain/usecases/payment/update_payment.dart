import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';

class UpdatePayment {
  final PaymentRepository repository;

  UpdatePayment(this.repository);

  Future<Payment> call(Payment payment) async {
    return await repository.updatePayment(payment);
  }
}