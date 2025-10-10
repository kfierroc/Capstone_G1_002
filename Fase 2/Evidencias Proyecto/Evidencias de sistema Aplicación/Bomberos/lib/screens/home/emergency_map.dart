import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class EmergencyMapScreen extends StatefulWidget {
  final Map<String, dynamic> addressData;

  const EmergencyMapScreen({super.key, required this.addressData});

  @override
  State<EmergencyMapScreen> createState() => _EmergencyMapScreenState();
}

class _EmergencyMapScreenState extends State<EmergencyMapScreen> {
  double _zoomLevel = 1.0;

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 3.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
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
          // ============================================
          // MAPA SIMULADO (Aquí iría el mapa real)
          // ============================================
          Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Transform.scale(
                scale: _zoomLevel,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isTablet ? 100 : 80,
                      color: Colors.red.shade700,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 12 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Ubicación objetivo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 120 : 100),
                    Text(
                      'Aquí se mostraría el mapa interactivo',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 10,
                          tablet: 12,
                          desktop: 14,
                        ),
                      ),
                    ),
                    Text(
                      '(Google Maps, Mapbox, etc.)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          // PANEL INFERIOR CON INFORMACIÓN TÁCTICA
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
                          // Título
                          Row(
                            children: [
                              Icon(
                                Icons.shield,
                                color: Colors.red.shade700,
                                size: isTablet ? 28 : 24,
                              ),
                              SizedBox(width: isTablet ? 16 : 12),
                              Text(
                                'Vista Táctica de Emergencia',
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

                          const SizedBox(height: 20),

                          // Información del domicilio
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      ' Domicilio registrado',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.addressData['address'] as String,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildInfoChip(
                                      Icons.people,
                                      '${widget.addressData['people_count']} Personas',
                                      Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildInfoChip(
                                      Icons.pets,
                                      '${widget.addressData['pets_count']} Mascotas',
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Condiciones Especiales
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.red.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Condiciones Especiales',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.addressData['special_conditions_count']} persona(s) con condiciones médicas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Instrucciones
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info,
                                      color: Colors.amber.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Instrucciones',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.addressData['special_instructions']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Información de coordenadas y grifo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.grey.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      ' Coordenadas: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Text(
                                      '-33.4234°, -70.6345°',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.water_drop,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      ' Grifo más cercano: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Text(
                                      '200m al norte',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Botón volver
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Volver a Información'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade700),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
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

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
