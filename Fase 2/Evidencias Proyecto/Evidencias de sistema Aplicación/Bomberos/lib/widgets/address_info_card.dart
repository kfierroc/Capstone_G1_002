import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMd),
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: AppThemeDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Domicilio',
            style: AppTextStyles.titleLarge,
          ),
          const Divider(height: AppTheme.paddingXl),
          _InfoSection(
            label: 'Dirección',
            value: addressData['address'] as String,
            icon: Icons.location_on,
          ),
          const SizedBox(height: AppTheme.spaceXxl),
          const Text(
            'Detalles de la Vivienda',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppTheme.spaceLg),
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
          const SizedBox(height: AppTheme.spaceXxl),
          _InfoSection(
            label: 'Instrucciones Especiales',
            value: addressData['special_instructions'] as String,
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: AppTheme.spaceXl),
          Row(
            children: [
              Icon(
                Icons.update,
                size: AppTheme.iconXs,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: AppTheme.space),
              Text(
                'Última actualización: ${_formatLastUpdated(addressData['last_update'])}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewMap,
              icon: const Icon(Icons.map),
              label: const Text('Ver en Mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: AppTheme.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(dynamic lastUpdated) {
    if (lastUpdated == null || lastUpdated.toString().toLowerCase() == 'null') {
      return 'Hoy';
    }
    
    try {
      final dateTime = DateTime.parse(lastUpdated.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Hace menos de 1 minuto';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} minutos';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} horas';
      } else if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return 'Hace ${(difference.inDays / 7).floor()} semanas';
      }
    } catch (e) {
      return 'Hoy';
    }
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
            Icon(icon, size: AppTheme.iconSm, color: AppTheme.textTertiary),
            const SizedBox(width: AppTheme.space),
            Text(label, style: AppTextStyles.subtitlePrimary),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
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
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
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
