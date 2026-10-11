import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../data/tech_api.dart';
import '../data/tech_models.dart';

class TechJobsState {
  const TechJobsState({
    this.tickets = const [],
    this.counts = const {},
    this.nextCursor,
    this.hasMore = false,
    this.selectedStatus,
    this.searchQuery = '',
    this.isLoading = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<TechTicketSummary> tickets;
  final Map<String, dynamic> counts;
  final String? nextCursor;
  final bool hasMore;
  final String? selectedStatus;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  int get totalCount => (counts['Total'] as num?)?.toInt() ?? 0;

  TechJobsState copyWith({
    List<TechTicketSummary>? tickets,
    Map<String, dynamic>? counts,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    String? selectedStatus,
    bool clearSelectedStatus = false,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TechJobsState(
      tickets: tickets ?? this.tickets,
      counts: counts ?? this.counts,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      selectedStatus: clearSelectedStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final techJobsControllerProvider =
    NotifierProvider<TechJobsController, TechJobsState>(TechJobsController.new);

class TechJobsController extends Notifier<TechJobsState> {
  @override
  TechJobsState build() {
    Future.microtask(refresh);
    return const TechJobsState();
  }

  TechApi? get _api {
    final client = ref.read(apiClientProvider);
    if (client == null) return null;
    return TechApi(client);
  }

  Future<void> refresh() async {
    final api = _api;
    if (api == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await api.tickets(
        status: state.selectedStatus,
        search: state.searchQuery,
      );
      state = state.copyWith(
        tickets: (result['tickets'] as List)
            .map((e) => TechTicketSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        counts: Map<String, dynamic>.from(result['counts'] as Map),
        nextCursor: result['next_cursor'] as String?,
        clearNextCursor: result['next_cursor'] == null,
        hasMore: result['has_more'] as bool? ?? false,
        isLoading: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<void> loadMore() async {
    final api = _api;
    if (api == null || !state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await api.tickets(
        status: state.selectedStatus,
        search: state.searchQuery,
        cursor: state.nextCursor,
      );
      final more = (result['tickets'] as List)
          .map((e) => TechTicketSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        tickets: [...state.tickets, ...more],
        nextCursor: result['next_cursor'] as String?,
        clearNextCursor: result['next_cursor'] == null,
        hasMore: result['has_more'] as bool? ?? false,
        isLoadingMore: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoadingMore: false, errorMessage: error.message);
    }
  }

  void setStatusFilter(String? status) {
    final next = state.selectedStatus == status ? null : status;
    state = state.copyWith(
      selectedStatus: next,
      clearSelectedStatus: next == null,
    );
    refresh();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    refresh();
  }
}
