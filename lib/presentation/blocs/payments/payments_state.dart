part of 'payments_bloc.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();
  
  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  final List<Payment> payments;
  final List<Payment> recentPayments;
  final double income;
  final double expense;
  final double balance;
  final Map<String, double> categoryExpenses;
  final DateTime? lastUpdated;
  
  const PaymentsLoaded({
    required this.payments,
    required this.recentPayments,
    required this.income,
    required this.expense,
    required this.balance,
    required this.categoryExpenses,
    this.lastUpdated,
  });
  
  PaymentsLoaded copyWith({
    List<Payment>? payments,
    List<Payment>? recentPayments,
    double? income,
    double? expense,
    double? balance,
    Map<String, double>? categoryExpenses,
    DateTime? lastUpdated,
  }) {
    return PaymentsLoaded(
      payments: payments ?? this.payments,
      recentPayments: recentPayments ?? this.recentPayments,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
      categoryExpenses: categoryExpenses ?? this.categoryExpenses,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  @override
  List<Object?> get props => [
    payments,
    recentPayments,
    income,
    expense,
    balance,
    categoryExpenses,
    lastUpdated,
  ];
}

class PaymentsError extends PaymentsState {
  final String message;
  final String? code;
  
  const PaymentsError(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}