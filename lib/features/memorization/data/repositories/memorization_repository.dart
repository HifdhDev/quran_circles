import 'package:sembast/sembast.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/store_refs.dart';
import '../../domain/entities/memorization_record.dart';
import '../../domain/repositories/i_memorization_repository.dart';

class MemorizationRepository implements IMemorizationRepository {
  final DatabaseService _db;

  MemorizationRepository(this._db);

  Future<Database> get _database => _db.database;

  @override
  Future<List<MemorizationRecord>> getByStudent(int studentId) async {
    final db = await _database;
    final records = await StoreRefs.memorization.find(db, finder: Finder(
      filter: Filter.equals('studentId', studentId),
      sortOrders: [SortOrder('recordedAt')],
    ));
    return records.map(_fromMap).toList();
  }

  @override
  Future<List<MemorizationRecord>> getByCircle(int circleId,
      {DateTime? from, DateTime? to}) async {
    final db = await _database;
    final filters = <Filter>[Filter.equals('circleId', circleId)];
    if (from != null) {
      filters.add(Filter.greaterThanOrEqualTo(
          'recordedAt', from.toUtc().toIso8601String()));
    }
    if (to != null) {
      filters.add(Filter.lessThanOrEqualTo(
          'recordedAt', to.toUtc().toIso8601String()));
    }
    final records = await StoreRefs.memorization.find(db, finder: Finder(
      filter: Filter.and(filters),
      sortOrders: [SortOrder('recordedAt')],
    ));
    return records.map(_fromMap).toList();
  }

  @override
  Future<List<MemorizationRecord>> getBySurah(
      int surahNumber, int circleId) async {
    final db = await _database;
    final records = await StoreRefs.memorization.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('surahNumber', surahNumber),
        Filter.equals('circleId', circleId),
      ]),
    ));
    return records.map(_fromMap).toList();
  }

  @override
  Future<int> add(MemorizationRecord record) async {
    final db = await _database;
    return StoreRefs.memorization.add(db, _toMap(record));
  }

  @override
  Future<void> update(MemorizationRecord record) async {
    final db = await _database;
    await StoreRefs.memorization
        .record(record.id!)
        .put(db, _toMap(record));
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await StoreRefs.memorization.record(id).delete(db);
  }

  @override
  Future<Map<String, int>> getProgressSummary(int studentId) async {
    final records = await getByStudent(studentId);
    final totalAyahs =
        records.fold<int>(0, (sum, r) => sum + (r.endAyah - r.startAyah + 1));
    final distinctSurahs = records.map((r) => r.surahNumber).toSet().length;
    final distinctJuz = records.map((r) => r.juzNumber).toSet().length;
    return {
      'totalAyahs': totalAyahs,
      'totalSurahs': distinctSurahs,
      'totalJuz': distinctJuz,
      'totalSessions': records.length,
    };
  }

  Map<String, dynamic> _toMap(MemorizationRecord r) => {
        'studentId': r.studentId,
        'circleId': r.circleId,
        'surahNumber': r.surahNumber,
        'startAyah': r.startAyah,
        'endAyah': r.endAyah,
        'juzNumber': r.juzNumber,
        'type': r.type,
        'evaluation': r.evaluation,
        'recordedAt': r.recordedAt.toUtc().toIso8601String(),
        'teacherId': r.teacherId,
      };

  MemorizationRecord _fromMap(
      RecordSnapshot<int, Map<String, dynamic>> record) {
    final d = record.value;
    return MemorizationRecord(
      id: record.key,
      studentId: d['studentId'] as int,
      circleId: d['circleId'] as int,
      surahNumber: d['surahNumber'] as int,
      startAyah: d['startAyah'] as int,
      endAyah: d['endAyah'] as int,
      juzNumber: d['juzNumber'] as int,
      type: d['type'] as String,
      evaluation: d['evaluation'] as String?,
      recordedAt: DateTime.parse(d['recordedAt'] as String).toLocal(),
      teacherId: d['teacherId'] as int,
    );
  }
}
