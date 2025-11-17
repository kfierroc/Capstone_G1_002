import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/registration_data.dart';
import '../../utils/app_styles.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Pantalla optimizada para editar información de residencia
/// Basada en step3_residence_info.dart para mantener consistencia
class EditResidenceInfoScreen extends StatefulWidget {
  final RegistrationData registrationData;
  final Function(RegistrationData) onSave;

  const EditResidenceInfoScreen({
    super.key,
    required this.registrationData,
    required this.onSave,
  });

  @override
  State<EditResidenceInfoScreen> createState() =>
      _EditResidenceInfoScreenState();
}

class _EditResidenceInfoScreenState extends State<EditResidenceInfoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controladores de dirección
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Variables de vivienda
  String? _selectedHousingType;
  String? _numberOfFloors;
  String? _selectedMaterial;
  String? _selectedCondition;

  bool _showManualCoordinates = false;
  bool _isLoading = false;

  GoogleMapController? _mapController;
  late LatLng _currentLatLng;
  Set<Marker> _markers = {};
  final FocusNode _addressFocus = FocusNode();
  Timer? _debounce;
  List<_PlacePrediction> _predictions = [];
  bool _isFetchingPredictions = false;
  
  String get _googleApiKey {
    final fromEnv = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    // Fallback para evitar que falle si .env no está cargado
    return 'AIzaSyDusFD-N_evAqvIVfRm-496mzhXDoFmz0E';
  }
  String? _placesSessionToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _addressFocus.addListener(() {
      if (_addressFocus.hasFocus) {
        _placesSessionToken = UniqueKey().toString();
      } else {
        _placesSessionToken = null;
      }
      setState(() {});
    });

    // Inicializar controladores de domicilio
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

    // Inicializar variables de vivienda
    _selectedHousingType = widget.registrationData.housingType;
    _numberOfFloors = widget.registrationData.numberOfFloors?.toString();
    _selectedMaterial = widget.registrationData.constructionMaterial;
    
    // Validar que housingCondition esté en la lista de condiciones válidas
    final validConditions = ['Excelente', 'Bueno', 'Regular', 'Malo', 'Muy malo'];
    final conditionFromData = widget.registrationData.housingCondition;
    _selectedCondition = (conditionFromData != null && validConditions.contains(conditionFromData))
        ? conditionFromData
        : null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final updatedData = widget.registrationData.copyWith(
          address: _addressController.text.trim(),
          latitude: double.tryParse(_latitudeController.text),
          longitude: double.tryParse(_longitudeController.text),
          housingType: _selectedHousingType,
          numberOfFloors: _numberOfFloors != null
              ? int.parse(_numberOfFloors!)
              : null,
          constructionMaterial: _selectedMaterial,
          housingCondition: _selectedCondition,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          setState(() => _isLoading = false);
          widget.onSave(updatedData);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Información actualizada correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.residencePrimary,
        foregroundColor: AppColors.textWhite,
        title: const Text('Editar Información de Residencia'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: const Color(0xB3FFFFFF),
          indicatorColor: AppColors.textWhite,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Dirección'),
            Tab(icon: Icon(Icons.home), text: 'Vivienda'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAddressTab(isTablet),
                  _buildHousingTab(),
                ],
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTab(bool isTablet) {
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              hintText: 'Dirección Google maps',
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _longitudeController,
                    validator: (value) =>
                        Validators.validateCoordinate(value, false),
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
    );
  }

  Widget _buildHousingTab() {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isTablet = ResponsiveHelper.isTablet(context) ||
                      ResponsiveHelper.isDesktop(context);

    final List<String> _housingTypes = [
      'Casa',
      'Departamento',
      'Empresa',
      'Local comercial',
      'Oficina',
      'Bodega',
      'Otro',
    ];

    final List<int> _floorOptions = List.generate(62, (index) => index + 1);

    final List<String> _materials = [
      'Hormigón/Concreto',
      'Ladrillo',
      'Madera',
      'Adobe',
      'Metal',
      'Material ligero',
      'Mixto',
      'Otro',
    ];

    final List<String> _conditions = [
      'Excelente',
      'Bueno',
      'Regular',
      'Malo',
      'Muy malo',
    ];

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de la Vivienda',
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
            'Proporciona información adicional sobre tu vivienda que ayudará a los bomberos en caso de emergencia',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 18,
              ),
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          SizedBox(height: isTablet ? 40 : 32),

          // Tipo de vivienda
          DropdownButtonFormField<String>(
            value: _selectedHousingType,
            decoration: InputDecoration(
              labelText: 'Tipo de vivienda *',
              hintText: 'Selecciona el tipo de vivienda',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _housingTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHousingType = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona el tipo de vivienda';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Número de pisos
          DropdownButtonFormField<String>(
            value: _numberOfFloors,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: _selectedHousingType == 'Casa' || _selectedHousingType == 'Departamento' 
                  ? 'Piso en el que resides *' 
                  : 'Número de pisos *',
              hintText: _selectedHousingType == 'Casa' || _selectedHousingType == 'Departamento'
                  ? 'Indica el piso donde resides'
                  : 'Indica la cantidad total de pisos de la vivienda',
              prefixIcon: const Icon(Icons.layers_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _floorOptions.map((floors) {
              return DropdownMenuItem(
                value: floors.toString(),
                child: Text(
                  '$floors ${floors == 1 ? 'piso' : 'pisos'}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _numberOfFloors = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona el número de pisos';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Material de construcción
          DropdownButtonFormField<String>(
            value: _selectedMaterial,
            decoration: InputDecoration(
              labelText: 'Material principal de construcción *',
              hintText: 'Selecciona el material',
              prefixIcon: const Icon(Icons.construction_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _materials.map((material) {
              return DropdownMenuItem(
                value: material,
                child: Text(material),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMaterial = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona el material';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Estado de la vivienda
          DropdownButtonFormField<String>(
            value: _selectedCondition,
            decoration: InputDecoration(
              labelText: 'Estado general de la vivienda *',
              hintText: 'Selecciona el estado',
              prefixIcon: const Icon(
                Icons.home_repair_service_outlined,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _conditions.map((condition) {
              return DropdownMenuItem(
                value: condition,
                child: Text(condition),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCondition = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona el estado';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Resumen de información
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
                    Icon(
                      Icons.summarize,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Resumen de tu información',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildSummaryItem(
                  'Dirección:',
                  widget.registrationData.address ?? 'No especificado',
                ),
                const SizedBox(height: 10),
                _buildSummaryItem(
                  'Tipo:',
                  _selectedHousingType ?? 'No especificado',
                ),
                const SizedBox(height: 10),
                _buildSummaryItem(
                  'Pisos:',
                  _numberOfFloors != null
                      ? '$_numberOfFloors ${int.parse(_numberOfFloors!) == 1 ? 'piso' : 'pisos'}'
                      : 'No especificado',
                ),
                const SizedBox(height: 10),
                _buildSummaryItem(
                  'Material:',
                  _selectedMaterial ?? 'No especificado',
                ),
                const SizedBox(height: 10),
                _buildSummaryItem(
                  'Estado:',
                  _selectedCondition ?? 'No especificado',
                ),
                const SizedBox(height: 10),
                _buildSummaryItem(
                  'Contacto:',
                  widget.registrationData.phoneNumber ??
                      'No especificado',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.medium,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.residencePrimary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
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
      // Guardar coordenadas exactas de Google Maps (sin redondeo)
      _latitudeController.text = pos.latitude.toString();
      _longitudeController.text = pos.longitude.toString();
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

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 17));
        _updateFromMap(pos);
        _placesSessionToken = null; // cerrar sesión de búsqueda
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
