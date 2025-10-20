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
      id: '1',
      direccion: 'Plaza Central',
      comuna: 'Maipú',
      tipo: 'Alto flujo',
      estado: 'Dañado',
      ultimaInspeccion: DateTime(2024, 1, 10),
      notas: 'Válvula dañada, requiere reparación urgente. No operativo.',
      reportadoPor: 'Teniente Silva',
      fechaReporte: DateTime(2024, 1, 10),
      lat: -33.5110,
      lng: -70.7580,
    ),
    Grifo(
      id: '2',
      direccion: 'Calle Los Aromos 123',
      comuna: 'Ñuñoa',
      tipo: 'Seco',
      estado: 'Sin verificar',
      ultimaInspeccion: DateTime(2023, 12, 20),
      notas: 'Requiere inspección, reportado por vecinos como posiblemente dañado',
      reportadoPor: 'Llamada ciudadana',
      fechaReporte: DateTime(2024, 1, 8),
      lat: -33.4574,
      lng: -70.5945,
    ),
    Grifo(
      id: '3',
      direccion: 'Av. Libertador 1234',
      comuna: 'Las Condes',
      tipo: 'Alto flujo',
      estado: 'Operativo',
      ultimaInspeccion: DateTime(2024, 1, 15),
      notas: 'Funcionando correctamente, presión adecuada',
      reportadoPor: 'Capitán Rodriguez',
      fechaReporte: DateTime(2024, 1, 15),
      lat: -33.4172,
      lng: -70.6067,
    ),
  ];

  List<Grifo> get _grifosFiltrados {
    return _grifos.where((grifo) {
      bool cumpleFiltro =
          _filtroEstado == 'Todos' || grifo.estado == _filtroEstado;
      bool cumpleBusqueda = _busqueda.isEmpty ||
          grifo.direccion.toLowerCase().contains(_busqueda.toLowerCase()) ||
          grifo.comuna.toLowerCase().contains(_busqueda.toLowerCase());
      return cumpleFiltro && cumpleBusqueda;
    }).toList();
  }

  Map<String, int> get _estadisticas {
    return {
      'total': _grifos.length,
      'operativos': _grifos.where((g) => g.estado == 'Operativo').length,
      'dañados': _grifos.where((g) => g.estado == 'Dañado').length,
      'mantenimiento': _grifos.where((g) => g.estado == 'Mantenimiento').length,
      'sin_verificar': _grifos.where((g) => g.estado == 'Sin verificar').length,
    };
  }

  void _cambiarEstadoGrifo(String id, String nuevoEstado) {
    setState(() {
      final index = _grifos.indexWhere((g) => g.id == id);
      if (index != -1) {
        final grifo = _grifos[index];
        _grifos.removeAt(index);
        _grifos.insert(
          0,
          grifo.copyWith(
            estado: nuevoEstado,
            ultimaInspeccion: DateTime.now(),
          ),
        );
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
