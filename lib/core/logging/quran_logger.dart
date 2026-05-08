import 'dart:async';
import 'dart:io';

enum LogLevel { debug, info, warning, error }

class LogRecord {
  final LogLevel level;
  final String message;
  final dynamic error;
  final DateTime timestamp;

  LogRecord(this.level, this.message, [this.error, DateTime? timestamp])
      : timestamp = timestamp ?? DateTime.now();

  String get formatted {
    final t = timestamp.toIso8601String();
    final e = error != null ? ' | $error' : '';
    return '[$t][${level.name.toUpperCase()}] $message$e';
  }
}

class QuranLogger {
  static final QuranLogger _instance = QuranLogger._();
  static QuranLogger get instance => _instance;

  final StreamController<LogRecord> _controller =
      StreamController<LogRecord>.broadcast();
  Stream<LogRecord> get stream => _controller.stream;

  File? _logFile;
  StreamSubscription? _subscription;
  int _currentSize = 0;

  QuranLogger._();

  void init(Directory logsDir) {
    logsDir.createSync(recursive: true);
    _logFile = File('${logsDir.path}/app.log');

    if (_logFile!.existsSync()) {
      _currentSize = _logFile!.lengthSync();
    }

    _subscription = _controller.stream
        .asyncMap(_writeToFile)
        .listen(null, onError: (_) {});
  }

  Future<void> _writeToFile(LogRecord record) async {
    if (_logFile == null) return;
    final line = '${record.formatted}\n';
    final bytes = line.length;

    if (_currentSize + bytes > (5 * 1024 * 1024)) {
      await _rotate();
    }

    await _logFile!.writeAsString(line, mode: FileMode.append);
    _currentSize += bytes;
  }

  Future<void> _rotate() async {
    final rotated = File('${_logFile!.path}.1');
    if (rotated.existsSync()) await rotated.delete();
    await _logFile!.rename(rotated.path);
    _currentSize = 0;
  }

  static void d(String message) =>
      _instance._controller.add(LogRecord(LogLevel.debug, message));

  static void i(String message) =>
      _instance._controller.add(LogRecord(LogLevel.info, message));

  static void w(String message, [dynamic error]) =>
      _instance._controller.add(LogRecord(LogLevel.warning, message, error));

  static void e(String message, [dynamic error]) =>
      _instance._controller.add(LogRecord(LogLevel.error, message, error));

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
