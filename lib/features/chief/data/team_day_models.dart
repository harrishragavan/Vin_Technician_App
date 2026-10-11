class TeamDayVisit {
  const TeamDayVisit({
    required this.ticket,
    this.customer,
    this.status,
    this.checkIn,
    this.checkOut,
  });

  final String ticket;
  final String? customer;
  final String? status;

  /// ISO 8601 with offset, or `null` if this visit has no check-in log
  /// (shouldn't happen) or is still in progress (for `checkOut`).
  final String? checkIn;
  final String? checkOut;

  factory TeamDayVisit.fromJson(Map<String, dynamic> json) {
    return TeamDayVisit(
      ticket: json['ticket'] as String? ?? '',
      customer: json['customer'] as String?,
      status: json['status'] as String?,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
    );
  }

  bool get isInProgress => checkIn != null && checkOut == null;
}

class TeamDayRow {
  const TeamDayRow({
    required this.technician,
    required this.technicianName,
    required this.visits,
  });

  final String technician;
  final String technicianName;
  final List<TeamDayVisit> visits;

  factory TeamDayRow.fromJson(Map<String, dynamic> json) {
    return TeamDayRow(
      technician: json['technician'] as String? ?? '',
      technicianName: json['technician_name'] as String? ?? '',
      visits: (json['visits'] as List)
          .map((e) => TeamDayVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
