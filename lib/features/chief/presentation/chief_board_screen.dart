import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../../core/models/status_option.dart';
import '../application/chief_board_controller.dart';
import '../data/board_ticket.dart';

/// "Board" (plan, "Chief technician dashboard" step 2): a status strip
/// that doubles as the status filter, search, and a cursor-paged ticket
/// list with the correct `resolved_by`. The full filter sheet (date
/// range, technician, priority, type) is a follow-up — this ships status
/// + search first since that is what the status strip already covers.
class ChiefBoardScreen extends ConsumerStatefulWidget {
  const ChiefBoardScreen({super.key});

  @override
  ConsumerState<ChiefBoardScreen> createState() => _ChiefBoardScreenState();
}

class _ChiefBoardScreenState extends ConsumerState<ChiefBoardScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chiefBoardControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(chiefBoardControllerProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chiefBoardControllerProvider);
    final controller = ref.read(chiefBoardControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search tickets, customers...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 44,
          child: _StatusStrip(
            statuses: state.statuses,
            counts: state.counts,
            totalCount: state.totalCount,
            selected: state.selectedStatus,
            onSelect: controller.setStatusFilter,
          ),
        ),
        const Divider(height: AppSpacing.md),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              state.errorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : state.tickets.isEmpty
              ? Center(
                  child: Text(
                    'No tickets match this filter.',
                    style: AppTypography.body.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: state.tickets.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= state.tickets.length) {
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
                      final ticket = state.tickets[index];
                      final status = state.statuses.firstWhere(
                        (s) => s.value == ticket.status,
                        orElse: () => StatusOption(
                          value: ticket.status,
                          label: ticket.status,
                          colorHex: '#6B7280',
                        ),
                      );
                      return _TicketRow(ticket: ticket, status: status);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.statuses,
    required this.counts,
    required this.totalCount,
    required this.selected,
    required this.onSelect,
  });

  final List<StatusOption> statuses;
  final Map<String, dynamic> counts;
  final int totalCount;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        _StatusChip(
          label: 'All',
          count: totalCount,
          color: context.colors.muted,
          selected: selected == null,
          onTap: () => onSelect(null),
        ),
        const SizedBox(width: AppSpacing.sm),
        for (final status in statuses) ...[
          _StatusChip(
            label: status.label,
            count: (counts[status.value] as num?)?.toInt() ?? 0,
            color: status.colorHex.toColor(),
            selected: selected == status.value,
            onTap: () => onSelect(status.value),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$label $count',
              style: AppTypography.bodyStrong.copyWith(
                color: selected ? context.colors.ink : context.colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket, required this.status});

  final BoardTicket ticket;
  final StatusOption status;

  @override
  Widget build(BuildContext context) {
    final location = [
      ticket.city,
      ticket.state,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: AppSpacing.statusRule,
            color: status.colorHex.toColor(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(ticket.name, style: AppTypography.mono),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        status.label,
                        style: AppTypography.caption.copyWith(
                          color: status.colorHex.toColor(),
                        ),
                      ),
                      const Spacer(),
                      if (ticket.scheduledDate != null)
                        Text(
                          _formatDate(ticket.scheduledDate!),
                          style: AppTypography.mono,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ticket.customerName ?? ticket.subject ?? ticket.name,
                    style: AppTypography.bodyStrong,
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      location,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ],
                  if (ticket.resolvedBy != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Resolved by ${ticket.resolvedBy}',
                      style: AppTypography.caption.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      return DateFormat('d MMM').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }
}
