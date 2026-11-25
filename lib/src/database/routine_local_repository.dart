import 'package:elo_vital/src/database/app_database.dart';
import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';
import 'package:elo_vital/src/models/routine_item_local_entity.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:sqflite/sqflite.dart';

/// Rotina do dia salva no celular.
///
/// Com dados locais, a primeira abertura de cada dia cria uma rotina de exemplo
/// (seed). Com a API, este repository vira o cache usado quando não há conexão.
class RoutineLocalRepository {
  static const String _table = 'routine_items';

  final AppDatabase appDatabase;

  RoutineLocalRepository({required this.appDatabase});

  /// Tarefas do dia. Com [seedIfEmpty], cria a rotina de exemplo se o dia
  /// ainda não tiver nada (só para os dados locais de teste).
  Future<List<RoutineItemModel>> getDay({
    required int userId,
    required DateTime day,
    bool seedIfEmpty = false,
  }) async {
    final db = await appDatabase.database;

    var rows = await _queryDay(db, userId, day);
    if (rows.isEmpty && seedIfEmpty) {
      await _seedDay(db, userId, day);
      rows = await _queryDay(db, userId, day);
    }

    return rows
        .map((row) => RoutineItemLocalEntity.fromMap(row).toModel())
        .toList();
  }

  Future<void> setStatus(int id, RoutineStatusEnum status) async {
    final db = await appDatabase.database;
    await db.update(
      _table,
      {
        'status': status.name,
        // Coluna antiga (versão 2 do banco), mantida em sincronia.
        'is_done': status == RoutineStatusEnum.done ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Troca as tarefas do dia pelas que vieram da API (cache offline).
  Future<void> replaceDay({
    required int userId,
    required DateTime day,
    required List<RoutineItemModel> items,
  }) async {
    final db = await appDatabase.database;
    final start = AppDateFormat.startOfDay(day);
    final end = start.add(const Duration(days: 1));

    await db.transaction((txn) async {
      await txn.delete(
        _table,
        where: 'user_id = ? AND scheduled_at >= ? AND scheduled_at < ?',
        whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      );
      for (final item in items) {
        await txn.insert(
          _table,
          RoutineItemLocalEntity.fromModel(item, userId: userId).toMap(),
        );
      }
    });
  }

  Future<List<Map<String, Object?>>> _queryDay(
    Database db,
    int userId,
    DateTime day,
  ) {
    final start = AppDateFormat.startOfDay(day);
    final end = start.add(const Duration(days: 1));

    return db.query(
      _table,
      // As consultas vêm da agenda de consultas (tabela appointments), então
      // ficam de fora da rotina salva (inclui as consultas de exemplo antigas).
      where: 'user_id = ? AND type != ? AND scheduled_at >= ? AND scheduled_at < ?',
      whereArgs: [
        userId,
        ActivityTypeEnum.appointment.name,
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'scheduled_at ASC',
    );
  }

  Future<void> _seedDay(Database db, int userId, DateTime day) async {
    const samples = [
      _SeedItem(ActivityTypeEnum.medicine, 'Losartana', '1 comprimido, 50 mg', 7, 30),
      _SeedItem(ActivityTypeEnum.water, 'Beber água', '1 copo (200 ml)', 8, 0),
      _SeedItem(ActivityTypeEnum.measurement, 'Medir a pressão', 'Anote a máxima e a mínima', 9, 0),
      _SeedItem(ActivityTypeEnum.exercise, 'Caminhada leve', '20 minutos', 10, 30),
      _SeedItem(ActivityTypeEnum.medicine, 'Metformina', '1 comprimido, 850 mg', 12, 0),
      _SeedItem(ActivityTypeEnum.medicine, 'Sinvastatina', '1 comprimido, 20 mg', 20, 0),
    ];

    final batch = db.batch();
    for (final sample in samples) {
      final entity = RoutineItemLocalEntity(
        userId: userId,
        type: sample.type,
        title: sample.title,
        subtitle: sample.subtitle,
        scheduledAt: DateTime(
          day.year,
          day.month,
          day.day,
          sample.hour,
          sample.minute,
        ),
        status: RoutineStatusEnum.pending,
      );
      batch.insert(_table, entity.toMap());
    }
    await batch.commit(noResult: true);
  }
}

/// Item da rotina de exemplo usada nos dados locais de teste.
class _SeedItem {
  final ActivityTypeEnum type;
  final String title;
  final String subtitle;
  final int hour;
  final int minute;

  const _SeedItem(this.type, this.title, this.subtitle, this.hour, this.minute);
}
