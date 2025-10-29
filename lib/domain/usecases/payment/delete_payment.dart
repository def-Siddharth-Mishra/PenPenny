import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class DeletePayment {
  final PaymentRepository paymentRepository;
  final AccountRepository accountRepository;

  DeletePayment(this.paymentRepository, this.accountRepository);

  Future<void> call(int paymentId) async {
    // Get the payment before deleting to reverse its effect on balance
    final payment = await paymentRepository.getPaymentById(paymentId);
    
    await paymentRepository.deletePayment(paymentId);
    
    // Reverse the payment's effect on account balance
    if (payment != null) {
      await _reversePaymentEffect(payment);
    }
  }

  Future<void> _reversePaymentEffect(payment) async {
    final account = await accountRepository.getAccountById(payment.account.id!);
    if (account != null) {
      double newBalance = account.balance;
      if (payment.type == PaymentType.credit) {
        newBalance -= payment.amount; // Reverse credit
      } else {
        newBalance += payment.amount; // Reverse debit
      }
      await accountRepository.updateAccountBalance(account.id!, newBalance);
    }
  }
}