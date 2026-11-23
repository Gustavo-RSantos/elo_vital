/// Validações simples dos formulários, com mensagens claras para o usuário.
class FormValidators {
  FormValidators._();

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? value) {
    final emptyError = FormValidators.requiredField(value, 'Digite o seu nome.');
    if (emptyError != null) return emptyError;
    if (value!.trim().length < 3) return 'Digite o seu nome completo.';
    return null;
  }

  static String? email(String? value) {
    final emptyError = FormValidators.requiredField(value, 'Digite o seu e-mail.');
    if (emptyError != null) return emptyError;
    if (!_emailRegExp.hasMatch(value!.trim())) {
      return 'Digite um e-mail válido, como exemplo@email.com.';
    }
    return null;
  }

  static String? newPassword(String? value) {
    final emptyError = FormValidators.requiredField(value, 'Crie uma senha.');
    if (emptyError != null) return emptyError;
    if (value!.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
    return null;
  }

  /// Número inteiro dentro de uma faixa (usado nas medições de saúde).
  static String? integerInRange(
    String? value, {
    required String emptyMessage,
    required int min,
    required int max,
    required String rangeMessage,
  }) {
    final emptyError = requiredField(value, emptyMessage);
    if (emptyError != null) return emptyError;

    final number = int.tryParse(value!.trim());
    if (number == null || number < min || number > max) return rangeMessage;
    return null;
  }
}
