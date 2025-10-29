import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/repositories/account_repository.dart';

part 'accounts_event.dart';
part 'accounts_state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountRepository repository;

  AccountsBloc(this.repository) : super(AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<CreateAccount>(_onCreateAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountsLoading());
      final accounts = await repository.getAllAccounts();
      emit(AccountsLoaded(accounts));
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      await repository.createAccount(event.account);
      add(LoadAccounts());
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      await repository.updateAccount(event.account);
      add(LoadAccounts());
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      await repository.deleteAccount(event.accountId);
      add(LoadAccounts());
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }
}