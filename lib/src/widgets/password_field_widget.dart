import 'package:elo_vital/src/widgets/app_text_field_widget.dart';
import 'package:flutter/material.dart';

/// Campo de senha com botão para mostrar ou ocultar o que foi digitado.
class PasswordFieldWidget extends StatefulWidget {
  const PasswordFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextFieldWidget(
      controller: widget.controller,
      label: widget.label,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: isObscured,
      autofillHints: const [AutofillHints.password],
      suffixIcon: IconButton(
        tooltip: isObscured ? 'Mostrar senha' : 'Ocultar senha',
        icon: Icon(
          isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => isObscured = !isObscured),
      ),
    );
  }
}
