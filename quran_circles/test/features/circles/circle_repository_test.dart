import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
import 'package:quran_circles/core/database/database_service.dart';
import 'package:quran_circles/features/circles/data/repositories/circle_repository.dart';
import 'package:quran_circles/features/circles/domain/entities/circle.dart';
import 'package:quran_circles/features/circles/domain/entities/attendance.dart';
import 'dart:io';

void main() {
  late DatabaseService db;
  late CircleRepository repo;

  setUp(() async {
    db = DatabaseService(factory: databaseFactoryIo);
    repo = CircleRepository(db);
    await db.database;
  });

  tearDown(() async => await db.close());

  group('CircleRepository', () {
    test('add and retrieve circle', () async {
      final id = await repo.add(Circle(
        name: 'حلقة الفجر',
        teacherId: 1,
        createdAt: DateTime.now(),
      ));

      final circle = await repo.getById(id);
      expect(circle, isNotNull);
      expect(circle!.name, 'حلقة الفجر');
    });

    test('getAll returns only active when filtered', () async {
      await repo.add(Circle(
        name: 'نشطة', teacherId: 1, createdAt: DateTime.now(), isActive: true,
      ));
      await repo.add(Circle(
        name: 'غير نشطة', teacherId: 1, createdAt: DateTime.now(), isActive: false,
      ));

      final active = await repo.getAll(activeOnly: true);
      expect(active.length, 1);
      expect(active.first.name, 'نشطة');
    });

    test('record and retrieve attendance', () async {
      final circleId = await repo.add(Circle(
        name: 'حلقة', teacherId: 1, createdAt: DateTime.now(),
      ));

      await repo.recordAttendance(Attendance(
        studentId: 1,
        circleId: circleId,
        date: DateTime.now(),
        status: AttendanceStatus.present,
      ));

      final attendance = await repo.getAttendance(circleId, DateTime.now());
      expect(attendance.length, 1);
      expect(attendance.first.status, AttendanceStatus.present);
    });
  });
}
