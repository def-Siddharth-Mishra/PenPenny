part of 'payments_bloc.dart';

abstract class PaymentsState {}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<Payment> payments;
  final double income;
  final double expense;
  
  PaymentsLoaded(this.payments, this.income, this.expense);
}

class PaymentsError extends PaymentsState {
  final String message;
  PaymentsError(this.message);
}