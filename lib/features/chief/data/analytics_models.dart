class StatusCount {
  const StatusCount({required this.status, required this.count});

  final String status;
  final int count;

  factory StatusCount.fromJson(Map<String, dynamic> json) {
    return StatusCount(
      status: json['status'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class PriorityCount {
  const PriorityCount({required this.priority, required this.count});

  final String priority;
  final int count;

  factory PriorityCount.fromJson(Map<String, dynamic> json) {
    return PriorityCount(
      priority: json['priority'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.technician,
    required this.technicianName,
    required this.assigned,
    required this.resolved,
  });

  final String technician;
  final String technicianName;
  final int assigned;
  final num resolved;

  double get resolutionRate => assigned == 0 ? 0 : resolved / assigned;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      technician: json['technician'] as String? ?? '',
      technicianName: json['technician_name'] as String? ?? '',
      assigned: (json['assigned'] as num?)?.toInt() ?? 0,
      resolved: (json['resolved'] as num?) ?? 0,
    );
  }
}
