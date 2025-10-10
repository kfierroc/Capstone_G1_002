import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';
import '../utils/responsive.dart';
import 'critical_stat_widget.dart';

/// Tarjeta de resumen crítico
class CriticalSummaryCard extends StatelessWidget {
  final int peopleCount;
  final int petsCount;
  final int specialConditionsCount;

  const CriticalSummaryCard({
    super.key,
    required this.peopleCount,
    required this.petsCount,
    required this.specialConditionsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: EdgeInsets.all(isTablet ? AppSizes.paddingXxl : AppSizes.paddingLg),
      decoration: AppDecorations.redGradient(
        borderRadius: isTablet ? AppSizes.radiusLg : AppSizes.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Crítico',
            style: AppTextStyles.whiteTitle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppSizes.fontXl,
                tablet: AppSizes.fontTitle,
                desktop: 26,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.paddingXl : AppSizes.spaceXxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CriticalStatWidget(
                value: peopleCount.toString(),
                label: 'Personas',
                icon: Icons.people,
              ),
              CriticalStatWidget(
                value: petsCount.toString(),
                label: 'Mascotas',
                icon: Icons.pets,
              ),
              CriticalStatWidget(
                value: specialConditionsCount.toString(),
                label: 'Con condiciones',
                icon: Icons.medical_services,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
