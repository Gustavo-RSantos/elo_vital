import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema global do Elo Vital: fonte Nunito, texto base de 18px, botões de 56px,
/// cantos de 16px e alvos de toque de, no mínimo, 48px.
class AppTheme {
  AppTheme._();

  static const double buttonHeight = 56;
  static const double radius = 16;

  static final RoundedRectangleBorder _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),
    );

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: _shape,
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: _shape,
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: _inputBorder(AppColors.border, 1.5),
        enabledBorder: _inputBorder(AppColors.border, 1.5),
        focusedBorder: _inputBorder(AppColors.primary, 3),
        errorBorder: _inputBorder(AppColors.error, 2),
        focusedErrorBorder: _inputBorder(AppColors.error, 3),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.12),
        margin: EdgeInsets.zero,
        shape: _shape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        height: 76,
        indicatorColor: AppColors.surfaceSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 28,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
    );
  }

  /// Botão de destaque em coral (ex.: "Nova consulta", "Convidar idoso").
  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(buttonHeight),
    shape: _shape,
    elevation: 0,
  );

  static OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    final nunito = GoogleFonts.nunitoTextTheme(
      base,
    ).apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

    // Nenhum texto abaixo de 16px; base de 18px; títulos de 24 a 28px.
    return nunito.copyWith(
      headlineMedium: nunito.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: nunito.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: nunito.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: nunito.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: nunito.titleSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: nunito.bodyLarge?.copyWith(fontSize: 18),
      bodyMedium: nunito.bodyMedium?.copyWith(fontSize: 18),
      bodySmall: nunito.bodySmall?.copyWith(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      labelLarge: nunito.labelLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: nunito.labelMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: nunito.labelSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
