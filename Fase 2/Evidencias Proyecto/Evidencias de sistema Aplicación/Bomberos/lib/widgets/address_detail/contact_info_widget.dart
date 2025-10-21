import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para mostrar información de contacto
/// Aplicando principio de responsabilidad única (SRP)
class ContactInfoWidget extends StatelessWidget {
  final String? phoneNumber;

  const ContactInfoWidget({
    super.key,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.phone,
          size: AddressDetailStyles.iconSizeSmall,
          color: AddressDetailStyles.green,
        ),
        const SizedBox(width: AddressDetailStyles.paddingSmall),
        const Text(
          'Información de Contacto',
          style: AddressDetailStyles.subtitleStyle,
        ),
      ],
    );
  }
}

/// Widget para mostrar una fila de información
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AddressDetailStyles.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AddressDetailStyles.labelStyle,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AddressDetailStyles.valueStyle,
          ),
        ],
      ),
    );
  }
}
