import 'api_client.dart';

/// `meta.options` — statuses, priorities, pending reasons, payment modes,
/// GST options, billing types, natures of job. Shared across every
/// feature (technician, invoice, chief), so it lives in core rather than
/// under any one feature.
class MetaApi {
  MetaApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> options() {
    return _client.get<Map<String, dynamic>>('meta.options');
  }
}
