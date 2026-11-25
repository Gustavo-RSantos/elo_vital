import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:flutter/material.dart';

/// Etiqueta com a situação da consulta (ícone e texto, nunca só a cor).
class AppointmentStatusChipWidget extends StatelessWidget {
  const AppointmentStatusChipWidget({super.key, required this.status});

  final AppointmentStatusEnum status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
            style: textTheme.labelMedium?.copyWith(color: status.textColor),
          ),
        ],
      ),
    );
  }
}
