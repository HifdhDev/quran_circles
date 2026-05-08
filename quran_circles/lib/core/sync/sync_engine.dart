import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:sembast/sembast.dart';
import '../database/database_service.dart';
import '../database/store_refs.dart';
import '../logging/quran_logger.dart';
import 'sync_record.dart';
import 'sync_transport.dart';
import 'conflict_resolver.dart';

class SyncEngine {
  final DatabaseService _db;
  final List<SyncTransport> _transports = [];
  final List<SyncPeer> _peers = [];
  final String _deviceId;
  StreamSubscription? _dataSubscription;
  bool _isRunning = false;

  SyncEngine(this._db, {required String deviceId}) : _deviceId = deviceId;

  void addTransport(SyncTransport transport) {
    _transports.add(transport);
  }

  Future<Database> get _database => _db.database;

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    for (final t in _transports) {
      try {
        if (await t.isAvailable()) {
          await t.start();
          _dataSubscription = t.onDataReceived.listen(_handleData);
          QuranLogger.i('Sync transport started: ${t.name}');
        }
      } catch (e) {
        QuranLogger.w('Failed to start transport ${t.name}', e);
      }
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    await _dataSubscription?.cancel();
    for (final t in _transports) {
      try {
        await t.stop();
      } catch (_) {}
    }
    _peers.clear();
  }

  void _handleData(List<int> raw) {
    try {
      final json = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
      final type = json['type'] as String;

      switch (type) {
        case 'sync_push':
          _handleSyncPush(json['records'] as List);
          break;
        case 'sync_pull_request':
          _handleSyncPullRequest(json);
          break;
        case 'sync_pull_response':
          _handleSyncPullResponse(json['records'] as List);
          break;
        case 'peer_announce':
          _handlePeerAnnounce(json['peer'] as Map<String, dynamic>);
          break;
      }
    } catch (e) {
      QuranLogger.w('Failed to parse sync data', e);
    }
  }

  Future<void> pushChanges(int localUserId) async {
    if (!_isRunning || _peers.isEmpty) return;

    final unsynced = await _getUnsyncedRecords();
    if (unsynced.isEmpty) return;

    for (final peer in _peers) {
      final transport = _transports.firstWhereOrNull(
        (t) => t.name == peer.transportName,
      );
      if (transport == null || !transport.isConnected) continue;

      try {
        final payload = jsonEncode({
          'type': 'sync_push',
          'records': unsynced.map((r) => r.toMap()).toList(),
          'deviceId': _deviceId,
        });
        await transport.send(utf8.encode(payload));
        await _markSynced(unsynced);
        QuranLogger.i('Pushed ${unsynced.length} records to ${peer.name}');
      } catch (e) {
        QuranLogger.w('Failed to push to ${peer.name}', e);
      }
    }
  }

  Future<void> pullChanges(String fromDeviceId) async {
    final db = await _database;
    final lastTimestamp = await StoreRefs.settings.record('last_sync_ts').get(db);
    final ts = lastTimestamp ?? 0;

    for (final peer in _peers) {
      final transport = _transports.firstWhereOrNull(
        (t) => t.name == peer.transportName,
      );
      if (transport == null || !transport.isConnected) continue;

      try {
        final payload = jsonEncode({
          'type': 'sync_pull_request',
          'deviceId': _deviceId,
          'lastTimestamp': ts,
        });
        await transport.send(utf8.encode(payload));
      } catch (e) {
        QuranLogger.w('Failed to pull from ${peer.name}', e);
      }
    }
  }

  Future<void> _handleSyncPush(List<dynamic> records) async {
    final db = await _database;
    for (final r in records) {
      final remote = SyncRecord.fromMap(r as Map<String, dynamic>);
      final local = await _findLocal(db, remote.collection, remote.recordId);

      final resolved = local != null
          ? ConflictResolver.resolve(local, remote, _deviceId, remote.deviceId)
          : remote;

      if (resolved.timestamp == remote.timestamp && local?.timestamp != remote.timestamp) {
        await _applyRecord(db, resolved);
      }
    }
  }

  void _handleSyncPullRequest(Map<String, dynamic> req) {
    final lastTs = req['lastTimestamp'] as int;
    _getRecordsSince(lastTs).then((records) {
      for (final peer in _peers) {
        final transport = _transports.firstWhereOrNull(
          (t) => t.name == peer.transportName,
        );
        if (transport == null || !transport.isConnected) continue;

        final payload = jsonEncode({
          'type': 'sync_pull_response',
          'records': records.map((r) => r.toMap()).toList(),
          'deviceId': _deviceId,
        });
        transport.send(utf8.encode(payload));
      }
    });
  }

  Future<void> _handleSyncPullResponse(List<dynamic> records) async {
    final db = await _database;
    for (final r in records) {
      final remote = SyncRecord.fromMap(r as Map<String, dynamic>);
      final local = await _findLocal(db, remote.collection, remote.recordId);

      final resolved = local != null
          ? ConflictResolver.resolve(local, remote, _deviceId, remote.deviceId)
          : remote;

      if (resolved.timestamp == remote.timestamp && local?.timestamp != remote.timestamp) {
        await _applyRecord(db, resolved);
      }
    }

    await StoreRefs.settings.record('last_sync_ts').put(db, DateTime.now().millisecondsSinceEpoch);
  }

  void _handlePeerAnnounce(Map<String, dynamic> peerData) {
    final peer = SyncPeer.fromMap(peerData);
    final exists = _peers.any((p) => p.id == peer.id);
    if (!exists) {
      _peers.add(peer);
      QuranLogger.i('New peer discovered: ${peer.name} (${peer.address})');
    }
  }

  Future<List<SyncRecord>> _getUnsyncedRecords() async {
    final db = await _database;
    final lastSyncTs = await StoreRefs.settings.record('last_sync_ts').get(db) ?? 0;
    return _getRecordsSince(lastSyncTs as int);
  }

  Future<List<SyncRecord>> _getRecordsSince(int timestamp) async {
    final db = await _database;
    final records = await StoreRefs.syncRecords.find(db, finder: Finder(
      filter: Filter.greaterThan('timestamp', timestamp),
    ));
    return records.map((r) => SyncRecord.fromMap(r.value, id: r.key)).toList();
  }

  Future<SyncRecord?> _findLocal(
      Database db, String collection, String recordId) async {
    final records = await StoreRefs.syncRecords.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('collection', collection),
        Filter.equals('recordId', recordId),
      ]),
    ));
    if (records.isEmpty) return null;
    return SyncRecord.fromMap(records.first.value, id: records.first.key);
  }

  Future<void> _applyRecord(Database db, SyncRecord record) async {
    if (record.isDeleted) {
      final existing = await _findLocal(db, record.collection, record.recordId);
      if (existing?.id != null) {
        await StoreRefs.syncRecords.record(existing!.id!).delete(db);
      }
      return;
    }

    final existing = await _findLocal(db, record.collection, record.recordId);
    if (existing?.id != null) {
      await StoreRefs.syncRecords
          .record(existing!.id!)
          .put(db, record.toMap());
    } else {
      await StoreRefs.syncRecords.add(db, record.toMap());
    }
  }

  Future<void> _markSynced(List<SyncRecord> records) async {
    if (records.isEmpty) return;
    final db = await _database;
    final maxTs = records.map((r) => r.timestamp).reduce(max);
    await StoreRefs.settings.record('last_sync_ts').put(db, maxTs);
  }

  List<SyncPeer> get peers => List.unmodifiable(_peers);
  bool get isRunning => _isRunning;
}
