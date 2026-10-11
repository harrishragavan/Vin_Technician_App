import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../data/chief_api.dart';
import '../data/team_day_models.dart';

class TeamDayState {
  const TeamDayState({
    required this.date,
    this.rows = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final DateTime date;
  final List<TeamDayRow> rows;
  final bool isLoading;
  final String? errorMessage;

  TeamDayState copyWith({
    DateTime? date,
    List<TeamDayRow>? rows,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeamDayState(
      date: date ?? this.date,
      rows: rows ?? this.rows,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final teamDayControllerProvider =
    NotifierProvider<TeamDayController, TeamDayState>(TeamDayController.new);

class TeamDayController extends Notifier<TeamDayState> {
  @override
  TeamDayState build() {
    Future.microtask(refresh);
    return TeamDayState(date: DateTime.now());
  }

  Future<void> refresh() async {
    final client = ref.read(apiClientProvider);
    if (client == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ChiefApi(client)
          .teamDay(date: DateFormat('yyyy-MM-dd').format(state.date));
      final rows = (result['technicians'] as List)
          .map((e) => TeamDayRow.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(rows: rows, isLoading: false);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
    refresh();
  }
}
