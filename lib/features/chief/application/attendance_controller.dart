import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../data/attendance_entry.dart';
import '../data/chief_api.dart';

class AttendanceState {
  const AttendanceState({
    this.entries = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<AttendanceEntry> entries;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  AttendanceState copyWith({
    List<AttendanceEntry>? entries,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AttendanceState(
      entries: entries ?? this.entries,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final attendanceControllerProvider =
    NotifierProvider<AttendanceController, AttendanceState>(
      AttendanceController.new,
    );

class AttendanceController extends Notifier<AttendanceState> {
  @override
  AttendanceState build() {
    Future.microtask(refresh);
    return const AttendanceState();
  }

  ChiefApi? get _api {
    final client = ref.read(apiClientProvider);
    if (client == null) return null;
    return ChiefApi(client);
  }

  Future<void> refresh() async {
    final api = _api;
    if (api == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await api.attendance();
      state = state.copyWith(
        entries: (result['entries'] as List)
            .map((e) => AttendanceEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
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
      final result = await api.attendance(cursor: state.nextCursor);
      final more = (result['entries'] as List)
          .map((e) => AttendanceEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        entries: [...state.entries, ...more],
        nextCursor: result['next_cursor'] as String?,
        clearNextCursor: result['next_cursor'] == null,
        hasMore: result['has_more'] as bool? ?? false,
        isLoadingMore: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoadingMore: false, errorMessage: error.message);
    }
  }
}
