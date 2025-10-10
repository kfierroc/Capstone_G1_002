import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';

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
    final color = petType == 'Perro' ? AppColors.dogColor : AppColors.catColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceXl),
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconXl),
          ),
          const SizedBox(width: AppSizes.spaceXl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name'] as String,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSizes.paddingXs),
                Text(
                  '${pet['type']} • ${pet['size']} • ${pet['breed']} • ${pet['weight']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
