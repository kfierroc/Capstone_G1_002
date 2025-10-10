import 'package:flutter/material.dart';
import '../../models/grifo.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/map_placeholder.dart';

/// Pantalla para registrar un nuevo grifo
class RegistrarGrifoScreen extends StatefulWidget {
  final String nombreUsuario;

  const RegistrarGrifoScreen({Key? key, required this.nombreUsuario})
      : super(key: key);

  @override
  State<RegistrarGrifoScreen> createState() => _RegistrarGrifoScreenState();
}

class _RegistrarGrifoScreenState extends State<RegistrarGrifoScreen> {
  double lat = -33.4489;
  double lng = -70.6693;
  String tipo = 'Estándar';
  String estado = 'Sin verificar';
  
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _comunaController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();

  @override
  void dispose() {
    _direccionController.dispose();
    _comunaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _registrarGrifo() {
    if (_direccionController.text.isEmpty || _comunaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.msgCamposRequeridos),
        ),
      );
      return;
    }

    final nuevoGrifo = Grifo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      direccion: _direccionController.text,
      comuna: _comunaController.text,
      tipo: tipo,
      estado: estado,
      ultimaInspeccion: DateTime.now(),
      notas: _notasController.text.isEmpty
          ? 'Sin notas adicionales'
          : _notasController.text,
      reportadoPor: widget.nombreUsuario,
      fechaReporte: DateTime.now(),
      lat: lat,
      lng: lng,
    );

    Navigator.pop(context, nuevoGrifo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Nuevo Grifo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Añade un nuevo punto de agua al sistema',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: AppStyles.spacingLarge),
              const Text(
                'Selecciona la ubicación del grifo',
                style: AppStyles.titleMedium,
              ),
              const SizedBox(height: AppStyles.spacingMedium),
              _buildMapSection(),
              const SizedBox(height: AppStyles.spacingMedium),
              _buildLocationInfo(),
              const SizedBox(height: AppStyles.spacingLarge),
              _buildFormFields(),
              const SizedBox(height: AppStyles.spacingLarge),
              _buildUserInfo(),
              const SizedBox(height: AppStyles.spacingLarge),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: AppStyles.borderRadiusSmall,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: AppStyles.iconLarge,
                  color: AppColors.info,
                ),
                const SizedBox(height: AppStyles.spacingSmall),
                const Text(
                  'Nuevo grifo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Coordenadas: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                ),
                Text('Tipo: $tipo'),
                Text('Estado: $estado'),
                const SizedBox(height: AppStyles.spacingSmall),
                Text(
                  'Haz clic en diferentes áreas del mapa para cambiar la ubicación',
                  style: AppStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const MapPlaceholder(itemCount: 1, showControls: true),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: AppStyles.borderRadiusSmall,
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.info),
              const SizedBox(width: AppStyles.spacingSmall),
              Text(
                'Seleccionado: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingXSmall),
          Text(
            'Haz clic en diferentes áreas del mapa para seleccionar la ubicación exacta del grifo',
            style: AppStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _direccionController,
          labelText: 'Dirección *',
        ),
        const SizedBox(height: AppStyles.spacingMedium),
        CustomTextField(
          controller: _comunaController,
          labelText: 'Comuna *',
        ),
        const SizedBox(height: AppStyles.spacingMedium),
        DropdownButtonFormField<String>(
          initialValue: tipo,
          decoration: AppStyles.getInputDecoration(labelText: 'Tipo de grifo'),
          items: AppConstants.tiposGrifo
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (value) => setState(() => tipo = value!),
        ),
        const SizedBox(height: AppStyles.spacingMedium),
        DropdownButtonFormField<String>(
          initialValue: estado,
          decoration: AppStyles.getInputDecoration(labelText: 'Estado'),
          items: AppConstants.estadosGrifoSinTodos
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => estado = value!),
        ),
        const SizedBox(height: AppStyles.spacingMedium),
        CustomTextField(
          controller: _notasController,
          labelText: 'Notas adicionales',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppStyles.borderRadiusSmall,
      ),
      child: Text(
        'Automáticamente asignado a tu usuario: ${widget.nombreUsuario}',
        style: AppStyles.bodySmall,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomOutlinedButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: AppStyles.spacingMedium),
        Expanded(
          child: CustomButton(
            text: 'Registrar Grifo',
            backgroundColor: AppColors.primary,
            onPressed: _registrarGrifo,
          ),
        ),
      ],
    );
  }
}

