import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/design/hold_to_confirm_button.dart';
import '../application/tech_home_controller.dart';
import '../data/tech_models.dart';

/// "Today" (plan, "Technician portal" step 1): the day bar, the active
/// job if one is Working, and today's jobs (scheduled today, plus any
/// Working/Pending carried over).
class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(techHomeControllerProvider);
    final controller = ref.read(techHomeControllerProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
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
          _DayBar(state: state, controller: controller),
          if (state.activeTicket != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ActiveJobCard(ticket: state.activeTicket!),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text("Today's jobs", style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          if (state.todayTickets.isEmpty)
            Text(
              'Nothing scheduled today.',
              style: AppTypography.body.copyWith(color: context.colors.muted),
            )
          else
            for (final ticket in state.todayTickets) _JobRow(ticket: ticket),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.state, required this.controller});

  final TechHomeState state;
  final TechHomeController controller;

  @override
  Widget build(BuildContext context) {
    final isIn = state.attendance?.isCheckedIn ?? false;
    final time = state.attendance?.time != null
        ? DateTime.tryParse(state.attendance!.time!)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isIn && time != null) ...[
            Text(
              'Day started at ${DateFormat('HH:mm').format(time)}',
              style: AppTypography.bodyStrong,
            ),
            if (state.attendance?.accuracy != null)
              Text(
                'GPS accuracy ${state.attendance!.accuracy!.toStringAsFixed(0)} m',
                style: AppTypography.caption.copyWith(
                  color: context.colors.muted,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
          HoldToConfirmButton(
            label: isIn ? 'Hold to end day' : 'Hold to start day',
            icon: isIn ? Icons.logout : Icons.login,
            isLoading: state.isTogglingAttendance,
            onConfirmed: controller.toggleDay,
          ),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.ticket});

  final TechTicketSummary ticket;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/technician/ticket/${ticket.name}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.signal, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Working',
                    style: AppTypography.caption.copyWith(
                      color: context.colors.signal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(ticket.name, style: AppTypography.mono),
                  Text(
                    ticket.customerName ?? ticket.subject ?? '',
                    style: AppTypography.bodyStrong,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.ticket});

  final TechTicketSummary ticket;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/technician/ticket/${ticket.name}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(ticket.name, style: AppTypography.mono),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        ticket.status,
                        style: AppTypography.caption.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    ticket.customerName ?? ticket.subject ?? ticket.name,
                    style: AppTypography.bodyStrong,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}
