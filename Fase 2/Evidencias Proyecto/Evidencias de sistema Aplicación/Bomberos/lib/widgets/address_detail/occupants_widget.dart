import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';
import 'medical_conditions_widget.dart';

/// Widget reutilizable para mostrar información de ocupantes
/// Aplicando principio de responsabilidad única (SRP)
class OccupantsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> integrantes;
  final List<Map<String, dynamic>> mascotas;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const OccupantsWidget({
    super.key,
    required this.integrantes,
    required this.mascotas,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Cambiar a min para evitar problemas de layout
      children: [
        const Text(
          'Ocupantes del Domicilio',
          style: TextStyle(
            fontSize: AddressDetailStyles.fontSizeXLarge,
            fontWeight: FontWeight.bold,
            color: AddressDetailStyles.darkGray,
          ),
        ),
        const SizedBox(height: AddressDetailStyles.paddingLarge),
        _buildTabBar(),
        const SizedBox(height: AddressDetailStyles.paddingLarge),
        // Usar SizedBox con altura fija en lugar de Expanded
        SizedBox(
          height: 400, // Aumentar altura para mejor visualización
          child: selectedTab == 0
              ? _buildPersonasList()
              : _buildMascotasList(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabChanged(0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AddressDetailStyles.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: selectedTab == 0
                    ? AddressDetailStyles.blue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AddressDetailStyles.radiusSmall),
              ),
              child: const Text(
                'Personas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AddressDetailStyles.darkGray,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabChanged(1),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AddressDetailStyles.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: selectedTab == 1
                    ? AddressDetailStyles.blue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AddressDetailStyles.radiusSmall),
              ),
              child: const Text(
                'Mascotas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AddressDetailStyles.darkGray,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonasList() {
    return ListView.builder(
      itemCount: integrantes.length,
      itemBuilder: (context, index) {
        final integrante = integrantes[index];
        final conditions = _extractConditions(integrante);
        
        return Container(
          margin: const EdgeInsets.only(bottom: AddressDetailStyles.paddingMedium),
          padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
          decoration: BoxDecoration(
            color: AddressDetailStyles.lightGray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AddressDetailStyles.radiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AddressDetailStyles.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Persona ${index + 1}',
                    style: const TextStyle(
                      fontSize: AddressDetailStyles.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AddressDetailStyles.darkGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AddressDetailStyles.paddingSmall),
              Text(
                'Edad: ${integrante['edad'] ?? 'No especificada'}',
                style: AddressDetailStyles.valueStyle,
              ),
              if (conditions.isNotEmpty) ...[
                const SizedBox(height: AddressDetailStyles.paddingMedium),
                MedicalConditionsWidget(conditions: conditions),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMascotasList() {
    return ListView.builder(
      itemCount: mascotas.length,
      itemBuilder: (context, index) {
        final mascota = mascotas[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: AddressDetailStyles.paddingMedium),
          padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
          decoration: BoxDecoration(
            color: AddressDetailStyles.lightGray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AddressDetailStyles.radiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: AddressDetailStyles.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mascota['nombre_m'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: AddressDetailStyles.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AddressDetailStyles.darkGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AddressDetailStyles.paddingSmall),
              Text(
                'Especie: ${mascota['especie'] ?? 'No especificada'}',
                style: AddressDetailStyles.valueStyle,
              ),
              const SizedBox(height: 2),
              Text(
                'Tamaño: ${mascota['tamanio'] ?? 'No especificado'}',
                style: AddressDetailStyles.valueStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _extractConditions(Map<String, dynamic> integrante) {
    final padecimiento = integrante['padecimiento'] as String?;
    if (padecimiento == null || padecimiento.isEmpty) {
      return [];
    }
    return padecimiento.split(',').map((e) => e.trim()).toList();
  }
}
