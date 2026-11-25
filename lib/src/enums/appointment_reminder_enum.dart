/// Lembretes que a pessoa pode pedir para uma consulta.
enum AppointmentReminderEnum {
  oneDay(minutes: 1440, label: '1 dia antes'),
  twoHours(minutes: 120, label: '2 horas antes');

  final int minutes;
  final String label;

  const AppointmentReminderEnum({required this.minutes, required this.label});

  /// Texto do lembrete para um valor em minutos (ex.: 1440 vira "1 dia antes").
  static String labelFor(int minutes) {
    for (final reminder in values) {
      if (reminder.minutes == minutes) return reminder.label;
    }
    return '$minutes min antes';
  }
}
