import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/appointment_reminder_enum.dart';
import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/screens/confirm_attendance_screen.dart';
import 'package:elo_vital/src/screens/new_appointment_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/app_pickers.dart';
import 'package:elo_vital/src/widgets/appointment_status_chip_widget.dart';
import 'package:elo_vital/src/widgets/conflict_dialog.dart';
import 'package:elo_vital/src/widgets/empty_state_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/info_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Detalhes de uma consulta e o que dá para fazer com ela: "Fui à consulta",
/// "Remarcar", "Cancelar" e "Marcar retorno", conforme a situação.
class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final int appointmentId;

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Voltar',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancel(BuildContext context, AppointmentModel appointment) async {
    final controller = context.read<AppointmentController>();

    final confirmed = await _confirm(
      context,
      title: 'Cancelar esta consulta?',
      message: 'A consulta de ${appointment.specialty} será cancelada.',
      confirmLabel: 'Sim, cancelar',
    );
    if (confirmed != true) return;

    await controller.cancel(appointment);
  }

  Future<void> _markMissed(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final controller = context.read<AppointmentController>();

    final confirmed = await _confirm(
      context,
      title: 'Você não foi à consulta?',
      message: 'Vamos registrar que você faltou a esta consulta.',
      confirmLabel: 'Sim, não fui',
    );
    if (confirmed != true) return;

    await controller.markMissed(appointment);
  }

  Future<void> _reschedule(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final controller = context.read<AppointmentController>();

    final date = await AppPickers.pickFutureDate(
      context,
      initialDate: appointment.scheduledAt,
      helpText: 'Nova data da consulta',
    );
    if (date == null || !context.mounted) return;

    final time = await AppPickers.pickTime(
      context,
      initialTime: TimeOfDay.fromDateTime(appointment.scheduledAt),
      helpText: 'Novo horário da consulta',
    );
    if (time == null || !context.mounted) return;

    final newDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (newDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma data e um horário que ainda não passaram.'),
        ),
      );
      return;
    }

    final conflicts = await controller.findConflicts(
      scheduledAt: newDate,
      ignoreId: appointment.id,
    );
    if (!context.mounted) return;
    if (conflicts.isNotEmpty) {
      final proceed = await showConflictDialog(context, conflicts);
      if (proceed != true || !context.mounted) return;
    }

    final created = await controller.reschedule(appointment, newDate);
    if (created == null || !context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointmentId: created.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final controller = context.watch<AppointmentController>();
    final appointment = controller.byId(appointmentId);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consulta')),
        body: const EmptyStateWidget(
          icon: Icons.event_busy_outlined,
          title: 'Consulta não encontrada',
          message: 'Ela pode ter sido removida.',
        ),
      );
    }

    final now = DateTime.now();
    final countdown = appointment.countdownLabel(now);
    final preparation = appointment.preparation?.trim() ?? '';
    final postNotes = appointment.postNotes?.trim() ?? '';
    final reminders = [...appointment.reminderMinutes]
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da consulta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(appointment.specialty, style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: AppointmentStatusChipWidget(status: appointment.status),
              ),
              if (countdown != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_bottom,
                      color: ActivityTypeEnum.appointment.textColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      countdown,
                      style: textTheme.titleSmall?.copyWith(
                        color: ActivityTypeEnum.appointment.textColor,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      InfoRowWidget(
                        icon: Icons.event_outlined,
                        label: 'Data e hora',
                        value:
                            '${AppDateFormat.fullDateWithYear(appointment.scheduledAt)} às '
                            '${AppDateFormat.time(appointment.scheduledAt)}',
                      ),
                      const SizedBox(height: 20),
                      InfoRowWidget(
                        icon: Icons.person_outline,
                        label: 'Médico',
                        value: appointment.doctorName ?? 'Não informado',
                      ),
                      const SizedBox(height: 20),
                      InfoRowWidget(
                        icon: Icons.place_outlined,
                        label: 'Local',
                        value: appointment.location ?? 'Não informado',
                      ),
                      const SizedBox(height: 20),
                      InfoRowWidget(
                        icon: Icons.notifications_none,
                        label: 'Lembretes',
                        value: reminders.isEmpty
                            ? 'Sem lembretes'
                            : reminders
                                  .map(AppointmentReminderEnum.labelFor)
                                  .join(', '),
                      ),
                    ],
                  ),
                ),
              ),
              if (preparation.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCallout(
                  context,
                  icon: Icons.info_outline,
                  title: 'Preparo',
                  text: preparation,
                ),
              ],
              if (postNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCallout(
                  context,
                  icon: Icons.record_voice_over_outlined,
                  title: 'O que o médico disse',
                  text: postNotes,
                ),
              ],
              if (appointment.originAppointmentId != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Esta consulta é uma remarcação ou um retorno de outra consulta.',
                  style: textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              if (controller.errorMessage != null) ...[
                ErrorMessageWidget(message: controller.errorMessage!),
                const SizedBox(height: 16),
              ],
              ..._buildActions(context, controller, appointment, now),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallout(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
  }) {
    final textTheme = Theme.of(context).textTheme;
    const type = ActivityTypeEnum.appointment;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: type.color, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: type.textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(color: type.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: textTheme.bodyLarge?.copyWith(color: type.textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    AppointmentController controller,
    AppointmentModel appointment,
    DateTime now,
  ) {
    final dangerStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.error,
      side: const BorderSide(color: AppColors.error, width: 2),
    );

    switch (appointment.status) {
      case AppointmentStatusEnum.scheduled:
        final isTodayOrPast =
            AppDateFormat.daysBetween(now, appointment.scheduledAt) <= 0;

        return [
          if (isTodayOrPast) ...[
            ElevatedButton(
              onPressed: () => _open(
                context,
                ConfirmAttendanceScreen(appointment: appointment),
              ),
              child: const Text('Fui à consulta'),
            ),
            const SizedBox(height: 12),
          ],
          if (appointment.isPastPending(now)) ...[
            OutlinedButton(
              onPressed: () => _markMissed(context, appointment),
              child: const Text('Não fui'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton(
            onPressed: () => _reschedule(context, appointment),
            child: const Text('Remarcar'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: dangerStyle,
            onPressed: () => _cancel(context, appointment),
            child: const Text('Cancelar consulta'),
          ),
        ];
      case AppointmentStatusEnum.completed:
        return [
          ElevatedButton(
            onPressed: () => _open(
              context,
              NewAppointmentScreen(returnOf: appointment),
            ),
            child: const Text('Marcar retorno'),
          ),
        ];
      case AppointmentStatusEnum.canceled:
      case AppointmentStatusEnum.missed:
        return [
          ElevatedButton(
            onPressed: () => _open(
              context,
              NewAppointmentScreen(returnOf: appointment),
            ),
            child: const Text('Marcar novamente'),
          ),
        ];
      case AppointmentStatusEnum.rescheduled:
        final followUp = controller.followUpOf(appointment.id);

        return [
          if (followUp != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentDetailScreen(appointmentId: followUp.id),
                  ),
                );
              },
              child: const Text('Ver a nova consulta'),
            ),
        ];
    }
  }
}
