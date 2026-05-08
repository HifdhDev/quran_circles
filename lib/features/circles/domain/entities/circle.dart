import 'package:equatable/equatable.dart';

class Circle extends Equatable {
  final int? id;
  final String name;
  final int teacherId;
  final String? description;
  final String? location;
  final DateTime createdAt;
  final bool isActive;

  const Circle({
    this.id,
    required this.name,
    required this.teacherId,
    this.description,
    this.location,
    required this.createdAt,
    this.isActive = true,
  });

  Circle copyWith({
    int? id,
    String? name,
    int? teacherId,
    String? description,
    String? location,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, teacherId, description, location, createdAt, isActive];
}
