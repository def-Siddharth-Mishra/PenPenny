import 'package:penpenny/data/datasources/database_helper.dart';
import 'package:penpenny/data/models/account_model.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  @override
  Future<List<Account>> getAllAccounts() async {
    final db = await DatabaseHelper.database;
    
    // Get accounts with summary like the original
    final String fields = [
      "a.id", "a.name", "a.holderName", "a.accountNumber", "a.icon", "a.color", "a.isDefault",
      "SUM(CASE WHEN t.type='DR' AND t.account=a.id THEN t.amount END) as expense",
      "SUM(CASE WHEN t.type='CR' AND t.account=a.id THEN t.amount END) as income"
    ].join(",");
    
    final String sql = "SELECT $fields FROM accounts a LEFT JOIN payments t ON t.account = a.id GROUP BY a.id";
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql);
    
    return List.generate(maps.length, (i) {
      Map<String, dynamic> item = Map.from(maps[i]);
      item["income"] = item["income"] ?? 0.0;
      item["expense"] = item["expense"] ?? 0.0;
      item["balance"] = double.parse((item["income"] - item["expense"]).toString());
      return AccountModel.fromJson(item);
    });
  }

  @override
  Future<Account?> getAccountById(int id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AccountModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<Account> createAccount(Account account) async {
    final db = await DatabaseHelper.database;
    final accountModel = AccountModel.fromEntity(account);
    final id = await db.insert('accounts', accountModel.toJson());
    return accountModel.copyWith(id: id);
  }

  @override
  Future<Account> updateAccount(Account account) async {
    final db = await DatabaseHelper.database;
    final accountModel = AccountModel.fromEntity(account);
    await db.update(
      'accounts',
      accountModel.toJson(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
    return account;
  }

  @override
  Future<void> deleteAccount(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Account?> getDefaultAccount() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'isDefault = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return AccountModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> setDefaultAccount(int accountId) async {
    final db = await DatabaseHelper.database;
    await db.transaction((txn) async {
      // Reset all accounts to non-default
      await txn.update('accounts', {'isDefault': 0});
      // Set the specified account as default
      await txn.update(
        'accounts',
        {'isDefault': 1},
        where: 'id = ?',
        whereArgs: [accountId],
      );
    });
  }
}