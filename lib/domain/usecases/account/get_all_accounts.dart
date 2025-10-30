import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class GetAllAccounts {
  final AccountRepository repository;

  GetAllAccounts(this.repository);

  Future<List<Account>> call() async {
    // Recalculate account balances before returning accounts
    await repository.recalculateAccountBalances();
    
    return await repository.getAllAccounts();
  }
}