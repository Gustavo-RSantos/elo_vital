import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/widgets/appointment_status_chip_widget.dart';
import 'package:flutter/material.dart';

/// Cartão de uma consulta nas listas: data e hora, situação, especialidade,
/// médico e local, e a contagem regressiva ("Faltam 3 dias").
class AppointmentCardWidget extends StatelessWidget {
  const AppointmentCardWidget({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const type = ActivityTypeEnum.appointment;
    final now = DateTime.now();
    final countdown = appointment.countdownLabel(now);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 8, color: type.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${AppDateFormat.shortDate(appointment.scheduledAt)} às '
                              '${AppDateFormat.time(appointment.scheduledAt)}',
                              style: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppointmentStatusChipWidget(
                            status: appointment.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(appointment.specialty, style: textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(appointment.summaryLine, style: textTheme.bodySmall),
                      if (countdown != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.hourglass_bottom,
                              size: 20,
                              color: type.textColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              countdown,
                              style: textTheme.titleSmall?.copyWith(
                                color: type.textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (appointment.isPastPending(now)) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              size: 20,
                              color: AppColors.warningText,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Confirme se você foi à consulta',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.warningText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Center(
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
