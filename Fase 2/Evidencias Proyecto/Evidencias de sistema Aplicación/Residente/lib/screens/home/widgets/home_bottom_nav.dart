import 'package:flutter/material.dart';

/// Bottom Navigation Bar personalizado para la pantalla de residente
/// Sigue el principio de Single Responsibility (SRP)
class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 600;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedFontSize: isTablet ? 14 : 12,
      unselectedFontSize: isTablet ? 12 : 10,
      iconSize: isTablet ? 28 : 24,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          activeIcon: Icon(Icons.people),
          label: 'Familia',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          activeIcon: Icon(Icons.pets),
          label: 'Mascotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          activeIcon: Icon(Icons.home),
          label: 'Domicilio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          activeIcon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }
}
