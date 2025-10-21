import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para mostrar instrucciones especiales
/// Aplicando principio de responsabilidad única (SRP)
class SpecialInstructionsWidget extends StatelessWidget {
  final String? instructions;

  const SpecialInstructionsWidget({
    super.key,
    this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      decoration: AddressDetailStyles.yellowCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⚠️',
                style: TextStyle(fontSize: AddressDetailStyles.iconSizeSmall),
              ),
              const SizedBox(width: AddressDetailStyles.paddingSmall),
              const Text(
                'Instrucciones Especiales',
                style: TextStyle(
                  fontSize: AddressDetailStyles.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AddressDetailStyles.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: AddressDetailStyles.paddingSmall),
          Text(
            instructions ?? 'No especificadas',
            style: const TextStyle(
              fontSize: AddressDetailStyles.fontSizeLarge,
              color: AddressDetailStyles.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
