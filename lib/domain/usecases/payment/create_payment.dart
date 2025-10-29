import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class CreatePayment {
  final PaymentRepository paymentRepository;
  final AccountRepository accountRepository;

  CreatePayment(this.paymentRepository, this.accountRepository);

  Future<Payment> call(Payment payment) async {
    final createdPayment = await paymentRepository.createPayment(payment);
    
    // Update account balance
    await _updateAccountBalance(payment);
    
    return createdPayment;
  }

  Future<void> _updateAccountBalance(Payment payment) async {
    final account = await accountRepository.getAccountById(payment.account.id!);
    if (account != null) {
      double newBalance = account.balance;
      if (payment.type == PaymentType.credit) {
        newBalance += payment.amount;
      } else {
        newBalance -= payment.amount;
      }
      await accountRepository.updateAccountBalance(account.id!, newBalance);
    }
  }
}