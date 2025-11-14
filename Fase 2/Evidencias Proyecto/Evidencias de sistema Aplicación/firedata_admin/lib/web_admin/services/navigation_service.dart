import 'package:flutter/material.dart';
import 'package:firedata_admin/services/admin_auth_service.dart';
import 'package:firedata_admin/web_admin/pages/dashboard_page.dart';
import 'package:firedata_admin/web_admin/pages/firefighters_page.dart';
import 'package:firedata_admin/web_admin/pages/houses_page.dart';
import 'package:firedata_admin/web_admin/pages/residents_page.dart';
import 'package:firedata_admin/web_admin/pages/hydrants_page.dart';

/// Definición de rutas internas del panel admin.
abstract class AdminRoutes {
  static const dashboard = '/dashboard';
  static const residents = '/residents';
  static const firefighters = '/firefighters';
  static const houses = '/houses';
  static const hydrants = '/hydrants';
  static const logout = '/logout';
}

/// Servicio pequeño para centralizar la lógica de navegación del panel.
class AdminNavigationService {
  Widget resolveRoute(String route) {
    switch (route) {
      case AdminRoutes.residents:
        return const ResidentsPage();
      case AdminRoutes.firefighters:
        return const FirefightersPage();
      case AdminRoutes.houses:
        return const HousesPage();
      case AdminRoutes.hydrants:
        return const HydrantsPage();
      case AdminRoutes.dashboard:
      default:
        return const DashboardPage();
    }
  }

  Future<void> logout(BuildContext context) async {
    await AdminAuthService.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }
}




