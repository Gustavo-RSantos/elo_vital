import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Banco SQLite do app. Cada bloco novo que precisa de tabela aumenta a
/// versão e cria a tabela também no onUpgrade.
///
/// Versão 1: users e app_settings (Bloco 2).
/// Versão 2: routine_items (Bloco 3).
/// Versão 3: coluna status em routine_items, measurements e water_logs (Bloco 4).
/// Versão 4: appointments e appointment_reminders (Bloco 5).
class AppDatabase {
  static const String _databaseName = 'elo_vital.db';
  static const int _databaseVersion = 4;

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

  /// Instalação nova: cria direto o esquema mais recente.
  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createSettingsTable(db);
    await _createRoutineTable(db);
    await _createMeasurementsTable(db);
    await _createWaterLogsTable(db);
    await _createAppointmentsTables(db);
  }

  /// Atualização de quem já tinha o app instalado.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createRoutineTableV2(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE routine_items ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'",
      );
      await db.execute(
        "UPDATE routine_items SET status = 'done' WHERE is_done = 1",
      );
      await _createMeasurementsTable(db);
      await _createWaterLogsTable(db);
    }
    if (oldVersion < 4) {
      await _createAppointmentsTables(db);
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

  /// Esquema atual da rotina (com status).
  Future<void> _createRoutineTable(Database db) {
    return db.execute('''
      CREATE TABLE routine_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        scheduled_at TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');
  }

  /// Esquema da versão 2 (sem status), usado só no caminho de atualização.
  Future<void> _createRoutineTableV2(Database db) {
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

  Future<void> _createMeasurementsTable(Database db) {
    return db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        systolic INTEGER,
        diastolic INTEGER,
        glucose INTEGER,
        glucose_moment TEXT,
        measured_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createWaterLogsTable(Database db) {
    return db.execute('''
      CREATE TABLE water_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount_ml INTEGER NOT NULL,
        logged_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAppointmentsTables(Database db) async {
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        specialty TEXT NOT NULL,
        doctor_name TEXT,
        scheduled_at TEXT NOT NULL,
        location TEXT,
        preparation TEXT,
        status TEXT NOT NULL DEFAULT 'scheduled',
        post_notes TEXT,
        origin_appointment_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE appointment_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointment_id INTEGER NOT NULL,
        minutes_before INTEGER NOT NULL
      )
    ''');
  }
}
