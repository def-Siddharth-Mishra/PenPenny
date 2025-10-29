import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/repositories/payment_repository.dart';

part 'payments_event.dart';
part 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentRepository repository;

  PaymentsBloc(this.repository) : super(PaymentsInitial()) {
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
      emit(PaymentsLoading());
      final payments = await repository.getAllPayments();
      
      // Calculate income and expense
      double income = 0;
      double expense = 0;
      for (var payment in payments) {
        if (payment.type == PaymentType.credit) {
          income += payment.amount;
        } else {
          expense += payment.amount;
        }
      }
      
      emit(PaymentsLoaded(payments, income, expense));
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentsByDateRange(
    LoadPaymentsByDateRange event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      emit(PaymentsLoading());
      final payments = await repository.getPaymentsByDateRange(
        event.dateRange.start,
        event.dateRange.end,
      );
      
      // Calculate income and expense
      double income = 0;
      double expense = 0;
      for (var payment in payments) {
        if (payment.type == PaymentType.credit) {
          income += payment.amount;
        } else {
          expense += payment.amount;
        }
      }
      
      emit(PaymentsLoaded(payments, income, expense));
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      await repository.createPayment(event.payment);
      add(LoadPayments());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onUpdatePayment(
    UpdatePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      await repository.updatePayment(event.payment);
      add(LoadPayments());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      await repository.deletePayment(event.paymentId);
      add(LoadPayments());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }
}