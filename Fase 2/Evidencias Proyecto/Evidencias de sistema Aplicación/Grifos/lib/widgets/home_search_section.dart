import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_styles.dart';
import '../utils/responsive_helper.dart';

/// Sección de búsqueda y filtros para la pantalla principal
class HomeSearchSection extends StatelessWidget {
  final String filtroEstado;
  final Function(String) onBusquedaChanged;
  final Function(String?) onFiltroChanged;

  const HomeSearchSection({
    Key? key,
    required this.filtroEstado,
    required this.onBusquedaChanged,
    required this.onFiltroChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.padding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buscar y Filtrar Grifos',
            style: AppStyles.titleMedium,
          ),
          const SizedBox(height: AppStyles.spacingMedium),
          TextField(
            decoration: AppStyles.getInputDecoration(
              labelText: 'Buscar',
              hintText: 'Buscar por dirección o comuna...',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: onBusquedaChanged,
          ),
          const SizedBox(height: AppStyles.spacingMedium),
          DropdownButtonFormField<String>(
            initialValue: filtroEstado,
            decoration: AppStyles.getInputDecoration(labelText: 'Estado'),
            items: AppConstants.estadosGrifo
                .map((estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    ))
                .toList(),
            onChanged: onFiltroChanged,
          ),
        ],
      ),
    );
  }
}

