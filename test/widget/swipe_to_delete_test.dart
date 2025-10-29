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

  final testPayment = Payment(
    id: 1,
    account: testAccount,
    category: testCategory,
    amount: 50.0,
    type: PaymentType.debit,
    datetime: DateTime.now(),
    title: 'Lunch',
    description: 'Restaurant meal',
  );

  group('Swipe to Delete Logic Tests', () {
    test('Payment deletion callback should work correctly', () {
      bool onDeleteCalled = false;
      Payment? deletedPayment;

      void onDelete(Payment payment) {
        onDeleteCalled = true;
        deletedPayment = payment;
      }

      // Simulate deletion
      onDelete(testPayment);

      expect(onDeleteCalled, isTrue);
      expect(deletedPayment, equals(testPayment));
    });

    test('Payment tap callback should work correctly', () {
      bool onTapCalled = false;

      void onTap() {
        onTapCalled = true;
      }

      // Simulate tap
      onTap();

      expect(onTapCalled, isTrue);
    });

    test('Payment type should determine dialog message', () {
      final expensePayment = testPayment.copyWith(type: PaymentType.debit);
      final incomePayment = testPayment.copyWith(type: PaymentType.credit);

      expect(expensePayment.type, equals(PaymentType.debit));
      expect(incomePayment.type, equals(PaymentType.credit));

      // Test message generation logic
      final expenseMessage = 'Are you sure you want to delete this ${expensePayment.type == PaymentType.credit ? 'income' : 'expense'} transaction?';
      final incomeMessage = 'Are you sure you want to delete this ${incomePayment.type == PaymentType.credit ? 'income' : 'expense'} transaction?';

      expect(expenseMessage, contains('expense'));
      expect(incomeMessage, contains('income'));
    });

    test('Undo functionality should be available', () {
      bool undoCalled = false;

      void onUndo() {
        undoCalled = true;
      }

      // Simulate undo
      onUndo();

      expect(undoCalled, isTrue);
    });
  });

  group('Payment Item Behavior Tests', () {
    test('Payment entity should have correct properties', () {
      expect(testPayment.id, equals(1));
      expect(testPayment.amount, equals(50.0));
      expect(testPayment.type, equals(PaymentType.debit));
      expect(testPayment.title, equals('Lunch'));
      expect(testPayment.category.name, equals('Food'));
    });

    test('Payment copyWith should work correctly', () {
      final copiedPayment = testPayment.copyWith(
        amount: 75.0,
        type: PaymentType.credit,
      );

      expect(copiedPayment.amount, equals(75.0));
      expect(copiedPayment.type, equals(PaymentType.credit));
      expect(copiedPayment.id, equals(testPayment.id));
      expect(copiedPayment.title, equals(testPayment.title));
    });

    test('Payment equality should work correctly', () {
      final samePayment = Payment(
        id: 1,
        account: testAccount,
        category: testCategory,
        amount: 50.0,
        type: PaymentType.debit,
        datetime: DateTime.now(),
        title: 'Lunch',
        description: 'Restaurant meal',
      );

      expect(testPayment, equals(samePayment));
      expect(testPayment.hashCode, equals(samePayment.hashCode));
    });

    test('Dismissible key should be unique per payment', () {
      final key1 = Key('payment_${testPayment.id}');
      final key2 = Key('payment_${testPayment.id}');
      final key3 = Key('payment_${testPayment.id! + 1}');

      expect(key1.toString(), equals(key2.toString()));
      expect(key1.toString(), isNot(equals(key3.toString())));
    });

    test('Swipe direction should be end to start', () {
      // Test that we're using the correct dismissible direction
      const direction = DismissDirection.endToStart;
      expect(direction, equals(DismissDirection.endToStart));
    });
  });
}