/// A single GPS reading, shaped to match what the server expects on every
/// check-in/check-out/attendance call: latitude, longitude, accuracy and
/// the fake-GPS flag (plan, "Stack decisions → Location").
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.isMocked,
    required this.capturedAt,
    this.address,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;

  /// From a fake-GPS app — sent to the server on every fix so Attendance
  /// can flag it (plan, "Screens → Attendance").
  final bool isMocked;

  final DateTime capturedAt;

  /// Reverse-geocoded address; the web never sends one today, so this is
  /// additive and callers should treat `null` as acceptable.
  final String? address;

  bool get isStale =>
      DateTime.now().difference(capturedAt) > const Duration(minutes: 2);

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracyMeters,
    'is_mocked': isMocked,
    if (address != null) 'location_address': address,
  };
}

class LocationServiceDisabledException implements Exception {}

class LocationPermissionDeniedException implements Exception {}

/// Denied for good — the caller should link to system settings instead of
/// asking again (plan, "Screens → Technician portal").
class LocationPermissionDeniedForeverException implements Exception {}

/// No fix within the hard stop (plan, "Performance budget": 15 s).
class LocationTimeoutException implements Exception {}
