/// One row of `chief.board`'s ticket list.
class BoardTicket {
  const BoardTicket({
    required this.name,
    required this.status,
    this.subject,
    this.priority,
    this.ticketType,
    this.customerName,
    this.customerMobile,
    this.address,
    this.city,
    this.state,
    this.scheduledDate,
    this.modified,
    this.resolvedBy,
  });

  final String name;
  final String status;
  final String? subject;
  final String? priority;
  final String? ticketType;
  final String? customerName;
  final String? customerMobile;
  final String? address;
  final String? city;
  final String? state;

  /// ISO 8601 date, e.g. "2026-10-09".
  final String? scheduledDate;

  /// ISO 8601 datetime with the site's offset.
  final String? modified;

  /// The technician on the ticket's last check-out — `null` until one
  /// exists (fix 7: never the first name in the assign list).
  final String? resolvedBy;

  factory BoardTicket.fromJson(Map<String, dynamic> json) {
    return BoardTicket(
      name: json['name'] as String,
      status: json['status'] as String? ?? '',
      subject: json['subject'] as String?,
      priority: json['priority'] as String?,
      ticketType: json['ticket_type'] as String?,
      customerName: json['custom_customer_name'] as String?,
      customerMobile: json['custom_customer_mobile_number'] as String?,
      address: json['custom_address'] as String?,
      city: json['custom_city__district_'] as String?,
      state: json['custom_state'] as String?,
      scheduledDate: json['custom_date'] as String?,
      modified: json['modified'] as String?,
      resolvedBy: json['resolved_by'] as String?,
    );
  }
}
