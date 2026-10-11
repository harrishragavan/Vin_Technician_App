class MapMarkerData {
  const MapMarkerData({
    required this.technician,
    required this.technicianName,
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.ticket,
    this.customer,
    this.address,
  });

  final String technician;
  final String technicianName;
  final double latitude;
  final double longitude;
  final String? timestamp;
  final String? ticket;
  final String? customer;
  final String? address;

  factory MapMarkerData.fromJson(Map<String, dynamic> json) {
    return MapMarkerData(
      technician: json['technician'] as String? ?? '',
      technicianName: json['technician_name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] as String?,
      ticket: json['ticket'] as String?,
      customer: json['customer'] as String?,
      address: json['address'] as String?,
    );
  }
}

class RouteVisit {
  const RouteVisit({
    required this.ticket,
    required this.latitude,
    required this.longitude,
    this.customer,
    this.status,
    this.checkIn,
    this.checkOut,
    this.address,
  });

  final String ticket;
  final double latitude;
  final double longitude;
  final String? customer;
  final String? status;
  final String? checkIn;
  final String? checkOut;
  final String? address;

  factory RouteVisit.fromJson(Map<String, dynamic> json) {
    return RouteVisit(
      ticket: json['ticket'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      customer: json['customer'] as String?,
      status: json['status'] as String?,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      address: json['address'] as String?,
    );
  }
}

class RouteSummary {
  const RouteSummary({
    required this.totalVisits,
    this.firstCheckIn,
    this.lastCheckOut,
    required this.totalDurationSeconds,
    required this.avgTimeSeconds,
  });

  final int totalVisits;
  final String? firstCheckIn;
  final String? lastCheckOut;
  final double totalDurationSeconds;
  final double avgTimeSeconds;

  factory RouteSummary.fromJson(Map<String, dynamic> json) {
    return RouteSummary(
      totalVisits: (json['total_visits'] as num?)?.toInt() ?? 0,
      firstCheckIn: json['first_check_in'] as String?,
      lastCheckOut: json['last_check_out'] as String?,
      totalDurationSeconds:
          (json['total_duration_seconds'] as num?)?.toDouble() ?? 0,
      avgTimeSeconds: (json['avg_time_seconds'] as num?)?.toDouble() ?? 0,
    );
  }
}
