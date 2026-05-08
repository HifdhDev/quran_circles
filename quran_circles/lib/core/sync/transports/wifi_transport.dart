import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';
import '../../logging/quran_logger.dart';
import '../sync_transport.dart';
import '../../../core/utils/constants.dart';

class WifiTransport extends SyncTransport {
  @override
  final String name = 'wifi';

  ServerSocket? _server;
  MDnsClient? _mDnsClient;
  RawDatagramSocket? _broadcastSocket;
  final List<Socket> _clientSockets = [];
  final StreamController<List<int>> _dataController =
      StreamController<List<int>>.broadcast();
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> isAvailable() async {
    try {
      final interfaces = await NetworkInterface.list();
      return interfaces.any((i) =>
          i.addresses.any((a) =>
              a.type == InternetAddressType.IPv4 && !a.isLoopback));
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> start() async {
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      AppConstants.syncPort,
      shared: true,
    );
    _server!.listen(_onClientConnected);
    _connected = true;

    _startMDns();
    _startBroadcast();
    QuranLogger.i('WiFi transport listening on port ${AppConstants.syncPort}');
  }

  void _startMDns() {
    _mDnsClient = MDnsClient();
    _mDnsClient!.start();

    _mDnsClient!.lookup<PtrResourceRecord>(
      resourceType: ResourceType.pointer,
      name: '_services._dns-sd._udp.local',
    ).listen((_) {
      _mDnsClient!.lookup<SrvResourceRecord>(
        resourceType: ResourceType.service,
        name: AppConstants.syncServiceType,
      ).listen((srv) {
        QuranLogger.i('Discovered peer via mDNS: ${srv.target}');
      });
    });
  }

  void _startBroadcast() async {
    _broadcastSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      AppConstants.syncPort + 1,
      reuseAddress: true,
      reusePort: true,
    );
    _broadcastSocket!.broadcastEnabled = true;

    Timer.periodic(const Duration(seconds: 30), (_) {
      final announce = jsonEncode({
        'type': 'peer_announce',
        'peer': {
          'id': 'device-${DateTime.now().millisecondsSinceEpoch}',
          'address': 'local',
          'name': 'QuranCircle',
          'port': AppConstants.syncPort,
          'transport': 'wifi',
        },
      });
      _broadcastSocket!.send(
        utf8.encode(announce),
        InternetAddress('255.255.255.255'),
        AppConstants.syncPort + 1,
      );
    });
  }

  void _onClientConnected(Socket socket) {
    _clientSockets.add(socket);
    socket.listen(
      (data) => _dataController.add(data),
      onDone: () => _clientSockets.remove(socket),
      onError: (_) => _clientSockets.remove(socket),
    );
  }

  @override
  Future<void> send(List<int> data) async {
    for (final socket in _clientSockets) {
      try {
        socket.add(data);
      } catch (_) {}
    }
  }

  @override
  Stream<List<int>> get onDataReceived => _dataController.stream;

  @override
  Future<void> stop() async {
    _connected = false;
    await _mDnsClient?.stop();
    for (final s in _clientSockets) {
      try {
        await s.close();
      } catch (_) {}
    }
    _clientSockets.clear();
    await _server?.close();
    _broadcastSocket?.close();
  }
}
