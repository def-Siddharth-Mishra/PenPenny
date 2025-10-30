import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/logging/app_logger.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/usecases/payment/create_payment.dart' as payment_create_usecase;
import 'package:penpenny/domain/usecases/payment/delete_payment.dart' as payment_delete_usecase;
import 'package:penpenny/domain/usecases/payment/get_all_payments.dart';
import 'package:penpenny/domain/usecases/payment/update_payment.dart' as payment_update_usecase;

part 'payments_event.dart';
part 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetAllPayments getAllPayments;
  final payment_create_usecase.CreatePayment createPayment;
  final payment_update_usecase.UpdatePayment updatePayment;
  final payment_delete_usecase.DeletePayment deletePayment;

  PaymentsBloc({
    required this.getAllPayments,
    required this.createPayment,
    required this.updatePayment,
    required this.deletePayment,
  }) : super(const PaymentsInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadPaymentsByDateRange>(_onLoadPaymentsByDateRange);
    on<CreatePayment>(_onCreatePayment);
    on<UpdatePayment>(_onUpdatePayment);
    on<DeletePayment>(_onDeletePayment);
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      emit(const PaymentsLoading());
      final payments = await getAllPayments();
      
      // Calculate income and expense
      double income = 0;
      double expense = 0;
      final Map<String, double> categoryExpenses = {};
      
      for (var payment in payments) {
        if (payment.type == PaymentType.credit) {
          income += payment.amount;
        } else {
          expense += payment.amount;
          // Track category expenses
          final categoryName = payment.category.name;
          categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + payment.amount;
        }
      }
      
      final balance = income - expense;
      final recentPayments = payments.take(10).toList();
      
      AppLogger.info('Loaded ${payments.length} payments, Income: $income, Expense: $expense', tag: 'PaymentsBloc');
      
      emit(PaymentsLoaded(
        payments: payments,
        recentPayments: recentPayments,
        income: income,
        expense: expense,
        balance: balance,
        categoryExpenses: categoryExpenses,
        lastUpdated: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Error loading payments', tag: 'PaymentsBloc', error: e, stackTrace: stackTrace);
      emit(const PaymentsError('Failed to load payments. Please try again.'));
    }
  }

  Future<void> _onLoadPaymentsByDateRange(
    LoadPaymentsByDateRange event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      emit(const PaymentsLoading());
      final payments = await getAllPayments();
      
      // Filter by date range
      final filteredPayments = payments.where((payment) {
        return payment.datetime.isAfter(event.dateRange.start) &&
               payment.datetime.isBefore(event.dateRange.end.add(const Duration(days: 1)));
      }).toList();
      
      // Calculate income and expense
      double income = 0;
      double expense = 0;
      final Map<String, double> categoryExpenses = {};
      
      for (var payment in filteredPayments) {
        if (payment.type == PaymentType.credit) {
          income += payment.amount;
        } else {
          expense += payment.amount;
          final categoryName = payment.category.name;
          categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + payment.amount;
        }
      }
      
      final balance = income - expense;
      final recentPayments = filteredPayments.take(10).toList();
      
      emit(PaymentsLoaded(
        payments: filteredPayments,
        recentPayments: recentPayments,
        income: income,
        expense: expense,
        balance: balance,
        categoryExpenses: categoryExpenses,
        lastUpdated: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Error loading payments by date range', tag: 'PaymentsBloc', error: e, stackTrace: stackTrace);
      emit(const PaymentsError('Failed to load payments. Please try again.'));
    }
  }

  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      await createPayment(event.payment);
      add(LoadPayments());
    } catch (e, stackTrace) {
      AppLogger.error('Error creating payment', tag: 'PaymentsBloc', error: e, stackTrace: stackTrace);
      emit(PaymentsError('Failed to create payment. Please try again.'));
    }
  }

  Future<void> _onUpdatePayment(
    UpdatePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      await updatePayment(event.payment);
      add(LoadPayments());
    } catch (e, stackTrace) {
      AppLogger.error('Error updating payment', tag: 'PaymentsBloc', error: e, stackTrace: stackTrace);
      emit(PaymentsError('Failed to update payment. Please try again.'));
    }
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      await deletePayment(event.paymentId);
      add(LoadPayments());
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting payment', tag: 'PaymentsBloc', error: e, stackTrace: stackTrace);
      emit(PaymentsError('Failed to delete payment. Please try again.'));
    }
  }
}