import 'package:elo_vital/src/database/app_database.dart';
import 'package:elo_vital/src/models/water_log_local_entity.dart';
import 'package:elo_vital/src/models/water_log_model.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';

/// Registros de água salvos no celular.
class WaterLocalRepository {
  static const String _table = 'water_logs';

  final AppDatabase appDatabase;

  WaterLocalRepository({required this.appDatabase});

  Future<WaterLogModel> add({
    required int userId,
    required int amountMl,
    required DateTime loggedAt,
  }) async {
    final db = await appDatabase.database;
    final entity = WaterLogLocalEntity(
      userId: userId,
      amountMl: amountMl,
      loggedAt: loggedAt,
    );
    final id = await db.insert(_table, entity.toMap());

    return WaterLogModel(id: id, amountMl: amountMl, loggedAt: loggedAt);
  }

  /// Registros do dia, do mais antigo para o mais novo.
  Future<List<WaterLogModel>> getDay({
    required int userId,
    required DateTime day,
  }) async {
    final db = await appDatabase.database;
    final start = AppDateFormat.startOfDay(day);
    final end = start.add(const Duration(days: 1));

    final rows = await db.query(
      _table,
      where: 'user_id = ? AND logged_at >= ? AND logged_at < ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'logged_at ASC',
    );

    return rows
        .map((row) => WaterLogLocalEntity.fromMap(row).toModel())
        .toList();
  }

  Future<void> delete(int id) async {
    final db = await appDatabase.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
