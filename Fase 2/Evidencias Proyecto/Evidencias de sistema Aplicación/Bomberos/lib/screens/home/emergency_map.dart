import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/responsive.dart';
import '../../models/grifo.dart';
import '../../services/grifo_service.dart';
import 'dart:math' as math;

class EmergencyMapScreen extends StatefulWidget {
  final Map<String, dynamic> addressData;

  const EmergencyMapScreen({super.key, required this.addressData});

  @override
  State<EmergencyMapScreen> createState() => _EmergencyMapScreenState();
}

class _EmergencyMapScreenState extends State<EmergencyMapScreen> {
  double _zoomLevel = 16.0;
  GoogleMapController? _mapController;
  static const LatLng _fallbackTarget = LatLng(-33.4489, -70.6693); // Santiago
  final GrifoService _grifoService = GrifoService();

  LatLng? _target; // coordenadas del domicilio si existen
  List<Grifo> _nearestGrifos = [];

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 1.0).clamp(3.0, 21.0);
    });
    _animateZoom();
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 1.0).clamp(3.0, 21.0);
    });
    _animateZoom();
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 16.0;
    });
    _animateZoom();
  }

  void _animateZoom() {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.zoomTo(_zoomLevel),
    );
  }

  @override
  void initState() {
    super.initState();
    _resolveTargetAndLoad();
  }

  void _resolveTargetAndLoad() {
    final lat = widget.addressData['lat'] as double?;
    final lon = widget.addressData['lon'] as double?;
    _target = (lat != null && lon != null) ? LatLng(lat, lon) : _fallbackTarget;
    _loadNearestGrifos();
  }

  Future<void> _loadNearestGrifos() async {
    try {
      final center = _target ?? _fallbackTarget;
      // Intentar RPC de cercanos si existe, si no, cargar todos y ordenar por distancia
      final nearby = await _grifoService.getGrifosNearby(lat: center.latitude, lon: center.longitude, radiusKm: 10);
      List<Grifo> grifos;
      if (nearby.isSuccess && nearby.data != null && nearby.data!.isNotEmpty) {
        grifos = nearby.data!;
      } else {
        final all = await _grifoService.getAllGrifos();
        grifos = all.data ?? [];
      }

      grifos.sort((a, b) => _distance(center, LatLng(a.lat, a.lon)).compareTo(
            _distance(center, LatLng(b.lat, b.lon)),
          ));
      setState(() {
        _nearestGrifos = grifos.take(3).toList();
      });
    } catch (_) {
      // Silenciar errores en esta vista táctica
    }
  }

  double _distance(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final aTerm = sinDLat * sinDLat + math.cos(lat1) * math.cos(lat2) * sinDLon * sinDLon;
    final c = 2 * math.atan2(math.sqrt(aTerm), math.sqrt(1 - aTerm));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.map, 
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  ' Ubicación de Emergencia',
                  style: TextStyle(
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
            Text(
              widget.addressData['address'] as String,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 10,
                  tablet: 12,
                  desktop: 14,
                ),
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _fallbackTarget,
              zoom: _zoomLevel,
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('objetivo'),
                position: _target ?? _fallbackTarget,
                infoWindow: const InfoWindow(title: 'Ubicación objetivo'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
              ..._nearestGrifos
                  .map(
                    (g) => Marker(
                      markerId: MarkerId('grifo_${g.idGrifo}'),
                      position: LatLng(g.lat, g.lon),
                      infoWindow: InfoWindow(
                        title: 'Grifo ${g.idGrifo}',
                        snippet: '${_distance(_target ?? _fallbackTarget, LatLng(g.lat, g.lon)).toStringAsFixed(2)} km',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    ),
                  )
                  .toSet(),
            },
          ),

          // ============================================
          // CONTROLES DE ZOOM
          // ============================================
          Positioned(
            right: isTablet ? 20 : 16,
            top: isTablet ? 20 : 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    onPressed: _zoomIn,
                    icon: Icon(
                      Icons.add,
                      size: isTablet ? 28 : 24,
                    ),
                    color: Colors.grey.shade800,
                    tooltip: 'Acercar',
                  ),
                  Container(
                    height: 1, 
                    width: isTablet ? 35 : 30, 
                    color: Colors.grey.shade300,
                  ),
                  IconButton(
                    onPressed: _zoomOut,
                    icon: Icon(
                      Icons.remove,
                      size: isTablet ? 28 : 24,
                    ),
                    color: Colors.grey.shade800,
                    tooltip: 'Alejar',
                  ),
                  Container(
                    height: 1, 
                    width: isTablet ? 35 : 30, 
                    color: Colors.grey.shade300,
                  ),
                  IconButton(
                    onPressed: _resetZoom,
                    icon: Icon(
                      Icons.my_location,
                      size: isTablet ? 28 : 24,
                    ),
                    color: Colors.grey.shade800,
                    tooltip: 'Centrar',
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // PANEL INFERIOR: SOLO 3 GRIFOS MÁS CERCANOS
          // ============================================
          DraggableScrollableSheet(
            initialChildSize: isTablet ? 0.4 : 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? 28 : 24),
                    topRight: Radius.circular(isTablet ? 28 : 24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle para arrastrar
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                        width: isTablet ? 50 : 40,
                        height: isTablet ? 5 : 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(isTablet ? 28 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Colors.red.shade700,
                                size: isTablet ? 28 : 24,
                              ),
                              SizedBox(width: isTablet ? 16 : 12),
                              Text(
                                '3 grifos más cercanos',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: 18,
                                    tablet: 22,
                                    desktop: 26,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._nearestGrifos.map((g) {
                            final distKm = _distance(_target ?? _fallbackTarget, LatLng(g.lat, g.lon));
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Grifo ${g.idGrifo}  ·  ${g.lat.toStringAsFixed(5)}, ${g.lon.toStringAsFixed(5)}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${distKm.toStringAsFixed(2)} km', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            );
                          }).toList(),
                          if (_nearestGrifos.isEmpty)
                            Text(
                              'Sin datos de grifos cercanos',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
