/// Usuário (idoso) usado pelo app. Também é o formato devolvido pela API.
class UserModel {
  final int id;
  final String name;
  final String email;
  final DateTime birthDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.birthDate,
  });

  /// Primeiro nome, usado na saudação ("Bom dia, Maria!").
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isEmpty ? '' : parts.first;
  }

  /// Contrato sugerido com a API: {"id": 1, "name": "...", "email": "...",
  /// "birthDate": "1955-03-12"}. Ajustar quando o backend estiver pronto.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
    );
  }
}
