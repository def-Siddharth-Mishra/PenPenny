import 'package:penpenny/domain/entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(int id);
  Future<Account> createAccount(Account account);
  Future<Account> updateAccount(Account account);
  Future<void> deleteAccount(int id);
  Future<Account?> getDefaultAccount();
  Future<void> setDefaultAccount(int accountId);
}