import 'package:elo_vital/src/database/app_database.dart';
import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/enums/measurement_type_enum.dart';
import 'package:elo_vital/src/models/measurement_local_entity.dart';
import 'package:elo_vital/src/models/measurement_model.dart';

/// Medições (pressão e glicemia) salvas no celular.
class MeasurementLocalRepository {
  static const String _table = 'measurements';

  final AppDatabase appDatabase;

  MeasurementLocalRepository({required this.appDatabase});

  Future<MeasurementModel> addBloodPressure({
    required int userId,
    required int systolic,
    required int diastolic,
    required DateTime measuredAt,
  }) {
    return _insert(
      MeasurementLocalEntity(
        userId: userId,
        type: MeasurementTypeEnum.bloodPressure,
        systolic: systolic,
        diastolic: diastolic,
        measuredAt: measuredAt,
      ),
    );
  }

  Future<MeasurementModel> addGlucose({
    required int userId,
    required int value,
    required GlucoseMomentEnum moment,
    required DateTime measuredAt,
  }) {
    return _insert(
      MeasurementLocalEntity(
        userId: userId,
        type: MeasurementTypeEnum.glucose,
        glucose: value,
        glucoseMoment: moment,
        measuredAt: measuredAt,
      ),
    );
  }

  Future<List<MeasurementModel>> getRecent({
    required int userId,
    int limit = 5,
  }) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'measured_at DESC',
      limit: limit,
    );

    return rows
        .map((row) => MeasurementLocalEntity.fromMap(row).toModel())
        .toList();
  }

  Future<MeasurementModel> _insert(MeasurementLocalEntity entity) async {
    final db = await appDatabase.database;
    final id = await db.insert(_table, entity.toMap());

    return MeasurementLocalEntity(
      id: id,
      userId: entity.userId,
      type: entity.type,
      systolic: entity.systolic,
      diastolic: entity.diastolic,
      glucose: entity.glucose,
      glucoseMoment: entity.glucoseMoment,
      measuredAt: entity.measuredAt,
    ).toModel();
  }
}
