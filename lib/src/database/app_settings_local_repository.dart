import 'package:elo_vital/src/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

/// Configurações simples do app: se o Onboarding já foi visto e qual usuário
/// está com a sessão ativa.
class AppSettingsLocalRepository {
  static const String _table = 'app_settings';
  static const String _onboardingSeenKey = 'onboarding_seen';
  static const String _sessionUserIdKey = 'session_user_id';

  final AppDatabase appDatabase;

  AppSettingsLocalRepository({required this.appDatabase});

  Future<bool> isOnboardingSeen() async {
    return await _read(_onboardingSeenKey) == 'true';
  }

  Future<void> setOnboardingSeen() => _write(_onboardingSeenKey, 'true');

  Future<int?> getSessionUserId() async {
    final value = await _read(_sessionUserIdKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> saveSession(int userId) {
    return _write(_sessionUserIdKey, userId.toString());
  }

  Future<void> clearSession() async {
    final db = await appDatabase.database;
    await db.delete(_table, where: 'setting_key = ?', whereArgs: [_sessionUserIdKey]);
  }

  Future<String?> _read(String key) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      _table,
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['setting_value'] as String;
  }

  Future<void> _write(String key, String value) async {
    final db = await appDatabase.database;
    await db.insert(_table, {
      'setting_key': key,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
