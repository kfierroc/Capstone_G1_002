import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';

/// Tarjeta de información del domicilio
class AddressInfoCard extends StatelessWidget {
  final Map<String, dynamic> addressData;
  final VoidCallback onViewMap;

  const AddressInfoCard({
    super.key,
    required this.addressData,
    required this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Domicilio',
            style: AppTextStyles.titleLarge,
          ),
          const Divider(height: AppSizes.paddingXl),
          _InfoSection(
            label: 'Dirección',
            value: addressData['address'] as String,
            icon: Icons.location_on,
          ),
          const SizedBox(height: AppSizes.spaceXxl),
          const Text(
            'Detalles de la Vivienda',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSizes.spaceLg),
          _DetailRow(
            label: 'Tipo de vivienda',
            value: addressData['housing_type'] as String,
          ),
          _DetailRow(
            label: 'Piso del departamento',
            value: addressData['floor'] as String,
          ),
          _DetailRow(
            label: 'Material de construcción',
            value: addressData['construction_material'] as String,
          ),
          _DetailRow(
            label: 'Estado de la vivienda',
            value: addressData['housing_condition'] as String,
          ),
          const SizedBox(height: AppSizes.spaceXxl),
          _InfoSection(
            label: 'Instrucciones Especiales',
            value: addressData['special_instructions'] as String,
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: AppSizes.spaceXl),
          Row(
            children: [
              Icon(
                Icons.update,
                size: AppSizes.iconXs,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSizes.space),
              Text(
                'Última actualización: ${addressData['last_update']}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceXl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewMap,
              icon: const Icon(Icons.map),
              label: const Text('Ver en Mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoSection({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: AppSizes.iconSm, color: AppColors.textTertiary),
            const SizedBox(width: AppSizes.space),
            Text(label, style: AppTextStyles.subtitlePrimary),
          ],
        ),
        const SizedBox(height: AppSizes.spaceSm),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.subtitlePrimary),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
