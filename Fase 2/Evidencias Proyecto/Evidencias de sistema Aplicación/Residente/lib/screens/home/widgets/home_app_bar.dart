import 'package:flutter/material.dart';
// import '../../shared_package/lib/design_system/colors/app_colors.dart';
// import '../../shared_package/lib/design_system/typography/text_styles.dart';

/// AppBar personalizado para la pantalla de residente
/// Sigue el principio de Single Responsibility (SRP)
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogoutPressed;
  final bool isLoading;

  const HomeAppBar({
    super.key,
    required this.onLogoutPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 600;

    return AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi Información Familiar',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Gestiona la información de tu domicilio',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        else
          IconButton(
            onPressed: onLogoutPressed,
            icon: Icon(
              Icons.logout,
              size: isTablet ? 26 : 24,
            ),
            tooltip: 'Cerrar sesión',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
