part of 'accounts_bloc.dart';

abstract class AccountsEvent {}

class LoadAccounts extends AccountsEvent {}

class CreateAccount extends AccountsEvent {
  final Account account;
  CreateAccount(this.account);
}

class UpdateAccount extends AccountsEvent {
  final Account account;
  UpdateAccount(this.account);
}

class DeleteAccount extends AccountsEvent {
  final int accountId;
  DeleteAccount(this.accountId);
}