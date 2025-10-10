import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../utils/app_styles.dart';

/// Card optimizado para mostrar información de miembro de familia
class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Persona ${index + 1}', style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${member.age} años (${member.birthYear})',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.info),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
          if (member.conditions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Condicion:',
              style: AppTextStyles.labelText,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: member.conditions.map(_buildConditionChip).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        condition,
        style: AppTextStyles.chipText.copyWith(color: Colors.red.shade900),
      ),
    );
  }
}

