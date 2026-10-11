class AttendanceEntry {
  const AttendanceEntry({
    required this.name,
    required this.technician,
    this.employeeName,
    this.time,
    required this.logType,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.accuracyPoor = false,
    this.deviceId,
  });

  final String name;
  final String technician;
  final String? employeeName;

  /// ISO 8601 with offset.
  final String? time;
  final String logType;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final bool accuracyPoor;
  final String? deviceId;

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      name: json['name'] as String,
      technician: json['technician'] as String? ?? '',
      employeeName: json['employee_name'] as String?,
      time: json['time'] as String?,
      logType: json['log_type'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      accuracyPoor: json['accuracy_poor'] as bool? ?? false,
      deviceId: json['device_id'] as String?,
    );
  }
}
