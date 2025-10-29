import 'package:hive/hive.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';

part 'payment_hive_model.g.dart';

@HiveType(typeId: 2)
class PaymentHiveModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int accountId;

  @HiveField(2)
  int categoryId;

  @HiveField(3)
  double amount;

  @HiveField(4)
  int paymentType; // 0 for debit, 1 for credit

  @HiveField(5)
  DateTime datetime;

  @HiveField(6)
  String title;

  @HiveField(7)
  String description;

  PaymentHiveModel({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.paymentType,
    required this.datetime,
    required this.title,
    required this.description,
  });

  factory PaymentHiveModel.fromEntity(Payment payment) {
    return PaymentHiveModel(
      id: payment.id,
      accountId: payment.account.id!,
      categoryId: payment.category.id!,
      amount: payment.amount,
      paymentType: payment.type == PaymentType.debit ? 0 : 1,
      datetime: payment.datetime,
      title: payment.title,
      description: payment.description,
    );
  }

  Payment toEntity(Account account, Category category) {
    return Payment(
      id: id,
      account: account,
      category: category,
      amount: amount,
      type: paymentType == 0 ? PaymentType.debit : PaymentType.credit,
      datetime: datetime,
      title: title,
      description: description,
    );
  }
}