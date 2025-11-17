import 'package:flutter/material.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../services/services.dart';
import '../../constants/grifo_styles.dart';
import '../../utils/responsive.dart';
import '../../widgets/grifo_card.dart';
import '../../widgets/grifo_stats_section.dart';
import '../../widgets/grifo_search_section.dart';
import '../../widgets/grifo_map_placeholder.dart';
import 'register_grifo_screen.dart';

class GrifosHomeScreen extends StatefulWidget {
  const GrifosHomeScreen({super.key});

  @override
  State<GrifosHomeScreen> createState() => _GrifosHomeScreenState();
}

class _GrifosHomeScreenState extends State<GrifosHomeScreen> {
  String _filtroEstado = 'Todos';
  String _busqueda = '';
  bool _isLoading = true;
  String? _errorMessage;
  String _bomberoName = 'Voluntario';

  // Servicios
  final GrifoService _grifoService = GrifoService();
  final InfoGrifoService _infoGrifoService = InfoGrifoService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  // Lista de grifos desde Supabase
  List<Grifo> _grifos = [];
  Map<int, InfoGrifo> _infoGrifos = {}; // Mapa de idGrifo -> InfoGrifo más reciente
  Map<int, String> _nombresComunas = {}; // Mapa de cutCom -> nombre de comuna
  Map<int, Map<String, dynamic>> _infoCompletaGrifos = {}; // Mapa de idGrifo -> información completa

  @override
  void initState() {
    super.initState();
    _cargarGrifos();
    _cargarNombreBombero();
  }

  /// Cargar nombre del bombero autenticado
  Future<void> _cargarNombreBombero() async {
    try {
      final bombero = await _authService.getCurrentUserBombero();
      if (bombero != null) {
        setState(() {
          _bomberoName = '${bombero.nombBombero} ${bombero.apePBombero}';
        });
      }
    } catch (e) {
      debugPrint('Error al cargar nombre del bombero: $e');
    }
  }

  /// Cargar grifos desde Supabase
  Future<void> _cargarGrifos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔍 Cargando grifos con información completa...');
      
      // Cargar grifos con información completa
      final grifosResult = await _grifoService.getGrifosConInfoCompleta();
      
