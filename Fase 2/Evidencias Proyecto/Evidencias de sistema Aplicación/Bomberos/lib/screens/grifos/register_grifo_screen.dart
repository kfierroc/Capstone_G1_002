import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../services/services.dart';
import '../../constants/grifo_colors.dart';
import '../../constants/grifo_styles.dart';
import '../../utils/responsive.dart';

class RegisterGrifoScreen extends StatefulWidget {
  const RegisterGrifoScreen({super.key});

  @override
  State<RegisterGrifoScreen> createState() => _RegisterGrifoScreenState();
}

class _RegisterGrifoScreenState extends State<RegisterGrifoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  final _comunaController = TextEditingController();
  final _notasController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  String _tipo = 'Alto flujo';
  String _estado = 'Sin verificar';
  double _lat = -33.4489;
  double _lng = -70.6693;
  bool _isLoading = false;
  bool _showManualCoordinates = false;

  final List<String> _tipos = ['Alto flujo', 'Seco', 'Hidrante', 'Bomba'];
  final List<String> _estados = ['Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];

  // Servicios
  final GrifoService _grifoService = GrifoService();
  final InfoGrifoService _infoGrifoService = InfoGrifoService();

  // Google Maps
  GoogleMapController? _mapController;
  late LatLng _currentLatLng;
  Set<Marker> _markers = {};
  final FocusNode _addressFocus = FocusNode();
  Timer? _debounce;
  List<_PlacePrediction> _predictions = [];
  bool _isFetchingPredictions = false;
  String? _placesSessionToken;

  String get _googleApiKey {
    final fromEnv = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    // Fallback para evitar que falle si .env no está cargado
    return 'AIzaSyDusFD-N_evAqvIVfRm-496mzhXDoFmz0E';
  }

  @override
  void initState() {
    super.initState();
    _addressFocus.addListener(() {
      if (_addressFocus.hasFocus) {
        _placesSessionToken = UniqueKey().toString();
      } else {
        _placesSessionToken = null;
      }
      setState(() {});
    });

    _latitudeController.text = _lat.toString();
    _longitudeController.text = _lng.toString();
    _currentLatLng = LatLng(_lat, _lng);
    _markers = {
      Marker(
        markerId: const MarkerId('grifo'),
        position: _currentLatLng,
        draggable: true,
        infoWindow: const InfoWindow(title: 'Ubicación del Grifo'),
        onDragEnd: (pos) => _updateFromMap(pos),
      ),
    };
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _comunaController.dispose();
    _notasController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Registrar Grifo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: isTablet ? 12 : 8),
                _buildForm(),
                SizedBox(height: isTablet ? 16 : 12),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: isTablet ? 32 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Nuevo Grifo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete la información del grifo de agua',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Información del Grifo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dirección con autocompletado
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dirección',
                style: GrifoStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _direccionController,
                focusNode: _addressFocus,
                onChanged: _onAddressChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la dirección';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Dirección completa *',
                  hintText: 'Ej: Av. Libertador 1234',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: GrifoColors.surfaceVariant,
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
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          _buildTextField(
            controller: _comunaController,
            label: 'Comuna',
            hint: 'Ej: Santiago, Las Condes, Providencia',
            icon: Icons.location_city,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la comuna';
              }
              if (value.trim().length < 2) {
                return 'Ingrese un nombre de comuna válido';
              }
              return null;
             },
           ),
           SizedBox(height: isTablet ? 12 : 8),
           Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Tipo',
                  value: _tipo,
                  items: _tipos,
                  onChanged: (value) => setState(() => _tipo = value!),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Estado',
                  value: _estado,
                  items: _estados,
                  onChanged: (value) => setState(() => _estado = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          _buildTextField(
            controller: _notasController,
            label: 'Notas',
            hint: 'Información adicional sobre el grifo...',
            icon: Icons.note,
             maxLines: 3,
           ),
           SizedBox(height: isTablet ? 12 : 8),
           // Vista previa de ubicación con mapa
           Container(
             padding: EdgeInsets.all(isTablet ? 12 : 10),
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
                 const SizedBox(height: 8),
                 ClipRRect(
                   borderRadius: BorderRadius.circular(12),
                   child: SizedBox(
                     height: isTablet ? 350 : 280,
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
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
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
                                _mapController?.animateCamera(CameraUpdate.zoomIn());
                              }, size: isTablet ? 44 : 36),
                              const SizedBox(height: 4),
                              _buildMapButton(Icons.remove, onTap: () {
                                _mapController?.animateCamera(CameraUpdate.zoomOut());
                              }, size: isTablet ? 44 : 36),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                        _direccionController.text.isEmpty 
                            ? 'Seleccione una ubicación en el mapa' 
                            : _direccionController.text,
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
                 const SizedBox(height: 8),
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
                          'Puedes arrastrar el marcador o tocar el mapa para seleccionar la ubicación del grifo.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
               ],
             ),
           ),
           const SizedBox(height: 8),
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
                  : 'Si tienes problemas con ubicar el grifo, ingresa las coordenadas manualmente',
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
            ),
           ),
           if (_showManualCoordinates) ...[
             const SizedBox(height: 8),
             Container(
               padding: const EdgeInsets.all(12),
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
                   const SizedBox(height: 12),
                   TextFormField(
                    controller: _latitudeController,
                    validator: (value) => _validateCoordinate(value, true),
                    keyboardType: const TextInputType.numberWithOptions(
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
                   const SizedBox(height: 8),
                   TextFormField(
                    controller: _longitudeController,
                    validator: (value) => _validateCoordinate(value, false),
                    keyboardType: const TextInputType.numberWithOptions(
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
                   const SizedBox(height: 8),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: GrifoColors.surfaceVariant,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GrifoStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updateFromMap(LatLng pos) {
    setState(() {
      _currentLatLng = pos;
      _lat = pos.latitude;
      _lng = pos.longitude;
      _markers = {
        Marker(
          markerId: const MarkerId('grifo'),
          position: pos,
          draggable: true,
          infoWindow: const InfoWindow(title: 'Ubicación del Grifo'),
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
    _lat = lat;
    _lng = lng;
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
    if (_googleApiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: falta Google Maps API Key')),
        );
      }
      return;
    }
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
          'types': 'address',
          if (_placesSessionToken != null) 'sessiontoken': _placesSessionToken!,
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
      _direccionController.text = p.description;
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
          'fields': 'geometry,name,formatted_address,address_components',
          'key': _googleApiKey,
          'language': 'es',
          if (_placesSessionToken != null) 'sessiontoken': _placesSessionToken!,
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
        
        // Extraer comuna de address_components si está disponible
        if (result.containsKey('address_components')) {
          final components = result['address_components'] as List<dynamic>;
          for (var component in components) {
            final comp = component as Map<String, dynamic>;
            final types = comp['types'] as List<dynamic>;
            if (types.contains('administrative_area_level_2') || 
                types.contains('locality')) {
              final comunaName = comp['long_name'] as String;
              _comunaController.text = comunaName;
              break;
            }
          }
        }
        
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 17));
        _updateFromMap(pos);
        _placesSessionToken = null; // cerrar sesión de búsqueda
      }
    } catch (_) {
      // Silencioso, no bloquear la UI si hay error de red
    }
  }

  String? _validateCoordinate(String? value, bool isLatitude) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la ${isLatitude ? "latitud" : "longitud"}';
    }
    final coord = double.tryParse(value);
    if (coord == null) {
      return 'Ingrese un valor numérico válido';
    }
    if (isLatitude) {
      if (coord < -90 || coord > 90) {
        return 'La latitud debe estar entre -90 y 90';
      }
    } else {
      if (coord < -180 || coord > 180) {
        return 'La longitud debe estar entre -180 y 180';
      }
    }
    return null;
  }

  Widget _buildSubmitButton() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? 64 : 56,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitForm,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save_rounded, size: 20),
          label: Text(
            _isLoading ? 'Registrando...' : 'Registrar Grifo',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Obtener el código CUT de la comuna
        final cutComResult = await _grifoService.obtenerCutComPorNombre(_comunaController.text.trim());
        
        if (!cutComResult.isSuccess) {
          throw Exception('Error al obtener código de comuna: ${cutComResult.error}');
        }

        // Crear el grifo
        final nuevoGrifo = Grifo(
          idGrifo: DateTime.now().millisecondsSinceEpoch,
          lat: _lat,
          lon: _lng,
          cutCom: cutComResult.data!, // Usar el código CUT obtenido
        );

        // Guardar el grifo en Supabase
        final grifoResult = await _grifoService.insertGrifo(nuevoGrifo);
        
        if (grifoResult.isSuccess && grifoResult.data != null) {
          // Obtener el RUT del bombero autenticado
          final authService = SupabaseAuthService();
          final bombero = await authService.getCurrentUserBombero();
          
          if (bombero == null) {
            debugPrint('❌ No se pudo obtener la información del bombero autenticado');
            throw Exception('No se pudo obtener la información del bombero autenticado. Por favor, inicie sesión nuevamente.');
          }
          
          debugPrint('✅ Bombero autenticado encontrado: ${bombero.rutCompleto} (${bombero.nombBombero} ${bombero.apePBombero})');
          
          // Crear la información inicial del grifo
          final infoGrifo = InfoGrifo(
            idRegGrifo: DateTime.now().millisecondsSinceEpoch,
            idGrifo: grifoResult.data!.idGrifo,
            fechaRegistro: DateTime.now(),
            estado: _estado,
            rutNum: bombero.rutNum, // Usar el RUT del bombero autenticado
          );

          debugPrint('📝 Insertando info_grifo con RUT: ${bombero.rutNum}');
          debugPrint('📝 Datos info_grifo: ${infoGrifo.toInsertData()}');

          // Guardar la información del grifo
          final infoResult = await _infoGrifoService.insertInfoGrifo(infoGrifo);
          
          if (infoResult.isSuccess) {
            if (mounted) {
              Navigator.pop(context, grifoResult.data);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grifo registrado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception(infoResult.error ?? 'Error al guardar información del grifo');
          }
        } else {
          throw Exception(grifoResult.error ?? 'Error al registrar el grifo');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar grifo: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
