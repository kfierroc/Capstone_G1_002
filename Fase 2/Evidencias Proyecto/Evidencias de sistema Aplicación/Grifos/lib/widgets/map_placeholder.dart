import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Widget placeholder para el mapa
class MapPlaceholder extends StatelessWidget {
  final int itemCount;
  final bool showControls;

  const MapPlaceholder({
    Key? key,
    required this.itemCount,
    this.showControls = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveHelper.padding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      height: ResponsiveHelper.spacing(
        context,
        mobile: 200,
        tablet: 300,
        desktop: 400,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: AppStyles.borderRadiusSmall,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: ResponsiveHelper.iconSize(
                    context,
                    mobile: 60,
                    tablet: 80,
                    desktop: 100,
                  ),
                  color: Colors.grey[600],
                ),
                SizedBox(
                  height: ResponsiveHelper.spacing(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Text(
                  'Mapa Interactivo',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: AppStyles.spacingSmall),
                Text(
                  'Vista geográfica de todos los grifos registrados ($itemCount mostrados)',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (showControls)
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    onPressed: () {},
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    onPressed: () {},
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Operativo', AppColors.operativo),
        const SizedBox(width: 12),
        _buildLegendItem('Dañado', AppColors.danado),
        const SizedBox(width: 12),
        _buildLegendItem('Mantenimiento', AppColors.mantenimiento),
        const SizedBox(width: 12),
        _buildLegendItem('Sin verificar', AppColors.sinVerificar),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

