import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/meta_api.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/status_option.dart';
import '../data/board_ticket.dart';
import '../data/chief_api.dart';

class ChiefBoardState {
  const ChiefBoardState({
    this.statuses = const [],
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

  final List<StatusOption> statuses;
  final List<BoardTicket> tickets;
  final Map<String, dynamic> counts;
  final String? nextCursor;
  final bool hasMore;
  final String? selectedStatus;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  int get totalCount => (counts['Total'] as num?)?.toInt() ?? 0;

  ChiefBoardState copyWith({
    List<StatusOption>? statuses,
    List<BoardTicket>? tickets,
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
    return ChiefBoardState(
      statuses: statuses ?? this.statuses,
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

final chiefBoardControllerProvider =
    NotifierProvider<ChiefBoardController, ChiefBoardState>(
      ChiefBoardController.new,
    );

/// Drives the Board tab: status strip + counts, search, and a cursor-paged
/// ticket list. Holds state in memory only for now — a Drift-backed first
/// page (per the plan's "Data freshness" table) is a follow-up once the
/// rest of the chief dashboard exists to justify the caching plumbing.
class ChiefBoardController extends Notifier<ChiefBoardState> {
  @override
  ChiefBoardState build() {
    Future.microtask(refresh);
    return const ChiefBoardState();
  }

  ChiefApi? get _api {
    final client = ref.read(apiClientProvider);
    if (client == null) return null;
    return ChiefApi(client);
  }

  MetaApi? get _metaApi {
    final client = ref.read(apiClientProvider);
    if (client == null) return null;
    return MetaApi(client);
  }

  Future<void> refresh() async {
    final api = _api;
    final metaApi = _metaApi;
    if (api == null || metaApi == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        metaApi.options(),
        api.board(status: state.selectedStatus, search: state.searchQuery),
      ]);
      final metaResult = results[0];
      final boardResult = results[1];

      final statuses = (metaResult['statuses'] as List)
          .map((e) => StatusOption.fromJson(e as Map<String, dynamic>))
          .toList();
      final tickets = (boardResult['tickets'] as List)
          .map((e) => BoardTicket.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        statuses: statuses,
        tickets: tickets,
        counts: Map<String, dynamic>.from(boardResult['counts'] as Map),
        nextCursor: boardResult['next_cursor'] as String?,
        clearNextCursor: boardResult['next_cursor'] == null,
        hasMore: boardResult['has_more'] as bool? ?? false,
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
      final boardResult = await api.board(
        status: state.selectedStatus,
        search: state.searchQuery,
        cursor: state.nextCursor,
      );
      final more = (boardResult['tickets'] as List)
          .map((e) => BoardTicket.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        tickets: [...state.tickets, ...more],
        nextCursor: boardResult['next_cursor'] as String?,
        clearNextCursor: boardResult['next_cursor'] == null,
        hasMore: boardResult['has_more'] as bool? ?? false,
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
