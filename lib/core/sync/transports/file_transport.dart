import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../logging/quran_logger.dart';
import '../sync_transport.dart';

class FileTransport extends SyncTransport {
  @override
  final String name = 'file';

  final StreamController<List<int>> _dataController =
      StreamController<List<int>>.broadcast();
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> start() async {
    _connected = true;
    QuranLogger.i('File transport ready');
  }

  @override
  Future<void> stop() async {
    _connected = false;
  }

  @override
  Future<void> send(List<int> data) async {}

  Future<String> exportToFile(Directory dir, Map<String, dynamic> data) async {
    final file = File('${dir.path}/quran_circles_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data));
    QuranLogger.i('Exported backup to ${file.path}');
    return file.path;
  }

  Future<Map<String, dynamic>?> importFromFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      QuranLogger.w('Failed to import from file', e);
      return null;
    }
  }

  @override
  Stream<List<int>> get onDataReceived => _dataController.stream;
}
