/// Um registro de água bebida (em ml).
class WaterLogModel {
  final int id;
  final int amountMl;
  final DateTime loggedAt;

  const WaterLogModel({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  /// Contrato sugerido com a API: {"id", "amountMl", "loggedAt"}.
  factory WaterLogModel.fromJson(Map<String, dynamic> json) {
    return WaterLogModel(
      id: json['id'] as int,
      amountMl: json['amountMl'] as int,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }
}
