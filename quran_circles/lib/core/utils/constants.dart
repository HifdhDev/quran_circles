class AppConstants {
  static const String appName = 'حلقات القرآن';
  static const String dbName = 'quran_circles.db';
  static const int dbVersion = 1;
  static const String syncServiceType = '_quran_circles._tcp';
  static const int syncPort = 47808;
  static const int syncTimeoutMs = 10000;
  static const int maxLogSizeBytes = 5 * 1024 * 1024;
  static const int maxSyncPayloadBytes = 1024 * 512;
}
