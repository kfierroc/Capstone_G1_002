import 'package:flutter/material.dart';
import '../../utils/responsive_constants.dart';
import '../../constants/grifo_colors.dart';

/// Componente de formulario de registro de grifo
/// Aplicando principios SOLID y Clean Code
class GrifoRegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController direccionController;
  final TextEditingController comunaController;
  final TextEditingController notasController;
  final String tipo;
  final String estado;
  final double lat;
  final double lng;
  final Function(String) onTipoChanged;
  final Function(String) onEstadoChanged;
  final Function(double) onLatChanged;
  final Function(double) onLngChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const GrifoRegisterForm({
    super.key,
    required this.formKey,
    required this.direccionController,
    required this.comunaController,
    required this.notasController,
    required this.tipo,
    required this.estado,
    required this.lat,
    required this.lng,
    required this.onTipoChanged,
    required this.onEstadoChanged,
    required this.onLatChanged,
    required this.onLngChanged,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<GrifoRegisterForm> createState() => _GrifoRegisterFormState();
}

class _GrifoRegisterFormState extends State<GrifoRegisterForm> {
  final List<String> _tipos = ['Alto flujo', 'Seco', 'Hidrante', 'Bomba'];
  final List<String> _estados = ['Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveConstants.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(20.0),
        tablet: const EdgeInsets.all(24.0),
        desktop: const EdgeInsets.all(28.0),
      ),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveConstants.getBorderRadius(
            MediaQuery.of(context).size.width,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: ResponsiveSpacing.large(context)),
            _buildDireccionField(),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            _buildComunaField(),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            _buildTipoEstadoRow(),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            _buildNotasField(),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            _buildCoordinatesSection(),
            SizedBox(height: ResponsiveSpacing.large(context)),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Información del Grifo',
      style: TextStyle(
        fontSize: ResponsiveConstants.getResponsiveFontSize(
          MediaQuery.of(context).size.width,
          mobile: 18.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
        fontWeight: FontWeight.bold,
        color: GrifoColors.textPrimary,
      ),
    );
  }

  Widget _buildDireccionField() {
    return TextFormField(
      controller: widget.direccionController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese la dirección';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Dirección',
        hintText: 'Ej: Av. Libertador 1234',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveConstants.getBorderRadius(
              MediaQuery.of(context).size.width,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            ),
          ),
        ),
        filled: true,
        fillColor: GrifoColors.surfaceVariant,
      ),
    );
  }

  Widget _buildComunaField() {
    return TextFormField(
      controller: widget.comunaController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese la comuna';
        }
        if (value.trim().length < 2) {
          return 'Ingrese un nombre de comuna válido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Comuna',
        hintText: 'Ej: Santiago, Las Condes, Providencia',
        prefixIcon: const Icon(Icons.location_city),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveConstants.getBorderRadius(
              MediaQuery.of(context).size.width,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            ),
          ),
        ),
        filled: true,
        fillColor: GrifoColors.surfaceVariant,
      ),
    );
  }

  Widget _buildTipoEstadoRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Tipo',
            initialValue: widget.tipo,
            items: _tipos,
            onChanged: widget.onTipoChanged,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.medium(context)),
        Expanded(
          child: _buildDropdown(
            label: 'Estado',
            initialValue: widget.estado,
            items: _estados,
            onChanged: widget.onEstadoChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String initialValue,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveConstants.getResponsiveFontSize(
              MediaQuery.of(context).size.width,
              mobile: 14.0,
              tablet: 16.0,
              desktop: 18.0,
            ),
            fontWeight: FontWeight.w500,
            color: GrifoColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveSpacing.small(context)),
        DropdownButtonFormField<String>(
          initialValue: initialValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveConstants.getBorderRadius(
                  MediaQuery.of(context).size.width,
                  mobile: 12.0,
                  tablet: 16.0,
                  desktop: 20.0,
                ),
              ),
            ),
            filled: true,
            fillColor: GrifoColors.surfaceVariant,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) => onChanged(value!),
        ),
      ],
    );
  }

  Widget _buildNotasField() {
    return TextFormField(
      controller: widget.notasController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notas',
        hintText: 'Información adicional sobre el grifo...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveConstants.getBorderRadius(
              MediaQuery.of(context).size.width,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            ),
          ),
        ),
        filled: true,
        fillColor: GrifoColors.surfaceVariant,
      ),
    );
  }

  Widget _buildCoordinatesSection() {
    return Container(
      padding: ResponsiveConstants.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12.0),
        tablet: const EdgeInsets.all(16.0),
        desktop: const EdgeInsets.all(20.0),
      ),
      decoration: BoxDecoration(
        color: GrifoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(
          ResponsiveConstants.getBorderRadius(
            MediaQuery.of(context).size.width,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coordenadas',
            style: TextStyle(
              fontSize: ResponsiveConstants.getResponsiveFontSize(
              MediaQuery.of(context).size.width,
              mobile: 14.0,
              tablet: 16.0,
              desktop: 18.0,
            ),
              fontWeight: FontWeight.w500,
              color: GrifoColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.lat.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    final lat = double.tryParse(value) ?? widget.lat;
                    widget.onLatChanged(lat);
                  },
                ),
              ),
              SizedBox(width: ResponsiveSpacing.medium(context)),
              Expanded(
                child: TextFormField(
                  initialValue: widget.lng.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    final lng = double.tryParse(value) ?? widget.lng;
                    widget.onLngChanged(lng);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.small(context)),
          Text(
            'Coordenadas por defecto: Santiago Centro',
            style: TextStyle(
              fontSize: ResponsiveConstants.getResponsiveFontSize(
                MediaQuery.of(context).size.width,
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              ),
              color: GrifoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveConstants.getResponsiveValue(
        MediaQuery.of(context).size.width,
        mobile: 48.0,
        tablet: 56.0,
        desktop: 64.0,
      ),
      child: ElevatedButton.icon(
        onPressed: widget.isLoading ? null : widget.onSubmit,
        icon: widget.isLoading
            ? SizedBox(
                width: ResponsiveConstants.getResponsiveValue(
                  MediaQuery.of(context).size.width,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
                height: ResponsiveConstants.getResponsiveValue(
                  MediaQuery.of(context).size.width,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          widget.isLoading ? 'Registrando...' : 'Registrar Grifo',
          style: TextStyle(
            fontSize: ResponsiveConstants.getResponsiveFontSize(
              MediaQuery.of(context).size.width,
              mobile: 14.0,
              tablet: 16.0,
              desktop: 18.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GrifoColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.getBorderRadius(
                MediaQuery.of(context).size.width,
                mobile: 12.0,
                tablet: 16.0,
                desktop: 20.0,
              ),
            ),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
