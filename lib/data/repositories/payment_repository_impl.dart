import 'package:penpenny/data/datasources/database_helper.dart';
import 'package:penpenny/data/models/payment_model.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  @override
  Future<List<Payment>> getAllPayments() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, 
             a.name as account_name, a.holderName as account_holderName, 
             a.accountNumber as account_accountNumber, a.icon as account_icon, 
             a.color as account_color, a.isDefault as account_isDefault,
             c.name as category_name, c.icon as category_icon, 
             c.color as category_color, c.budget as category_budget
      FROM payments p
      JOIN accounts a ON p.account = a.id
      JOIN categories c ON p.category = c.id
      ORDER BY p.datetime DESC
    ''');
    
    return List.generate(maps.length, (i) => _mapToPaymentModel(maps[i]));
  }

  @override
  Future<Payment?> getPaymentById(int id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, 
             a.name as account_name, a.holderName as account_holderName, 
             a.accountNumber as account_accountNumber, a.icon as account_icon, 
             a.color as account_color, a.isDefault as account_isDefault,
             c.name as category_name, c.icon as category_icon, 
             c.color as category_color, c.budget as category_budget
      FROM payments p
      JOIN accounts a ON p.account = a.id
      JOIN categories c ON p.category = c.id
      WHERE p.id = ?
    ''', [id]);
    
    if (maps.isNotEmpty) {
      return _mapToPaymentModel(maps.first);
    }
    return null;
  }

  @override
  Future<List<Payment>> getPaymentsByAccount(int accountId) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, 
             a.name as account_name, a.holderName as account_holderName, 
             a.accountNumber as account_accountNumber, a.icon as account_icon, 
             a.color as account_color, a.isDefault as account_isDefault,
             c.name as category_name, c.icon as category_icon, 
             c.color as category_color, c.budget as category_budget
      FROM payments p
      JOIN accounts a ON p.account = a.id
      JOIN categories c ON p.category = c.id
      WHERE p.account = ?
      ORDER BY p.datetime DESC
    ''', [accountId]);
    
    return List.generate(maps.length, (i) => _mapToPaymentModel(maps[i]));
  }

  @override
  Future<List<Payment>> getPaymentsByCategory(int categoryId) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, 
             a.name as account_name, a.holderName as account_holderName, 
             a.accountNumber as account_accountNumber, a.icon as account_icon, 
             a.color as account_color, a.isDefault as account_isDefault,
             c.name as category_name, c.icon as category_icon, 
             c.color as category_color, c.budget as category_budget
      FROM payments p
      JOIN accounts a ON p.account = a.id
      JOIN categories c ON p.category = c.id
      WHERE p.category = ?
      ORDER BY p.datetime DESC
    ''', [categoryId]);
    
    return List.generate(maps.length, (i) => _mapToPaymentModel(maps[i]));
  }

  @override
  Future<List<Payment>> getPaymentsByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, 
             a.name as account_name, a.holderName as account_holderName, 
             a.accountNumber as account_accountNumber, a.icon as account_icon, 
             a.color as account_color, a.isDefault as account_isDefault,
             c.name as category_name, c.icon as category_icon, 
             c.color as category_color, c.budget as category_budget
      FROM payments p
      JOIN accounts a ON p.account = a.id
      JOIN categories c ON p.category = c.id
      WHERE p.datetime BETWEEN ? AND ?
      ORDER BY p.datetime DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    return List.generate(maps.length, (i) => _mapToPaymentModel(maps[i]));
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    final db = await DatabaseHelper.database;
    final paymentModel = PaymentModel.fromEntity(payment);
    final id = await db.insert('payments', paymentModel.toJson());
    return paymentModel.copyWith(id: id);
  }

  @override
  Future<Payment> updatePayment(Payment payment) async {
    final db = await DatabaseHelper.database;
    final paymentModel = PaymentModel.fromEntity(payment);
    await db.update(
      'payments',
      paymentModel.toJson(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
    return payment;
  }

  @override
  Future<void> deletePayment(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  PaymentModel _mapToPaymentModel(Map<String, dynamic> map) {
    return PaymentModel.fromJson({
      'id': map['id'],
      'title': map['title'],
      'description': map['description'],
      'amount': map['amount'],
      'type': map['type'],
      'datetime': map['datetime'],
      'account': {
        'id': map['account'],
        'name': map['account_name'],
        'holderName': map['account_holderName'],
        'accountNumber': map['account_accountNumber'],
        'icon': map['account_icon'],
        'color': map['account_color'],
        'isDefault': map['account_isDefault'],
      },
      'category': {
        'id': map['category'],
        'name': map['category_name'],
        'icon': map['category_icon'],
        'color': map['category_color'],
        'budget': map['category_budget'],
      },
    });
  }
}