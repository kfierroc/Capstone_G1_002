import 'package:flutter/material.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';
import '../utils/responsive.dart';

class GrifoSearchSection extends StatefulWidget {
  final String filtroEstado;
  final Function(String) onBusquedaChanged;
  final Function(String?) onFiltroChanged;

  const GrifoSearchSection({
    super.key,
    required this.filtroEstado,
    required this.onBusquedaChanged,
    required this.onFiltroChanged,
  });

  @override
  State<GrifoSearchSection> createState() => _GrifoSearchSectionState();
}

class _GrifoSearchSectionState extends State<GrifoSearchSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: GrifoStyles.borderRadiusMedium,
        boxShadow: GrifoStyles.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buscar y Filtrar',
            style: GrifoStyles.titleLarge,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildSearchField(),
          SizedBox(height: isTablet ? 16 : 12),
          _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        widget.onBusquedaChanged(value);
        setState(() {}); // Actualizar el UI para mostrar/ocultar el botón de limpiar
      },
      decoration: InputDecoration(
        hintText: 'Buscar por dirección o comuna...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onBusquedaChanged('');
                  setState(() {}); // Actualizar el UI
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: GrifoColors.surfaceVariant,
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final estados = ['Todos', 'Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];
    
    // En móviles, usar layout vertical para evitar overflow
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: GrifoColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrar por estado:',
                style: GrifoStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: widget.filtroEstado,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: GrifoColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: estados.map((estado) {
              return DropdownMenuItem<String>(
                value: estado,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: estado == 'Todos' 
                            ? GrifoColors.grey 
                            : GrifoColors.getEstadoColor(estado),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        estado,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: widget.onFiltroChanged,
          ),
        ],
      );
    }
    
    // En tablets y desktop, usar layout horizontal
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          color: GrifoColors.textSecondary,
          size: isTablet ? 24 : 20,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Flexible(
          child: Text(
            'Filtrar por estado:',
            style: GrifoStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: widget.filtroEstado,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: GrifoColors.surfaceVariant,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 16 : 12,
              ),
            ),
            items: estados.map((estado) {
              return DropdownMenuItem<String>(
                value: estado,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: estado == 'Todos' 
                            ? GrifoColors.grey 
                            : GrifoColors.getEstadoColor(estado),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Flexible(
                      child: Text(
                        estado,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: widget.onFiltroChanged,
          ),
        ),
      ],
    );
  }
}
