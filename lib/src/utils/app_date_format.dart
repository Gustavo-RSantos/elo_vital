import 'package:intl/intl.dart';

/// Formatação e leitura de datas em português do Brasil.
///
/// Requer `initializeDateFormatting('pt_BR')` no `main.dart`.
class AppDateFormat {
  AppDateFormat._();

  static const String _locale = 'pt_BR';

  /// Ex.: "Quinta-feira, 20 de novembro".
  static String fullDate(DateTime date) {
    final text = DateFormat("EEEE, d 'de' MMMM", _locale).format(date);
    return _capitalize(text);
  }

  /// Ex.: "Quinta-feira, 20 de novembro de 2026".
  static String fullDateWithYear(DateTime date) {
    final text = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", _locale).format(date);
    return _capitalize(text);
  }

  /// Ex.: "novembro de 2026" (para o calendário de consultas).
  static String monthYear(DateTime date) {
    final text = DateFormat("MMMM 'de' yyyy", _locale).format(date);
    return _capitalize(text);
  }

  /// Ex.: "12 de março".
  static String dayMonth(DateTime date) {
    return DateFormat("d 'de' MMMM", _locale).format(date);
  }

  /// Ex.: "20/11/2026".
  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', _locale).format(date);
  }

  /// Ex.: "08:30".
  static String time(DateTime date) {
    return DateFormat('HH:mm', _locale).format(date);
  }

  /// Ex.: "15h" ou "15h30" (para frases como "consulta às 15h").
  static String hourLabel(DateTime date) {
    if (date.minute == 0) return '${date.hour}h';
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formato de data usado na API e no banco local: "2026-11-20".
  static String isoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Lê "dd/MM/yyyy". Devolve null se o texto não for uma data válida.
  static DateTime? tryParseShortDate(String text) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(text);
    } on FormatException {
      return null;
    }
  }

  /// Bom dia, Boa tarde ou Boa noite, conforme o horário.
  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Bom dia';
    if (now.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Ex.: "Sincronizado há 2 min".
  static String syncLabel(DateTime? lastSync, DateTime now) {
    if (lastSync == null) return 'Ainda não sincronizado';

    final difference = now.difference(lastSync);
    if (difference.inMinutes < 1) return 'Sincronizado agora';
    if (difference.inMinutes < 60) {
      return 'Sincronizado há ${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return 'Sincronizado há ${difference.inHours} h';
    }
    return 'Sincronizado em ${shortDate(lastSync)}';
  }

  /// Quantos dias de calendário faltam de [from] até [to] (negativo se já passou).
  static int daysBetween(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
