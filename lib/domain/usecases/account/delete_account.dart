import 'package:penpenny/domain/repositories/account_repository.dart';

class DeleteAccount {
  final AccountRepository repository;

  DeleteAccount(this.repository);

  Future<void> call(int accountId) async {
    return await repository.deleteAccount(accountId);
  }
}