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
}
