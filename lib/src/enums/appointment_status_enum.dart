import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Situação de uma consulta. Sempre mostrada com ícone e texto.
enum AppointmentStatusEnum {
  scheduled(
    label: 'Agendada',
    icon: Icons.schedule,
    color: AppColors.waterText,
    backgroundColor: AppColors.waterSoft,
    textColor: AppColors.waterText,
  ),
  completed(
    label: 'Realizada',
    icon: Icons.check_circle,
    color: AppColors.success,
    backgroundColor: AppColors.successSoft,
    textColor: AppColors.successText,
  ),
  canceled(
    label: 'Cancelada',
    icon: Icons.cancel_outlined,
    color: AppColors.textSecondary,
    backgroundColor: AppColors.surfaceSoft,
    textColor: AppColors.textSecondary,
  ),
  missed(
    label: 'Faltei',
    icon: Icons.event_busy_outlined,
    color: AppColors.measurementText,
    backgroundColor: AppColors.measurementSoft,
    textColor: AppColors.measurementText,
  ),
  rescheduled(
    label: 'Remarcada',
    icon: Icons.event_repeat_outlined,
    color: AppColors.exerciseText,
    backgroundColor: AppColors.exerciseSoft,
    textColor: AppColors.exerciseText,
  );

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color textColor;

  const AppointmentStatusEnum({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.textColor,
  });
}
