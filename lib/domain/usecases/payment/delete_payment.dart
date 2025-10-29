import 'package:penpenny/domain/repositories/payment_repository.dart';

class DeletePayment {
  final PaymentRepository repository;

  DeletePayment(this.repository);

  Future<void> call(int paymentId) async {
    return await repository.deletePayment(paymentId);
  }
}