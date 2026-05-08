import 'package:equatable/equatable.dart';

enum Gender { male, female }

class Student extends Equatable {
  final int? id;
  final String name;
  final int age;
  final Gender gender;
  final String phone;
  final String? guardianName;
  final String? notes;
  final DateTime enrolledAt;
  final bool isActive;

  const Student({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.guardianName,
    this.notes,
    required this.enrolledAt,
    this.isActive = true,
  });

  Student copyWith({
    int? id,
    String? name,
    int? age,
    Gender? gender,
    String? phone,
    String? guardianName,
    String? notes,
    DateTime? enrolledAt,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      guardianName: guardianName ?? this.guardianName,
      notes: notes ?? this.notes,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, age, gender, phone, guardianName, notes, enrolledAt, isActive];
}
