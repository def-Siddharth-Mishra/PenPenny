import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:penpenny/domain/entities/account.dart';

part 'account_hive_model.g.dart';

// Helper to create IconData that can be tree-shaken
class IconDataHelper {
  static const IconData _defaultIcon = Icons.account_balance_wallet;
  
  static IconData fromCodePoint(int codePoint) {
    // Use a switch or map to return const IconData instances
    // This allows Flutter to tree-shake properly
    switch (codePoint) {
      case 0xe047: return Icons.account_balance_wallet;
      case 0xe0c8: return Icons.credit_card;
      case 0xe227: return Icons.savings;
      case 0xe8c4: return Icons.account_balance;
      default: return const IconData(0xe047, fontFamily: 'MaterialIcons'); // Default wallet icon
    }
  }
}

@HiveType(typeId: 0)
class AccountHiveModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String holderName;

  @HiveField(3)
  String accountNumber;

  @HiveField(4)
  int iconCodePoint;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  bool isDefault;

  @HiveField(7)
  double balance;

  @HiveField(8)
  double income;

  @HiveField(9)
  double expense;

  AccountHiveModel({
    this.id,
    required this.name,
    required this.holderName,
    required this.accountNumber,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
    this.balance = 0.0,
    this.income = 0.0,
    this.expense = 0.0,
  });

  factory AccountHiveModel.fromEntity(Account account) {
    return AccountHiveModel(
      id: account.id,
      name: account.name,
      holderName: account.holderName,
      accountNumber: account.accountNumber,
      iconCodePoint: account.icon.codePoint,
      colorValue: account.color.value,
      isDefault: account.isDefault,
      balance: account.balance,
      income: account.income,
      expense: account.expense,
    );
  }

  Account toEntity() {
    return Account(
      id: id,
      name: name,
      holderName: holderName,
      accountNumber: accountNumber,
      icon: IconDataHelper.fromCodePoint(iconCodePoint),
      color: Color(colorValue),
      isDefault: isDefault,
      balance: balance,
      income: income,
      expense: expense,
    );
  }
}