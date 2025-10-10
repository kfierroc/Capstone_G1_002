import 'package:flutter/material.dart';
import '../../models/grifo.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/grifo_card.dart';
import '../../widgets/map_placeholder.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/home_stats_section.dart';
import '../../widgets/home_search_section.dart';
import 'register_grifo_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final String? userEmail;

  const HomeScreen({Key? key, required this.onLogout, this.userEmail})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filtroEstado = 'Todos';
  String _busqueda = '';
  late String _nombreUsuario;

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
  ];

  @override
  void initState() {
    super.initState();
    _nombreUsuario = widget.userEmail?.split('@').first ?? 'Usuario';
  }

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
        builder: (context) => RegistrarGrifoScreen(nombreUsuario: _nombreUsuario),
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
    final maxWidth = ResponsiveHelper.maxContentWidth(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sistema de Grifos',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildRegisterButton(),
                _buildStats(stats),
                _buildSearchSection(),
                MapPlaceholder(itemCount: _grifosFiltrados.length),
                _buildGrifosList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
                  width: double.infinity,
      padding: ResponsiveHelper.padding(
                    context,
                    mobile: const EdgeInsets.all(20),
                    tablet: const EdgeInsets.all(30),
                    desktop: const EdgeInsets.all(40),
                  ),
      color: AppColors.primary,
                  child: Text(
        'Bienvenido, $_nombreUsuario',
                    style: TextStyle(
                      color: Colors.white,
          fontSize: ResponsiveHelper.fontSize(
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
    return Padding(
      padding: ResponsiveHelper.padding(
                    context,
                    mobile: const EdgeInsets.all(16),
                    tablet: const EdgeInsets.all(20),
                    desktop: const EdgeInsets.all(24),
                  ),
      child: CustomButton(
        text: 'Registrar Grifo',
        icon: Icons.add,
        backgroundColor: AppColors.secondary,
        onPressed: _navegarARegistro,
      ),
    );
  }

  Widget _buildStats(Map<String, int> stats) {
    return HomeStatsSection(stats: stats);
  }

  Widget _buildSearchSection() {
    return HomeSearchSection(
      filtroEstado: _filtroEstado,
      onBusquedaChanged: (value) => setState(() => _busqueda = value),
      onFiltroChanged: (value) => setState(() => _filtroEstado = value!),
    );
  }

  Widget _buildGrifosList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Padding(
          padding: ResponsiveHelper.padding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
        ),
                  child: Text(
            'Lista de Grifos (${_grifosFiltrados.length})',
            style: AppStyles.titleLarge,
          ),
        ),
        ..._grifosFiltrados.map(
          (grifo) => GrifoCard(
            grifo: grifo,
            onCambiarEstado: _cambiarEstadoGrifo,
          ),
        ),
        const SizedBox(height: AppStyles.spacingXXLarge),
      ],
    );
  }
}
