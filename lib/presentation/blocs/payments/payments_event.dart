part of 'payments_bloc.dart';

abstract class PaymentsEvent {}

class LoadPayments extends PaymentsEvent {}

class LoadPaymentsByDateRange extends PaymentsEvent {
  final DateTimeRange dateRange;
  LoadPaymentsByDateRange(this.dateRange);
}

class CreatePayment extends PaymentsEvent {
  final Payment payment;
  CreatePayment(this.payment);
}

class UpdatePayment extends PaymentsEvent {
  final Payment payment;
  UpdatePayment(this.payment);
}

class DeletePayment extends PaymentsEvent {
  final int paymentId;
  DeletePayment(this.paymentId);
}