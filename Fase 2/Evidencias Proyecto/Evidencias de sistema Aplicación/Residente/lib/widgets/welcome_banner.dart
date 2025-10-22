import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Widget de bienvenida personalizado con nombre del usuario
class WelcomeBanner extends StatelessWidget {
  final String? userName;
  final VoidCallback onLogout;
  final bool isTablet;

  const WelcomeBanner({
    super.key,
    this.userName,
    required this.onLogout,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName?.isNotEmpty == true ? userName! : 'Usuario';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isTablet ? 20 : 16),
          bottomRight: Radius.circular(isTablet ? 20 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo personalizado
          Row(
            children: [
              Icon(
                Icons.waving_hand,
                color: AppColors.textWhite,
                size: isTablet ? 32 : 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $displayName!',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenido al Sistema de Información Familiar',
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Mensaje informativo
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              border: Border.all(
                color: AppColors.textWhite.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textWhite.withValues(alpha: 0.9),
                  size: isTablet ? 20 : 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gestiona la información de tu domicilio, familia y mascotas de forma segura',
                    style: TextStyle(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón de cerrar sesión
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: Icon(
                  Icons.logout,
                  size: isTablet ? 20 : 18,
                ),
                label: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: BorderSide(
                    color: AppColors.textWhite.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 12 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
