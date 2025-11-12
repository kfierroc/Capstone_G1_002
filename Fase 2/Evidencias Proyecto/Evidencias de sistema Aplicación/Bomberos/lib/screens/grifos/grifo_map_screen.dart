import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/grifo_service.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../utils/responsive.dart';

/// Pantalla que muestra todos los grifos en un mapa interactivo
class GrifoMapScreen extends StatefulWidget {
  final Grifo? grifoEspecifico; // Si se proporciona, muestra solo este grifo
  final InfoGrifo? infoGrifoEspecifico; // Información del grifo específico (opcional)
  
  const GrifoMapScreen({
    super.key,
    this.grifoEspecifico,
    this.infoGrifoEspecifico,
  });

  @override
  State<GrifoMapScreen> createState() => _GrifoMapScreenState();
}

class _GrifoMapScreenState extends State<GrifoMapScreen> {
  final GrifoService _grifoService = GrifoService();
  bool _isLoading = true;
  String? _errorMessage;
  GoogleMapController? _mapController;
  
  List<Grifo> _grifos = [];
  Map<int, InfoGrifo> _infoGrifos = {};
  Map<String, int> _estadisticas = {};

  LatLng get _initialTarget {
    // Si hay un grifo específico, usar sus coordenadas
    if (widget.grifoEspecifico != null) {
      return LatLng(widget.grifoEspecifico!.lat, widget.grifoEspecifico!.lon);
    }
    if (_grifos.isNotEmpty) {
      final first = _grifos.first;
      return LatLng(first.lat, first.lon);
    }
    return const LatLng(-33.4489, -70.6693); // Santiago
  }

  double get _initialZoom {
    // Si hay un grifo específico, usar zoom más cercano
    if (widget.grifoEspecifico != null) {
      return 16.0;
    }
    return 5.0;
  }

