import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';

/// Destaque no topo do Início: "Hoje você tem consulta às 15h".
class AppointmentHighlightWidget extends StatelessWidget {
  const AppointmentHighlightWidget({super.key, required this.item});

  final RoutineItemModel item;

  @override
  Widget build(BuildContext context) {
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
        children: [
          Icon(type.icon, color: type.textColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoje você tem consulta às ${AppDateFormat.hourLabel(item.scheduledAt)}',
                  style: textTheme.titleSmall?.copyWith(color: type.textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.title}, ${item.subtitle}',
                  style: textTheme.bodySmall?.copyWith(color: type.textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
