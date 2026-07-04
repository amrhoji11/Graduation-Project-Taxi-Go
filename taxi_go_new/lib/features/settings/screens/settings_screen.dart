import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taxi_go_new/features/settings/cubit/settings_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().getSettings();
  }

  Future<void> _pickLanguage(String current) async {
    final l10n = AppLocalizations.of(context)!;

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: Row(
              children: [
                if (current == 'en') const Icon(Icons.check, size: 18),
                const SizedBox(width: 8),
                Text(l10n.settingsLanguageEnglish),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'ar'),
            child: Row(
              children: [
                if (current == 'ar') const Icon(Icons.check, size: 18),
                const SizedBox(width: 8),
                Text(l10n.settingsLanguageArabic),
              ],
            ),
          ),
        ],
      ),
    );

    if (selected != null && selected != current && mounted) {
      context.read<SettingsCubit>().updateLanguage(selected);
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsCouldNotOpenWhatsapp)),
      );
    }
  }

  Future<void> _callSupport(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsCouldNotCall)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading || state is SettingsInitial) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.settingsTitle)),
            body: const AppLoading(),
          );
        }

        if (state is SettingsLoaded) {
          final settings = state.settings;

          return Scaffold(
            appBar: AppBar(title: Text(l10n.settingsTitle)),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppSectionHeader(title: l10n.settingsGeneral),
                AppCard(
                  child: _SettingsTile(
                    icon: Icons.language_outlined,
                    title: l10n.settingsLanguage,
                    subtitle: settings.language == 'ar'
                        ? l10n.settingsLanguageArabic
                        : l10n.settingsLanguageEnglish,
                    onTap: () => _pickLanguage(settings.language),
                  ),
                ),
                AppCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.settingsDarkMode),
                    value: settings.darkMode,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().updateDarkMode(value),
                  ),
                ),
                AppCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.settingsNotifications),
                    value: settings.notificationsEnabled,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .updateNotifications(value),
                  ),
                ),
                AppSectionHeader(title: l10n.settingsAccount),
                AppCard(
                  child: _SettingsTile(
                    icon: Icons.phone_outlined,
                    title: l10n.settingsChangePhone,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const _ChangePhoneDialog(),
                    ),
                  ),
                ),
                AppSectionHeader(title: l10n.settingsSupport),
                AppCard(
                  child: _SettingsTile(
                    icon: Icons.chat_outlined,
                    title: l10n.settingsContactWhatsapp,
                    subtitle: settings.supportPhoneNumber.isEmpty
                        ? l10n.settingsNotAvailable
                        : settings.supportPhoneNumber,
                    trailingIcon: settings.whatsappContact.isEmpty
                        ? null
                        : Icons.open_in_new,
                    onTap: settings.whatsappContact.isEmpty
                        ? null
                        : () => _openLink(settings.whatsappContact),
                  ),
                ),
                AppCard(
                  child: _SettingsTile(
                    icon: Icons.call_outlined,
                    title: l10n.settingsCallSupport,
                    subtitle: settings.supportPhoneNumber.isEmpty
                        ? l10n.settingsNotAvailable
                        : settings.supportPhoneNumber,
                    trailingIcon: settings.supportPhoneNumber.isEmpty
                        ? null
                        : Icons.call,
                    onTap: settings.supportPhoneNumber.isEmpty
                        ? null
                        : () => _callSupport(settings.supportPhoneNumber),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: AppEmptyState(
            icon: Icons.settings_outlined,
            title: l10n.settingsNoneLoaded,
            actionLabel: l10n.settingsLoadAction,
            onAction: () => context.read<SettingsCubit>().getSettings(),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          Icon(
            trailingIcon ?? Icons.arrow_forward_ios_rounded,
            size: trailingIcon != null ? 18 : 14,
          ),
        ],
      ),
    );
  }
}

/// Two-step request OTP -> confirm flow against
/// `AccountController.request-change-phone`/`confirm-change-phone`. The
/// country code is fixed to `+970`, matching the rest of the app (see
/// `LoginScreen`).
class _ChangePhoneDialog extends StatefulWidget {
  const _ChangePhoneDialog();

  @override
  State<_ChangePhoneDialog> createState() => _ChangePhoneDialogState();
}

class _ChangePhoneDialogState extends State<_ChangePhoneDialog> {
  static const String _countryCode = '+970';

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthChangePhoneRequested) {
          setState(() => _otpSent = true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is AuthChangePhoneConfirmed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final l10n = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(l10n.settingsChangePhone),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(_countryCode),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _phoneController,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.phone,
                      label: l10n.settingsNewPhoneNumber,
                    ),
                  ),
                ],
              ),
              if (_otpSent) ...[
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  label: l10n.settingsOtpCode,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (!_otpSent) {
                        context.read<AuthCubit>().requestChangePhone(
                          countryCode: _countryCode,
                          phoneNumber: _phoneController.text.trim(),
                        );
                      } else {
                        context.read<AuthCubit>().confirmChangePhone(
                          countryCode: _countryCode,
                          phoneNumber: _phoneController.text.trim(),
                          token: _otpController.text.trim(),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_otpSent ? l10n.commonConfirm : l10n.settingsSendCode),
            ),
          ],
        );
      },
    );
  }
}
