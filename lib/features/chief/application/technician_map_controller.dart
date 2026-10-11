import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../data/chief_api.dart';
import '../data/map_models.dart';

class TechnicianMapState {
  const TechnicianMapState({
    required this.date,
    this.selectedTechnician,
    this.markers = const [],
    this.routeVisits = const [],
    this.routeSummary,
    this.isLoading = true,
    this.errorMessage,
  });

  final DateTime date;
  final String? selectedTechnician;
  final List<MapMarkerData> markers;
  final List<RouteVisit> routeVisits;
  final RouteSummary? routeSummary;
  final bool isLoading;
  final String? errorMessage;

  bool get isRouteMode => selectedTechnician != null;

  TechnicianMapState copyWith({
    DateTime? date,
    String? selectedTechnician,
    bool clearSelectedTechnician = false,
    List<MapMarkerData>? markers,
    List<RouteVisit>? routeVisits,
    RouteSummary? routeSummary,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TechnicianMapState(
      date: date ?? this.date,
      selectedTechnician: clearSelectedTechnician
          ? null
          : (selectedTechnician ?? this.selectedTechnician),
      markers: markers ?? this.markers,
      routeVisits: routeVisits ?? this.routeVisits,
      routeSummary: routeSummary ?? this.routeSummary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final technicianMapControllerProvider =
    NotifierProvider<TechnicianMapController, TechnicianMapState>(
      TechnicianMapController.new,
    );

class TechnicianMapController extends Notifier<TechnicianMapState> {
  @override
  TechnicianMapState build() {
    Future.microtask(refresh);
    return TechnicianMapState(date: DateTime.now());
  }

  Future<void> refresh() async {
    final client = ref.read(apiClientProvider);
    if (client == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = ChiefApi(client);
      final dateStr = DateFormat('yyyy-MM-dd').format(state.date);
      final result = await api.map(
        date: dateStr,
        technician: state.selectedTechnician,
      );

      if (result['mode'] == 'technician_route') {
        state = state.copyWith(
          routeVisits: (result['visits'] as List)
              .map((e) => RouteVisit.fromJson(e as Map<String, dynamic>))
              .toList(),
          routeSummary: RouteSummary.fromJson(
            result['summary'] as Map<String, dynamic>,
          ),
          markers: const [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          markers: (result['markers'] as List)
              .map((e) => MapMarkerData.fromJson(e as Map<String, dynamic>))
              .toList(),
          routeVisits: const [],
          isLoading: false,
        );
      }
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
    refresh();
  }

  void selectTechnician(String? technician) {
    state = state.copyWith(
      selectedTechnician: technician,
      clearSelectedTechnician: technician == null,
    );
    refresh();
  }
}
