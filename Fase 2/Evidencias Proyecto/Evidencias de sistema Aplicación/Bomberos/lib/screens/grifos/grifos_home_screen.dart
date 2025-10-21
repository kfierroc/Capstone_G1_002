import 'package:flutter/material.dart';
import '../../models/grifo.dart';
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

  // Mock de datos
  final List<Grifo> _grifos = [
    Grifo(
      idGrifo: 1,
      lat: -33.5110,
      lon: -70.7580,
      cutCom: '13101',
    ),
    Grifo(
      idGrifo: 2,
      lat: -33.4574,
      lon: -70.5945,
      cutCom: '13102',
    ),
    Grifo(
      idGrifo: 3,
      lat: -33.4172,
      lon: -70.6067,
      cutCom: '13103',
    ),
  ];

  List<Grifo> get _grifosFiltrados {
    return _grifos.where((grifo) {
      // Por ahora solo filtramos por búsqueda ya que el nuevo modelo no tiene estado
      bool cumpleBusqueda = _busqueda.isEmpty ||
          grifo.cutCom.toLowerCase().contains(_busqueda.toLowerCase());
      return cumpleBusqueda;
    }).toList();
  }

  Map<String, int> get _estadisticas {
    return {
      'total': _grifos.length,
      'operativos': 0, // Se obtendrá de info_grifo
      'dañados': 0,
      'mantenimiento': 0,
      'sin_verificar': 0,
    };
  }

  void _cambiarEstadoGrifo(int id, String nuevoEstado) {
    setState(() {
      final index = _grifos.indexWhere((g) => g.idGrifo == id);
      if (index != -1) {
        // En el nuevo modelo, el estado se maneja en info_grifo
        // Por ahora solo actualizamos la lista local
        final grifo = _grifos[index];
        _grifos.removeAt(index);
        _grifos.insert(0, grifo);
      }
    });
  }

  void _navegarARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterGrifoScreen(),
      ),
    ).then((nuevoGrifo) {
      if (nuevoGrifo != null && nuevoGrifo is Grifo) {
        setState(() {
          _grifos.insert(0, nuevoGrifo);
        });
      }
    });
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
      ),
      body: SingleChildScrollView(
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
            onCambiarEstado: _cambiarEstadoGrifo,
          ),
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }
}
