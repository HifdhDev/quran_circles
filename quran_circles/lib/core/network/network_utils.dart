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

  static Future<bool> isWiFiConnected() async {
    try {
      return await NetworkInterface.list().then((list) => list.isNotEmpty).catchError((_) => false);
    } catch (_) {
      return false;
    }
  }
}
