import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para las tarjetas del resumen crítico
/// Aplicando principio de responsabilidad única (SRP)
class SummaryCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color iconColor;

  const SummaryCard({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AddressDetailStyles.paddingSmall),
      decoration: AddressDetailStyles.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AddressDetailStyles.iconSizeSmall,
            color: iconColor,
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: AddressDetailStyles.numberStyle,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AddressDetailStyles.labelStyle,
          ),
        ],
      ),
    );
  }
}
