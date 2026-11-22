import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Banco SQLite do app. Cada bloco novo que precisa de tabela aumenta a
/// versão e cria a tabela também no onUpgrade.
class AppDatabase {
  static const String _databaseName = 'elo_vital.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _databaseName);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        birth_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');
  }
}
