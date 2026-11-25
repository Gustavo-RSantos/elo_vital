import 'package:elo_vital/src/database/appointment_local_repository.dart';
import 'package:elo_vital/src/database/routine_local_repository.dart';
import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/services/appointment_service.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/error_message_helper.dart';
import 'package:flutter/foundation.dart';

/// Controla a agenda de consultas. Com USE_LOCAL_DATA=true (padrão) usa o
/// SQLite; com USE_LOCAL_DATA=false usa a API pelo AppointmentService.
class AppointmentController extends ChangeNotifier {
  /// Duas coisas a menos de 30 minutos uma da outra contam como conflito.
  static const Duration _conflictWindow = Duration(minutes: 30);

  final AppointmentLocalRepository appointmentLocalRepository;
  final RoutineLocalRepository routineLocalRepository;
  final AppointmentService appointmentService;

  AppointmentController({
    required this.appointmentLocalRepository,
    required this.routineLocalRepository,
    required this.appointmentService,
  });

  List<AppointmentModel> appointments = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  int? _userId;

  bool get _useLocalData => EnvironmentEnum.useLocalData.value == 'true';

  /// Consultas agendadas que ainda vão acontecer, da mais próxima à mais distante.
  List<AppointmentModel> get upcoming {
    final now = DateTime.now();
    return appointments.where((item) => item.isUpcoming(now)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Todo o resto (realizadas, canceladas, faltas, remarcadas e as que já
  /// passaram sem confirmação), da mais recente à mais antiga.
  List<AppointmentModel> get past {
    final now = DateTime.now();
    return appointments.where((item) => !item.isUpcoming(now)).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  /// Consultas de um dia, em ordem de horário.
  List<AppointmentModel> forDay(DateTime day) {
    return appointments
        .where((item) => AppDateFormat.isSameDay(item.scheduledAt, day))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  AppointmentModel? byId(int id) {
    for (final item in appointments) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Consulta criada ao remarcar [id] (a "nova" consulta), se existir.
  AppointmentModel? followUpOf(int id) {
    for (final item in appointments) {
      if (item.originAppointmentId == id) return item;
    }
    return null;
  }

  Future<void> load(int userId) async {
    _userId = userId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_useLocalData) {
        appointments = await appointmentLocalRepository.getAll(
          userId: userId,
          seedIfEmpty: true,
        );
      } else {
        try {
          appointments = await appointmentService.fetchAll();
        } catch (error) {
          // Sem conexão com a API: mostra o que ficou salvo no celular.
          // TODO(API): salvar as consultas no cache local ao buscar da API.
          debugPrint('Sem API, usando o cache local: $error');
          appointments = await appointmentLocalRepository.getAll(
            userId: userId,
          );
        }
      }
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> add({
    required String specialty,
    String? doctorName,
    required DateTime scheduledAt,
    String? location,
    String? preparation,
    required List<int> reminderMinutes,
    int? originAppointmentId,
  }) {
    return _save(() async {
      final created = _useLocalData
          ? await appointmentLocalRepository.add(
              userId: _requireUserId(),
              specialty: specialty,
              doctorName: doctorName,
              scheduledAt: scheduledAt,
              location: location,
              preparation: preparation,
              reminderMinutes: reminderMinutes,
              originAppointmentId: originAppointmentId,
            )
          : await appointmentService.add(
              specialty: specialty,
              doctorName: doctorName,
              scheduledAt: scheduledAt,
              location: location,
              preparation: preparation,
              reminderMinutes: reminderMinutes,
              originAppointmentId: originAppointmentId,
            );

      appointments = [...appointments, created];
      return created;
    });
  }

  /// "Fui à consulta": marca como realizada e guarda o que o médico disse.
  Future<bool> confirmAttendance(
    AppointmentModel appointment, {
    String? postNotes,
  }) {
    return _changeStatus(
      appointment,
      AppointmentStatusEnum.completed,
      postNotes: postNotes,
    );
  }

  Future<bool> markMissed(AppointmentModel appointment) {
    return _changeStatus(appointment, AppointmentStatusEnum.missed);
  }

  Future<bool> cancel(AppointmentModel appointment) {
    return _changeStatus(appointment, AppointmentStatusEnum.canceled);
  }

  /// Remarca mantendo o histórico: a original vira "Remarcada" e nasce uma
  /// nova consulta ligada a ela. Devolve a nova consulta.
  Future<AppointmentModel?> reschedule(
    AppointmentModel original,
    DateTime newScheduledAt,
  ) {
    return _save(() async {
      final created = _useLocalData
          ? await appointmentLocalRepository.reschedule(
              userId: _requireUserId(),
              original: original,
              newScheduledAt: newScheduledAt,
            )
          : await appointmentService.reschedule(original.id, newScheduledAt);

      appointments = [
        for (final item in appointments)
          if (item.id == original.id)
            item.copyWith(status: AppointmentStatusEnum.rescheduled)
          else
            item,
        created,
      ];
      return created;
    });
  }

  /// Descreve o que já está marcado perto de [scheduledAt] (consultas e
  /// tarefas da rotina), para avisar a pessoa antes de salvar.
  Future<List<String>> findConflicts({
    required DateTime scheduledAt,
    int? ignoreId,
  }) async {
    final conflicts = <String>[];

    for (final item in appointments) {
      if (item.id == ignoreId) continue;
      if (item.status != AppointmentStatusEnum.scheduled) continue;
      if (item.scheduledAt.difference(scheduledAt).abs() < _conflictWindow) {
        conflicts.add(
          'Consulta de ${item.specialty} às ${AppDateFormat.time(item.scheduledAt)}',
        );
      }
    }

    final userId = _userId;
    if (userId != null) {
      try {
        final routineItems = await routineLocalRepository.getDay(
          userId: userId,
          day: scheduledAt,
        );
        for (final item in routineItems) {
          if (item.isSkipped) continue;
          if (item.scheduledAt.difference(scheduledAt).abs() < _conflictWindow) {
            conflicts.add(
              '${item.type.label}: ${item.title} às ${AppDateFormat.time(item.scheduledAt)}',
            );
          }
        }
      } catch (error) {
        debugPrint('Não foi possível checar a rotina: $error');
      }
    }

    return conflicts;
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  /// Limpa os dados ao sair da conta.
  void clear() {
    appointments = [];
    isLoading = false;
    isSaving = false;
    errorMessage = null;
    _userId = null;
    notifyListeners();
  }

  int _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('As consultas ainda não foram carregadas.');
    }
    return userId;
  }

  Future<bool> _changeStatus(
    AppointmentModel appointment,
    AppointmentStatusEnum status, {
    String? postNotes,
  }) async {
    final done = await _save<bool>(() async {
      if (_useLocalData) {
        await appointmentLocalRepository.updateStatus(
          appointment.id,
          status,
          postNotes: postNotes,
        );
      } else {
        await appointmentService.updateStatus(
          appointment.id,
          status,
          postNotes: postNotes,
        );
      }

      appointments = [
        for (final item in appointments)
          if (item.id == appointment.id)
            item.copyWith(status: status, postNotes: postNotes)
          else
            item,
      ];
      return true;
    });
    return done ?? false;
  }

  Future<T?> _save<T>(Future<T> Function() action) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
