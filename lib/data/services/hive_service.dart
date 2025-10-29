import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:penpenny/data/models/hive/account_hive_model.dart';
import 'package:penpenny/data/models/hive/category_hive_model.dart';
import 'package:penpenny/data/models/hive/payment_hive_model.dart';
import 'package:penpenny/data/models/hive/app_settings_hive_model.dart';

class HiveService {
  static const String accountsBox = 'accounts';
  static const String categoriesBox = 'categories';
  static const String paymentsBox = 'payments';
  static const String settingsBox = 'settings';
  static const String settingsKey = 'app_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(AccountHiveModelAdapter());
    Hive.registerAdapter(CategoryHiveModelAdapter());
    Hive.registerAdapter(PaymentHiveModelAdapter());
    Hive.registerAdapter(AppSettingsHiveModelAdapter());
    
    // Open boxes
    await Hive.openBox<AccountHiveModel>(accountsBox);
    await Hive.openBox<CategoryHiveModel>(categoriesBox);
    await Hive.openBox<PaymentHiveModel>(paymentsBox);
    await Hive.openBox<AppSettingsHiveModel>(settingsBox);
    
    // Initialize default data if needed
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    final accountsBoxInstance = Hive.box<AccountHiveModel>(accountsBox);
    final categoriesBoxInstance = Hive.box<CategoryHiveModel>(categoriesBox);
    
    // Add default account if no accounts exist
    if (accountsBoxInstance.isEmpty) {
      final defaultAccount = AccountHiveModel(
        id: 1,
        name: 'Cash',
        holderName: '',
        accountNumber: '',
        iconCodePoint: Icons.wallet.codePoint,
        colorValue: Colors.teal.value,
        isDefault: true,
        balance: 0.0,
      );
      await accountsBoxInstance.add(defaultAccount);
    }
    
    // Add default categories if no categories exist
    if (categoriesBoxInstance.isEmpty) {
      final defaultCategories = [
        CategoryHiveModel(id: 1, name: 'Housing', iconCodePoint: Icons.house.codePoint, colorValue: Colors.blue.value),
        CategoryHiveModel(id: 2, name: 'Transportation', iconCodePoint: Icons.emoji_transportation.codePoint, colorValue: Colors.green.value),
        CategoryHiveModel(id: 3, name: 'Food', iconCodePoint: Icons.restaurant.codePoint, colorValue: Colors.orange.value),
        CategoryHiveModel(id: 4, name: 'Utilities', iconCodePoint: Icons.category.codePoint, colorValue: Colors.purple.value),
        CategoryHiveModel(id: 5, name: 'Insurance', iconCodePoint: Icons.health_and_safety.codePoint, colorValue: Colors.red.value),
        CategoryHiveModel(id: 6, name: 'Medical & Healthcare', iconCodePoint: Icons.medical_information.codePoint, colorValue: Colors.pink.value),
        CategoryHiveModel(id: 7, name: 'Saving & Investing', iconCodePoint: Icons.attach_money.codePoint, colorValue: Colors.indigo.value),
        CategoryHiveModel(id: 8, name: 'Personal Spending', iconCodePoint: Icons.shopping_bag.codePoint, colorValue: Colors.cyan.value),
        CategoryHiveModel(id: 9, name: 'Recreation & Entertainment', iconCodePoint: Icons.tv.codePoint, colorValue: Colors.amber.value),
        CategoryHiveModel(id: 10, name: 'Miscellaneous', iconCodePoint: Icons.library_books_sharp.codePoint, colorValue: Colors.brown.value),
      ];
      
      for (final category in defaultCategories) {
        await categoriesBoxInstance.add(category);
      }
    }
    
    // Recalculate account balances based on existing payments
    await _recalculateAccountBalances();
  }

  static Future<void> _recalculateAccountBalances() async {
    final paymentsBox = paymentsBoxInstance;
    final accountsBox = accountsBoxInstance;
    
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

  static Box<AccountHiveModel> get accountsBoxInstance => Hive.box<AccountHiveModel>(accountsBox);
  static Box<CategoryHiveModel> get categoriesBoxInstance => Hive.box<CategoryHiveModel>(categoriesBox);
  static Box<PaymentHiveModel> get paymentsBoxInstance => Hive.box<PaymentHiveModel>(paymentsBox);
  static Box<AppSettingsHiveModel> get settingsBoxInstance => Hive.box<AppSettingsHiveModel>(settingsBox);

  static Future<void> resetAllData() async {
    await accountsBoxInstance.clear();
    await categoriesBoxInstance.clear();
    await paymentsBoxInstance.clear();
    await settingsBoxInstance.clear();
    await _initializeDefaultData();
  }

  static Future<void> recalculateAccountBalances() async {
    await _recalculateAccountBalances();
  }
}