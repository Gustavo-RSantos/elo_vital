import 'package:flutter/material.dart';

/// Tipos de medição de saúde.
enum MeasurementTypeEnum {
  bloodPressure(
    label: 'Pressão arterial',
    shortLabel: 'Pressão',
    icon: Icons.monitor_heart_outlined,
  ),
  glucose(
    label: 'Glicemia',
    shortLabel: 'Glicemia',
    icon: Icons.bloodtype_outlined,
  );

  final String label;
  final String shortLabel;
  final IconData icon;

  const MeasurementTypeEnum({
    required this.label,
    required this.shortLabel,
    required this.icon,
  });
}
