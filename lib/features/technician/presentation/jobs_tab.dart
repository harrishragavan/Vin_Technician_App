import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/tech_jobs_controller.dart';
import '../data/tech_models.dart';

/// "Jobs" (plan, "Technician portal" step 2): search, a status filter
/// strip, and a list grouped loosely by status with pagination. The
/// calendar view is a follow-up.
class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});

  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
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
      ref.read(techJobsControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(techJobsControllerProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(techJobsControllerProvider);
    final controller = ref.read(techJobsControllerProvider.notifier);
    final statuses = state.counts.keys.where((k) => k != 'Total').toList();

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
              hintText: 'Search jobs, customers...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _FilterChip(
                label: 'All (${state.totalCount})',
                selected: state.selectedStatus == null,
                onTap: () => controller.setStatusFilter(null),
              ),
              const SizedBox(width: AppSpacing.sm),
              for (final status in statuses) ...[
                _FilterChip(
                  label: '$status (${state.counts[status]})',
                  selected: state.selectedStatus == status,
                  onTap: () => controller.setStatusFilter(status),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
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
                    'No jobs match this filter.',
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
                      return _TicketRow(ticket: state.tickets[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
              color: selected ? context.colors.signal : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyStrong.copyWith(
            color: selected ? context.colors.ink : context.colors.muted,
          ),
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final TechTicketSummary ticket;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/technician/ticket/${ticket.name}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ticket.customerName ?? ticket.subject ?? ticket.name,
                    style: AppTypography.bodyStrong,
                  ),
                  if (ticket.city != null)
                    Text(
                      ticket.city!,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.muted,
                      ),
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
