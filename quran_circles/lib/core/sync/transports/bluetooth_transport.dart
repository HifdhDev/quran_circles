import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../logging/quran_logger.dart';
import '../sync_transport.dart';

class BluetoothTransport extends SyncTransport {
  @override
  final String name = 'bluetooth';

  final StreamController<List<int>> _dataController =
      StreamController<List<int>>.broadcast();
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run('system_profiler', ['SPBluetoothDataType']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> start() async {
    _connected = true;
    QuranLogger.i('Bluetooth transport ready (platform-dependent)');
  }

  @override
  Future<void> stop() async {
    _connected = false;
  }

  @override
  Future<void> send(List<int> data) async {
    QuranLogger.d('Bluetooth send would write ${data.length} bytes');
  }

  @override
  Stream<List<int>> get onDataReceived => _dataController.stream;
}
