import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../utils/responsive.dart';

/// Widget para mostrar estadística crítica
class CriticalStatWidget extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const CriticalStatWidget({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? AppTheme.spaceXl : AppTheme.spaceLg),
          decoration: BoxDecoration(
            color: AppTheme.textWhite.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(
              isTablet ? AppTheme.radius : AppTheme.radiusMd,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.textWhite,
            size: isTablet ? AppTheme.iconXxl : AppTheme.iconLg,
          ),
        ),
        SizedBox(height: isTablet ? AppTheme.spaceLg : AppTheme.space),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: AppTheme.fontTitleSize,
              tablet: 28,
              desktop: 32,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textWhite70,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: AppTheme.fontXsSize,
              tablet: AppTheme.fontSmSize,
              desktop: AppTheme.fontMd,
            ),
          ),
        ),
      ],
    );
  }
}
