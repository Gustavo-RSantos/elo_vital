import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Resultado da classificação de uma medição. Sempre mostrado com ícone e
/// texto, nunca só pela cor.
enum ReadingStatusEnum {
  normal(
    label: 'Normal',
    icon: Icons.check_circle,
    color: AppColors.success,
    backgroundColor: AppColors.successSoft,
    textColor: AppColors.successText,
  ),
  attention(
    label: 'Atenção',
    icon: Icons.warning_amber_rounded,
    color: AppColors.warningText,
    backgroundColor: AppColors.warningSoft,
    textColor: AppColors.warningText,
  );

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color textColor;

  const ReadingStatusEnum({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.textColor,
  });
}
