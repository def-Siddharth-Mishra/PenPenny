import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class CreateAccount {
  final AccountRepository repository;

  CreateAccount(this.repository);

  Future<Account> call(Account account) async {
    return await repository.createAccount(account);
  }
}