import 'package:flutter/material.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'app_button.dart';
import 'app_status_chip.dart';

enum _BlockDuration { oneDay, sevenDays, thirtyDays, permanent }

/// Account-status chips (Active/Inactive, Blocked/Not blocked) plus the two
/// admin actions every protected user (driver or passenger) needs: toggle
/// active/inactive, and block (with a duration) / unblock. Shared by the
/// admin driver and passenger detail dialogs so both stay visually and
/// behaviorally identical.
class UserStatusActions extends StatelessWidget {
  final bool isActive;
  final bool isBlocked;
  final Future<void> Function() onToggleActive;
  final Future<void> Function({String? reason, DateTime? endsAt})
  onToggleBlock;

  const UserStatusActions({
    super.key,
    required this.isActive,
    required this.isBlocked,
    required this.onToggleActive,
    required this.onToggleBlock,
  });

  Future<void> _confirmToggleActive(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isActive ? l10n.userStatusDeactivateTitle : l10n.userStatusActivateTitle),
        content: Text(
          isActive ? l10n.userStatusDeactivateConfirm : l10n.userStatusActivateConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isActive ? l10n.userStatusDeactivate : l10n.userStatusActivate),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onToggleActive();
    }
  }

  Future<void> _confirmUnblock(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.userStatusUnblockTitle),
        content: Text(l10n.userStatusUnblockConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.userStatusUnblock),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onToggleBlock();
    }
  }

  Future<void> _showBlockDialog(BuildContext context) async {
    _BlockDuration duration = _BlockDuration.sevenDays;
    final reasonCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.userStatusBlockTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<_BlockDuration>(
                    initialValue: duration,
                    decoration: InputDecoration(labelText: l10n.userStatusDuration),
                    items: [
                      DropdownMenuItem(
                        value: _BlockDuration.oneDay,
                        child: Text(l10n.userStatusOneDay),
                      ),
                      DropdownMenuItem(
                        value: _BlockDuration.sevenDays,
                        child: Text(l10n.userStatusSevenDays),
                      ),
                      DropdownMenuItem(
                        value: _BlockDuration.thirtyDays,
                        child: Text(l10n.userStatusThirtyDays),
                      ),
                      DropdownMenuItem(
                        value: _BlockDuration.permanent,
                        child: Text(l10n.userStatusPermanent),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => duration = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.commonReasonOptional,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.userStatusBlock),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    DateTime? endsAt;
    final now = DateTime.now();
    switch (duration) {
      case _BlockDuration.oneDay:
        endsAt = now.add(const Duration(days: 1));
      case _BlockDuration.sevenDays:
        endsAt = now.add(const Duration(days: 7));
      case _BlockDuration.thirtyDays:
        endsAt = now.add(const Duration(days: 30));
      case _BlockDuration.permanent:
        endsAt = null;
    }

    final reason = reasonCtrl.text.trim();
    await onToggleBlock(reason: reason.isEmpty ? null : reason, endsAt: endsAt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppStatusChip(
              label: isActive ? l10n.commonActive : l10n.commonInactive,
              tone: isActive ? AppStatusTone.success : AppStatusTone.neutral,
            ),
            AppStatusChip(
              label: isBlocked ? l10n.commonBlocked : l10n.userStatusNotBlocked,
              tone: isBlocked ? AppStatusTone.error : AppStatusTone.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppSecondaryButton(
              label: isActive ? l10n.userStatusDeactivate : l10n.userStatusActivate,
              icon: isActive ? Icons.block_outlined : Icons.check_circle_outline,
              expand: false,
              onPressed: () => _confirmToggleActive(context),
            ),
            AppSecondaryButton(
              label: isBlocked ? l10n.userStatusUnblock : l10n.userStatusBlock,
              icon: isBlocked ? Icons.lock_open_outlined : Icons.lock_outline,
              expand: false,
              onPressed: isBlocked
                  ? () => _confirmUnblock(context)
                  : () => _showBlockDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}
