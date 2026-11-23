/// Situação de uma tarefa da rotina.
enum RoutineStatusEnum {
  /// Ainda não foi feita.
  pending,

  /// Foi feita (remédio tomado, medição registrada...).
  done,

  /// A pessoa escolheu pular (ex.: dose de remédio pulada).
  skipped,
}
