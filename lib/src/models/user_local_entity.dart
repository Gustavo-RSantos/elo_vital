import 'package:elo_vital/src/models/user_model.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';

/// Linha da tabela `users` do SQLite.
///
/// Atenção: a senha fica salva em texto puro apenas porque estes são dados
/// locais de teste. Com a API, a senha nunca fica no celular (o backend
/// guarda o hash BCrypt).
class UserLocalEntity {
  final int? id;
  final String name;
  final String email;
  final String password;
  final DateTime birthDate;

  const UserLocalEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
  });

  factory UserLocalEntity.fromMap(Map<String, Object?> map) {
    return UserLocalEntity(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'birth_date': AppDateFormat.isoDate(birthDate),
    };
  }

  UserModel toUserModel() {
    return UserModel(id: id!, name: name, email: email, birthDate: birthDate);
  }
}
