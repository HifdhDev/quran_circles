import 'dart:async';
import 'dart:convert';
import '../../logging/quran_logger.dart';
import '../sync_transport.dart';

class QRTransport extends SyncTransport {
  @override
  final String name = 'qr';

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
    QuranLogger.i('QR transport ready');
  }

  @override
  Future<void> stop() async {
    _connected = false;
  }

  @override
  Future<void> send(List<int> data) async {
    final encoded = base64Encode(data);
    QuranLogger.d('QR payload ready: ${encoded.length} chars');
  }

  String exportAsJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  void importFromJson(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        _dataController.add(utf8.encode(json));
      }
    } catch (e) {
      QuranLogger.w('Invalid QR import data', e);
    }
  }

  @override
  Stream<List<int>> get onDataReceived => _dataController.stream;
}
