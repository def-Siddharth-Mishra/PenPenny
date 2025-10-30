part of 'accounts_bloc.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();
  
  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;
  final Account? defaultAccount;
  final double totalBalance;
  
  const AccountsLoaded({
    required this.accounts,
    this.defaultAccount,
    required this.totalBalance,
  });
  
  AccountsLoaded copyWith({
    List<Account>? accounts,
    Account? defaultAccount,
    double? totalBalance,
  }) {
    return AccountsLoaded(
      accounts: accounts ?? this.accounts,
      defaultAccount: defaultAccount ?? this.defaultAccount,
      totalBalance: totalBalance ?? this.totalBalance,
    );
  }
  
  @override
  List<Object?> get props => [accounts, defaultAccount, totalBalance];
}

class AccountsError extends AccountsState {
  final String message;
  final String? code;
  
  const AccountsError(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}