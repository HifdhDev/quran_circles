import 'package:equatable/equatable.dart';

enum UserRole { teacher, supervisor, admin }

class User extends Equatable {
  final int? id;
  final String name;
  final String phone;
  final UserRole role;
  final String deviceId;
  final DateTime createdAt;

  const User({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.deviceId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, phone, role, deviceId];
}
