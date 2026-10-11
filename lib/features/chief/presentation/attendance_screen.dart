import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/attendance_controller.dart';
import '../data/attendance_entry.dart';

/// "Attendance" (plan, step 5): per technician and day, IN/OUT times, a
/// warning when GPS accuracy is poor, and the device.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(attendanceControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceControllerProvider);
    final controller = ref.read(attendanceControllerProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state.entries.isEmpty) {
      return Center(
        child: Text(
          'No attendance records.',
          style: AppTypography.body.copyWith(color: context.colors.muted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.entries.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= state.entries.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _AttendanceRow(entry: state.entries[index]);
        },
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.entry});

  final AttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final isIn = entry.logType == 'IN';
    final time = entry.time != null ? DateTime.tryParse(entry.time!) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.statusRule,
            height: 36,
            color: isIn ? const Color(0xFF22C55E) : context.colors.muted,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.employeeName ?? entry.technician,
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      entry.logType,
                      style: AppTypography.caption.copyWith(
                        color: isIn
                            ? const Color(0xFF22C55E)
                            : context.colors.muted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    if (time != null)
                      Text(
                        DateFormat('d MMM, HH:mm').format(time),
                        style: AppTypography.mono,
                      ),
                    if (entry.deviceId != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '· ${entry.deviceId}',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (entry.accuracyPoor)
            Tooltip(
              message: 'Accuracy: ${entry.accuracy?.toStringAsFixed(0)} m',
              child: Icon(
                Icons.location_disabled,
                size: 18,
                color: context.colors.danger,
              ),
            ),
        ],
      ),
    );
  }
}
