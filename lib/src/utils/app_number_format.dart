import 'package:intl/intl.dart';

/// Formatação de números em português do Brasil.
class AppNumberFormat {
  AppNumberFormat._();

  /// Ex.: 2000 vira "2.000 ml".
  static String ml(int value) {
    return '${NumberFormat.decimalPattern('pt_BR').format(value)} ml';
  }
}
