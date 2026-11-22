import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Banco SQLite do app. Cada bloco novo que precisa de tabela aumenta a
/// versão e cria a tabela também no onUpgrade.
///
/// Versão 1: users e app_settings (Bloco 2).
/// Versão 2: routine_items (Bloco 3).
class AppDatabase {
  static const String _databaseName = 'elo_vital.db';
  static const int _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createSettingsTable(db);
    await _createRoutineTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createRoutineTable(db);
    }
  }

  Future<void> _createUsersTable(Database db) {
    return db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        birth_date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSettingsTable(Database db) {
    return db.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createRoutineTable(Database db) {
    return db.execute('''
      CREATE TABLE routine_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        scheduled_at TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