  @override
  void initState() {
    super.initState();
    _cargarGrifos();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _cargarGrifos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Si hay un grifo específico, solo cargar ese
      if (widget.grifoEspecifico != null) {
        debugPrint('🗺️ Cargando grifo específico ${widget.grifoEspecifico!.idGrifo}...');
        
        final grifo = widget.grifoEspecifico!;
        final List<Grifo> grifos = [grifo];
        final Map<int, InfoGrifo> infoGrifos = {};
        
        // Usar la información del grifo que se pasó como parámetro
        if (widget.infoGrifoEspecifico != null) {
          infoGrifos[grifo.idGrifo] = widget.infoGrifoEspecifico!;
        }
        
        // Calcular estadísticas solo para este grifo
        final Map<String, int> stats = {
          'operativo': 0,
          'dañado': 0,
          'mantenimiento': 0,
          'sin_verificar': 0,
        };
        
        final info = infoGrifos[grifo.idGrifo];
        if (info != null) {
          switch (info.estado.toLowerCase()) {
            case 'operativo':
              stats['operativo'] = 1;
              break;
            case 'dañado':
              stats['dañado'] = 1;
              break;
            case 'mantenimiento':
              stats['mantenimiento'] = 1;
              break;
            case 'sin verificar':
              stats['sin_verificar'] = 1;
              break;
          }
        } else {
          stats['sin_verificar'] = 1;
        }
        
        setState(() {
          _grifos = grifos;
          _infoGrifos = infoGrifos;
          _estadisticas = stats;
          _isLoading = false;
        });
        
        // Centrar el mapa en el grifo específico después de cargar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(grifo.lat, grifo.lon),
                16.0,
              ),
            );
          }
        });
        
        debugPrint('✅ Grifo específico cargado');
        return;
      }
      
      debugPrint('🗺️ Cargando grifos para el mapa...');
      
      // Cargar grifos con información completa
      final grifosResult = await _grifoService.getGrifosConInfoCompleta();
      
      if (grifosResult.isSuccess && grifosResult.data != null) {
        final List<Grifo> grifos = [];
        final Map<int, InfoGrifo> infoGrifos = {};
        
        for (final grifoData in grifosResult.data!) {
          final grifo = Grifo.fromJson(grifoData);
          grifos.add(grifo);
          
          // Obtener información de grifo
          final infoGrifoData = grifoData['info_grifo'] as List<dynamic>?;
          if (infoGrifoData != null && infoGrifoData.isNotEmpty) {
            InfoGrifo? infoMasReciente;
            
            for (final infoData in infoGrifoData) {
              final info = InfoGrifo.fromJson(infoData);
              if (infoMasReciente == null || info.fechaRegistro.isAfter(infoMasReciente.fechaRegistro)) {
                infoMasReciente = info;
              }
            }
            
            if (infoMasReciente != null) {
              infoGrifos[grifo.idGrifo] = infoMasReciente;
            }
          }
        }
        
        // Calcular estadísticas
        final Map<String, int> stats = {
          'operativo': 0,
          'dañado': 0,
          'mantenimiento': 0,
          'sin_verificar': 0,
        };

        for (final info in infoGrifos.values) {
          switch (info.estado.toLowerCase()) {
            case 'operativo':
              stats['operativo'] = (stats['operativo'] ?? 0) + 1;
              break;
            case 'dañado':
              stats['dañado'] = (stats['dañado'] ?? 0) + 1;
              break;
            case 'mantenimiento':
              stats['mantenimiento'] = (stats['mantenimiento'] ?? 0) + 1;
              break;
            case 'sin verificar':
              stats['sin_verificar'] = (stats['sin_verificar'] ?? 0) + 1;
              break;
          }
        }
        
        setState(() {
          _grifos = grifos;
          _infoGrifos = infoGrifos;
          _estadisticas = stats;
          _isLoading = false;
        });
        
        debugPrint('✅ Grifos cargados: ${grifos.length}');
      } else {
        setState(() {
          _errorMessage = grifosResult.error ?? 'Error al cargar grifos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Mapa Interactivo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cargando mapa...',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isTablet ? 80 : 60,
                          color: const Color(0xFFDC2626),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Error al cargar mapa',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _cargarGrifos,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Encabezado con estadísticas
                    _buildHeader(),
                    // Mapa de Google con marcadores
                    Expanded(
                      child: _buildGoogleMap(),
                    ),
                    
                    // Leyenda de estados
                    _buildLegend(),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    final isTablet = ResponsiveHelper.isTablet(context);
    final totalGrifos = _grifos.length;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.map,
              color: Colors.white,
              size: isTablet ? 32 : 28,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.grifoEspecifico != null
                      ? 'Ubicación del Grifo ${widget.grifoEspecifico!.idGrifo}'
                      : 'Vista geográfica de todos los grifos registrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.grifoEspecifico != null
                      ? 'Coordenadas: ${widget.grifoEspecifico!.lat.toStringAsFixed(6)}, ${widget.grifoEspecifico!.lon.toStringAsFixed(6)}'
                      : '($totalGrifos mostrados)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    final markers = _buildMarkers();
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
        // Precargar tiles del área visible
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_mapController != null) {
            _preloadMapTiles();
          }
        });
      },
      initialCameraPosition: CameraPosition(target: _initialTarget, zoom: _initialZoom),
      cameraTargetBounds: CameraTargetBounds(
        LatLngBounds(
          southwest: const LatLng(-56.0, -110.0),
          northeast: const LatLng(-17.0, -65.0),
        ),
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(3, 21),
      zoomControlsEnabled: true,
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      markers: markers,
    );
  }


  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    for (final grifo in _grifos) {
      final info = _infoGrifos[grifo.idGrifo];
      final estado = info?.estado ?? 'Sin verificar';
      final hue = _estadoToHue(estado);
      markers.add(
        Marker(
          markerId: MarkerId('grifo_${grifo.idGrifo}'),
          position: LatLng(grifo.lat, grifo.lon),
          infoWindow: InfoWindow(
            title: 'Grifo ${grifo.idGrifo}',
            snippet: 'Estado: $estado',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        ),
      );
    }
    return markers;
  }

  Future<void> _preloadMapTiles() async {
    // Mover la cámara para forzar la carga de tiles
    if (_mapController == null) return;
    
    try {
      // Hacer zoom out para cargar área más amplia
      await _mapController!.animateCamera(CameraUpdate.zoomBy(-1));
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Volver al zoom anterior
      await _mapController!.animateCamera(CameraUpdate.zoomBy(1));
    } catch (e) {
      debugPrint('Error en preload: $e');
    }
  }

  double _estadoToHue(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
        return BitmapDescriptor.hueGreen;
      case 'dañado':
        return BitmapDescriptor.hueRed;
      case 'mantenimiento':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  Widget _buildLegend() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estados de grifos:',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Wrap(
            spacing: isTablet ? 16 : 12,
            runSpacing: isTablet ? 12 : 8,
            children: [
              _buildLegendItem('Operativo', const Color(0xFF10B981), _estadisticas['operativo'] ?? 0),
              _buildLegendItem('Dañado', const Color(0xFFEF4444), _estadisticas['dañado'] ?? 0),
              _buildLegendItem('Mantenimiento', const Color(0xFFF59E0B), _estadisticas['mantenimiento'] ?? 0),
              _buildLegendItem('Sin verificar', const Color(0xFF6B7280), _estadisticas['sin_verificar'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 20 : 16,
          height: isTablet ? 20 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: isTablet ? 8 : 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

