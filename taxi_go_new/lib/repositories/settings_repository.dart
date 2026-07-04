import 'package:taxi_go_new/core/api/api_client.dart';
import 'package:taxi_go_new/core/api/api_endpoints.dart';
import 'package:taxi_go_new/models/settings_model.dart';

class SettingsRepository {
  final ApiClient apiClient;

  SettingsRepository({
    required this.apiClient,
  });

  Future<SettingsModel> getSettings() async {
    String language = 'en';
    bool darkMode = false;
    bool notificationsEnabled = true;
    String whatsappContact = '';
    String supportPhoneNumber = '';

    try {
      final response = await apiClient.get(ApiEndpoints.getLanguage);
      final data = response.data;

      if (data is String) {
        language = data;
      } else if (data is Map && data['language'] != null) {
        language = data['language'].toString();
      }
    } catch (_) {}

    try {
      final response = await apiClient.get(ApiEndpoints.getDarkMode);
      final data = response.data;

      if (data is bool) {
        darkMode = data;
      } else if (data is Map && data['darkModeEnabled'] is bool) {
        darkMode = data['darkModeEnabled'] as bool;
      }
    } catch (_) {}

    try {
      final response = await apiClient.get(ApiEndpoints.viewNotificationsStatus);
      final data = response.data;

      if (data is bool) {
        notificationsEnabled = data;
      } else if (data is Map && data['notificationsEnabled'] is bool) {
        notificationsEnabled = data['notificationsEnabled'] as bool;
      }
    } catch (_) {}

    try {
      final response = await apiClient.get(ApiEndpoints.whatsappContact);
      final data = response.data;

      if (data is Map && data['whatsappLink'] != null) {
        whatsappContact = data['whatsappLink'].toString();
      }
      if (data is Map && data['whatsappNumber'] != null) {
        supportPhoneNumber = data['whatsappNumber'].toString();
      }
    } catch (_) {}

    return SettingsModel(
      language: language,
      darkMode: darkMode,
      notificationsEnabled: notificationsEnabled,
      whatsappContact: whatsappContact,
      supportPhoneNumber: supportPhoneNumber,
    );
  }

  Future<void> updateLanguage(String language) async {
    await apiClient.put(
      ApiEndpoints.language,
      data: {
        'language': language,
      },
    );
  }

  /// Backend `UpdateDarkModeDto` only has an `Enabled` field - there is no
  /// `darkMode` key on the backend at all.
  Future<void> updateDarkMode(bool value) async {
    await apiClient.put(
      ApiEndpoints.darkMode,
      data: {
        'enabled': value,
      },
    );
  }

  Future<void> updateNotifications(bool value) async {
    await apiClient.put(
      ApiEndpoints.notificationsStatus,
      data: {
        'enabled': value,
      },
    );
  }
}
