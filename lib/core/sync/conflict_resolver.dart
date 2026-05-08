enum ConflictStrategy { lastWriteWins, merge }
import 'sync_record.dart';

class ConflictResolver {
  static SyncRecord resolve(
    SyncRecord local,
    SyncRecord remote,
    String localDeviceId,
    String remoteDeviceId,
  ) {
    if (local.timestamp > remote.timestamp) return local;
    if (remote.timestamp > local.timestamp) return remote;
    return localDeviceId.compareTo(remoteDeviceId) > 0 ? local : remote;
  }
}
