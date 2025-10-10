import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';

/// Tarjeta de información de contacto
class ContactCard extends StatelessWidget {
  final String mainPhone;
  final String altPhone;

  const ContactCard({
    super.key,
    required this.mainPhone,
    required this.altPhone,
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
            'Información de Contacto',
            style: AppTextStyles.titleLarge,
          ),
          const Divider(height: AppSizes.paddingXl),
          _ContactRow(
            label: 'Contacto Principal',
            phone: mainPhone,
            icon: Icons.phone,
          ),
          const SizedBox(height: AppSizes.spaceXl),
          _ContactRow(
            label: 'Contacto Alternativo',
            phone: altPhone,
            icon: Icons.phone_android,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String label;
  final String phone;
  final IconData icon;

  const _ContactRow({
    required this.label,
    required this.phone,
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
        Text(
          phone,
          style: AppTextStyles.bodyLarge,
        ),
      ],
    );
  }
}
