import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget reutilizable para mostrar alertas de emergencia
class EmergencyAlertBanner extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const EmergencyAlertBanner({
    super.key,
    this.title = 'MODO EMERGENCIA ACTIVO',
    this.description = 'Este sistema proporciona información importante para situaciones de emergencia. Verifica siempre la información y mantén comunicación con la central de comunicaciónes.',
    this.icon = Icons.emergency,
    this.gradientColors = const [Colors.red, Colors.red],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      width: double.infinity,
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 14 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isTablet ? 36 : 28,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
