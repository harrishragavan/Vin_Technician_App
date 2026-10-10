import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;

import 'location_fix.dart';

/// Foreground-only, high-accuracy fixes for check-in/check-out and
/// attendance. No background location is ever requested — the plan calls
/// this out specifically so the app avoids Play's background-location
/// review.
class LocationService {
  const LocationService();

  static final _geocoding = Geocoding();

  /// Takes a fix, retrying up to [maxRetries] times while accuracy is
  /// worse than [accuracyLimitMeters] (the server default, from Vin Chakra
  /// Mobile Settings). Hard stops at 15 s total per the performance budget.
  Future<LocationFix> getFix({
    double accuracyLimitMeters = 100,
    int maxRetries = 2,
    bool reverseGeocode = false,
  }) async {
    await _ensurePermission();

    Position? best;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      final position = await _getPosition();
      if (best == null || position.accuracy < best.accuracy) {
        best = position;
      }
      if (position.accuracy <= accuracyLimitMeters) break;
    }

    String? address;
    if (reverseGeocode && best != null) {
      address = await _reverseGeocode(best.latitude, best.longitude);
    }

    return LocationFix(
      latitude: best!.latitude,
      longitude: best.longitude,
      accuracyMeters: best.accuracy,
      isMocked: best.isMocked,
      capturedAt: DateTime.now(),
      address: address,
    );
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationServiceDisabledException();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }
    if (permission == LocationPermission.denied) {
      throw LocationPermissionDeniedException();
    }
  }

  Future<Position> _getPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw LocationTimeoutException();
    }
  }

  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      return [
        p.street,
        p.subLocality,
        p.locality,
      ].where((part) => part != null && part.isNotEmpty).join(', ');
    } catch (_) {
      // Non-fatal: the ticket check-in still has coordinates without a
      // human-readable address.
      return null;
    }
  }
}
