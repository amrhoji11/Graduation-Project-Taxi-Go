import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/models/settings_model.dart';
import 'package:taxi_go_new/repositories/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsCubit({
    required this.settingsRepository,
  }) : super(const SettingsInitial());

  Future<void> getSettings() async {
    emit(const SettingsLoading());

    try {
      final settings =
      await settingsRepository.getSettings();

      emit(
        SettingsLoaded(
          settings: settings,
        ),
      );
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      await settingsRepository.updateLanguage(language);
      await getSettings();
    } catch (e) {
      emit(SettingsFailure(message: e.toString()));
    }
  }

  Future<void> updateDarkMode(bool value) async {
    try {
      await settingsRepository.updateDarkMode(value);
      await getSettings();
    } catch (e) {
      emit(SettingsFailure(message: e.toString()));
    }
  }

  Future<void> updateNotifications(bool value) async {
    try {
      await settingsRepository.updateNotifications(value);
      await getSettings();
    } catch (e) {
      emit(SettingsFailure(message: e.toString()));
    }
  }
}
