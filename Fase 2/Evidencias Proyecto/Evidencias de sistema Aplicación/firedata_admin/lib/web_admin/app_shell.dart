import 'package:flutter/material.dart';
import 'package:firedata_admin/web_admin/services/navigation_service.dart';
import 'widgets/admin_sidebar.dart';

/// Estructura principal del panel administrativo.
///
/// Maneja una barra superior, navegación lateral y contenido dinámico basado
/// en la sección seleccionada. Es responsive: en pantallas pequeñas la barra
/// lateral se convierte en drawer.
class AdminAppShell extends StatefulWidget {
  const AdminAppShell({super.key});

  @override
  State<AdminAppShell> createState() => _AdminAppShellState();
}

class _AdminAppShellState extends State<AdminAppShell> {
  String _currentRoute = AdminRoutes.dashboard;

  final _navigationService = AdminNavigationService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: const Text('FireData Panel Administrativo'),
            actions: [
              IconButton(
                tooltip: 'Actualizar',
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          drawer: isWide
              ? null
              : Drawer(
                  child: AdminSidebar(
                    currentRoute: _currentRoute,
                    onDestinationSelected: (route) {
                      Navigator.of(context).pop();
                      _handleRouteChange(route);
                    },
                  ),
                ),
          body: Row(
            children: [
              if (isWide)
                AdminSidebar(
                  currentRoute: _currentRoute,
                  onDestinationSelected: _handleRouteChange,
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _navigationService.resolveRoute(_currentRoute),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleRouteChange(String route) {
    if (route == AdminRoutes.logout) {
      _navigationService.logout(context);
      return;
    }
    setState(() => _currentRoute = route);
  }
}



