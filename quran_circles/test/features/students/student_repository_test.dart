import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
import 'package:quran_circles/core/database/database_service.dart';
import 'package:quran_circles/features/students/data/repositories/student_repository.dart';
import 'package:quran_circles/features/students/domain/entities/student.dart';
import 'dart:io';

void main() {
  late DatabaseService db;
  late StudentRepository repo;
  late String dbPath;

  setUp(() async {
    dbPath = p.join(Directory.systemTemp.path, 'test_students.db');
    db = DatabaseService(factory: databaseFactoryIo);
    repo = StudentRepository(db);
    await db.database;
  });

  tearDown(() async {
    await db.close();
    final file = File(dbPath);
    if (await file.exists()) await file.delete();
  });

  group('StudentRepository', () {
    test('add and retrieve student', () async {
      final student = Student(
        name: 'أحمد محمد',
        age: 12,
        gender: Gender.male,
        phone: '0555123456',
        enrolledAt: DateTime.now(),
      );

      final id = await repo.add(student);
      expect(id, greaterThan(0));

      final retrieved = await repo.getById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'أحمد محمد');
      expect(retrieved.phone, '0555123456');
    });

    test('getAll returns all students', () async {
      await repo.add(Student(
        name: 'طالب 1', age: 10, gender: Gender.male,
        phone: '111', enrolledAt: DateTime.now(),
      ));
      await repo.add(Student(
        name: 'طالب 2', age: 11, gender: Gender.female,
        phone: '222', enrolledAt: DateTime.now(),
      ));

      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('search filters by name', () async {
      await repo.add(Student(
        name: 'أحمد', age: 10, gender: Gender.male,
        phone: '111', enrolledAt: DateTime.now(),
      ));
      await repo.add(Student(
        name: 'خالد', age: 11, gender: Gender.male,
        phone: '222', enrolledAt: DateTime.now(),
      ));

      final results = await repo.search('أحمد');
      expect(results.length, 1);
      expect(results.first.name, 'أحمد');
    });

    test('delete removes student', () async {
      final id = await repo.add(Student(
        name: 'للحذف', age: 10, gender: Gender.male,
        phone: '000', enrolledAt: DateTime.now(),
      ));

      await repo.delete(id);
      final retrieved = await repo.getById(id);
      expect(retrieved, isNull);
    });

    test('update modifies student fields', () async {
      final id = await repo.add(Student(
        name: 'قديم', age: 10, gender: Gender.male,
        phone: '111', enrolledAt: DateTime.now(),
      ));

      await repo.update(Student(
        id: id, name: 'جديد', age: 11, gender: Gender.male,
        phone: '222', enrolledAt: DateTime.now(),
      ));

      final updated = await repo.getById(id);
      expect(updated!.name, 'جديد');
      expect(updated.age, 11);
    });
  });
}
