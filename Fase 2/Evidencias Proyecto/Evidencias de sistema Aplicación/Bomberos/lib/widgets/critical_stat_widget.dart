import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
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
          padding: EdgeInsets.all(isTablet ? AppSizes.spaceXl : AppSizes.spaceLg),
          decoration: BoxDecoration(
            color: AppColors.textWhite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(
              isTablet ? AppSizes.radius : AppSizes.radiusMd,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.textWhite,
            size: isTablet ? AppSizes.iconXxl : AppSizes.iconLg,
          ),
        ),
        SizedBox(height: isTablet ? AppSizes.spaceLg : AppSizes.space),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: AppSizes.fontTitle,
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
            color: AppColors.textWhite70,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: AppSizes.fontXs,
              tablet: AppSizes.fontSm,
              desktop: AppSizes.font,
            ),
          ),
        ),
      ],
    );
  }
}
