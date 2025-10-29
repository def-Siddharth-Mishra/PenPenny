import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';

enum PaymentType { debit, credit }

class Payment {
  final int? id;
  final Account account;
  final Category category;
  final double amount;
  final PaymentType type;
  final DateTime datetime;
  final String title;
  final String description;

  const Payment({
    this.id,
    required this.account,
    required this.category,
    required this.amount,
    required this.type,
    required this.datetime,
    required this.title,
    required this.description,
  });

  Payment copyWith({
    int? id,
    Account? account,
    Category? category,
    double? amount,
    PaymentType? type,
    DateTime? datetime,
    String? title,
    String? description,
  }) {
    return Payment(
      id: id ?? this.id,
      account: account ?? this.account,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      datetime: datetime ?? this.datetime,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}