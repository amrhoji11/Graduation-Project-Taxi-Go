part of 'settings_cubit.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final SettingsModel settings;

  const SettingsLoaded({
    required this.settings,
  });
}

class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure({
    required this.message,
  });
}