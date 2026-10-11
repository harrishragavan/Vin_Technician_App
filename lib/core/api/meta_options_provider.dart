import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'meta_api.dart';
import 'providers.dart';

/// The full `meta.options` payload, fetched once per session. Screens
/// that only need one or two lists (payment modes, GST options, pending
/// reasons, ...) read this rather than each fetching their own slice.
final metaOptionsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  if (client == null) return {};
  return MetaApi(client).options();
});
