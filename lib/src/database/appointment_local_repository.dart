import 'package:elo_vital/src/database/app_database.dart';
import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/models/appointment_local_entity.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:sqflite/sqflite.dart';

/// Consultas salvas no celular (com os lembretes escolhidos para cada uma).
class AppointmentLocalRepository {
  static const String _table = 'appointments';
  static const String _remindersTable = 'appointment_reminders';

  final AppDatabase appDatabase;

  AppointmentLocalRepository({required this.appDatabase});

  /// Todas as consultas do usuário, da mais antiga para a mais nova. Com
  /// [seedIfEmpty], cria consultas de exemplo uma única vez por usuário (só
  /// para os dados locais de teste).
  Future<List<AppointmentModel>> getAll({
    required int userId,
    bool seedIfEmpty = false,
  }) async {
    final db = await appDatabase.database;
    if (seedIfEmpty) await _seedOnce(db, userId);

    final rows = await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scheduled_at ASC',
    );
    if (rows.isEmpty) return [];

    final ids = rows.map((row) => row['id'] as int).toList();
    final reminderRows = await db.query(
      _remindersTable,
      where: 'appointment_id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );

    final remindersByAppointment = <int, List<int>>{};
    for (final row in reminderRows) {
      remindersByAppointment
          .putIfAbsent(row['appointment_id'] as int, () => [])
          .add(row['minutes_before'] as int);
    }

    return rows.map((row) {
      final entity = AppointmentLocalEntity.fromMap(row);
      return entity.toModel(
        reminderMinutes: remindersByAppointment[entity.id] ?? [],
      );
    }).toList();
  }

  Future<AppointmentModel> add({
    required int userId,
    required String specialty,
    String? doctorName,
    required DateTime scheduledAt,
    String? location,
    String? preparation,
    required List<int> reminderMinutes,
    int? originAppointmentId,
  }) async {
    final db = await appDatabase.database;
    final entity = AppointmentLocalEntity(
      userId: userId,
      specialty: specialty,
      doctorName: doctorName,
      scheduledAt: scheduledAt,
      location: location,
      preparation: preparation,
      status: AppointmentStatusEnum.scheduled,
      originAppointmentId: originAppointmentId,
    );

    return db.transaction((txn) {
      return _insert(txn, entity, reminderMinutes);
    });
  }

  Future<void> updateStatus(
    int id,
    AppointmentStatusEnum status, {
    String? postNotes,
  }) async {
    final db = await appDatabase.database;
    await db.update(
      _table,
      {'status': status.name, if (postNotes != null) 'post_notes': postNotes},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remarca mantendo o histórico: cria uma nova consulta apontando para a
  /// original e marca a original como "Remarcada".
  Future<AppointmentModel> reschedule({
    required int userId,
    required AppointmentModel original,
    required DateTime newScheduledAt,
  }) async {
    final db = await appDatabase.database;
    final entity = AppointmentLocalEntity(
      userId: userId,
      specialty: original.specialty,
      doctorName: original.doctorName,
      scheduledAt: newScheduledAt,
      location: original.location,
      preparation: original.preparation,
      status: AppointmentStatusEnum.scheduled,
      originAppointmentId: original.id,
    );

    return db.transaction((txn) async {
      final created = await _insert(txn, entity, original.reminderMinutes);
      await txn.update(
        _table,
        {'status': AppointmentStatusEnum.rescheduled.name},
        where: 'id = ?',
        whereArgs: [original.id],
      );
      return created;
    });
  }

  Future<AppointmentModel> _insert(
    DatabaseExecutor executor,
    AppointmentLocalEntity entity,
    List<int> reminderMinutes,
  ) async {
    final id = await executor.insert(_table, entity.toMap());
    for (final minutes in reminderMinutes) {
      await executor.insert(_remindersTable, {
        'appointment_id': id,
        'minutes_before': minutes,
      });
    }

    return AppointmentLocalEntity(
      id: id,
      userId: entity.userId,
      specialty: entity.specialty,
      doctorName: entity.doctorName,
      scheduledAt: entity.scheduledAt,
      location: entity.location,
      preparation: entity.preparation,
      status: entity.status,
      postNotes: entity.postNotes,
      originAppointmentId: entity.originAppointmentId,
    ).toModel(reminderMinutes: reminderMinutes);
  }

  /// Cria as consultas de exemplo na primeira vez que o usuário abre a agenda.
  Future<void> _seedOnce(Database db, int userId) async {
    final seedKey = 'appointments_seeded_$userId';
    final seeded = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [seedKey],
      limit: 1,
    );
    if (seeded.isNotEmpty) return;

    final now = DateTime.now();
    DateTime at(int daysFromToday, int hour, int minute) {
      return DateTime(now.year, now.month, now.day + daysFromToday, hour, minute);
    }

    AppointmentLocalEntity sample({
      required String specialty,
      String? doctorName,
      required DateTime scheduledAt,
      String? location,
      String? preparation,
      AppointmentStatusEnum status = AppointmentStatusEnum.scheduled,
      String? postNotes,
    }) {
      return AppointmentLocalEntity(
        userId: userId,
        specialty: specialty,
        doctorName: doctorName,
        scheduledAt: scheduledAt,
        location: location,
        preparation: preparation,
        status: status,
        postNotes: postNotes,
      );
    }

    // A consulta de hoje fica daqui a 2 horas (no máximo às 23h), para dar
    // para ver o destaque "Hoje você tem consulta" no Início.
    final todayHour = now.hour + 2 > 23 ? 23 : now.hour + 2;

    await db.transaction((txn) async {
      await _insert(
        txn,
        sample(
          specialty: 'Cardiologia',
          doctorName: 'Dra. Helena Costa',
          scheduledAt: at(0, todayHour, 0),
          location: 'Clínica Vida',
          preparation: 'Levar os exames de sangue mais recentes.',
        ),
        [1440, 120],
      );
      await _insert(
        txn,
        sample(
          specialty: 'Endocrinologia',
          doctorName: 'Dr. Paulo Mendes',
          scheduledAt: at(3, 9, 30),
          location: 'Hospital Central',
          preparation: 'Ir em jejum de 8 horas.',
        ),
        [1440, 120],
      );
      await _insert(
        txn,
        sample(
          specialty: 'Oftalmologia',
          scheduledAt: at(10, 14, 0),
          location: 'Clínica Visão',
          preparation: 'Levar os óculos e os exames anteriores.',
        ),
        [1440],
      );
      await _insert(
        txn,
        sample(
          specialty: 'Clínico geral',
          doctorName: 'Dra. Ana Lima',
          scheduledAt: at(-12, 10, 0),
          location: 'UBS Centro',
          status: AppointmentStatusEnum.completed,
          postNotes: 'Pediu exames de sangue. Voltar em 3 meses.',
        ),
        [120],
      );
      await _insert(
        txn,
        sample(
          specialty: 'Dermatologia',
          doctorName: 'Dr. Carlos Souza',
          scheduledAt: at(-25, 16, 0),
          location: 'Clínica Pele',
          status: AppointmentStatusEnum.missed,
        ),
        [],
      );

      await txn.insert('app_settings', {
        'setting_key': seedKey,
        'setting_value': 'true',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
