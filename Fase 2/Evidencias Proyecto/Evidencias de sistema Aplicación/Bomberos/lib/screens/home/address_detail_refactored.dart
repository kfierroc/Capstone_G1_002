import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/address_detail/address_detail_widgets.dart';
import '../grifos/grifos_home_screen.dart';
import './emergency_map.dart';

/// Pantalla de detalles de una dirección específica para bomberos
/// Refactorizada aplicando principios SOLID y Clean Code
class AddressDetailScreen extends StatefulWidget {
  final Map<String, dynamic> residenceData;

  const AddressDetailScreen({super.key, required this.residenceData});

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final SearchService _searchService = SearchService();
  final SupabaseAuthService _authService = SupabaseAuthService();
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic>? _detailedData;
  bool _isLoading = true;
  int _selectedTab = 0;
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadDetailedData();
    _loadUserName();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUserName() async {
    try {
      final bombero = await _authService.getCurrentUserBombero();
      if (bombero != null) {
        setState(() {
          _userName = '${bombero.nombBombero} ${bombero.apePBombero}';
        });
      } else {
        // Fallback al email si no se puede obtener el bombero
        final currentUser = _authService.currentUser;
        if (currentUser != null && currentUser.email != null) {
          setState(() {
            _userName = _extractNameFromEmail(currentUser.email!);
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar nombre del bombero: $e');
      // Fallback al email si hay error
      final currentUser = _authService.currentUser;
      if (currentUser != null && currentUser.email != null) {
        setState(() {
          _userName = _extractNameFromEmail(currentUser.email!);
        });
      }
    }
  }

  String _extractNameFromEmail(String email) {
    final emailPart = email.split('@')[0];
    final namePart = emailPart.replaceAll(RegExp(r'[._]'), ' ');
    final words = namePart.split(' ');
    return words
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Navegar a la pantalla de búsqueda con el término de búsqueda
      Navigator.pushNamed(context, '/resident-search', arguments: query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
  }

  Future<void> _loadDetailedData() async {
    try {
      final residenceId = widget.residenceData['id_residencia'] as int;
      final result = await _searchService.getResidenceDetails(residenceId);

      if (mounted) {
        setState(() {
          _detailedData = result.isSuccess ? result.data : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando detalles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = _detailedData ?? widget.residenceData;
    final integrantes =
        (data['integrantes'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    final mascotas =
        (data['mascotas'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];

    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildSimpleHeader(),
          Expanded(
            child: isDesktop 
              ? SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      SearchSectionWidget(
                        searchController: _searchController,
                        onSearch: _performSearch,
                        onClear: _clearSearch,
                        onViewGrifos: () {
                          debugPrint('🔍 Navegando a grifos...');
                          try {
                            Navigator.pushNamed(context, '/grifos');
                          } catch (error) {
                            debugPrint('❌ Error navegando a grifos: $error');
                            // Fallback: navegar directamente a la pantalla
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GrifosHomeScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildCriticalSummary(integrantes, mascotas),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildAddressInfo(data),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildHousingInfo(data),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      // Instrucciones especiales eliminadas temporalmente
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildContactInfo(data),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      ModernOccupantsWidget(
                        integrantes: integrantes,
                        mascotas: mascotas,
                        selectedTab: _selectedTab,
                        onTabChanged: (tab) =>
                            setState(() => _selectedTab = tab),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: Column(
                    children: [
                      SearchSectionWidget(
                        searchController: _searchController,
                        onSearch: _performSearch,
                        onClear: _clearSearch,
                        onViewGrifos: () {
                          debugPrint('🔍 Navegando a grifos...');
                          try {
                            Navigator.pushNamed(context, '/grifos');
                          } catch (error) {
                            debugPrint('❌ Error navegando a grifos: $error');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GrifosHomeScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildCriticalSummary(integrantes, mascotas),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildAddressInfo(data),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildHousingInfo(data),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      _buildContactInfo(data),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 20,
                      ),
                      ModernOccupantsWidget(
                        integrantes: integrantes,
                        mascotas: mascotas,
                        selectedTab: _selectedTab,
                        onTabChanged: (tab) => setState(() => _selectedTab = tab),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isTablet(context) ? 24 : 20,
        vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: const Color(0xFF3B82F6),
          ),
          Expanded(
            child: Text(
              'Detalles de Dirección',
              style: TextStyle(
                fontSize: ResponsiveHelper.isTablet(context) ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            _userName,
            style: TextStyle(
              fontSize: ResponsiveHelper.isTablet(context) ? 14 : 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalSummary(
    List<Map<String, dynamic>> integrantes,
    List<Map<String, dynamic>> mascotas,
  ) {
    final integrantesConCondiciones = integrantes.where((i) {
      // Buscar en múltiples campos posibles para condiciones médicas
      final possibleFields = [
        'condiciones_medicas',
        'condiciones_especiales',
        'enfermedades',
        'discapacidades',
        'padecimiento',
        'condiciones',
        'problemas_salud',
        'necesidades_especiales',
      ];
      
      for (String field in possibleFields) {
        if (i[field] != null) {
          if (i[field] is String) {
            final value = i[field] as String;
            if (value.isNotEmpty && value.toLowerCase() != 'null') {
              return true;
            }
          } else if (i[field] is List) {
            final list = i[field] as List;
            if (list.isNotEmpty) {
              return true;
            }
          }
        }
      }
      return false;
    }).length;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isTablet(context) ? 20 : 4,
        vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 24 : 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isTablet(context) ? 12 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: ResponsiveHelper.isTablet(context) ? 24 : 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Resumen Crítico',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.isTablet(context) ? 24 : 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildModernSummaryCard(
                  number: '${integrantes.length}',
                  label: 'Personas',
                  icon: Icons.people_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: ResponsiveHelper.isTablet(context) ? 16 : 6),
              Expanded(
                child: _buildModernSummaryCard(
                  number: '${mascotas.length}',
                  label: 'Mascotas',
                  icon: Icons.pets_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: ResponsiveHelper.isTablet(context) ? 16 : 6),
              Expanded(
                child: _buildModernSummaryCard(
                  number: '$integrantesConCondiciones',
                  label: 'Condiciones\nMedicas',
                  icon: Icons.medical_services_rounded,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummaryCard({
    required String number,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 16 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.isTablet(context) ? 10 : 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.isTablet(context) ? 20 : 16,
            ),
          ),
          SizedBox(height: ResponsiveHelper.isTablet(context) ? 10 : 6),
          Text(
            number,
            style: TextStyle(
              fontSize: ResponsiveHelper.isTablet(context) ? 22 : 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: ResponsiveHelper.isTablet(context) ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.isTablet(context) ? 12 : 9,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isTablet(context) ? 20 : 4,
        vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 24 : 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isTablet(context) ? 12 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: ResponsiveHelper.isTablet(context) ? 24 : 20,
                ),
              ),
              SizedBox(width: ResponsiveHelper.isTablet(context) ? 16 : 12),
              Expanded(
                child: Text(
                  'Información del Domicilio',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildModernInfoRow(
            label: 'Dirección',
            value: data['address'] as String? ?? 'No especificada',
            icon: Icons.home_rounded,
            color: const Color(0xFF3B82F6),
          ),
          _buildModernInfoRow(
            label: 'Coordenadas',
            value: '${data['lat']}, ${data['lon']}',
            icon: Icons.my_location_rounded,
            color: const Color(0xFF10B981),
          ),
          _buildModernInfoRow(
            label: 'Comuna',
            value: data['comuna'] as String? ?? 'No especificada',
            icon: Icons.location_city_rounded,
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isTablet(context) ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.update_rounded,
                    color: const Color(0xFF6B7280),
                    size: ResponsiveHelper.isTablet(context) ? 16 : 14,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.isTablet(context) ? 12 : 10,
                ),
                Expanded(
                  child: Text(
                    'Última actualización: ${_formatLastUpdated(data['last_updated'])}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isTablet(context) ? 14 : 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Botón Ver en Mapa
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final data = {
                  'address': _detailedData?['address'] ?? widget.residenceData['address'] ?? 'Dirección no disponible',
                  'people_count': _detailedData?['people_count'] ?? widget.residenceData['people_count'] ?? 0,
                  'pets_count': _detailedData?['pets_count'] ?? widget.residenceData['pets_count'] ?? 0,
                  'special_conditions_count': _detailedData?['special_conditions_count'] ?? widget.residenceData['special_conditions_count'] ?? 0,
                  'special_instructions': _detailedData?['special_instructions'] ?? widget.residenceData['special_instructions'] ?? 'Sin instrucciones específicas',
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmergencyMapScreen(addressData: data),
                  ),
                );
              },
              icon: const Icon(Icons.map_rounded, size: 16),
              label: Text(
                'Ver en Mapa',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isTablet(context) ? 14 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 8 : 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.isTablet(context) ? 20 : 18,
            ),
          ),
          SizedBox(width: ResponsiveHelper.isTablet(context) ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isTablet(context) ? 12 : 11,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveHelper.isTablet(context) ? 4 : 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isTablet(context) ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(dynamic lastUpdated) {
    if (lastUpdated == null || lastUpdated.toString().toLowerCase() == 'null') {
      return 'No registrada';
    }

    try {
      final dateTime = DateTime.parse(lastUpdated.toString());
      
      // Formato: día/mes/año
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      
      return '$day/$month/$year';
    } catch (e) {
      return 'No registrada';
    }
  }

  Widget _buildHousingInfo(Map<String, dynamic> data) {
    final registroV = data['registro_v'] as Map<String, dynamic>? ?? {};
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isTablet(context) ? 20 : 4,
        vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 24 : 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isTablet(context) ? 12 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_work_rounded,
                  color: Colors.white,
                  size: ResponsiveHelper.isTablet(context) ? 24 : 20,
                ),
              ),
              SizedBox(width: ResponsiveHelper.isTablet(context) ? 16 : 12),
              Expanded(
                child: Text(
                  'Información de la Vivienda',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Detalles de la Vivienda
          _buildHousingDetailRow(
            'Tipo de vivienda',
            registroV['tipo'] as String? ?? 'No especificado',
          ),
          const SizedBox(height: 12),
          _buildHousingDetailRow(
            'Piso del departamento',
            registroV['pisos']?.toString() ?? 'No especificado',
          ),
          const SizedBox(height: 12),
          _buildHousingDetailRow(
            'Material de construcción',
            registroV['material'] as String? ?? 'No especificado',
          ),
          const SizedBox(height: 12),
          _buildHousingDetailRow(
            'Estado de la vivienda',
            registroV['estado'] as String? ?? 'No especificado',
          ),
        ],
      ),
    );
  }

  Widget _buildHousingDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Agregado para evitar overflow
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.isTablet(context) ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveHelper.isTablet(context) ? 4 : 2),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.isTablet(context) ? 14 : 13,
            color: const Color(0xFF64748B),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildContactInfo(Map<String, dynamic> data) {
    final grupoFamiliar = data['grupo_familiar'] as Map<String, dynamic>? ?? {};
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isTablet(context) ? 20 : 4,
        vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 24 : 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isTablet(context) ? 12 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.contact_phone_rounded,
                  color: Colors.white,
                  size: ResponsiveHelper.isTablet(context) ? 24 : 20,
                ),
              ),
              SizedBox(width: ResponsiveHelper.isTablet(context) ? 16 : 12),
              Expanded(
                child: Text(
                  'Información de Contacto',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Información de contacto eliminada temporalmente
          const SizedBox(height: 16),
          _buildModernInfoRow(
            label: 'Teléfono Principal',
            value:
                grupoFamiliar['telefono_titular'] as String? ??
                'No especificado',
            icon: Icons.phone_rounded,
            color: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }
}
