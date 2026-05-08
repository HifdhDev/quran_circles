import 'package:equatable/equatable.dart';

class MemorizationRecord extends Equatable {
  final int? id;
  final int studentId;
  final int circleId;
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final int juzNumber;
  final String type;
  final String? evaluation;
  final DateTime recordedAt;
  final int teacherId;

  const MemorizationRecord({
    this.id,
    required this.studentId,
    required this.circleId,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.juzNumber,
    required this.type,
    this.evaluation,
    required this.recordedAt,
    required this.teacherId,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        circleId,
        surahNumber,
        startAyah,
        endAyah,
        juzNumber,
        type,
        evaluation,
        recordedAt,
        teacherId,
      ];
}
