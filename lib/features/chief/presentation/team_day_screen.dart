import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/team_day_controller.dart';
import '../data/team_day_models.dart';

const _dayStartHour = 8;
const _dayEndHour = 20;
const _dayMinutes = (_dayEndHour - _dayStartHour) * 60;

/// "Team day" (plan, "Chief technician dashboard" step 1): one row per
/// technician on a time axis from 08:00 to 20:00, each visit a block from
/// check-in to check-out shaded by outcome, gaps showing idle time.
class TeamDayScreen extends ConsumerWidget {
  const TeamDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamDayControllerProvider);
    final controller = ref.read(teamDayControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => controller.setDate(
                  state.date.subtract(const Duration(days: 1)),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('EEEE, d MMM').format(state.date),
                    style: AppTypography.bodyStrong,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () =>
                    controller.setDate(state.date.add(const Duration(days: 1))),
              ),
            ],
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              state.errorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : state.rows.isEmpty
              ? Center(
                  child: Text(
                    'No check-ins on this day.',
                    style: AppTypography.body.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    children: [
                      const _HourRuler(),
                      for (final row in state.rows) _TechnicianRow(row: row),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _HourRuler extends StatelessWidget {
  const _HourRuler();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 96,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          for (var hour = _dayStartHour; hour <= _dayEndHour; hour += 4)
            Expanded(
              child: Text(
                '$hour:00',
                style: AppTypography.caption.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TechnicianRow extends StatelessWidget {
  const _TechnicianRow({required this.row});

  final TeamDayRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              row.technicianName,
              style: AppTypography.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 28,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      for (final visit in row.visits)
                        _visitBlock(context, visit, constraints.maxWidth),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitBlock(
    BuildContext context,
    TeamDayVisit visit,
    double trackWidth,
  ) {
    final checkIn = _parseTimeOfDay(visit.checkIn);
    if (checkIn == null) return const SizedBox.shrink();
    final checkOut = _parseTimeOfDay(visit.checkOut);

    final startFraction = (checkIn / _dayMinutes).clamp(0.0, 1.0);
    final endMinutes = checkOut ?? _dayMinutes.toDouble();
    final endFraction = (endMinutes / _dayMinutes).clamp(0.0, 1.0);
    final widthFraction = (endFraction - startFraction).clamp(0.02, 1.0);

    final color = visit.isInProgress
        ? context.colors.signal
        : visit.status == 'Resolved'
        ? const Color(0xFF22C55E)
        : visit.status == 'Pending'
        ? const Color(0xFFF59E0B)
        : context.colors.muted;

    return Positioned(
      left: startFraction * trackWidth,
      width: widthFraction * trackWidth,
      top: 0,
      bottom: 0,
      child: Tooltip(
        message: '${visit.ticket} · ${visit.customer ?? ''}',
        child: GestureDetector(
          onTap: () {
            // Ticket detail opens here once chief.ticket exists.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${visit.ticket} · ${visit.customer ?? 'Unknown customer'}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: widthFraction > 0.08
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      visit.ticket,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// Minutes since `_dayStartHour`, or `null` if outside today/unparsable.
  double? _parseTimeOfDay(String? iso) {
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return null;
    final minutes = (dt.hour - _dayStartHour) * 60 + dt.minute;
    return minutes.toDouble();
  }
}
