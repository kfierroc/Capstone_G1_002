import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para la sección de búsqueda
/// Aplicando principio de responsabilidad única (SRP)
class SearchSectionWidget extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final VoidCallback onViewGrifos;

  const SearchSectionWidget({
    super.key,
    required this.onSearch,
    required this.onClear,
    required this.onViewGrifos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      decoration: AddressDetailStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Búsqueda de Domicilio',
            style: TextStyle(
              fontSize: AddressDetailStyles.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AddressDetailStyles.darkGray,
            ),
          ),
          const SizedBox(height: AddressDetailStyles.paddingLarge),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSearch,
                  style: AddressDetailStyles.redButtonStyle,
                  child: const Text(
                    'Buscar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AddressDetailStyles.paddingMedium),
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  style: AddressDetailStyles.outlineButtonStyle,
                  child: const Text('Limpiar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AddressDetailStyles.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewGrifos,
              icon: const Icon(Icons.water_drop),
              label: const Text('Consultar Grifos de Agua'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AddressDetailStyles.blue,
                side: const BorderSide(color: AddressDetailStyles.blue),
                padding: const EdgeInsets.symmetric(
                  vertical: AddressDetailStyles.paddingLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AddressDetailStyles.radiusSmall),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
