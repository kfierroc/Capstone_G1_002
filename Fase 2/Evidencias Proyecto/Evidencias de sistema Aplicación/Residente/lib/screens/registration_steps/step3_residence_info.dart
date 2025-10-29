import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Step3ResidenceInfo extends StatefulWidget {
  final RegistrationData registrationData;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step3ResidenceInfo({
    super.key,
    required this.registrationData,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<Step3ResidenceInfo> createState() => _Step3ResidenceInfoState();
}

class _Step3ResidenceInfoState extends State<Step3ResidenceInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  // Removed _mainPhoneController since phone is already captured in step 2
  // Removed _specialInstructionsController

  bool _showManualCoordinates = false;

  GoogleMapController? _mapController;
  late LatLng _currentLatLng;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.registrationData.address ?? '';
    _latitudeController.text =
        widget.registrationData.latitude?.toString() ?? '';
    _longitudeController.text =
        widget.registrationData.longitude?.toString() ?? '';
    
    // If no coordinates, use defaults
    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      _latitudeController.text = '-33.4234';
      _longitudeController.text = '-70.6345';
    }

    final parsedLat = double.tryParse(_latitudeController.text) ?? -33.4234;
    final parsedLng = double.tryParse(_longitudeController.text) ?? -70.6345;
    _currentLatLng = LatLng(parsedLat, parsedLng);
    _markers = {
      Marker(
        markerId: const MarkerId('residence'),
        position: _currentLatLng,
        draggable: true,
        infoWindow: const InfoWindow(title: 'Residencia'),
        onDragEnd: (pos) => _updateFromMap(pos),
      ),
    };
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.registrationData.address = _addressController.text.trim();
      widget.registrationData.latitude = double.tryParse(
        _latitudeController.text,
      );
      widget.registrationData.longitude = double.tryParse(
        _longitudeController.text,
      );
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Column(
      children: [
        Expanded(
          child: ResponsiveContainer(
            maxWidth: isTablet ? 800 : null,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la Residencia',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 28,
                          tablet: 32,
                          desktop: 36,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proporciona los datos básicos de tu vivienda',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 18,
                        ),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 32),

                    // Dirección
                    const Text(
                      'Dirección',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      validator: Validators.validateAddress,
                      decoration: InputDecoration(
                        labelText: 'Dirección completa *',
                        hintText: 'Calle, número, comuna, ciudad',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Vista previa de ubicación
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.map, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Vista previa de ubicación',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 200,
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      mapType: MapType.normal,
                                      initialCameraPosition: CameraPosition(
                                        target: _currentLatLng,
                                        zoom: 16,
                                      ),
                                      markers: _markers,
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                      onMapCreated: (controller) {
                                        _mapController = controller;
                                      },
                                      onTap: (pos) => _updateFromMap(pos),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Column(
                                        children: [
                                          _buildMapButton(Icons.add, onTap: () {
                                            _mapController
                                                ?.animateCamera(CameraUpdate.zoomIn());
                                          }),
                                          const SizedBox(height: 4),
                                          _buildMapButton(Icons.remove, onTap: () {
                                            _mapController
                                                ?.animateCamera(CameraUpdate.zoomOut());
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '📍 Ubicación confirmada',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _addressController.text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '📡 Coordenadas: ${_latitudeController.text}, ${_longitudeController.text}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Esta vista previa ayuda a los bomberos a localizar rápidamente tu domicilio en caso de emergencia.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Opción de ingresar coordenadas manualmente
                    TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showManualCoordinates = !_showManualCoordinates;
                          });
                        },
                        icon: Icon(
                          _showManualCoordinates
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        label: Text(
                          _showManualCoordinates
                              ? 'Ocultar coordenadas'
                              : 'Si tienes problemas con ubicar tu residencia, tú mismo ingresa su coordenada',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),

                    if (_showManualCoordinates) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingresar coordenadas manualmente',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _latitudeController,
                                validator: (value) =>
                                    Validators.validateCoordinate(value, true),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'Latitud (coordenada Y) *',
                                  hintText: 'Ejemplo: -33.4489',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (_) => _tryUpdateMapFromFields(),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _longitudeController,
                                validator: (value) =>
                                    Validators.validateCoordinate(value, false),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'Longitud (coordenada X) *',
                                  hintText: 'Ejemplo: -70.6693',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (_) => _tryUpdateMapFromFields(),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        '💡 Puedes obtener las coordenadas desde Google Maps: haz clic derecho en tu ubicación y selecciona las coordenadas que aparecen.',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                  ],
                ),
              ),
            ),
          ),
        ),

        // Botones
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Anterior', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateFromMap(LatLng pos) {
    setState(() {
      _currentLatLng = pos;
      _markers = {
        Marker(
          markerId: const MarkerId('residence'),
          position: pos,
          draggable: true,
          infoWindow: const InfoWindow(title: 'Residencia'),
          onDragEnd: (p) => _updateFromMap(p),
        ),
      };
      _latitudeController.text = pos.latitude.toStringAsFixed(6);
      _longitudeController.text = pos.longitude.toStringAsFixed(6);
    });
  }

  void _tryUpdateMapFromFields() {
    final lat = double.tryParse(_latitudeController.text);
    final lng = double.tryParse(_longitudeController.text);
    if (lat == null || lng == null) return;
    final pos = LatLng(lat, lng);
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
    _updateFromMap(pos);
  }

  Widget _buildMapButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }
}
