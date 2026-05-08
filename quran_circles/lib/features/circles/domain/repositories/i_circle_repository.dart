import '../entities/circle.dart';
import '../entities/attendance.dart';

abstract class ICircleRepository {
  Future<List<Circle>> getAll({bool? activeOnly});
  Future<Circle?> getById(int id);
  Future<int> add(Circle circle);
  Future<void> update(Circle circle);
  Future<void> delete(int id);

  Future<void> recordAttendance(Attendance attendance);
  Future<List<Attendance>> getAttendance(int circleId, DateTime date);
  Future<List<Attendance>> getAttendanceRange(int circleId, DateTime from, DateTime to);
  Future<List<Attendance>> getStudentAttendance(int studentId);
}