      if (grifosResult.isSuccess && grifosResult.data != null) {
        debugPrint('✅ Grifos con información cargados: ${grifosResult.data!.length}');
        
        // Procesar la información
        final List<Grifo> grifos = [];
        final Map<int, InfoGrifo> infoGrifos = {};
        final Map<int, String> nombresComunas = {};
        final Map<int, Map<String, dynamic>> infoCompleta = {};
        
        for (final grifoData in grifosResult.data!) {
          // Crear objeto Grifo
          final grifo = Grifo.fromJson(grifoData);
          grifos.add(grifo);
          
          // Obtener información de comuna
          final comunaData = grifoData['comunas'] as Map<String, dynamic>?;
          if (comunaData != null) {
            nombresComunas[grifo.cutCom] = comunaData['comuna'] as String;
          }
          
          // Procesar información de grifo
          final infoGrifoData = grifoData['info_grifo'] as List<dynamic>?;
          if (infoGrifoData != null && infoGrifoData.isNotEmpty) {
            // Obtener la información más reciente
            InfoGrifo? infoMasReciente;
            Map<String, dynamic>? infoCompletaMasReciente;
            
            for (final infoData in infoGrifoData) {
              final info = InfoGrifo.fromJson(infoData);
              if (infoMasReciente == null || info.fechaRegistro.isAfter(infoMasReciente.fechaRegistro)) {
                infoMasReciente = info;
                infoCompletaMasReciente = {
                  'info_grifo': infoData,
                  'bombero': infoData['bombero'],
                  'comuna': comunaData,
                };
              }
            }
            
            if (infoMasReciente != null) {
              infoGrifos[grifo.idGrifo] = infoMasReciente;
              infoCompleta[grifo.idGrifo] = infoCompletaMasReciente!;
            }
          }
        }
        
        setState(() {
          _grifos = grifos;
          _infoGrifos = infoGrifos;
          _nombresComunas = nombresComunas;
          _infoCompletaGrifos = infoCompleta;
          _isLoading = false;
        });
        
        debugPrint('✅ Información procesada:');
        debugPrint('   - Grifos: ${grifos.length}');
        debugPrint('   - Con información: ${infoGrifos.length}');
        debugPrint('   - Comunas: ${nombresComunas.length}');
      } else {
        debugPrint('❌ Error cargando grifos: ${grifosResult.error}');
        setState(() {
          _errorMessage = grifosResult.error ?? 'Error al cargar grifos';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Grifo> get _grifosFiltrados {
    final grifosFiltrados = _grifos.where((grifo) {
      // Filtrar por búsqueda de texto
      bool cumpleBusqueda = _busqueda.isEmpty ||
          grifo.cutCom.toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
          (_nombresComunas[grifo.cutCom]?.toLowerCase().contains(_busqueda.toLowerCase()) ?? false);
      
      // Filtrar por estado
      bool cumpleEstado = true;
      if (_filtroEstado != 'Todos') {
        final infoGrifo = _infoGrifos[grifo.idGrifo];
        if (infoGrifo != null) {
          cumpleEstado = infoGrifo.estado.toLowerCase() == _filtroEstado.toLowerCase();
        } else {
          // Si no hay información de estado, solo mostrar si el filtro es "Sin verificar"
          cumpleEstado = _filtroEstado.toLowerCase() == 'sin verificar';
        }
      }
      
      return cumpleBusqueda && cumpleEstado;
    }).toList();
    
    // Log de depuración
    debugPrint('🔍 Filtros aplicados:');
    debugPrint('   - Búsqueda: "$_busqueda"');
    debugPrint('   - Estado: "$_filtroEstado"');
    debugPrint('   - Total grifos: ${_grifos.length}');
    debugPrint('   - Grifos filtrados: ${grifosFiltrados.length}');
    
    return grifosFiltrados;
  }

  Map<String, int> get _estadisticas {
    final Map<String, int> stats = {
      'total': _grifos.length,
      'operativos': 0,
      'dañados': 0,
      'mantenimiento': 0,
      'sin_verificar': 0,
    };

    // Contar estados desde la información de grifos
    for (final info in _infoGrifos.values) {
      switch (info.estado.toLowerCase()) {
        case 'operativo':
          stats['operativos'] = (stats['operativos'] ?? 0) + 1;
          break;
        case 'dañado':
          stats['dañados'] = (stats['dañados'] ?? 0) + 1;
          break;
        case 'mantenimiento':
          stats['mantenimiento'] = (stats['mantenimiento'] ?? 0) + 1;
          break;
        case 'sin verificar':
          stats['sin_verificar'] = (stats['sin_verificar'] ?? 0) + 1;
          break;
      }
    }

    // Los grifos sin información en _infoGrifos se consideran "sin verificar"
    final grifosConInfo = _infoGrifos.keys.toSet();
    final grifosSinInfo = _grifos.where((grifo) => !grifosConInfo.contains(grifo.idGrifo)).length;
    stats['sin_verificar'] = (stats['sin_verificar'] ?? 0) + grifosSinInfo;

    return stats;
  }

  void _cambiarEstadoGrifo(int id, String nuevoEstado) async {
    try {
      // Obtener el RUT del bombero autenticado
      final authService = SupabaseAuthService();
      final bombero = await authService.getCurrentUserBombero();
      
      if (bombero == null) {
        throw Exception('No se pudo obtener la información del bombero autenticado. Por favor, inicie sesión nuevamente.');
      }
      
      debugPrint('✅ Bombero autenticado encontrado: ${bombero.rutCompleto} (${bombero.nombBombero} ${bombero.apePBombero})');
      
      // Crear nueva información de grifo con el estado actualizado
      final nuevaInfoGrifo = InfoGrifo(
        idRegGrifo: DateTime.now().millisecondsSinceEpoch,
        idGrifo: id,
        fechaRegistro: DateTime.now(),
        estado: nuevoEstado,
        nota: '', // Sin notas al cambiar estado
        rutNum: bombero.rutNum, // Usar el RUT del bombero autenticado
      );

      debugPrint('📝 Cambiando estado del grifo $id a: $nuevoEstado');
      debugPrint('📝 Datos info_grifo: ${nuevaInfoGrifo.toInsertData()}');

      // Guardar en Supabase
      final result = await _infoGrifoService.insertInfoGrifo(nuevaInfoGrifo);
      
      if (result.isSuccess) {
        // Actualizar el mapa local
        setState(() {
          _infoGrifos[id] = nuevaInfoGrifo;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estado cambiado a: $nuevoEstado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result.error ?? 'Error al cambiar estado');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navegarARegistro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterGrifoScreen(),
      ),
    );

    // Si se registró un grifo exitosamente, recargar la lista
    if (resultado != null && mounted) {
      _cargarGrifos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _estadisticas;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
          'Sistema de Grifos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _cargarGrifos,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cargando grifos...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Error al cargar grifos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _cargarGrifos,
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text(
                              'Reintentar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: ResponsiveContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildRegisterButton(),
                        _buildStats(stats),
                        _buildSearchSection(),
                        GrifoMapPlaceholder(itemCount: _grifosFiltrados.length),
                        _buildGrifosList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
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
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Bienvenido, Voluntario $_bomberoName',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 22,
                  desktop: 26,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? 64 : 56,
        child: ElevatedButton.icon(
          onPressed: _navegarARegistro,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Registrar Grifo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
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

  Widget _buildStats(Map<String, int> stats) {
    return GrifoStatsSection(stats: stats);
  }

  Widget _buildSearchSection() {
    return GrifoSearchSection(
      filtroEstado: _filtroEstado,
      onBusquedaChanged: (value) => setState(() => _busqueda = value),
      onFiltroChanged: (value) => setState(() => _filtroEstado = value!),
    );
  }

  Widget _buildGrifosList() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Text(
            'Lista de Grifos (${_grifosFiltrados.length})',
            style: GrifoStyles.titleLarge,
          ),
        ),
        ..._grifosFiltrados.map(
          (grifo) => GrifoCard(
            grifo: grifo,
            infoGrifo: _infoGrifos[grifo.idGrifo],
            nombreComuna: _nombresComunas[grifo.cutCom] ?? 'Comuna ${grifo.cutCom}',
            infoCompleta: _infoCompletaGrifos[grifo.idGrifo],
            onCambiarEstado: _cambiarEstadoGrifo,
          ),
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }
}
