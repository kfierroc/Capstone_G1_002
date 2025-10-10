import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/validators.dart';

/// Widget reutilizable para formulario de dirección y ubicación
class AddressFormWidget extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final bool showManualCoordinates;
  final Function(bool) onToggleManualCoordinates;
  final VoidCallback onConfirmLocation;

  const AddressFormWidget({
    super.key,
    required this.addressController,
    required this.latitudeController,
    required this.longitudeController,
    required this.showManualCoordinates,
    required this.onToggleManualCoordinates,
    required this.onConfirmLocation,
  });

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  bool _hasConfirmedLocation = false;

  @override
  void initState() {
    super.initState();
    _hasConfirmedLocation = widget.addressController.text.isNotEmpty;
  }

  void _confirmLocation() {
    if (widget.addressController.text.isNotEmpty) {
      setState(() {
        _hasConfirmedLocation = true;
        if (widget.latitudeController.text.isEmpty) {
          widget.latitudeController.text = '-33.4234';
          widget.longitudeController.text = '-70.6345';
        }
      });
      widget.onConfirmLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dirección', style: AppTextStyles.heading4),
        const SizedBox(height: AppSpacing.sm),
        
        TextFormField(
          controller: widget.addressController,
          validator: Validators.validateAddress,
          decoration: InputDecoration(
            labelText: 'Dirección completa *',
            hintText: 'Calle, número, comuna, ciudad',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _confirmLocation,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirmar ubicación en el mapa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),

        if (_hasConfirmedLocation) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildLocationPreview(),
        ],

        const SizedBox(height: AppSpacing.lg),
        
        // Opción de coordenadas manuales
        TextButton.icon(
          onPressed: () => widget.onToggleManualCoordinates(!widget.showManualCoordinates),
          icon: Icon(
            widget.showManualCoordinates
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
          label: Text(
            widget.showManualCoordinates
                ? 'Ocultar coordenadas manuales'
                : 'Ingresar coordenadas manualmente',
          ),
          style: TextButton.styleFrom(foregroundColor: AppColors.info),
        ),

        if (widget.showManualCoordinates) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildManualCoordinates(),
        ],
      ],
    );
  }

  Widget _buildLocationPreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '📍 Ubicación confirmada',
                style: AppTextStyles.labelText,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.addressController.text,
            style: AppTextStyles.bodyMedium,
          ),
          if (widget.latitudeController.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '📡 Coordenadas: ${widget.latitudeController.text}, ${widget.longitudeController.text}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualCoordinates() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresar coordenadas manualmente',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: widget.latitudeController,
            validator: (value) => Validators.validateCoordinate(value, true),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              labelText: 'Latitud *',
              hintText: '-33.4489',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: widget.longitudeController,
            validator: (value) => Validators.validateCoordinate(value, false),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              labelText: 'Longitud *',
              hintText: '-70.6693',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

