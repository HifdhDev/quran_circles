import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DatabaseService {
  static const String _dbName = 'quran_circles.db';
  Database? _database;
  final DatabaseFactory _factory;

  DatabaseService({DatabaseFactory? factory})
      : _factory = factory ?? databaseFactoryIo;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dir = Directory.systemTemp.path;
    final path = p.join(dir, _dbName);
    return _factory.openDatabase(path, version: 1);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
