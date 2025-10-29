import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class GetAllAccounts {
  final AccountRepository repository;

  GetAllAccounts(this.repository);

  Future<List<Account>> call() async {
    return await repository.getAllAccounts();
  }
}