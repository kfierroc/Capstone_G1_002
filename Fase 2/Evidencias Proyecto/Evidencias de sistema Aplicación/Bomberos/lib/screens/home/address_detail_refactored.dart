import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../utils/responsive.dart';
import '../../constants/address_detail_styles.dart';
import '../../widgets/address_detail/address_detail_widgets.dart';

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

  void _loadUserName() {
    final currentUser = _authService.currentUser;
    if (currentUser != null && currentUser.email != null) {
      setState(() {
        _userName = _extractNameFromEmail(currentUser.email!);
      });
    }
  }

  String _extractNameFromEmail(String email) {
    final emailPart = email.split('@')[0];
    final namePart = emailPart.replaceAll(RegExp(r'[._]'), ' ');
    final words = namePart.split(' ');
    return words.map((word) => word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '').join(' ');
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = _detailedData ?? widget.residenceData;
    final integrantes = (data['integrantes'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ?? [];
    final mascotas = (data['mascotas'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      body: ResponsiveContainer(
        child: Column(
          children: [
            AddressDetailHeader(
              userName: _userName,
              onClose: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
                child: Column(
                  children: [
                    SearchSectionWidget(
                      onSearch: () {},
                      onClear: () {},
                      onViewGrifos: () => Navigator.pushNamed(context, '/grifos'),
                    ),
                    const SizedBox(height: AddressDetailStyles.paddingLarge),
                    _buildCriticalSummary(integrantes, mascotas),
                    const SizedBox(height: AddressDetailStyles.paddingLarge),
                    _buildAddressInfo(data),
                    const SizedBox(height: AddressDetailStyles.paddingLarge),
                    _buildHousingInfo(data),
                    const SizedBox(height: AddressDetailStyles.paddingLarge),
                    SpecialInstructionsWidget(
                      instructions: data['instrucciones_especiales'] as String?,
                    ),
                    const SizedBox(height: AddressDetailStyles.paddingLarge),
                    _buildContactInfo(data),
                    const SizedBox(height: AddressDetailStyles.paddingLarge),
                    OccupantsWidget(
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
      ),
    );
  }

  Widget _buildCriticalSummary(List<Map<String, dynamic>> integrantes, List<Map<String, dynamic>> mascotas) {
    final integrantesConCondiciones = integrantes.where((i) {
      final padecimiento = i['padecimiento'] as String?;
      return padecimiento != null && padecimiento.isNotEmpty;
    }).length;

    return Container(
      padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      decoration: AddressDetailStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Crítico',
            style: AddressDetailStyles.titleStyle,
          ),
          const SizedBox(height: AddressDetailStyles.paddingXLarge),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              SummaryCard(
                number: '${integrantes.length}',
                label: 'Personas',
                icon: Icons.people,
                iconColor: AddressDetailStyles.blue,
              ),
              SummaryCard(
                number: '${mascotas.length}',
                label: 'Mascotas',
                icon: Icons.pets,
                iconColor: AddressDetailStyles.orange,
              ),
              SummaryCard(
                number: '$integrantesConCondiciones',
                label: 'Con condiciones',
                icon: Icons.medical_services,
                iconColor: AddressDetailStyles.primaryRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      decoration: AddressDetailStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: AddressDetailStyles.iconSizeSmall,
                color: AddressDetailStyles.primaryRed,
              ),
              const SizedBox(width: AddressDetailStyles.paddingSmall),
              const Text(
                'Información del Domicilio',
                style: AddressDetailStyles.subtitleStyle,
              ),
            ],
          ),
          const SizedBox(height: AddressDetailStyles.paddingLarge),
          InfoRow(
            label: 'Dirección',
            value: data['direccion'] as String? ?? 'No especificada',
          ),
          InfoRow(
            label: 'Coordenadas',
            value: '${data['lat']}, ${data['lon']}',
          ),
          InfoRow(
            label: 'Comuna',
            value: data['comuna'] as String? ?? 'No especificada',
          ),
          const SizedBox(height: AddressDetailStyles.paddingXLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Última actualización: Hoy',
                style: TextStyle(
                  fontSize: AddressDetailStyles.fontSizeMedium,
                  color: AddressDetailStyles.mediumGray,
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AddressDetailStyles.blue,
                  side: const BorderSide(color: AddressDetailStyles.blue),
                ),
                child: const Text('Ver en Mapa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHousingInfo(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      decoration: AddressDetailStyles.cardDecoration,
      child: HousingInfoWidget(housingData: data),
    );
  }

  Widget _buildContactInfo(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
      decoration: AddressDetailStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContactInfoWidget(
            phoneNumber: data['telefono_principal'] as String?,
          ),
          const SizedBox(height: AddressDetailStyles.paddingLarge),
          InfoRow(
            label: 'Teléfono Principal',
            value: data['telefono_principal'] as String? ?? 'No especificado',
          ),
        ],
      ),
    );
  }
}
