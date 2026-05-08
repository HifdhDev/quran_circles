import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> login(String phone, String deviceId);
  Future<User> register(String name, String phone, UserRole role, String deviceId);
  Future<User?> getCurrentUser();
  Future<void> logout();
}
