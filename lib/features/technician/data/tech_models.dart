/// One row of `tech.home.today_tickets` or `tech.tickets.tickets`.
class TechTicketSummary {
  const TechTicketSummary({
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
  final String? scheduledDate;
  final String? modified;

  factory TechTicketSummary.fromJson(Map<String, dynamic> json) {
    return TechTicketSummary(
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
    );
  }
}

class PhoneOption {
  const PhoneOption({required this.phone, required this.isPrimary});

  final String phone;
  final bool isPrimary;

  factory PhoneOption.fromJson(Map<String, dynamic> json) {
    return PhoneOption(
      phone: json['phone'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class CheckLogEntry {
  const CheckLogEntry({
    required this.checkType,
    this.timestamp,
    this.technician,
    this.latitude,
    this.longitude,
    this.isMocked = false,
    this.locationAddress,
  });

  final String checkType;
  final String? timestamp;
  final String? technician;
  final double? latitude;
  final double? longitude;
  final bool isMocked;
  final String? locationAddress;

  factory CheckLogEntry.fromJson(Map<String, dynamic> json) {
    return CheckLogEntry(
      checkType: json['check_type'] as String? ?? '',
      timestamp: json['timestamp'] as String?,
      technician: json['technician'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isMocked: json['is_mocked'] == 1 || json['is_mocked'] == true,
      locationAddress: json['location_address'] as String?,
    );
  }
}

class MachineEntry {
  const MachineEntry({
    this.machineType,
    this.machineName,
    this.machineBrand,
    this.machineQuantity,
    this.machineProblem,
  });

  final String? machineType;
  final String? machineName;
  final String? machineBrand;
  final num? machineQuantity;
  final String? machineProblem;

  factory MachineEntry.fromJson(Map<String, dynamic> json) {
    return MachineEntry(
      machineType: json['machine_type'] as String?,
      machineName: json['machine_name'] as String?,
      machineBrand: json['machine_brand'] as String?,
      machineQuantity: json['machine_quantity'] as num?,
      machineProblem: json['machine_problem'] as String?,
    );
  }
}

/// `tech.ticket` / the `ticket` field of `check_in`/`check_out`/
/// `mark_pending` responses. Never carries an OTP (fix 1) — only
/// [hasOtp].
class TicketDetail {
  const TicketDetail({
    required this.name,
    required this.status,
    this.subject,
    this.description,
    this.priority,
    this.ticketType,
    this.customerName,
    this.primaryPhone,
    this.secondaryPhones = const [],
    this.phoneNosList = const [],
    this.address,
    this.city,
    this.state,
    this.machineName,
    this.machineProblem,
    this.requiredSpares,
    this.scheduledDate,
    this.modeOfPayment,
    this.gstBillRequired,
    this.machines = const [],
    this.checkLog = const [],
    this.pendingReasonOptions = const [],
    this.hasOtp = false,
  });

  final String name;
  final String status;
  final String? subject;
  final String? description;
  final String? priority;
  final String? ticketType;
  final String? customerName;
  final String? primaryPhone;
  final List<String> secondaryPhones;
  final List<PhoneOption> phoneNosList;
  final String? address;
  final String? city;
  final String? state;
  final String? machineName;
  final String? machineProblem;
  final String? requiredSpares;
  final String? scheduledDate;
  final String? modeOfPayment;
  final String? gstBillRequired;
  final List<MachineEntry> machines;
  final List<CheckLogEntry> checkLog;
  final List<String> pendingReasonOptions;
  final bool hasOtp;

  bool get isCheckedIn =>
      checkLog.isNotEmpty && checkLog.last.checkType == 'Check-in';

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    return TicketDetail(
      name: json['name'] as String,
      status: json['status'] as String? ?? '',
      subject: json['subject'] as String?,
      description: json['description'] as String?,
      priority: json['priority'] as String?,
      ticketType: json['ticket_type'] as String?,
      customerName: json['custom_customer_name'] as String?,
      primaryPhone: json['primary_phone'] as String?,
      secondaryPhones:
          (json['secondary_phones'] as List?)?.cast<String>() ?? const [],
      phoneNosList:
          (json['phone_nos_list'] as List?)
              ?.map((e) => PhoneOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      address: json['custom_address'] as String?,
      city: json['custom_city__district_'] as String?,
      state: json['custom_state'] as String?,
      machineName: json['custom_machine_name'] as String?,
      machineProblem: json['custom_machine_problem'] as String?,
      requiredSpares: json['custom_required_spares'] as String?,
      scheduledDate: json['custom_date'] as String?,
      modeOfPayment: json['custom_mode_of_payment'] as String?,
      gstBillRequired: json['custom_gst_bill_required'] as String?,
      machines:
          (json['custom_machine_type_list'] as List?)
              ?.map((e) => MachineEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      checkLog:
          (json['check_log'] as List?)
              ?.map((e) => CheckLogEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pendingReasonOptions:
          (json['pending_reason_options'] as List?)?.cast<String>() ?? const [],
      hasOtp: json['has_otp'] as bool? ?? false,
    );
  }
}

class AttendanceState {
  const AttendanceState({
    required this.state,
    this.time,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.deviceId,
  });

  final String state; // "IN" or "OUT"
  final String? time;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? deviceId;

  bool get isCheckedIn => state == 'IN';

  factory AttendanceState.fromJson(Map<String, dynamic> json) {
    return AttendanceState(
      state: json['state'] as String? ?? 'OUT',
      time: json['time'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      deviceId: json['device_id'] as String?,
    );
  }
}
