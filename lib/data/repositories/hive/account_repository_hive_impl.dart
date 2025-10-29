import 'package:penpenny/data/models/hive/account_hive_model.dart';
import 'package:penpenny/data/services/hive_service.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class AccountRepositoryHiveImpl implements AccountRepository {
  @override
  Future<List<Account>> getAllAccounts() async {
    final box = HiveService.accountsBoxInstance;
    return box.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Account?> getAccountById(int id) async {
    final box = HiveService.accountsBoxInstance;
    try {
      final model = box.values.firstWhere((account) => account.id == id);
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Account?> getDefaultAccount() async {
    final box = HiveService.accountsBoxInstance;
    try {
      final model = box.values.firstWhere((account) => account.isDefault);
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Account> createAccount(Account account) async {
    final box = HiveService.accountsBoxInstance;
    
    // Generate new ID
    final newId = box.values.isEmpty ? 1 : box.values.map((a) => a.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    
    final model = AccountHiveModel.fromEntity(account.copyWith(id: newId));
    await box.add(model);
    
    return model.toEntity();
  }

  @override
  Future<Account> updateAccount(Account account) async {
    final box = HiveService.accountsBoxInstance;
    
    final index = box.values.toList().indexWhere((a) => a.id == account.id);
    if (index == -1) throw StateError('Account not found');
    
    final model = AccountHiveModel.fromEntity(account);
    await box.putAt(index, model);
    
    return model.toEntity();
  }

  @override
  Future<void> deleteAccount(int id) async {
    final box = HiveService.accountsBoxInstance;
    
    final index = box.values.toList().indexWhere((a) => a.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  @override
  Future<void> setDefaultAccount(int id) async {
    final box = HiveService.accountsBoxInstance;
    final accounts = box.values.toList();
    
    for (int i = 0; i < accounts.length; i++) {
      final account = accounts[i];
      account.isDefault = account.id == id;
      await box.putAt(i, account);
    }
  }

  @override
  Future<double> getTotalBalance() async {
    final accounts = await getAllAccounts();
    return accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
  }

  @override
  Future<Account> updateAccountBalance(int accountId, double newBalance) async {
    final box = HiveService.accountsBoxInstance;
    
    final index = box.values.toList().indexWhere((a) => a.id == accountId);
    if (index == -1) throw StateError('Account not found');
    
    final account = box.values.toList()[index];
    account.balance = newBalance;
    await box.putAt(index, account);
    
    return account.toEntity();
  }

  Future<void> recalculateAccountBalances() async {
    final paymentsBox = HiveService.paymentsBoxInstance;
    final accountsBox = HiveService.accountsBoxInstance;
    
    // Reset all account balances to 0
    final accounts = accountsBox.values.toList();
    for (int i = 0; i < accounts.length; i++) {
      accounts[i].balance = 0.0;
      accounts[i].income = 0.0;
      accounts[i].expense = 0.0;
    }
    
    // Calculate balances from payments
    for (final payment in paymentsBox.values) {
      final accountIndex = accounts.indexWhere((a) => a.id == payment.accountId);
      if (accountIndex != -1) {
        final account = accounts[accountIndex];
        if (payment.paymentType == 1) { // Credit
          account.balance += payment.amount;
          account.income += payment.amount;
        } else { // Debit
          account.balance -= payment.amount;
          account.expense += payment.amount;
        }
      }
    }
    
    // Save updated accounts
    for (int i = 0; i < accounts.length; i++) {
      await accountsBox.putAt(i, accounts[i]);
    }
  }
}