import 'package:flutter/material.dart';
import '../models/mascota.dart';
import '../utils/app_styles.dart';

/// Card optimizado para mostrar información de mascota
class PetCard extends StatelessWidget {
  final Mascota pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PetCard({
    super.key,
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.pets,
              color: AppColors.petsPrimary,
              size: AppIconSizes.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.nombreM, style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${pet.especie} • ${pet.tamanio}',
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
    );
  }
}

