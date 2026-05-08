import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/store_refs.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final DatabaseService _db;

  AuthRepository(this._db);

  Future<Database> get _database => _db.database;

  @override
  Future<User?> login(String phone, String deviceId) async {
    final db = await _database;
    final records = await StoreRefs.users.find(
      db,
      finder: Finder(filter: Filter.equals('phone', phone)),
    );
    if (records.isEmpty) return null;
    return _fromMap(records.first.key, records.first.value);
  }

  @override
  Future<User> register(
      String name, String phone, UserRole role, String deviceId) async {
    final db = await _database;
    final id = await StoreRefs.users.add(db, {
      'name': name,
      'phone': phone,
      'role': role.name,
      'deviceId': deviceId,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    return User(
      id: id,
      name: name,
      phone: phone,
      role: role,
      deviceId: deviceId,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    final db = await _database;
    final records = await StoreRefs.users.find(db, finder: Finder(limit: 1));
    if (records.isEmpty) return null;
    return _fromMap(records.first.key, records.first.value);
  }

  @override
  Future<void> logout() async {}

  User _fromMap(int id, Map<String, dynamic> data) {
    return User(
      id: id,
      name: data['name'] as String,
      phone: data['phone'] as String,
      role: UserRole.values.firstWhere((r) => r.name == data['role']),
      deviceId: data['deviceId'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String).toLocal(),
    );
  }
}
