import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotificationsDb {
  static const _dbName = 'nfc_bus.db';
  static const _dbVersion = 1;
  static const table = 'notifications';

  static final NotificationsDb _instance = NotificationsDb._();
  NotificationsDb._();
  factory NotificationsDb() => _instance;

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT UNIQUE,
            child_id INTEGER,
            child_name TEXT,
            title TEXT,
            body TEXT,
            created_at TEXT,
            seen INTEGER DEFAULT 0
          );
        ''');
      },
    );
    return _db!;
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await _open();
    return db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> list(
      {int limit = 100, int offset = 0}) async {
    final db = await _open();
    print(db.query(table, orderBy: 'id DESC', limit: limit, offset: offset));
    return db.query(table, orderBy: 'id DESC', limit: limit, offset: offset);
  }

  Future<int> markAllSeen() async {
    final db = await _open();
    return db.update(table, {'seen': 1});
  }

  Future<void> clear() async {
    final db = await _open();
    await db.delete(table);
  }
}
