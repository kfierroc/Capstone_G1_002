import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/registration_data.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final FocusNode _addressFocus = FocusNode();
  Timer? _debounce;
  List<_PlacePrediction> _predictions = [];
  bool _isFetchingPredictions = false;
  String get _googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

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
    _addressFocus.dispose();
    _debounce?.cancel();
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
                      focusNode: _addressFocus,
                      onChanged: _onAddressChanged,
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
                    if (_shouldShowPredictions)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          maxHeight: isTablet ? 300 : 240,
                        ),
                        child: _isFetchingPredictions
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _predictions.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                                itemBuilder: (context, index) {
                                  final p = _predictions[index];
                                  return ListTile(
                                    dense: false,
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text(p.primaryText),
                                    subtitle: p.secondaryText != null ? Text(p.secondaryText!) : null,
                                    onTap: () => _onPredictionTap(p),
                                  );
                                },
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
                                height: isTablet ? 420 : 320,
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
                                      gestureRecognizers:
                                          <Factory<OneSequenceGestureRecognizer>>{
                                        Factory<EagerGestureRecognizer>(
                                            () => EagerGestureRecognizer()),
                                      },
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
                                          }, size: isTablet ? 44 : 36),
                                          const SizedBox(height: 4),
                                          _buildMapButton(Icons.remove, onTap: () {
                                            _mapController
                                                ?.animateCamera(CameraUpdate.zoomOut());
                                          }, size: isTablet ? 44 : 36),
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
                                        'Ubicación confirmada',
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
                                    'Coordenadas: ${_latitudeController.text}, ${_longitudeController.text}',
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

  Widget _buildMapButton(IconData icon, {VoidCallback? onTap, double size = 32}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: size * 0.56, color: Colors.grey.shade700),
      ),
    );
  }

  bool get _shouldShowPredictions =>
      _addressFocus.hasFocus && _predictions.isNotEmpty;

  void _onAddressChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await _fetchPredictions(value.trim());
    });
  }

  Future<void> _fetchPredictions(String input) async {
    setState(() => _isFetchingPredictions = true);
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        <String, String>{
          'input': input,
          'key': _googleApiKey,
          'language': 'es',
          'components': 'country:cl',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final preds = (data['predictions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((m) => _PlacePrediction.fromJson(m))
            .toList();
        setState(() => _predictions = preds);
      } else {
        setState(() => _predictions = []);
      }
    } catch (_) {
      setState(() => _predictions = []);
    } finally {
      if (mounted) setState(() => _isFetchingPredictions = false);
    }
  }

  Future<void> _onPredictionTap(_PlacePrediction p) async {
    // Cerrar lista
    setState(() {
      _addressController.text = p.description;
      _predictions = [];
      _addressFocus.unfocus();
    });

    // Obtener detalles para coordenadas
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        <String, String>{
          'place_id': p.placeId,
          'fields': 'geometry,name,formatted_address',
          'key': _googleApiKey,
          'language': 'es',
        },
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>;
        final loc = result['geometry']['location'] as Map<String, dynamic>;
        final lat = (loc['lat'] as num).toDouble();
        final lng = (loc['lng'] as num).toDouble();
        final pos = LatLng(lat, lng);

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 17));
        _updateFromMap(pos);
      }
    } catch (_) {
      // Silencioso, no bloquear la UI si hay error de red
    }
  }
}

class _PlacePrediction {
  final String placeId;
  final String description;
  final String primaryText;
  final String? secondaryText;

  _PlacePrediction({
    required this.placeId,
    required this.description,
    required this.primaryText,
    this.secondaryText,
  });

  factory _PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    final primary = structured != null ? (structured['main_text'] as String? ?? '') : '';
    final secondary = structured != null ? (structured['secondary_text'] as String?) : null;
    return _PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      primaryText: primary.isNotEmpty ? primary : (json['description'] as String),
      secondaryText: secondary,
    );
  }
}
