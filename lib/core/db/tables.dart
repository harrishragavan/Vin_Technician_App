import 'package:drift/drift.dart';

/// Server-defined pick lists — statuses, priorities, pending reasons,
/// payment modes, GST options, billing types, natures of job — cached from
/// `meta.options` (plan, "Data freshness": refreshed only when the
/// server's `version` hash changes; option values are records, never
/// hard-coded in the app).
class OptionItems extends Table {
  TextColumn get category => text()(); // e.g. "ticket_status"
  TextColumn get value => text()(); // the stored value, e.g. "Working"
  TextColumn get label => text()(); // display label
  TextColumn get colorHex => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {category, value};
}

/// Small key/value cache for things that do not need their own table yet:
/// the `meta.options` version hash, last-sync timestamps per screen, and so
/// on. Ticket, job and invoice caches are added here as their own tables
/// once Phase 3 builds the screens that need paged list queries.
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
