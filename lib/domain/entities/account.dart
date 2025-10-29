import 'package:flutter/material.dart';

class Account {
  final int? id;
  final String name;
  final String holderName;
  final String accountNumber;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final double balance;
  final double income;
  final double expense;

  const Account({
    this.id,
    required this.name,
    required this.holderName,
    required this.accountNumber,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.balance = 0.0,
    this.income = 0.0,
    this.expense = 0.0,
  });

  Account copyWith({
    int? id,
    String? name,
    String? holderName,
    String? accountNumber,
    IconData? icon,
    Color? color,
    bool? isDefault,
    double? balance,
    double? income,
    double? expense,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      holderName: holderName ?? this.holderName,
      accountNumber: accountNumber ?? this.accountNumber,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      balance: balance ?? this.balance,
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}