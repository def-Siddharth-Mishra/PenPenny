import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';
import 'package:penpenny/domain/usecases/payment/create_payment.dart';
import 'package:penpenny/domain/usecases/payment/delete_payment.dart';
import 'package:penpenny/domain/usecases/payment/get_all_payments.dart';
import 'package:penpenny/domain/usecases/payment/update_payment.dart';

import 'payment_crud_test.mocks.dart';

@GenerateMocks([PaymentRepository, AccountRepository])
void main() {
  late MockPaymentRepository mockPaymentRepository;
  late MockAccountRepository mockAccountRepository;
  late CreatePayment createPayment;
  late GetAllPayments getAllPayments;
  late UpdatePayment updatePayment;
  late DeletePayment deletePayment;

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    mockAccountRepository = MockAccountRepository();
    createPayment = CreatePayment(mockPaymentRepository, mockAccountRepository);
    getAllPayments = GetAllPayments(mockPaymentRepository);
    updatePayment = UpdatePayment(mockPaymentRepository, mockAccountRepository);
    deletePayment = DeletePayment(mockPaymentRepository, mockAccountRepository);
  });

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

  group('Payment CRUD Operations', () {
    test('should create payment successfully', () async {
      // Arrange
      when(mockPaymentRepository.createPayment(any)).thenAnswer((_) async => testPayment);
      when(mockAccountRepository.getAccountById(any)).thenAnswer((_) async => testAccount);
      when(mockAccountRepository.updateAccountBalance(any, any)).thenAnswer((_) async => testAccount);

      // Act
      final result = await createPayment(testPayment);

      // Assert
      expect(result, equals(testPayment));
      verify(mockPaymentRepository.createPayment(testPayment)).called(1);
    });

    test('should get all payments successfully', () async {
      // Arrange
      final payments = [testPayment];
      when(mockPaymentRepository.getAllPayments()).thenAnswer((_) async => payments);

      // Act
      final result = await getAllPayments();

      // Assert
      expect(result, equals(payments));
      verify(mockPaymentRepository.getAllPayments()).called(1);
    });

    test('should update payment successfully', () async {
      // Arrange
      final updatedPayment = testPayment.copyWith(amount: 75.0);
      when(mockPaymentRepository.getPaymentById(any)).thenAnswer((_) async => testPayment);
      when(mockPaymentRepository.updatePayment(any)).thenAnswer((_) async => updatedPayment);
      when(mockAccountRepository.getAccountById(any)).thenAnswer((_) async => testAccount);
      when(mockAccountRepository.updateAccountBalance(any, any)).thenAnswer((_) async => testAccount);

      // Act
      final result = await updatePayment(updatedPayment);

      // Assert
      expect(result, equals(updatedPayment));
      verify(mockPaymentRepository.updatePayment(updatedPayment)).called(1);
    });

    test('should delete payment successfully', () async {
      // Arrange
      when(mockPaymentRepository.getPaymentById(any)).thenAnswer((_) async => testPayment);
      when(mockPaymentRepository.deletePayment(any)).thenAnswer((_) async {});
      when(mockAccountRepository.getAccountById(any)).thenAnswer((_) async => testAccount);
      when(mockAccountRepository.updateAccountBalance(any, any)).thenAnswer((_) async => testAccount);

      // Act
      await deletePayment(1);

      // Assert
      verify(mockPaymentRepository.deletePayment(1)).called(1);
    });

    test('should handle create payment error', () async {
      // Arrange
      when(mockPaymentRepository.createPayment(any)).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => createPayment(testPayment), throwsException);
    });

    test('should handle get all payments error', () async {
      // Arrange
      when(mockPaymentRepository.getAllPayments()).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => getAllPayments(), throwsException);
    });

    test('should handle update payment error', () async {
      // Arrange
      when(mockPaymentRepository.getPaymentById(any)).thenAnswer((_) async => testPayment);
      when(mockPaymentRepository.updatePayment(any)).thenThrow(Exception('Database error'));
      when(mockAccountRepository.getAccountById(any)).thenAnswer((_) async => testAccount);

      // Act & Assert
      expect(() => updatePayment(testPayment), throwsException);
    });

    test('should handle delete payment error', () async {
      // Arrange
      when(mockPaymentRepository.getPaymentById(any)).thenAnswer((_) async => testPayment);
      when(mockPaymentRepository.deletePayment(any)).thenThrow(Exception('Database error'));
      when(mockAccountRepository.getAccountById(any)).thenAnswer((_) async => testAccount);

      // Act & Assert
      expect(() => deletePayment(1), throwsException);
    });
  });

  group('Payment Entity Tests', () {
    test('should create payment with correct properties', () {
      expect(testPayment.id, equals(1));
      expect(testPayment.account, equals(testAccount));
      expect(testPayment.category, equals(testCategory));
      expect(testPayment.amount, equals(50.0));
      expect(testPayment.type, equals(PaymentType.debit));
      expect(testPayment.title, equals('Lunch'));
      expect(testPayment.description, equals('Restaurant meal'));
    });

    test('should copy payment with updated properties', () {
      final copiedPayment = testPayment.copyWith(
        amount: 100.0,
        title: 'Dinner',
      );

      expect(copiedPayment.amount, equals(100.0));
      expect(copiedPayment.title, equals('Dinner'));
      expect(copiedPayment.id, equals(testPayment.id));
      expect(copiedPayment.category, equals(testPayment.category));
    });

    test('should compare payments correctly', () {
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
  });
}