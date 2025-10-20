import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Tarjeta de información de mascota
class PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final petType = pet['type'] as String;
    final icon = petType == 'Perro' ? Icons.pets : Icons.emoji_nature;
    final color = petType == 'Perro' ? AppTheme.dogColor : AppTheme.catColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceXl),
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: AppTheme.iconXl),
          ),
          const SizedBox(width: AppTheme.spaceXl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name'] as String,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppTheme.paddingXs),
                Text(
                  '${pet['type']} • ${pet['size']} • ${pet['breed']} • ${pet['weight']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
