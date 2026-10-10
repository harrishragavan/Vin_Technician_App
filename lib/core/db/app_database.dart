import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The phone's single source of truth (plan, "Stack decisions → Local
/// data"): screens draw from here first, then refresh from the server.
/// Sign-out or a different user signing in wipes this database entirely
/// (see `clearAllData`) so nobody sees the previous user's cached jobs.
@DriftDatabase(tables: [OptionItems, SyncMeta])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  Future<String?> readSyncMeta(String key) async {
    final row = await (select(
      syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeSyncMeta(String key, String value) {
    return into(
      syncMeta,
    ).insertOnConflictUpdate(SyncMetaCompanion.insert(key: key, value: value));
  }

  Future<List<OptionItem>> optionsFor(String category) {
    return (select(optionItems)
          ..where((t) => t.category.equals(category))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> replaceOptionsFor(
    String category,
    List<OptionItemsCompanion> rows,
  ) {
    return transaction(() async {
      await (delete(
        optionItems,
      )..where((t) => t.category.equals(category))).go();
      await batch((batch) => batch.insertAll(optionItems, rows));
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'vin_technician_app');
}
