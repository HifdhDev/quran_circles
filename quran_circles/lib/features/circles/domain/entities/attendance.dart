import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, excused }

class Attendance extends Equatable {
  final int? id;
  final int studentId;
  final int circleId;
  final DateTime date;
  final AttendanceStatus status;
  final String? notes;

  const Attendance({
    this.id,
    required this.studentId,
    required this.circleId,
    required this.date,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [id, studentId, circleId, date, status, notes];
}
