import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

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
      margin: const EdgeInsets.only(bottom: AppTheme.spaceXl),
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: isOwner ? AppTheme.ownerBackground : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isOwner ? AppTheme.ownerBorder : AppTheme.border,
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
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'RUT: ${person['rut']}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '${person['age']} años',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              '⚠️ Condiciones Médicas/Especiales:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppTheme.fontMd,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.space),
            Wrap(
              spacing: AppTheme.space,
              runSpacing: AppTheme.space,
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
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.medicalBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.medicalBorder),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: AppTheme.fontSm,
          fontWeight: FontWeight.w600,
          color: AppTheme.medicalText,
        ),
      ),
    );
  }
}
