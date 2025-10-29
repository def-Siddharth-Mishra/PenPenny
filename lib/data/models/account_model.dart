import 'package:flutter/material.dart';
import 'package:penpenny/domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    super.id,
    required super.name,
    required super.holderName,
    required super.accountNumber,
    required super.icon,
    required super.color,
    super.isDefault = false,
    super.balance = 0.0,
    super.income = 0.0,
    super.expense = 0.0,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      holderName: json['holderName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      isDefault: json['isDefault'] == 1,
      income: json['income']?.toDouble() ?? 0.0,
      expense: json['expense']?.toDouble() ?? 0.0,
      balance: json['balance']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'holderName': holderName,
      'accountNumber': accountNumber,
      'icon': icon.codePoint,
      'color': color.value,
      'isDefault': isDefault ? 1 : 0,
      'balance': balance,
    };
  }

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      name: account.name,
      holderName: account.holderName,
      accountNumber: account.accountNumber,
      icon: account.icon,
      color: account.color,
      isDefault: account.isDefault,
      balance: account.balance,
      income: account.income,
      expense: account.expense,
    );
  }
}