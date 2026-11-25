import 'package:flutter/material.dart';

/// Seletores de data e hora usados nas consultas (em português, hora de 24h).
class AppPickers {
  AppPickers._();

  /// Escolher uma data de hoje em diante (até 3 anos).
  static Future<DateTime?> pickFutureDate(
    BuildContext context, {
    DateTime? initialDate,
    required String helpText,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = initialDate == null || initialDate.isBefore(today)
        ? today
        : initialDate;

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(now.year + 3, 12, 31),
      helpText: helpText,
    );
  }

  /// Escolher um horário, sempre no formato de 24 horas.
  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: helpText,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  /// Ex.: 9h05 vira "09:05".
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
