import 'package:flutter/material.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';
import '../utils/responsive.dart';

class GrifoStatsSection extends StatelessWidget {
  final Map<String, int> stats;

  const GrifoStatsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: GrifoStyles.borderRadiusMedium,
        boxShadow: GrifoStyles.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas de Grifos',
            style: GrifoStyles.titleLarge,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildStatsGrid(context),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 3 : 2,
      childAspectRatio: isTablet ? 1.5 : 1.2,
      crossAxisSpacing: isTablet ? 16 : 12,
      mainAxisSpacing: isTablet ? 16 : 12,
      children: [
        _buildStatCard(
          'Total',
          stats['total'].toString(),
          GrifoColors.primary,
          Icons.water_drop,
        ),
        _buildStatCard(
          'Operativos',
          stats['operativos'].toString(),
          GrifoColors.operativo,
          Icons.check_circle,
        ),
        _buildStatCard(
          'Dañados',
          stats['dañados'].toString(),
          GrifoColors.danado,
          Icons.error,
        ),
        _buildStatCard(
          'Mantenimiento',
          stats['mantenimiento'].toString(),
          GrifoColors.mantenimiento,
          Icons.build,
        ),
        _buildStatCard(
          'Sin Verificar',
          stats['sin_verificar'].toString(),
          GrifoColors.sinVerificar,
          Icons.help_outline,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: GrifoStyles.borderRadiusSmall,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GrifoStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
