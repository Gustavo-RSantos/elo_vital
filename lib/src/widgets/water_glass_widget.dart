import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Copo ilustrado em lavanda que se enche conforme o progresso da meta (0 a 1).
class WaterGlassWidget extends StatelessWidget {
  const WaterGlassWidget({super.key, required this.progress});

  final double progress;

  static const double _width = 150;
  static const double _height = 210;
  static const double _border = 5;

  @override
  Widget build(BuildContext context) {
    const innerHeight = _height - _border * 2;

    return Semantics(
      label: 'Copo de água',
      value: '${(progress * 100).round()}% da meta do dia',
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: AppColors.waterSoft,
          border: Border.all(color: AppColors.lavender, width: _border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            topRight: Radius.circular(7),
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: innerHeight * progress,
              color: AppColors.lavender,
            ),
          ),
        ),
      ),
    );
  }
}
