import 'package:flutter/material.dart';
import '../../services/grifo_service.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../utils/responsive.dart';

/// Pantalla que muestra todos los grifos en un mapa interactivo
class GrifoMapScreen extends StatefulWidget {
  const GrifoMapScreen({super.key});

  @override
  State<GrifoMapScreen> createState() => _GrifoMapScreenState();
}

class _GrifoMapScreenState extends State<GrifoMapScreen> {
  final GrifoService _grifoService = GrifoService();
  bool _isLoading = true;
  String? _errorMessage;
  
  List<Grifo> _grifos = [];
  Map<int, InfoGrifo> _infoGrifos = {};
  Map<String, int> _estadisticas = {};

  @override
  void initState() {
    super.initState();
    _cargarGrifos();
  }

  Future<void> _cargarGrifos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
        return const Color(0xFF10B981); // Verde
      case 'dañado':
        return const Color(0xFFEF4444); // Rojo
      case 'mantenimiento':
        return const Color(0xFFF59E0B); // Amarillo
      default:
        return const Color(0xFF6B7280); // Gris
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
                    
                    // Mapa placeholder
                    Expanded(
                      child: _buildMapPlaceholder(),
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
                  'Vista geográfica de todos los grifos registrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '($totalGrifos mostrados)',
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

  Widget _buildMapPlaceholder() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: isTablet ? 120 : 100,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Text(
            'Mapa Interactivo',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 24),
            child: Text(
              'Aquí se mostraría un mapa interactivo con la ubicación de todos los grifos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),
          
          // Mostrar algunos grifos como ejemplo
          if (_grifos.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 24),
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicaciones de ejemplo:',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  ..._grifos.take(5).map((grifo) {
                    final info = _infoGrifos[grifo.idGrifo];
                    final estado = info?.estado ?? 'Sin verificar';
                    final color = _getEstadoColor(estado);
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
                      child: Row(
                        children: [
                          Container(
                            width: isTablet ? 16 : 14,
                            height: isTablet ? 16 : 14,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 10),
                          Expanded(
                            child: Text(
                              'Grifo ${grifo.idGrifo} - ${grifo.lat.toStringAsFixed(4)}, ${grifo.lon.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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

