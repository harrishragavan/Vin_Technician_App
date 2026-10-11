import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/providers.dart';
import '../../../core/location/location_fix.dart';
import '../../../core/location/providers.dart';
import '../data/tech_api.dart';
import '../data/tech_models.dart';

class TicketDetailState {
  const TicketDetailState({
    this.detail,
    this.isLoading = true,
    this.isActionInProgress = false,
    this.errorMessage,
    this.locationErrorMessage,
    this.otpSent,
    this.otpDeliveryStatus,
  });

  final TicketDetail? detail;
  final bool isLoading;
  final bool isActionInProgress;
  final String? errorMessage;
  final String? locationErrorMessage;
  final bool? otpSent;

  /// "SENT", "FAILED", or null while unknown/not checked yet.
  final String? otpDeliveryStatus;

  TicketDetailState copyWith({
    TicketDetail? detail,
    bool? isLoading,
    bool? isActionInProgress,
    String? errorMessage,
    bool clearError = false,
    String? locationErrorMessage,
    bool clearLocationError = false,
    bool? otpSent,
    String? otpDeliveryStatus,
  }) {
    return TicketDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      locationErrorMessage: clearLocationError
          ? null
          : (locationErrorMessage ?? this.locationErrorMessage),
      otpSent: otpSent ?? this.otpSent,
      otpDeliveryStatus: otpDeliveryStatus ?? this.otpDeliveryStatus,
    );
  }
}

final ticketDetailControllerProvider =
    NotifierProvider.family<TicketDetailController, TicketDetailState, String>(
      TicketDetailController.new,
    );

/// Owns one ticket's whole job-sheet lifecycle: load, check-in (GPS +
/// phone pick), OTP resend/status, check-out (OTP entry), mark pending.
/// One instance per ticket name (family), so switching between tickets
/// never mixes up state.
class TicketDetailController extends Notifier<TicketDetailState> {
  TicketDetailController(this.ticketName);

  final String ticketName;

  @override
  TicketDetailState build() {
    Future.microtask(refresh);
    return const TicketDetailState();
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
      final result = await api.ticket(ticketName);
      state = state.copyWith(
        detail: TicketDetail.fromJson(result),
        isLoading: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<LocationFix?> _acquireFix() async {
    try {
      final fix = await ref
          .read(locationServiceProvider)
          .getFix(reverseGeocode: true);
      state = state.copyWith(clearLocationError: true);
      return fix;
    } on LocationServiceDisabledException {
      state = state.copyWith(
        locationErrorMessage: 'Turn on location services to continue.',
      );
    } on LocationPermissionDeniedForeverException {
      state = state.copyWith(
        locationErrorMessage:
            'Location permission is blocked. Enable it in system settings.',
      );
    } on LocationPermissionDeniedException {
      state = state.copyWith(
        locationErrorMessage: 'Location permission is needed to continue.',
      );
    } on LocationTimeoutException {
      state = state.copyWith(
        locationErrorMessage: 'Could not get a GPS fix in time. Try again.',
      );
    }
    return null;
  }

  Future<void> checkIn({String selectedPhone = ''}) async {
    final api = _api;
    if (api == null || state.isActionInProgress) return;
    state = state.copyWith(isActionInProgress: true, clearError: true);

    final fix = await _acquireFix();
    if (fix == null) {
      state = state.copyWith(isActionInProgress: false);
      return;
    }

    try {
      final result = await api.checkIn(
        ticketName: ticketName,
        latitude: fix.latitude,
        longitude: fix.longitude,
        accuracy: fix.accuracyMeters,
        isMocked: fix.isMocked,
        locationAddress: fix.address ?? '',
        selectedPhone: selectedPhone,
        clientRequestId: const Uuid().v4(),
      );
      state = state.copyWith(
        detail: TicketDetail.fromJson(result['ticket'] as Map<String, dynamic>),
        isActionInProgress: false,
        otpSent: result['otp_sent'] as bool?,
      );
      if (result['otp_sent'] == true) {
        _pollOtpStatusOnce();
      }
    } on ApiException catch (error) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: error.message,
      );
    }
  }

  Future<void> _pollOtpStatusOnce() async {
    final api = _api;
    if (api == null) return;
    await Future<void>.delayed(const Duration(seconds: 3));
    try {
      final result = await api.otpStatus(ticketName);
      state = state.copyWith(otpDeliveryStatus: result['status'] as String?);
    } on ApiException {
      // Non-fatal: the status line just stays at its last known value.
    }
  }

  Future<void> resendOtp({String selectedPhone = ''}) async {
    final api = _api;
    if (api == null || state.isActionInProgress) return;
    state = state.copyWith(
      isActionInProgress: true,
      clearError: true,
      otpDeliveryStatus: null,
    );
    try {
      await api.resendOtp(
        ticketName: ticketName,
        selectedPhone: selectedPhone,
        clientRequestId: const Uuid().v4(),
      );
      state = state.copyWith(isActionInProgress: false, otpSent: true);
      _pollOtpStatusOnce();
    } on ApiException catch (error) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: error.message,
      );
    }
  }

  Future<bool> checkOut({
    required String otp,
    String modeOfPayment = '',
    String gstBillRequired = '',
  }) async {
    final api = _api;
    if (api == null || state.isActionInProgress) return false;
    state = state.copyWith(isActionInProgress: true, clearError: true);

    final fix = await _acquireFix();
    if (fix == null) {
      state = state.copyWith(isActionInProgress: false);
      return false;
    }

    try {
      final result = await api.checkOut(
        ticketName: ticketName,
        otp: otp,
        latitude: fix.latitude,
        longitude: fix.longitude,
        accuracy: fix.accuracyMeters,
        isMocked: fix.isMocked,
        locationAddress: fix.address ?? '',
        modeOfPayment: modeOfPayment,
        gstBillRequired: gstBillRequired,
        clientRequestId: const Uuid().v4(),
      );
      state = state.copyWith(
        detail: TicketDetail.fromJson(result['ticket'] as Map<String, dynamic>),
        isActionInProgress: false,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: error.message,
      );
      return false;
    }
  }

  Future<bool> markPending({
    required String reason,
    String customReason = '',
  }) async {
    final api = _api;
    if (api == null || state.isActionInProgress) return false;
    state = state.copyWith(isActionInProgress: true, clearError: true);

    final fix = await _acquireFix();
    if (fix == null) {
      state = state.copyWith(isActionInProgress: false);
      return false;
    }

    try {
      final result = await api.markPending(
        ticketName: ticketName,
        reason: reason,
        latitude: fix.latitude,
        longitude: fix.longitude,
        accuracy: fix.accuracyMeters,
        isMocked: fix.isMocked,
        locationAddress: fix.address ?? '',
        customReason: customReason,
        clientRequestId: const Uuid().v4(),
      );
      state = state.copyWith(
        detail: TicketDetail.fromJson(result['ticket'] as Map<String, dynamic>),
        isActionInProgress: false,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: error.message,
      );
      return false;
    }
  }
}
