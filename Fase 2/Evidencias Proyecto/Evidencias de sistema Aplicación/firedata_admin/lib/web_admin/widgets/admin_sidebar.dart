import 'package:flutter/material.dart';
import 'package:firedata_admin/web_admin/services/navigation_service.dart';

/// Sidebar principal del panel administrativo.
class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onDestinationSelected;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final extended = MediaQuery.of(context).size.width > 1100;

    return NavigationRail(
      selectedIndex: _routeToIndex(currentRoute),
      onDestinationSelected: (index) =>
          onDestinationSelected(_indexToRoute(index)),
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      extended: extended,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.security, color: Colors.white),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.groups_2_outlined),
          selectedIcon: Icon(Icons.groups_2),
          label: Text('Residentes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.fire_extinguisher_outlined),
          selectedIcon: Icon(Icons.fire_extinguisher),
          label: Text('Bomberos'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.house_outlined),
          selectedIcon: Icon(Icons.house),
          label: Text('Viviendas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop),
          label: Text('Grifos'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.logout),
          selectedIcon: Icon(Icons.logout),
          label: Text('Cerrar sesión'),
        ),
      ],
    );
  }

  int _routeToIndex(String route) {
    switch (route) {
      case AdminRoutes.residents:
        return 1;
      case AdminRoutes.firefighters:
        return 2;
      case AdminRoutes.houses:
        return 3;
      case AdminRoutes.hydrants:
        return 4;
      case AdminRoutes.logout:
        return 5;
      case AdminRoutes.dashboard:
      default:
        return 0;
    }
  }

  String _indexToRoute(int index) {
    switch (index) {
      case 1:
        return AdminRoutes.residents;
      case 2:
        return AdminRoutes.firefighters;
      case 3:
        return AdminRoutes.houses;
      case 4:
        return AdminRoutes.hydrants;
      case 5:
        return AdminRoutes.logout;
      case 0:
      default:
        return AdminRoutes.dashboard;
    }
  }
}



