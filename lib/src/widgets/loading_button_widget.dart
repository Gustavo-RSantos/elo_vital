import 'package:flutter/material.dart';

/// Botão principal que mostra um indicador de carregamento e ignora toques
/// enquanto a ação está em andamento.
class LoadingButtonWidget extends StatelessWidget {
  const LoadingButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.style,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: isLoading ? () {} : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
