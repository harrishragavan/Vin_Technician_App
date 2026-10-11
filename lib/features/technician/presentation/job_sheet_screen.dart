import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/ticket_detail_controller.dart';
import '../data/tech_models.dart';
import 'check_in_sheet.dart';
import 'complete_sheet.dart';
import 'pending_sheet.dart';

/// Job sheet (plan, "Technician portal" step 3): ticket id/status/
/// priority, customer, call buttons, navigate, machines, spares,
/// description, check-in/out history, and a bottom action area that
/// changes with the job's state.
class JobSheetScreen extends ConsumerWidget {
  const JobSheetScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ticketDetailControllerProvider(ticketId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final detail = state.detail;

    return Scaffold(
      appBar: AppBar(title: Text(ticketId, style: AppTypography.mono)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : detail == null
          ? Center(
              child: Text(
                state.errorMessage ?? 'Could not load this ticket.',
                style: AppTypography.body.copyWith(
                  color: context.colors.danger,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        state.errorMessage!,
                        style: AppTypography.body.copyWith(
                          color: context.colors.danger,
                        ),
                      ),
                    ),
                  if (state.locationErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        state.locationErrorMessage!,
                        style: AppTypography.body.copyWith(
                          color: context.colors.danger,
                        ),
                      ),
                    ),
                  _Header(detail: detail),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  _CustomerSection(detail: detail),
                  const Divider(),
                  if (detail.machines.isNotEmpty) ...[
                    _MachinesSection(detail: detail),
                    const Divider(),
                  ] else if (detail.machineName != null) ...[
                    _LegacyMachineSection(detail: detail),
                    const Divider(),
                  ],
                  if (detail.description != null &&
                      detail.description!.isNotEmpty) ...[
                    _DescriptionSection(detail: detail),
                    const Divider(),
                  ],
                  if (detail.checkLog.isNotEmpty)
                    _CheckLogSection(detail: detail),
                ],
              ),
            ),
      bottomNavigationBar: detail == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _ActionArea(
                  ticketId: ticketId,
                  detail: detail,
                  isActionInProgress: state.isActionInProgress,
                ),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.detail});

  final TicketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(detail.status, style: AppTypography.caption),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (detail.priority != null)
              Text(
                detail.priority!,
                style: AppTypography.caption.copyWith(
                  color: context.colors.muted,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(detail.subject ?? detail.name, style: AppTypography.heading),
      ],
    );
  }
}

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.detail});

  final TicketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.customerName ?? 'Unknown customer',
            style: AppTypography.bodyStrong,
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final phone in detail.phoneNosList)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: InkWell(
                onTap: () => launchUrl(Uri.parse('tel:${phone.phone}')),
                child: Row(
                  children: [
                    Icon(Icons.call, size: 16, color: context.colors.signal),
                    const SizedBox(width: AppSpacing.xs),
                    Text(phone.phone, style: AppTypography.mono),
                    if (phone.isPrimary) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'primary',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (detail.address != null && detail.address!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () {
                final query = Uri.encodeComponent(
                  [
                    detail.address,
                    detail.city,
                    detail.state,
                  ].where((p) => p != null && p.isNotEmpty).join(', '),
                );
                launchUrl(
                  Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$query',
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.navigation_outlined,
                    size: 16,
                    color: context.colors.signal,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      [
                        detail.address,
                        detail.city,
                        detail.state,
                      ].where((p) => p != null && p.isNotEmpty).join(', '),
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MachinesSection extends StatelessWidget {
  const _MachinesSection({required this.detail});

  final TicketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Machines', style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.xs),
          for (final machine in detail.machines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '${machine.machineName ?? machine.machineType ?? 'Machine'}'
                '${machine.machineQuantity != null ? ' x${machine.machineQuantity}' : ''}'
                '${machine.machineProblem != null ? ' — ${machine.machineProblem}' : ''}',
                style: AppTypography.body,
              ),
            ),
        ],
      ),
    );
  }
}

class _LegacyMachineSection extends StatelessWidget {
  const _LegacyMachineSection({required this.detail});

  final TicketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.machineName ?? '', style: AppTypography.bodyStrong),
          if (detail.machineProblem != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(detail.machineProblem!, style: AppTypography.body),
          ],
          if (detail.requiredSpares != null &&
              detail.requiredSpares!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Spares: ${detail.requiredSpares}',
              style: AppTypography.caption.copyWith(
                color: context.colors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.detail});

  final TicketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(detail.description!, style: AppTypography.body),
    );
  }
}

class _CheckLogSection extends StatelessWidget {
  const _CheckLogSection({required this.detail});

  final TicketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Check-in / check-out history', style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.xs),
          for (final log in detail.checkLog)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    log.checkType == 'Check-in' ? Icons.login : Icons.logout,
                    size: 16,
                    color: context.colors.muted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(log.checkType, style: AppTypography.body),
                  const SizedBox(width: AppSpacing.xs),
                  if (log.timestamp != null)
                    Text(
                      DateFormat('d MMM, HH:mm')
                          .format(DateTime.parse(log.timestamp!)),
                      style: AppTypography.mono,
                    ),
                  if (log.isMocked) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.warning_amber,
                      size: 14,
                      color: context.colors.danger,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionArea extends ConsumerWidget {
  const _ActionArea({
    required this.ticketId,
    required this.detail,
    required this.isActionInProgress,
  });

  final String ticketId;
  final TicketDetail detail;
  final bool isActionInProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (detail.status == 'Working') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isActionInProgress
                  ? null
                  : () => showPendingSheet(context, ref, ticketId),
              child: const Text('Pending'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isActionInProgress
                  ? null
                  : () => showCompleteSheet(context, ref, ticketId),
              child: const Text('Complete'),
            ),
          ),
        ],
      );
    }

    if (detail.status == 'Resolved' || detail.status == 'Self-Completed') {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.receipt_long_outlined),
        label: const Text('Create invoice — coming soon'),
      );
    }

    // Open, Pending, or anything else assignable: Check in. The actual
    // hold-to-confirm happens inside the sheet, after the OTP phone is
    // picked — this button just opens it.
    return FilledButton.icon(
      onPressed: isActionInProgress
          ? null
          : () => showCheckInSheet(context, ref, ticketId),
      icon: const Icon(Icons.login),
      label: Text(detail.status == 'Pending' ? 'Resume job' : 'Check in'),
    );
  }
}
