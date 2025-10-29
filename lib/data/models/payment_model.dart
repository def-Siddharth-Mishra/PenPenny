import 'package:intl/intl.dart';
import 'package:penpenny/data/models/account_model.dart';
import 'package:penpenny/data/models/category_model.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    super.id,
    required super.account,
    required super.category,
    required super.amount,
    required super.type,
    required super.datetime,
    required super.title,
    required super.description,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      account: AccountModel.fromJson(json['account']),
      category: CategoryModel.fromJson(json['category']),
      amount: json['amount']?.toDouble() ?? 0.0,
      type: json['type'] == 'CR' ? PaymentType.credit : PaymentType.debit,
      datetime: DateTime.parse(json['datetime']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'title': title,
      'description': description,
      'account': account.id,
      'category': category.id,
      'amount': amount,
      'datetime': DateFormat('yyyy-MM-dd kk:mm:ss').format(datetime),
      'type': type == PaymentType.credit ? 'CR' : 'DR',
    };
    
    if (id != null) {
      json['id'] = id;
    }
    
    return json;
  }

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      account: payment.account,
      category: payment.category,
      amount: payment.amount,
      type: payment.type,
      datetime: payment.datetime,
      title: payment.title,
      description: payment.description,
    );
  }

  @override
  PaymentModel copyWith({
    int? id,
    Account? account,
    Category? category,
    String? title,
    String? description,
    double? amount,
    PaymentType? type,
    DateTime? datetime,
  }) {
    return PaymentModel(
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
}