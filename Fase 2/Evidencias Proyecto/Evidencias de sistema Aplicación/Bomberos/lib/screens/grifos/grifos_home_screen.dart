import 'package:flutter/material.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../services/services.dart';
import '../../constants/grifo_colors.dart';
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

  // Servicios
  final GrifoService _grifoService = GrifoService();
  final InfoGrifoService _infoGrifoService = InfoGrifoService();

  // Lista de grifos desde Supabase
  List<Grifo> _grifos = [];
  Map<int, InfoGrifo> _infoGrifos = {}; // Mapa de idGrifo -> InfoGrifo más reciente
  final Map<int, String> _nombresComunas = {}; // Mapa de cutCom -> nombre de comuna

  @override
  void initState() {
    super.initState();
    _cargarGrifos();
  }

  /// Cargar grifos desde Supabase
  Future<void> _cargarGrifos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar todos los grifos
      final grifosResult = await _grifoService.getAllGrifos();
      
      if (grifosResult.isSuccess && grifosResult.data != null) {
        setState(() {
          _grifos = grifosResult.data!;
        });

        // Cargar información de cada grifo
        await _cargarInfoGrifos();
        
        // Cargar nombres de comunas
        await _cargarNombresComunas();
      } else {
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

  /// Cargar información de grifos desde Supabase
  Future<void> _cargarInfoGrifos() async {
    try {
      final infoResult = await _infoGrifoService.getAllInfoGrifos();
      
      if (infoResult.isSuccess && infoResult.data != null) {
        // Crear mapa con la información más reciente de cada grifo
        final Map<int, InfoGrifo> infoMap = {};
        
        for (final info in infoResult.data!) {
          // Mantener solo la información más reciente de cada grifo
          if (!infoMap.containsKey(info.idGrifo) || 
              info.fechaRegistro.isAfter(infoMap[info.idGrifo]!.fechaRegistro)) {
            infoMap[info.idGrifo] = info;
          }
        }
        
        setState(() {
          _infoGrifos = infoMap;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar información de grifos: $e');
    }
  }

  /// Cargar nombres de comunas para todos los grifos
  Future<void> _cargarNombresComunas() async {
    try {
      debugPrint('🏙️ Cargando nombres de comunas...');
      
      // Obtener códigos únicos de comunas de todos los grifos
      final cutComsUnicos = _grifos.map((g) => g.cutCom).toSet();
      
      for (final cutCom in cutComsUnicos) {
        final resultado = await _grifoService.obtenerNombreComunaPorCutCom(cutCom);
        if (resultado.isSuccess) {
          setState(() {
            _nombresComunas[cutCom] = resultado.data!;
          });
        } else {
          debugPrint('⚠️ Error al cargar comuna $cutCom: ${resultado.error}');
          setState(() {
            _nombresComunas[cutCom] = 'Comuna $cutCom'; // Fallback
          });
        }
      }
      
      debugPrint('✅ Nombres de comunas cargados: $_nombresComunas');
    } catch (e) {
      debugPrint('❌ Error al cargar nombres de comunas: $e');
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
      backgroundColor: GrifoColors.background,
      appBar: AppBar(
        backgroundColor: GrifoColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sistema de Grifos',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarGrifos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: GrifoColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar grifos',
                        style: GrifoStyles.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: GrifoStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarGrifos,
                        child: const Text('Reintentar'),
                      ),
                    ],
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
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      color: GrifoColors.primary,
      child: Text(
        'Bienvenido, Capitán Rodriguez',
        style: TextStyle(
          color: Colors.white,
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 22,
            desktop: 26,
          ),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? 64 : 56,
        child: ElevatedButton.icon(
          onPressed: _navegarARegistro,
          icon: const Icon(Icons.add),
          label: const Text('Registrar Grifo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GrifoColors.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isTablet ? 16 : 12,
              ),
            ),
            elevation: 2,
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
            onCambiarEstado: _cambiarEstadoGrifo,
          ),
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }
}
