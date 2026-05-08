import 'package:sembast/sembast.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/store_refs.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/i_student_repository.dart';

class StudentRepository implements IStudentRepository {
  final DatabaseService _db;

  StudentRepository(this._db);

  Future<Database> get _database => _db.database;

  @override
  Future<List<Student>> getAll({bool? activeOnly}) async {
    final db = await _database;
    Finder? finder;
    if (activeOnly != null) {
      finder = Finder(filter: Filter.equals('isActive', activeOnly));
    }
    final records = await StoreRefs.students.find(db, finder: finder);
    return records.map(_fromMap).toList();
  }

  @override
  Future<Student?> getById(int id) async {
    final db = await _database;
    final record = await StoreRefs.students.record(id).get(db);
    if (record == null) return null;
    return _fromMap(RecordSnapshot(id, record));
  }

  @override
  Future<int> add(Student student) async {
    final db = await _database;
    return StoreRefs.students.add(db, _toMap(student));
  }

  @override
  Future<void> update(Student student) async {
    final db = await _database;
    await StoreRefs.students.record(student.id!).put(db, _toMap(student));
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await StoreRefs.students.record(id).delete(db);
  }

  @override
  Future<List<Student>> search(String query) async {
    final db = await _database;
    final records = await StoreRefs.students.find(db);
    final lower = query.toLowerCase();
    return records
        .map(_fromMap)
        .where((s) => s.name.toLowerCase().contains(lower) || s.phone.contains(query))
        .toList();
  }

  Map<String, dynamic> _toMap(Student s) => {
        'name': s.name,
        'age': s.age,
        'gender': s.gender.name,
        'phone': s.phone,
        'guardianName': s.guardianName,
        'notes': s.notes,
        'enrolledAt': s.enrolledAt.toUtc().toIso8601String(),
        'isActive': s.isActive,
      };

  Student _fromMap(RecordSnapshot<int, Map<String, dynamic>> record) {
    final d = record.value;
    return Student(
      id: record.key,
      name: d['name'] as String,
      age: d['age'] as int,
      gender: Gender.values.firstWhere((g) => g.name == d['gender']),
      phone: d['phone'] as String,
      guardianName: d['guardianName'] as String?,
      notes: d['notes'] as String?,
      enrolledAt: DateTime.parse(d['enrolledAt'] as String).toLocal(),
      isActive: d['isActive'] as bool? ?? true,
    );
  }
}
