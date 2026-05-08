import 'package:flutter_test/flutter_test.dart';
import 'package:quran_circles/core/sync/sync_record.dart';
import 'package:quran_circles/core/sync/conflict_resolver.dart';

void main() {
  group('SyncRecord', () {
    test('toMap and fromMap roundtrip', () {
      final record = SyncRecord(
        collection: 'students',
        recordId: 'uuid-123',
        data: '{"name":"أحمد"}',
        deviceId: 'device-1',
        timestamp: 1000,
      );

      final map = record.toMap();
      final restored = SyncRecord.fromMap(map);

      expect(restored.collection, 'students');
      expect(restored.recordId, 'uuid-123');
      expect(restored.deviceId, 'device-1');
      expect(restored.timestamp, 1000);
    });

    test('withId creates copy with new id', () {
      final record = SyncRecord(
        collection: 'test', recordId: 'r1', data: '{}',
        deviceId: 'd1', timestamp: 1,
      );

      final withNewId = record.withId(42);
      expect(withNewId.id, 42);
      expect(withNewId.collection, 'test');
    });
  });

  group('ConflictResolver', () {
    test('last write wins when timestamps differ', () {
      final local = SyncRecord(
        collection: 'test', recordId: 'r1', data: '{"v":"local"}',
        deviceId: 'device-a', timestamp: 100,
      );
      final remote = SyncRecord(
        collection: 'test', recordId: 'r1', data: '{"v":"remote"}',
        deviceId: 'device-b', timestamp: 200,
      );

      final resolved = ConflictResolver.resolve(local, remote, 'device-a', 'device-b');
      expect(resolved.data, '{"v":"remote"}');
      expect(resolved.timestamp, 200);
    });

    test('deviceId tiebreaker when timestamps equal', () {
      final local = SyncRecord(
        collection: 'test', recordId: 'r1', data: '{"v":"local"}',
        deviceId: 'device-b', timestamp: 100,
      );
      final remote = SyncRecord(
        collection: 'test', recordId: 'r1', data: '{"v":"remote"}',
        deviceId: 'device-a', timestamp: 100,
      );

      final resolved = ConflictResolver.resolve(local, remote, 'device-b', 'device-a');
      expect(resolved.data, '{"v":"local"}');
    });
  });
}
