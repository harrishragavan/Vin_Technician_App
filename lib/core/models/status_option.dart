/// One row of `meta.options.statuses` — a server-defined HD Ticket
/// Status, never hard-coded in the app (plan: "Ticket statuses are
/// records ... the app must read them, not hard-code them").
class StatusOption {
  const StatusOption({
    required this.value,
    required this.label,
    required this.colorHex,
    this.category,
    this.sortOrder = 0,
  });

  final String value;
  final String label;
  final String colorHex;
  final String? category;
  final int sortOrder;

  factory StatusOption.fromJson(Map<String, dynamic> json) {
    return StatusOption(
      value: json['value'] as String,
      label: json['label'] as String? ?? json['value'] as String,
      colorHex: json['color_hex'] as String? ?? '#6B7280',
      category: json['category'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
