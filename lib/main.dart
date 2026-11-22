import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/controller/routine_controller.dart';
import 'package:elo_vital/src/database/app_database.dart';
import 'package:elo_vital/src/database/app_settings_local_repository.dart';
import 'package:elo_vital/src/database/auth_local_repository.dart';
import 'package:elo_vital/src/database/routine_local_repository.dart';
import 'package:elo_vital/src/screens/splash_screen.dart';
import 'package:elo_vital/src/services/auth_service.dart';
import 'package:elo_vital/src/services/routine_service.dart';
import 'package:elo_vital/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega os nomes de dias e meses em português para o DateFormat.
  await initializeDateFormatting('pt_BR');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(create: (_) => AppDatabase()),
        Provider<AppSettingsLocalRepository>(
          create: (context) => AppSettingsLocalRepository(
            appDatabase: context.read<AppDatabase>(),
          ),
        ),
        Provider<AuthLocalRepository>(
          create: (context) =>
              AuthLocalRepository(appDatabase: context.read<AppDatabase>()),
        ),
        Provider<RoutineLocalRepository>(
          create: (context) =>
              RoutineLocalRepository(appDatabase: context.read<AppDatabase>()),
        ),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<RoutineService>(
          create: (context) =>
              RoutineService(authService: context.read<AuthService>()),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            authLocalRepository: context.read<AuthLocalRepository>(),
            authService: context.read<AuthService>(),
            settingsRepository: context.read<AppSettingsLocalRepository>(),
          ),
        ),
        ChangeNotifierProvider<RoutineController>(
          create: (context) => RoutineController(
            routineLocalRepository: context.read<RoutineLocalRepository>(),
            routineService: context.read<RoutineService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Elo Vital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
