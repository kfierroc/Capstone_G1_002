import 'package:flutter/material.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';
import '../utils/responsive.dart';

class GrifoMapPlaceholder extends StatelessWidget {
  final int itemCount;

  const GrifoMapPlaceholder({
    super.key,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      height: isTablet ? 300 : 200,
      decoration: BoxDecoration(
        color: GrifoColors.surfaceVariant,
        borderRadius: GrifoStyles.borderRadiusMedium,
        border: Border.all(
          color: GrifoColors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: isTablet ? 64 : 48,
            color: GrifoColors.grey,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Mapa de Grifos',
            style: GrifoStyles.titleMedium.copyWith(
              color: GrifoColors.textSecondary,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            '$itemCount grifos encontrados',
            style: GrifoStyles.bodyMedium.copyWith(
              color: GrifoColors.textTertiary,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 12 : 8,
            ),
            decoration: BoxDecoration(
              color: GrifoColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Funcionalidad de mapa próximamente',
              style: GrifoStyles.bodySmall.copyWith(
                color: GrifoColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
