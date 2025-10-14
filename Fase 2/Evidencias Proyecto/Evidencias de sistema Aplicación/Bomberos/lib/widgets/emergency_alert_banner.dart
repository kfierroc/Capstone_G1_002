import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';
import '../utils/responsive.dart';

/// Banner de alerta de modo emergencia
class EmergencyAlertBanner extends StatelessWidget {
  const EmergencyAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      width: double.infinity,
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: EdgeInsets.all(isTablet ? AppSizes.paddingXxl : AppSizes.paddingLg),
      decoration: AppDecorations.redGradient(
        borderRadius: isTablet ? AppSizes.radiusLg : AppSizes.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🚨 MODO EMERGENCIA ACTIVO',
            style: AppTextStyles.whiteTitle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppSizes.fontLg,
                tablet: AppSizes.fontXxl,
                desktop: 24,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.spaceLg : AppSizes.space),
          Text(
            'Este sistema proporciona información crítica para operaciones de rescate. '
            'Verifica siempre la información y mantén comunicación con el centro de comando.',
            style: AppTextStyles.whiteBody.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppSizes.fontSm,
                tablet: AppSizes.font,
                desktop: AppSizes.fontLg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
