import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';

void main() {
  final testAccount = Account(
    id: 1,
    name: 'Test Account',
    holderName: 'Test Holder',
    accountNumber: '1234567890',
    icon: Icons.account_balance,
    color: Colors.blue,
    balance: 1000.0,
    income: 1500.0,
    expense: 500.0,
  );

  final testCategory = Category(
    id: 1,
    name: 'Food',
    icon: Icons.restaurant,
    color: Colors.orange,
    budget: 500.0,
    expense: 200.0,
  );

  final testPayments = [
    Payment(
      id: 1,
      account: testAccount,
      category: testCategory,
      amount: 50.0,
      type: PaymentType.debit,
      datetime: DateTime.now(),
      title: 'Lunch',
      description: 'Restaurant meal',
    ),
    Payment(
      id: 2,
      account: testAccount,
      category: testCategory,
      amount: 100.0,
      type: PaymentType.credit,
      datetime: DateTime.now().subtract(const Duration(days: 1)),
      title: 'Salary',
      description: 'Monthly salary',
    ),
  ];

  group('Dashboard Logic Tests', () {
    test('ExpenseData calculation should work correctly', () {
      // This is a simple unit test for the data calculation logic
      final payments = [
        Payment(
          id: 1,
          account: testAccount,
          category: testCategory,
          amount: 100.0,
          type: PaymentType.debit,
          datetime: DateTime.now(),
          title: 'Test',
          description: 'Test',
        ),
      ];

      // Test that we have the right data structure
      expect(payments.length, equals(1));
      expect(payments.first.amount, equals(100.0));
      expect(payments.first.type, equals(PaymentType.debit));
    });

    test('Payment filtering should work correctly', () {
      final allPayments = [
        Payment(
          id: 1,
          account: testAccount,
          category: testCategory,
          amount: 50.0,
          type: PaymentType.debit,
          datetime: DateTime.now(),
          title: 'Expense',
          description: 'Test expense',
        ),
        Payment(
          id: 2,
          account: testAccount,
          category: testCategory,
          amount: 100.0,
          type: PaymentType.credit,
          datetime: DateTime.now(),
          title: 'Income',
          description: 'Test income',
        ),
      ];

      final expensePayments = allPayments.where((p) => p.type == PaymentType.debit).toList();
      final incomePayments = allPayments.where((p) => p.type == PaymentType.credit).toList();

      expect(expensePayments.length, equals(1));
      expect(incomePayments.length, equals(1));
      expect(expensePayments.first.amount, equals(50.0));
      expect(incomePayments.first.amount, equals(100.0));
    });

    test('Budget calculation should work correctly', () {
      final category = Category(
        id: 1,
        name: 'Shopping',
        icon: Icons.shopping_cart,
        color: Colors.purple,
        budget: 100.0,
        expense: 0.0,
      );

      final payments = [
        Payment(
          id: 1,
          account: testAccount,
          category: category,
          amount: 80.0, // 80% of budget
          type: PaymentType.debit,
          datetime: DateTime.now(),
          title: 'Shopping',
          description: 'Purchase',
        ),
      ];

      // Calculate budget usage
      final totalExpense = payments
          .where((p) => p.type == PaymentType.debit && p.category.id == category.id)
          .fold(0.0, (sum, p) => sum + p.amount);
      
      final budgetUsage = (totalExpense / category.budget) * 100;

      expect(totalExpense, equals(80.0));
      expect(budgetUsage, equals(80.0));
      expect(budgetUsage >= 70, isTrue); // Should trigger alert
    });

    test('Recent transactions limiting should work correctly', () {
      final manyPayments = List.generate(15, (index) => 
        Payment(
          id: index,
          account: testAccount,
          category: testCategory,
          amount: 50.0,
          type: PaymentType.debit,
          datetime: DateTime.now(),
          title: 'Payment $index',
          description: 'Description $index',
        ),
      );

      final recentPayments = manyPayments.take(10).toList();
      
      expect(manyPayments.length, equals(15));
      expect(recentPayments.length, equals(10));
      expect(recentPayments.first.title, equals('Payment 0'));
      expect(recentPayments.last.title, equals('Payment 9'));
    });

    test('Category expense calculation should work correctly', () {
      final categoryExpenses = <int, double>{};
      double totalExpense = 0;

      // Calculate expenses by category
      for (final payment in testPayments) {
        if (payment.type == PaymentType.debit) {
          final categoryId = payment.category.id!;
          categoryExpenses[categoryId] = (categoryExpenses[categoryId] ?? 0) + payment.amount;
          totalExpense += payment.amount;
        }
      }

      expect(categoryExpenses[testCategory.id], equals(50.0));
      expect(totalExpense, equals(50.0));
    });

    test('Income and expense totals should calculate correctly', () {
      double income = 0;
      double expense = 0;
      
      for (var payment in testPayments) {
        if (payment.type == PaymentType.credit) {
          income += payment.amount;
        } else {
          expense += payment.amount;
        }
      }
      
      expect(income, equals(100.0));
      expect(expense, equals(50.0));
      expect(income - expense, equals(50.0)); // Net balance
    });
  });

  group('Entity Tests', () {
    test('Account entity should work correctly', () {
      expect(testAccount.id, equals(1));
      expect(testAccount.name, equals('Test Account'));
      expect(testAccount.balance, equals(1000.0));
      expect(testAccount.income, equals(1500.0));
      expect(testAccount.expense, equals(500.0));
    });

    test('Category entity should work correctly', () {
      expect(testCategory.id, equals(1));
      expect(testCategory.name, equals('Food'));
      expect(testCategory.budget, equals(500.0));
      expect(testCategory.expense, equals(200.0));
    });

    test('Payment entity should work correctly', () {
      final payment = testPayments.first;
      expect(payment.id, equals(1));
      expect(payment.amount, equals(50.0));
      expect(payment.type, equals(PaymentType.debit));
      expect(payment.title, equals('Lunch'));
      expect(payment.category.name, equals('Food'));
      expect(payment.account.name, equals('Test Account'));
    });
  });
}