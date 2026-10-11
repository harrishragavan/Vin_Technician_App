import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/hold_to_confirm_button.dart';
import '../application/ticket_detail_controller.dart';

Future<void> showPendingSheet(
  BuildContext context,
  WidgetRef ref,
  String ticketId,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PendingSheet(ticketId: ticketId),
  );
}

class _PendingSheet extends ConsumerStatefulWidget {
  const _PendingSheet({required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<_PendingSheet> createState() => _PendingSheetState();
}

class _PendingSheetState extends ConsumerState<_PendingSheet> {
  String? _reason;
  final _customReasonController = TextEditingController();

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ticketDetailControllerProvider(widget.ticketId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final detail = state.detail;
    if (detail == null) return const SizedBox.shrink();

    final isOthers = _reason == 'Others';
    final canConfirm =
        _reason != null &&
        (!isOthers || _customReasonController.text.trim().isNotEmpty);

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
          Text('Mark pending', style: AppTypography.heading),
          const SizedBox(height: AppSpacing.md),
          RadioGroup<String>(
            groupValue: _reason,
            onChanged: (value) => setState(() => _reason = value),
            child: Column(
              children: [
                for (final reason in detail.pendingReasonOptions)
                  RadioListTile<String>(
                    value: reason,
                    title: Text(reason),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ),
          ),
          if (isOthers) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _customReasonController,
              decoration: const InputDecoration(labelText: 'Note'),
              onChanged: (_) => setState(() {}),
            ),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ],
          if (state.locationErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.locationErrorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          HoldToConfirmButton(
            label: 'Hold to mark pending',
            icon: Icons.pause_circle_outline,
            isLoading: state.isActionInProgress,
            enabled: canConfirm,
            onConfirmed: () async {
              final success = await controller.markPending(
                reason: _reason ?? '',
                customReason: _customReasonController.text.trim(),
              );
              if (success && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
