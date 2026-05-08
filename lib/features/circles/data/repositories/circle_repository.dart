import 'package:sembast/sembast.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/store_refs.dart';
import '../../domain/entities/circle.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/i_circle_repository.dart';

class CircleRepository implements ICircleRepository {
  final DatabaseService _db;

  CircleRepository(this._db);

  Future<Database> get _database => _db.database;

  @override
  Future<List<Circle>> getAll({bool? activeOnly}) async {
    final db = await _database;
    Finder? finder;
    if (activeOnly != null) {
      finder = Finder(filter: Filter.equals('isActive', activeOnly));
    }
    final records = await StoreRefs.circles.find(db, finder: finder);
    return records.map((r) => _circleFromMap(r.key, r.value)).toList();
  }

  @override
  Future<Circle?> getById(int id) async {
    final db = await _database;
    final record = await StoreRefs.circles.record(id).get(db);
    if (record == null) return null;
    return _circleFromMap(id, record);
  }

  @override
  Future<int> add(Circle circle) async {
    final db = await _database;
    return StoreRefs.circles.add(db, _circleToMap(circle));
  }

  @override
  Future<void> update(Circle circle) async {
    final db = await _database;
    await StoreRefs.circles.record(circle.id!).put(db, _circleToMap(circle));
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await StoreRefs.circles.record(id).delete(db);
  }

  @override
  Future<void> recordAttendance(Attendance attendance) async {
    final db = await _database;
    await StoreRefs.attendance.add(db, _attendanceToMap(attendance));
  }

  @override
  Future<List<Attendance>> getAttendance(int circleId, DateTime date) async {
    final db = await _database;
    final dateStr = date.toUtc().toIso8601String().substring(0, 10);
    final records = await StoreRefs.attendance.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('circleId', circleId),
        Filter.custom((snapshot) {
          final d = snapshot.value['date'] as String? ?? '';
          return d.startsWith(dateStr);
        }),
      ]),
    ));
    return records.map((r) => _attendanceFromMap(r.key, r.value)).toList();
  }

  @override
  Future<List<Attendance>> getAttendanceRange(
      int circleId, DateTime from, DateTime to) async {
    final db = await _database;
    final fromStr = from.toUtc().toIso8601String().substring(0, 10);
    final toStr = to.toUtc().toIso8601String().substring(0, 10);
    final records = await StoreRefs.attendance.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('circleId', circleId),
        Filter.custom((snapshot) {
          final d = snapshot.value['date'] as String? ?? '';
          return d.substring(0, 10).compareTo(fromStr) >= 0 &&
              d.substring(0, 10).compareTo(toStr) <= 0;
        }),
      ]),
    ));
    return records.map((r) => _attendanceFromMap(r.key, r.value)).toList();
  }

  @override
  Future<List<Attendance>> getStudentAttendance(int studentId) async {
    final db = await _database;
    final records = await StoreRefs.attendance.find(db, finder: Finder(
      filter: Filter.equals('studentId', studentId),
    ));
    return records.map((r) => _attendanceFromMap(r.key, r.value)).toList();
  }

  Map<String, dynamic> _circleToMap(Circle c) => {
        'name': c.name,
        'teacherId': c.teacherId,
        'description': c.description,
        'location': c.location,
        'createdAt': c.createdAt.toUtc().toIso8601String(),
        'isActive': c.isActive,
      };

  Circle _circleFromMap(int id, Map<String, dynamic> d) {
    return Circle(
      id: id,
      name: d['name'] as String,
      teacherId: d['teacherId'] as int,
      description: d['description'] as String?,
      location: d['location'] as String?,
      createdAt: DateTime.parse(d['createdAt'] as String).toLocal(),
      isActive: d['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _attendanceToMap(Attendance a) => {
        'studentId': a.studentId,
        'circleId': a.circleId,
        'date': a.date.toUtc().toIso8601String(),
        'status': a.status.name,
        'notes': a.notes,
      };

  Attendance _attendanceFromMap(int id, Map<String, dynamic> d) {
    return Attendance(
      id: id,
      studentId: d['studentId'] as int,
      circleId: d['circleId'] as int,
      date: DateTime.parse(d['date'] as String).toLocal(),
      status:
          AttendanceStatus.values.firstWhere((s) => s.name == d['status']),
      notes: d['notes'] as String?,
    );
  }
}
