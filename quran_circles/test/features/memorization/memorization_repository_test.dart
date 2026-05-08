import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
import 'package:quran_circles/core/database/database_service.dart';
import 'package:quran_circles/features/memorization/data/repositories/memorization_repository.dart';
import 'package:quran_circles/features/memorization/domain/entities/memorization_record.dart';
import 'dart:io';

void main() {
  late DatabaseService db;
  late MemorizationRepository repo;

  setUp(() async {
    db = DatabaseService(factory: databaseFactoryIo);
    repo = MemorizationRepository(db);
    await db.database;
  });

  tearDown(() async => await db.close());

  group('MemorizationRepository', () {
    test('add and retrieve memorization records', () async {
      final id = await repo.add(MemorizationRecord(
        studentId: 1,
        circleId: 1,
        surahNumber: 1,
        startAyah: 1,
        endAyah: 7,
        juzNumber: 1,
        type: 'new',
        recordedAt: DateTime.now(),
        teacherId: 1,
      ));

      expect(id, greaterThan(0));

      final records = await repo.getByStudent(1);
      expect(records.length, 1);
      expect(records.first.surahNumber, 1);
    });

    test('progress summary counts correctly', () async {
      await repo.add(MemorizationRecord(
        studentId: 1, circleId: 1,
        surahNumber: 1, startAyah: 1, endAyah: 7, juzNumber: 1,
        type: 'new', recordedAt: DateTime.now(), teacherId: 1,
      ));
      await repo.add(MemorizationRecord(
        studentId: 1, circleId: 1,
        surahNumber: 36, startAyah: 1, endAyah: 83, juzNumber: 23,
        type: 'revision', recordedAt: DateTime.now(), teacherId: 1,
      ));

      final summary = await repo.getProgressSummary(1);
      expect(summary['totalSessions'], 2);
      expect(summary['totalSurahs'], 2);
      expect(summary['totalAyahs'], 90);
    });

    test('getByCircle filters correctly', () async {
      await repo.add(MemorizationRecord(
        studentId: 1, circleId: 1,
        surahNumber: 1, startAyah: 1, endAyah: 7, juzNumber: 1,
        type: 'new', recordedAt: DateTime.now(), teacherId: 1,
      ));
      await repo.add(MemorizationRecord(
        studentId: 2, circleId: 2,
        surahNumber: 2, startAyah: 1, endAyah: 10, juzNumber: 1,
        type: 'new', recordedAt: DateTime.now(), teacherId: 1,
      ));

      final circle1 = await repo.getByCircle(1);
      expect(circle1.length, 1);
    });
  });
}
