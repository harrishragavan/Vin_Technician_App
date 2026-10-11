import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../data/analytics_models.dart';
import '../data/chief_api.dart';

class AnalyticsState {
  const AnalyticsState({
    this.statusSummary = const [],
    this.prioritySummary = const [],
    this.leaderboard = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<StatusCount> statusSummary;
  final List<PriorityCount> prioritySummary;
  final List<LeaderboardEntry> leaderboard;
  final bool isLoading;
  final String? errorMessage;

  AnalyticsState copyWith({
    List<StatusCount>? statusSummary,
    List<PriorityCount>? prioritySummary,
    List<LeaderboardEntry>? leaderboard,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnalyticsState(
      statusSummary: statusSummary ?? this.statusSummary,
      prioritySummary: prioritySummary ?? this.prioritySummary,
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final analyticsControllerProvider =
    NotifierProvider<AnalyticsController, AnalyticsState>(
      AnalyticsController.new,
    );

class AnalyticsController extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    Future.microtask(refresh);
    return const AnalyticsState();
  }

  Future<void> refresh() async {
    final client = ref.read(apiClientProvider);
    if (client == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ChiefApi(client).analytics();
      state = state.copyWith(
        statusSummary: (result['status_summary'] as List)
            .map((e) => StatusCount.fromJson(e as Map<String, dynamic>))
            .toList(),
        prioritySummary: (result['priority_summary'] as List)
            .map((e) => PriorityCount.fromJson(e as Map<String, dynamic>))
            .toList(),
        leaderboard: (result['leaderboard'] as List)
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        isLoading: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }
}
