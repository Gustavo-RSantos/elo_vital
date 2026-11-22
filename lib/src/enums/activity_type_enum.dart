import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tipos de atividade da rotina do idoso, cada um com a sua identidade visual.
enum ActivityTypeEnum {
  medicine(
    label: 'Remédio',
    icon: Icons.medication_outlined,
    color: AppColors.medicine,
    backgroundColor: AppColors.medicineSoft,
    textColor: AppColors.medicineText,
  ),
  measurement(
    label: 'Medição',
    icon: Icons.monitor_heart_outlined,
    color: AppColors.measurement,
    backgroundColor: AppColors.measurementSoft,
    textColor: AppColors.measurementText,
  ),
  water(
    label: 'Água',
    icon: Icons.water_drop_outlined,
    color: AppColors.water,
    backgroundColor: AppColors.waterSoft,
    textColor: AppColors.waterText,
  ),
  exercise(
    label: 'Exercício',
    icon: Icons.directions_walk,
    color: AppColors.exercise,
    backgroundColor: AppColors.exerciseSoft,
    textColor: AppColors.exerciseText,
  ),
  appointment(
    label: 'Consulta',
    icon: Icons.event_outlined,
    color: AppColors.appointment,
    backgroundColor: AppColors.appointmentSoft,
    textColor: AppColors.appointmentText,
  );

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color textColor;

  const ActivityTypeEnum({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.textColor,
  });
}
