import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/app_settings.dart';
import 'package:penpenny/domain/repositories/app_settings_repository.dart';

part 'app_settings_event.dart';
part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final AppSettingsRepository repository;

  AppSettingsBloc(this.repository) : super(AppSettingsInitial()) {
    on<LoadAppSettings>(_onLoadAppSettings);
    on<UpdateUsername>(_onUpdateUsername);
    on<UpdateCurrency>(_onUpdateCurrency);
    on<UpdateThemeColor>(_onUpdateThemeColor);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<ResetSettings>(_onResetSettings);
  }

  Future<void> _onLoadAppSettings(
    LoadAppSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      emit(AppSettingsLoading());
      final settings = await repository.getSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await repository.updateUsername(event.username);
      final settings = await repository.getSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateCurrency(
    UpdateCurrency event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await repository.updateCurrency(event.currency);
      final settings = await repository.getSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateThemeColor(
    UpdateThemeColor event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await repository.updateThemeColor(event.color);
      final settings = await repository.getSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await repository.updateThemeMode(event.themeMode);
      final settings = await repository.getSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await repository.resetSettings();
      final settings = await repository.getSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }
}