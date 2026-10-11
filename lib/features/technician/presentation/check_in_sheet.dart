import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/hold_to_confirm_button.dart';
import '../application/ticket_detail_controller.dart';

Future<void> showCheckInSheet(
  BuildContext context,
  WidgetRef ref,
  String ticketId,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CheckInSheet(ticketId: ticketId),
  );
}

class _CheckInSheet extends ConsumerStatefulWidget {
  const _CheckInSheet({required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<_CheckInSheet> {
  String? _selectedPhone;

  @override
  Widget build(BuildContext context) {
    final provider = ticketDetailControllerProvider(widget.ticketId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final detail = state.detail;
    if (detail == null) return const SizedBox.shrink();

    _selectedPhone ??=
        detail.primaryPhone ??
        (detail.phoneNosList.isEmpty ? null : detail.phoneNosList.first.phone);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Check in', style: AppTypography.heading),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "OTP goes to the customer's phone on file.",
            style: AppTypography.body.copyWith(color: context.colors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          RadioGroup<String>(
            groupValue: _selectedPhone,
            onChanged: (value) => setState(() => _selectedPhone = value),
            child: Column(
              children: [
                for (final phone in detail.phoneNosList)
                  RadioListTile<String>(
                    value: phone.phone,
                    title: Text(phone.phone, style: AppTypography.mono),
                    subtitle: phone.isPrimary ? const Text('Primary') : null,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ),
          ),
          if (detail.phoneNosList.isEmpty)
            Text(
              'No phone number on file for this customer.',
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          if (state.locationErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.locationErrorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          HoldToConfirmButton(
            label: 'Hold to check in',
            icon: Icons.login,
            isLoading: state.isActionInProgress,
            enabled: _selectedPhone != null,
            onConfirmed: () async {
              await controller.checkIn(selectedPhone: _selectedPhone ?? '');
              if (context.mounted && ref.read(provider).errorMessage == null) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
