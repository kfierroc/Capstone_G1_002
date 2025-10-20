import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget reutilizable para el botón de acceso a grifos
class GrifosButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const GrifosButton({
    super.key,
    required this.onPressed,
    this.text = 'Consultar Grifos de Agua',
    this.icon = Icons.water_drop,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      width: double.infinity,
      margin: ResponsiveHelper.getResponsiveMargin(context),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: isTablet ? 32 : 28,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 20 : 16,
            horizontal: isTablet ? 32 : 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
