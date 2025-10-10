import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/responsive_helper.dart';
import 'stat_card.dart';

/// Sección de estadísticas para la pantalla principal
class HomeStatsSection extends StatelessWidget {
  final Map<String, int> stats;

  const HomeStatsSection({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.padding(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 16),
        tablet: const EdgeInsets.symmetric(horizontal: 20),
        desktop: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: ResponsiveHelper.isMobile(context)
          ? _buildMobileLayout()
          : _buildGridLayout(context),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total',
                value: stats['total']!,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppStyles.spacingSmall),
            Expanded(
              child: StatCard(
                label: 'Operativos',
                value: stats['operativos']!,
                color: AppColors.operativo,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingSmall),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Dañados',
                value: stats['dañados']!,
                color: AppColors.danado,
              ),
            ),
            const SizedBox(width: AppStyles.spacingSmall),
            Expanded(
              child: StatCard(
                label: 'Mantenimiento',
                value: stats['mantenimiento']!,
                color: AppColors.mantenimiento,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingSmall),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Sin verificar',
                value: stats['sin_verificar']!,
                color: AppColors.sinVerificar,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveHelper.isTablet(context) ? 3 : 5,
      childAspectRatio: 1.2,
      crossAxisSpacing: AppStyles.spacingMedium,
      mainAxisSpacing: AppStyles.spacingMedium,
      children: [
        StatCard(
          label: 'Total',
          value: stats['total']!,
          color: AppColors.info,
        ),
        StatCard(
          label: 'Operativos',
          value: stats['operativos']!,
          color: AppColors.operativo,
        ),
        StatCard(
          label: 'Dañados',
          value: stats['dañados']!,
          color: AppColors.danado,
        ),
        StatCard(
          label: 'Mantenimiento',
          value: stats['mantenimiento']!,
          color: AppColors.mantenimiento,
        ),
        StatCard(
          label: 'Sin verificar',
          value: stats['sin_verificar']!,
          color: AppColors.sinVerificar,
        ),
      ],
    );
  }
}

