import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget reutilizable para la AppBar del sistema de emergencias
class EmergencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isLoading;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLogoutPressed;
  final List<Widget>? actions;

  const EmergencyAppBar({
    super.key,
    this.title = 'Sistema de Emergencias',
    this.subtitle,
    this.isLoading = false,
    this.onBackPressed,
    this.onLogoutPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return AppBar(
      backgroundColor: Colors.red.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
      toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
      leading: onBackPressed != null
          ? IconButton(
              icon: Icon(Icons.arrow_back, size: isTablet ? 28 : 24),
              tooltip: 'Volver',
              onPressed: onBackPressed,
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            if (isLoading)
              SizedBox(
                height: isTablet ? 16 : 12,
                width: isTablet ? 16 : 12,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              )
            else
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 13,
                    desktop: 15,
                  ),
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
          ],
        ],
      ),
      actions: [
        if (onLogoutPressed != null)
          IconButton(
            icon: Icon(Icons.logout, size: isTablet ? 28 : 24),
            tooltip: 'Cerrar Sesión',
            onPressed: onLogoutPressed,
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
