import 'package:elo_vital/src/screens/home_screen.dart';
import 'package:elo_vital/src/screens/quick_register_screen.dart';
import 'package:elo_vital/src/screens/settings_screen.dart';
import 'package:elo_vital/src/widgets/placeholder_tab_widget.dart';
import 'package:flutter/material.dart';

/// Tela principal com a barra inferior: Início, Consultas, Registrar e Ajustes.
/// A aba Consultas ainda mostra um espaço provisório.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    PlaceholderTabWidget(title: 'Consultas', icon: Icons.event_outlined),
    QuickRegisterScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Consultas',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Registrar',
          ),
          // "Configurações" não cabia numa linha só e quebrava a palavra. O
          // rótulo curto "Ajustes" cabe, e o tooltip mantém o nome completo
          // (leitor de tela e toque longo).
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
            tooltip: 'Configurações',
          ),
        ],
      ),
    );
  }
}
