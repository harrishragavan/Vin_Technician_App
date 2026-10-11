import '../../../core/api/api_client.dart';

class ChiefApi {
  ChiefApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> board({
    String? status,
    String? search,
    String? cursor,
    int pageLength = 20,
  }) {
    return _client.get<Map<String, dynamic>>(
      'chief.board',
      params: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'cursor': ?cursor,
        'page_length': pageLength,
      },
    );
  }

  Future<Map<String, dynamic>> technicians() {
    return _client.get<Map<String, dynamic>>('chief.technicians');
  }

  Future<Map<String, dynamic>> teamDay({String? date}) {
    return _client.get<Map<String, dynamic>>(
      'chief.team_day',
      params: {'date': ?date},
    );
  }

  Future<Map<String, dynamic>> analytics({String? dateFrom, String? dateTo}) {
    return _client.get<Map<String, dynamic>>(
      'chief.analytics',
      params: {'date_from': ?dateFrom, 'date_to': ?dateTo},
    );
  }

  Future<Map<String, dynamic>> attendance({
    String? dateFrom,
    String? dateTo,
    String? technician,
    String? cursor,
    int pageLength = 20,
  }) {
    return _client.get<Map<String, dynamic>>(
      'chief.attendance',
      params: {
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'technician': ?technician,
        'cursor': ?cursor,
        'page_length': pageLength,
      },
    );
  }

  Future<Map<String, dynamic>> map({String? date, String? technician}) {
    return _client.get<Map<String, dynamic>>(
      'chief.map',
      params: {'date': ?date, 'technician': ?technician},
    );
  }
}
