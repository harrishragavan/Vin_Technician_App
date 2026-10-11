import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/providers.dart';
import '../data/chief_api.dart';

class TechnicianOption {
  const TechnicianOption({required this.value, required this.label});

  final String value;
  final String label;

  factory TechnicianOption.fromJson(Map<String, dynamic> json) {
    return TechnicianOption(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
}

/// `chief.technicians` — enabled Agent/TP Agent users, for the pickers on
/// Team day and Map. Fetched once per app session.
final techniciansProvider = FutureProvider<List<TechnicianOption>>((ref) async {
  final client = ref.watch(apiClientProvider);
  if (client == null) return const [];
  final result = await ChiefApi(client).technicians();
  return (result['technicians'] as List)
      .map((e) => TechnicianOption.fromJson(e as Map<String, dynamic>))
      .toList();
});
