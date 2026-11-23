import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/models/measurement_model.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';

/// Linha da lista "Últimas medições": valor, data e hora, e o resultado.
class MeasurementTileWidget extends StatelessWidget {
  const MeasurementTileWidget({super.key, required this.measurement});

  final MeasurementModel measurement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const type = ActivityTypeEnum.measurement;
    final status = measurement.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: type.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(measurement.type.icon, color: type.textColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(measurement.valueLabel, style: textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${measurement.type.shortLabel}, '
                    '${AppDateFormat.shortDate(measurement.measuredAt)} às '
                    '${AppDateFormat.time(measurement.measuredAt)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 18, color: status.color),
                  const SizedBox(width: 4),
                  Text(
                    status.label,
                    style: textTheme.labelMedium?.copyWith(
                      color: status.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
