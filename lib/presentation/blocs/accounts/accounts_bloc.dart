import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/usecases/account/create_account.dart' as account_create_usecase;
import 'package:penpenny/domain/usecases/account/delete_account.dart' as account_delete_usecase;
import 'package:penpenny/domain/usecases/account/get_all_accounts.dart';
import 'package:penpenny/domain/usecases/account/update_account.dart' as account_update_usecase;

part 'accounts_event.dart';
part 'accounts_state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetAllAccounts getAllAccounts;
  final account_create_usecase.CreateAccount createAccount;
  final account_update_usecase.UpdateAccount updateAccount;
  final account_delete_usecase.DeleteAccount deleteAccount;

  AccountsBloc({
    required this.getAllAccounts,
    required this.createAccount,
    required this.updateAccount,
    required this.deleteAccount,
  }) : super(AccountsInitial()) {
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
      final accounts = await getAllAccounts();
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
      await createAccount(event.account);
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
      await updateAccount(event.account);
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
      await deleteAccount(event.accountId);
      add(LoadAccounts());
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }
}