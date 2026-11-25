import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';

/// Destaque no topo do Início: "Hoje você tem consulta às 15h". Toque para
/// abrir os detalhes da consulta.
class AppointmentHighlightWidget extends StatelessWidget {
  const AppointmentHighlightWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  final RoutineItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const type = ActivityTypeEnum.appointment;

    return Material(
      color: type.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: type.color, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      style: textTheme.titleSmall?.copyWith(
                        color: type.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.title}, ${item.subtitle}',
                      style: textTheme.bodySmall?.copyWith(
                        color: type.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: type.textColor),
            ],
          ),
        ),
      ),
    );
  }
}
