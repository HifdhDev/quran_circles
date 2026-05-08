import 'dart:io';

class NetworkUtils {
  static Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              addr.address.startsWith(RegExp(r'10\.|172\.|192\.168'))) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static bool isWiFiConnected() {
    try {
      return NetworkInterface.list().then((list) => list.isNotEmpty).catchError((_) => false) as bool;
    } catch (_) {
      return false;
    }
  }
}
