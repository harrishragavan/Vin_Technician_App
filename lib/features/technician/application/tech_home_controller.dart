import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../../../core/location/location_fix.dart';
import '../../../core/location/providers.dart';
import '../data/tech_api.dart';
import '../data/tech_models.dart';

class TechHomeState {
  const TechHomeState({
    this.attendance,
    this.activeTicket,
    this.todayTickets = const [],
    this.counts = const {},
    this.isLoading = true,
    this.isTogglingAttendance = false,
    this.errorMessage,
    this.locationErrorMessage,
  });

  final AttendanceState? attendance;
  final TechTicketSummary? activeTicket;
  final List<TechTicketSummary> todayTickets;
  final Map<String, dynamic> counts;
  final bool isLoading;
  final bool isTogglingAttendance;
  final String? errorMessage;
  final String? locationErrorMessage;

  TechHomeState copyWith({
    AttendanceState? attendance,
    TechTicketSummary? activeTicket,
    bool clearActiveTicket = false,
    List<TechTicketSummary>? todayTickets,
    Map<String, dynamic>? counts,
    bool? isLoading,
    bool? isTogglingAttendance,
    String? errorMessage,
    bool clearError = false,
    String? locationErrorMessage,
    bool clearLocationError = false,
  }) {
    return TechHomeState(
      attendance: attendance ?? this.attendance,
      activeTicket: clearActiveTicket
          ? null
          : (activeTicket ?? this.activeTicket),
      todayTickets: todayTickets ?? this.todayTickets,
      counts: counts ?? this.counts,
      isLoading: isLoading ?? this.isLoading,
      isTogglingAttendance: isTogglingAttendance ?? this.isTogglingAttendance,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      locationErrorMessage: clearLocationError
          ? null
          : (locationErrorMessage ?? this.locationErrorMessage),
    );
  }
}

final techHomeControllerProvider =
    NotifierProvider<TechHomeController, TechHomeState>(TechHomeController.new);

class TechHomeController extends Notifier<TechHomeState> {
  @override
  TechHomeState build() {
    Future.microtask(refresh);
    return const TechHomeState();
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
      final result = await api.home();
      final activeJson = result['active_ticket'] as Map<String, dynamic>?;
      state = state.copyWith(
        attendance: AttendanceState.fromJson(
          result['attendance'] as Map<String, dynamic>,
        ),
        activeTicket: activeJson != null
            ? TechTicketSummary.fromJson(activeJson)
            : null,
        clearActiveTicket: activeJson == null,
        todayTickets: (result['today_tickets'] as List)
            .map((e) => TechTicketSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        counts: Map<String, dynamic>.from(result['counts'] as Map),
        isLoading: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<void> toggleDay() async {
    final api = _api;
    if (api == null || state.isTogglingAttendance) return;
    final nextLogType = (state.attendance?.isCheckedIn ?? false) ? 'OUT' : 'IN';

    state = state.copyWith(
      isTogglingAttendance: true,
      clearError: true,
      clearLocationError: true,
    );

    LocationFix fix;
    try {
      fix = await ref.read(locationServiceProvider).getFix();
    } on LocationServiceDisabledException {
      state = state.copyWith(
        isTogglingAttendance: false,
        locationErrorMessage: 'Turn on location services to start your day.',
      );
      return;
    } on LocationPermissionDeniedForeverException {
      state = state.copyWith(
        isTogglingAttendance: false,
        locationErrorMessage:
            'Location permission is blocked. Enable it in system settings.',
      );
      return;
    } on LocationPermissionDeniedException {
      state = state.copyWith(
        isTogglingAttendance: false,
        locationErrorMessage:
            'Location permission is needed to start your day.',
      );
      return;
    } on LocationTimeoutException {
      state = state.copyWith(
        isTogglingAttendance: false,
        locationErrorMessage: 'Could not get a GPS fix in time. Try again.',
      );
      return;
    }

    try {
      final result = await api.attendance(
        logType: nextLogType,
        latitude: fix.latitude,
        longitude: fix.longitude,
        accuracy: fix.accuracyMeters,
        isMocked: fix.isMocked,
        clientRequestId: const Uuid().v4(),
      );
      state = state.copyWith(
        attendance: AttendanceState.fromJson(result),
        isTogglingAttendance: false,
      );
      refresh();
    } on ApiException catch (error) {
      state = state.copyWith(
        isTogglingAttendance: false,
        errorMessage: error.message,
      );
    }
  }
}
