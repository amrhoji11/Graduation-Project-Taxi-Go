class SettingsModel {
  final String language;
  final bool darkMode;
  final bool notificationsEnabled;
  final String whatsappContact;
  final String supportPhoneNumber;

  const SettingsModel({
    required this.language,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.whatsappContact,
    required this.supportPhoneNumber,
  });

  factory SettingsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SettingsModel(
      language: json['language'] ?? 'en',
      darkMode: json['darkMode'] ?? false,
      notificationsEnabled:
      json['notificationsEnabled'] ?? true,
      whatsappContact:
      json['whatsappContact'] ?? '',
      supportPhoneNumber:
      json['supportPhoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'whatsappContact': whatsappContact,
      'supportPhoneNumber': supportPhoneNumber,
    };
  }
}