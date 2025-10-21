import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para mostrar información de la vivienda
/// Aplicando principio de responsabilidad única (SRP)
class HousingInfoWidget extends StatelessWidget {
  final Map<String, dynamic> housingData;

  const HousingInfoWidget({
    super.key,
    required this.housingData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles de la Vivienda',
          style: TextStyle(
            fontSize: AddressDetailStyles.fontSizeXLarge,
            fontWeight: FontWeight.bold,
            color: AddressDetailStyles.darkGray,
          ),
        ),
        const SizedBox(height: AddressDetailStyles.paddingLarge),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.0,
          crossAxisSpacing: AddressDetailStyles.paddingLarge,
          mainAxisSpacing: AddressDetailStyles.paddingLarge,
          children: [
            _buildHousingInfoItem(
              'Tipo',
              housingData['tipo_vivienda'] as String? ?? 'No especificado',
            ),
            _buildHousingInfoItem(
              'Pisos',
              housingData['numero_pisos']?.toString() ?? 'No especificado',
            ),
            _buildHousingInfoItem(
              'Material',
              housingData['material'] as String? ?? 'No especificado',
            ),
            _buildHousingInfoItem(
              'Estado',
              housingData['estado_vivienda'] as String? ?? 'No especificado',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHousingInfoItem(String label, String value) {
    return Column(
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
    );
  }
}
