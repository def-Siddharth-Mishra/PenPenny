part of 'accounts_bloc.dart';

abstract class AccountsState {}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;
  AccountsLoaded(this.accounts);
}

class AccountsError extends AccountsState {
  final String message;
  AccountsError(this.message);
}