import 'package:elo_vital/src/database/app_settings_local_repository.dart';
import 'package:elo_vital/src/database/auth_local_repository.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/enums/start_destination_enum.dart';
import 'package:elo_vital/src/models/user_model.dart';
import 'package:elo_vital/src/services/auth_service.dart';
import 'package:elo_vital/src/utils/error_message_helper.dart';
import 'package:flutter/foundation.dart';

/// Controla login, cadastro e sessão. Com USE_LOCAL_DATA=true (padrão) usa o
/// SQLite do celular; com USE_LOCAL_DATA=false usa a API pelo AuthService.
class AuthController extends ChangeNotifier {
  final AuthLocalRepository authLocalRepository;
  final AuthService authService;
  final AppSettingsLocalRepository settingsRepository;

  AuthController({
    required this.authLocalRepository,
    required this.authService,
    required this.settingsRepository,
  });

  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  bool get _useLocalData => EnvironmentEnum.useLocalData.value == 'true';

  /// Decide a primeira tela depois da Splash.
  Future<StartDestinationEnum> loadStartDestination() async {
    try {
      final userId = await settingsRepository.getSessionUserId();
      if (userId != null) {
        // TODO(API): restaurar a sessão a partir do token salvo.
        final user = await authLocalRepository.getUserById(userId);
        if (user != null) {
          currentUser = user;
          return StartDestinationEnum.main;
        }
        await settingsRepository.clearSession();
      }

      final onboardingSeen = await settingsRepository.isOnboardingSeen();
      return onboardingSeen
          ? StartDestinationEnum.login
          : StartDestinationEnum.onboarding;
    } catch (error) {
      debugPrint('Erro ao carregar o destino inicial: $error');
      return StartDestinationEnum.onboarding;
    }
  }

  Future<void> markOnboardingSeen() async {
    try {
      await settingsRepository.setOnboardingSeen();
    } catch (error) {
      debugPrint('Erro ao salvar que o Onboarding foi visto: $error');
    }
  }

  Future<bool> login({required String email, required String password}) {
    return _runAuth(() {
      if (_useLocalData) {
        return authLocalRepository.login(email: email, password: password);
      }
      return authService.login(email: email, password: password);
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  }) {
    return _runAuth(() {
      if (_useLocalData) {
        return authLocalRepository.register(
          name: name,
          email: email,
          password: password,
          birthDate: birthDate,
        );
      }
      return authService.register(
        name: name,
        email: email,
        password: password,
        birthDate: birthDate,
      );
    });
  }

  Future<void> logout() async {
    await settingsRepository.clearSession();
    authService.accessToken = null;
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuth(Future<UserModel> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await action();
      currentUser = user;
      await settingsRepository.saveSession(user.id);
      return true;
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
