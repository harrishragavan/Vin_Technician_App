import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/meta_options_provider.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/ticket_detail_controller.dart';
import 'otp_input.dart';

Future<void> showCompleteSheet(
  BuildContext context,
  WidgetRef ref,
  String ticketId,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CompleteSheet(ticketId: ticketId),
  );
}

class _CompleteSheet extends ConsumerStatefulWidget {
  const _CompleteSheet({required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<_CompleteSheet> createState() => _CompleteSheetState();
}

class _CompleteSheetState extends ConsumerState<_CompleteSheet> {
  final _otpKey = GlobalKey<OtpInputState>();
  String? _paymentMode;
  String? _gstRequired;

  @override
  Widget build(BuildContext context) {
    final provider = ticketDetailControllerProvider(widget.ticketId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final metaAsync = ref.watch(metaOptionsProvider);

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
          Text('Complete', style: AppTypography.heading),
          const SizedBox(height: AppSpacing.md),
          metaAsync.when(
            data: (meta) {
              final paymentModes =
                  (meta['payment_modes'] as List?)?.cast<String>() ?? const [];
              final gstOptions =
                  (meta['gst_options'] as List?)?.cast<String>() ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (paymentModes.isNotEmpty) ...[
                    Text('Payment mode', style: AppTypography.bodyStrong),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final mode in paymentModes)
                          ChoiceChip(
                            label: Text(mode),
                            selected: _paymentMode == mode,
                            onSelected: (_) =>
                                setState(() => _paymentMode = mode),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (gstOptions.isNotEmpty) ...[
                    Text('GST bill required', style: AppTypography.bodyStrong),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final option in gstOptions)
                          ChoiceChip(
                            label: Text(option),
                            selected: _gstRequired == option,
                            onSelected: (_) =>
                                setState(() => _gstRequired = option),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Center(
            child: Text(
              'Enter the customer\'s OTP',
              style: AppTypography.body.copyWith(color: context.colors.muted),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OtpInput(
            key: _otpKey,
            enabled: !state.isActionInProgress,
            onCompleted: (otp) async {
              final success = await controller.checkOut(
                otp: otp,
                modeOfPayment: _paymentMode ?? '',
                gstBillRequired: _gstRequired ?? '',
              );
              if (success && context.mounted) {
                Navigator.of(context).pop();
              } else {
                _otpKey.currentState?.clear();
              }
            },
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                state.errorMessage!,
                style: AppTypography.body.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ),
          ],
          if (state.locationErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                state.locationErrorMessage!,
                style: AppTypography.body.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ),
          ],
          if (state.isActionInProgress) ...[
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
