import 'package:elo_vital/src/database/app_database.dart';
import 'package:elo_vital/src/models/user_local_entity.dart';
import 'package:elo_vital/src/models/user_model.dart';
import 'package:elo_vital/src/services/auth_exception.dart';

/// Contas de usuário salvas no celular (dados locais de teste, usados enquanto
/// a API não está pronta).
class AuthLocalRepository {
  static const String _table = 'users';

  final AppDatabase appDatabase;

  AuthLocalRepository({required this.appDatabase});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    final db = await appDatabase.database;
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      _table,
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }

    final entity = UserLocalEntity(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      birthDate: birthDate,
    );
    final id = await db.insert(_table, entity.toMap());

    return UserModel(
      id: id,
      name: entity.name,
      email: entity.email,
      birthDate: entity.birthDate,
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      _table,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty || rows.first['password'] != password) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    return UserLocalEntity.fromMap(rows.first).toUserModel();
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserLocalEntity.fromMap(rows.first).toUserModel();
  }
}
