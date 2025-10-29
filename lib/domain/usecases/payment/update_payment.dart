import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class UpdatePayment {
  final PaymentRepository paymentRepository;
  final AccountRepository accountRepository;

  UpdatePayment(this.paymentRepository, this.accountRepository);

  Future<Payment> call(Payment payment) async {
    // Get the old payment to reverse its effect on balance
    final oldPayment = await paymentRepository.getPaymentById(payment.id!);
    
    final updatedPayment = await paymentRepository.updatePayment(payment);
    
    // Recalculate account balances
    await _recalculateAccountBalance(oldPayment, payment);
    
    return updatedPayment;
  }

  Future<void> _recalculateAccountBalance(Payment? oldPayment, Payment newPayment) async {
    // If old payment exists, reverse its effect
    if (oldPayment != null) {
      final oldAccount = await accountRepository.getAccountById(oldPayment.account.id!);
      if (oldAccount != null) {
        double balance = oldAccount.balance;
        if (oldPayment.type == PaymentType.credit) {
          balance -= oldPayment.amount; // Reverse credit
        } else {
          balance += oldPayment.amount; // Reverse debit
        }
        await accountRepository.updateAccountBalance(oldAccount.id!, balance);
      }
    }
    
    // Apply new payment effect
    final newAccount = await accountRepository.getAccountById(newPayment.account.id!);
    if (newAccount != null) {
      double balance = newAccount.balance;
      if (newPayment.type == PaymentType.credit) {
        balance += newPayment.amount;
      } else {
        balance -= newPayment.amount;
      }
      await accountRepository.updateAccountBalance(newAccount.id!, balance);
    }
  }
}