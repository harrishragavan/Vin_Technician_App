import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/analytics_controller.dart';
import '../data/analytics_models.dart';

const _palette = [
  Color(0xFFE4572E),
  Color(0xFF3B82F6),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
  Color(0xFFA855F7),
  Color(0xFF14B8A6),
  Color(0xFFEC4899),
  Color(0xFF6B7280),
];

/// "Analytics" (plan, step 4): status split as one stacked bar, priority
/// as bars, a resolved-over-assigned leaderboard. Built with plain
/// fractional-width containers rather than a chart library or
/// CustomPainter — three bars this simple don't justify either.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsControllerProvider);
    final controller = ref.read(analyticsControllerProvider.notifier);

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
          Text('Status split', style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          _StackedBar(data: state.statusSummary),
          const SizedBox(height: AppSpacing.lg),
          Text('Priority', style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          _PriorityBars(data: state.prioritySummary),
          const SizedBox(height: AppSpacing.lg),
          Text('Leaderboard', style: AppTypography.heading),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Chief Technicians are excluded — auto-assignment puts them on every ticket.',
            style: AppTypography.caption.copyWith(color: context.colors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.leaderboard.isEmpty)
            Text(
              'No data for this range.',
              style: AppTypography.body.copyWith(color: context.colors.muted),
            )
          else
            for (final entry in state.leaderboard)
              _LeaderboardRow(entry: entry),
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.data});

  final List<StatusCount> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, item) => sum + item.count);
    if (total == 0) {
      return Text(
        'No tickets in range.',
        style: AppTypography.body.copyWith(color: context.colors.muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                for (var i = 0; i < data.length; i++)
                  Expanded(
                    flex: data[i].count,
                    child: Container(color: _palette[i % _palette.length]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < data.length; i++)
              _Legend(
                color: _palette[i % _palette.length],
                label: '${data[i].status} (${data[i].count})',
              ),
          ],
        ),
      ],
    );
  }
}

class _PriorityBars extends StatelessWidget {
  const _PriorityBars({required this.data});

  final List<PriorityCount> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Text(
        'No tickets in range.',
        style: AppTypography.body.copyWith(color: context.colors.muted),
      );
    }
    final maxCount = data.map((e) => e.count).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final item in data)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(item.priority, style: AppTypography.body),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final fraction = maxCount == 0
                            ? 0.0
                            : item.count / maxCount;
                        return Stack(
                          children: [
                            Container(
                              height: 16,
                              color: context.colors.surfaceAlt,
                            ),
                            Container(
                              height: 16,
                              width: constraints.maxWidth * fraction,
                              color: context.colors.signal,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.count}',
                    style: AppTypography.mono,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: context.colors.muted),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              entry.technicianName,
              style: AppTypography.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(height: 16, color: context.colors.surfaceAlt),
                      Container(
                        height: 16,
                        width:
                            constraints.maxWidth *
                            entry.resolutionRate.clamp(0.0, 1.0),
                        color: const Color(0xFF22C55E),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 56,
            child: Text(
              '${entry.resolved.toStringAsFixed(0)}/${entry.assigned}',
              style: AppTypography.mono.copyWith(fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
