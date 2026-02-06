import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/history_item.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final path = join(await getDatabasesPath(), 'ml_history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path TEXT NOT NULL,
            type INTEGER NOT NULL,
            face_count INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<HistoryItem>> getAll() async {
    final db = await database;
    final rows = await db.query('history', orderBy: 'created_at DESC');
    return rows.map(HistoryItem.fromMap).toList();
  }

  Future<int> insert(HistoryItem item) async {
    final db = await database;
    return db.insert('history', item.toMap());
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('history', where: 'id=?', whereArgs: [id]);
  }
}
