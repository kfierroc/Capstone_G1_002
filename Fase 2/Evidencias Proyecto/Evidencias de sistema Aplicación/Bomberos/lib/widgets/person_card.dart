import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';

/// Tarjeta de información de persona
class PersonCard extends StatelessWidget {
  final Map<String, dynamic> person;

  const PersonCard({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = person['is_owner'] as bool? ?? false;
    final conditions = person['conditions'] as List<String>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceXl),
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: isOwner ? AppColors.ownerBackground : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isOwner ? AppColors.ownerBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            person['name'] as String,
            style: AppTextStyles.titleMedium,
          ),
          if (person['rut'] != null) ...[
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              'RUT: ${person['rut']}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            '${person['age']} años',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceLg),
            Text(
              '⚠️ Condiciones Médicas/Especiales:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.font,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.space),
            Wrap(
              spacing: AppSizes.space,
              runSpacing: AppSizes.space,
              children: conditions.map((condition) {
                return _buildConditionChip(condition);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceLg,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.medicalBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.medicalBorder),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: AppColors.medicalText,
        ),
      ),
    );
  }
}
