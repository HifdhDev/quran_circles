import '../entities/memorization_record.dart';

abstract class IMemorizationRepository {
  Future<List<MemorizationRecord>> getByStudent(int studentId);
  Future<List<MemorizationRecord>> getByCircle(int circleId, {DateTime? from, DateTime? to});
  Future<List<MemorizationRecord>> getBySurah(int surahNumber, int circleId);
  Future<int> add(MemorizationRecord record);
  Future<void> update(MemorizationRecord record);
  Future<void> delete(int id);
  Future<Map<String, int>> getProgressSummary(int studentId);
}
