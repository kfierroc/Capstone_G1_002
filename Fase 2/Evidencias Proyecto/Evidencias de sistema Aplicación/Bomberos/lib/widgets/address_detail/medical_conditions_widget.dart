import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para mostrar condiciones médicas
/// Aplicando principio de responsabilidad única (SRP)
class MedicalConditionsWidget extends StatelessWidget {
  final List<String> conditions;

  const MedicalConditionsWidget({
    super.key,
    required this.conditions,
  });

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AddressDetailStyles.paddingMedium),
      decoration: AddressDetailStyles.lightRedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚨 Condiciones Médicas/Especiales:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AddressDetailStyles.darkRed,
            ),
          ),
          const SizedBox(height: AddressDetailStyles.paddingSmall),
          Wrap(
            spacing: AddressDetailStyles.paddingSmall,
            runSpacing: AddressDetailStyles.paddingSmall,
            children: conditions
                .map(
                  (condition) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AddressDetailStyles.paddingMedium,
                      vertical: 6,
                    ),
                    decoration: AddressDetailStyles.chipDecoration,
                    child: Text(
                      condition,
                      style: const TextStyle(
                        color: AddressDetailStyles.darkGray,
                        fontSize: AddressDetailStyles.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
