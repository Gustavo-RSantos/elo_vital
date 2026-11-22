import 'package:flutter/material.dart';

/// Conteúdo de uma página do Onboarding: título, texto e a identidade visual
/// da ilustração (ícone e cores).
class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
