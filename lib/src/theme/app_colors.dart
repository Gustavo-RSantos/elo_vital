import 'package:flutter/material.dart';

/// Paleta do Elo Vital, extraída da logo e ajustada para contraste mínimo de
/// 4.5:1 em textos. As cores de "decoração" nunca devem ser usadas em texto.
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFF462D77);
  static const Color primaryHover = Color(0xFF684892);
  static const Color accent = Color(0xFFC93851); // coral de ação (texto branco)
  static const Color brandCoral = Color(0xFFF46473); // só decoração

  // Texto
  static const Color textPrimary = Color(0xFF11134C);
  static const Color textSecondary = Color(0xFF55507A);

  // Fundos e bordas
  static const Color background = Color(0xFFFBF9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1EDF8);
  static const Color border = Color(0xFFE4DDF0);

  // Decoração (nunca texto)
  static const Color lavender = Color(0xFF998DC4);
  static const Color orchid = Color(0xFFAC6ABA);
  static const Color pink = Color(0xFFE8749B);
  static const Color salmon = Color(0xFFFC866B);
  static const Color orange = Color(0xFFFDA065);

  // Gradiente da marca: só em splash, faixas finas e ilustrações
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, brandCoral, orange],
  );

  // Estados
  static const Color success = Color(0xFF2E7D5B);
  static const Color successSoft = Color(0xFFEAF6F0);
  static const Color successText = Color(0xFF1F6B4A);
  static const Color warningSoft = Color(0xFFFFF3E8);
  static const Color warningText = Color(0xFF8A4B0F);
  static const Color error = Color(0xFFB3261E);
  static const Color errorSoft = Color(0xFFFDECEA);
  static const Color errorText = Color(0xFF8C1D18);

  // Tipos de atividade: cor do ícone, fundo suave e cor do texto
  static const Color medicine = Color(0xFF462D77);
  static const Color medicineSoft = Color(0xFFF1EDF8);
  static const Color medicineText = Color(0xFF462D77);

  static const Color measurement = Color(0xFFF46473);
  static const Color measurementSoft = Color(0xFFFFF0F1);
  static const Color measurementText = Color(0xFFB83048);

  static const Color water = Color(0xFF998DC4);
  static const Color waterSoft = Color(0xFFF1F0FA);
  static const Color waterText = Color(0xFF4F4694);

  static const Color exercise = Color(0xFFFDA065);
  static const Color exerciseSoft = Color(0xFFFFF3E8);
  static const Color exerciseText = Color(0xFF9A4A0C);

  static const Color appointment = Color(0xFFAC6ABA);
  static const Color appointmentSoft = Color(0xFFF8EDFA);
  static const Color appointmentText = Color(0xFF7A3A8A);
}
