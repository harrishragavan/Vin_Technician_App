import '../../../core/api/api_client.dart';

class TechApi {
  TechApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> home() {
    return _client.get<Map<String, dynamic>>('tech.home');
  }

  Future<Map<String, dynamic>> tickets({
    String? status,
    String? priority,
    String? search,
    String? cursor,
    int pageLength = 20,
  }) {
    return _client.get<Map<String, dynamic>>(
      'tech.tickets',
      params: {
        'status': ?status,
        'priority': ?priority,
        'search': ?search,
        'cursor': ?cursor,
        'page_length': pageLength,
      },
    );
  }

  Future<Map<String, dynamic>> ticket(String ticketName) {
    return _client.get<Map<String, dynamic>>(
      'tech.ticket',
      params: {'ticket_name': ticketName},
    );
  }

  Future<Map<String, dynamic>> attendance({
    required String logType,
    required double latitude,
    required double longitude,
    double? accuracy,
    bool isMocked = false,
    required String clientRequestId,
  }) {
    return _client.post<Map<String, dynamic>>(
      'tech.attendance',
      clientRequestId: clientRequestId,
      data: {
        'log_type': logType,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': ?accuracy,
        'is_mocked': isMocked,
      },
    );
  }

  Future<Map<String, dynamic>> checkIn({
    required String ticketName,
    required double latitude,
    required double longitude,
    double? accuracy,
    bool isMocked = false,
    String locationAddress = '',
    String selectedPhone = '',
    required String clientRequestId,
  }) {
    return _client.post<Map<String, dynamic>>(
      'tech.check_in',
      clientRequestId: clientRequestId,
      data: {
        'ticket_name': ticketName,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': ?accuracy,
        'is_mocked': isMocked,
        'location_address': locationAddress,
        'selected_phone': selectedPhone,
      },
    );
  }

  Future<Map<String, dynamic>> otpStatus(String ticketName) {
    return _client.get<Map<String, dynamic>>(
      'tech.otp_status',
      params: {'ticket_name': ticketName},
    );
  }

  Future<Map<String, dynamic>> resendOtp({
    required String ticketName,
    String selectedPhone = '',
    required String clientRequestId,
  }) {
    return _client.post<Map<String, dynamic>>(
      'tech.resend_otp',
      clientRequestId: clientRequestId,
      data: {'ticket_name': ticketName, 'selected_phone': selectedPhone},
    );
  }

  Future<Map<String, dynamic>> checkOut({
    required String ticketName,
    required String otp,
    required double latitude,
    required double longitude,
    double? accuracy,
    bool isMocked = false,
    String locationAddress = '',
    String modeOfPayment = '',
    String gstBillRequired = '',
    required String clientRequestId,
  }) {
    return _client.post<Map<String, dynamic>>(
      'tech.check_out',
      clientRequestId: clientRequestId,
      data: {
        'ticket_name': ticketName,
        'otp': otp,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': ?accuracy,
        'is_mocked': isMocked,
        'location_address': locationAddress,
        'mode_of_payment': modeOfPayment,
        'gst_bill_required': gstBillRequired,
      },
    );
  }

  Future<Map<String, dynamic>> markPending({
    required String ticketName,
    required String reason,
    required double latitude,
    required double longitude,
    double? accuracy,
    bool isMocked = false,
    String locationAddress = '',
    String customReason = '',
    required String clientRequestId,
  }) {
    return _client.post<Map<String, dynamic>>(
      'tech.mark_pending',
      clientRequestId: clientRequestId,
      data: {
        'ticket_name': ticketName,
        'reason': reason,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': ?accuracy,
        'is_mocked': isMocked,
        'location_address': locationAddress,
        'custom_reason': customReason,
      },
    );
  }
}
