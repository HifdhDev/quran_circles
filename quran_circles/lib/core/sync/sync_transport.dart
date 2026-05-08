abstract class SyncTransport {
  String get name;
  Future<bool> isAvailable();
  Future<void> start();
  Future<void> stop();
  Stream<List<int>> get onDataReceived;
  Future<void> send(List<int> data);
  bool get isConnected;
}

class SyncPeer {
  final String id;
  final String address;
  final String name;
  final int port;
  final String transportName;

  const SyncPeer({
    required this.id,
    required this.address,
    required this.name,
    required this.port,
    required this.transportName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'address': address,
        'name': name,
        'port': port,
        'transport': transportName,
      };

  factory SyncPeer.fromMap(Map<String, dynamic> map) => SyncPeer(
        id: map['id'] as String,
        address: map['address'] as String,
        name: map['name'] as String,
        port: map['port'] as int,
        transportName: map['transport'] as String,
      );
}
