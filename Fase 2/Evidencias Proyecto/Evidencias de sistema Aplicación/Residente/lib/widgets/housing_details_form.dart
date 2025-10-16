import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/app_data.dart';

/// Widget reutilizable para formulario de detalles de vivienda
class HousingDetailsForm extends StatelessWidget {
  final String? selectedHousingType;
  final String? numberOfFloors;
  final String? selectedMaterial;
  final String? selectedCondition;
  final Function(String?) onHousingTypeChanged;
  final Function(String?) onFloorsChanged;
  final Function(String?) onMaterialChanged;
  final Function(String?) onConditionChanged;

  const HousingDetailsForm({
    super.key,
    required this.selectedHousingType,
    required this.numberOfFloors,
    required this.selectedMaterial,
    required this.selectedCondition,
    required this.onHousingTypeChanged,
    required this.onFloorsChanged,
    required this.onMaterialChanged,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalles de la Vivienda', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.lg),
        
        // Tipo de vivienda
        DropdownButtonFormField<String>(
          initialValue: selectedHousingType,
          decoration: InputDecoration(
            labelText: 'Tipo de vivienda *',
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          items: HousingData.types
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: onHousingTypeChanged,
          validator: (value) => value == null ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Número de pisos
        DropdownButtonFormField<String>(
          initialValue: numberOfFloors,
          decoration: InputDecoration(
            labelText: 'Número de pisos *',
            prefixIcon: const Icon(Icons.layers_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          items: List.generate(62, (index) => index + 1)
              .map((floors) => DropdownMenuItem(
                    value: floors.toString(),
                    child: Text('$floors ${floors == 1 ? 'piso' : 'pisos'}'),
                  ))
              .toList(),
          onChanged: onFloorsChanged,
          validator: (value) => value == null ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Material de construcción
        DropdownButtonFormField<String>(
          initialValue: selectedMaterial,
          decoration: InputDecoration(
            labelText: 'Material principal *',
            prefixIcon: const Icon(Icons.construction_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          items: HousingData.materials
              .map((material) =>
                  DropdownMenuItem(value: material, child: Text(material)))
              .toList(),
          onChanged: onMaterialChanged,
          validator: (value) => value == null ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Estado de la vivienda
        DropdownButtonFormField<String>(
          initialValue: selectedCondition,
          decoration: InputDecoration(
            labelText: 'Estado general *',
            prefixIcon: const Icon(Icons.home_repair_service_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          items: HousingData.conditions
              .map((condition) =>
                  DropdownMenuItem(value: condition, child: Text(condition)))
              .toList(),
          onChanged: onConditionChanged,
          validator: (value) => value == null ? 'Requerido' : null,
        ),
      ],
    );
  }
}

