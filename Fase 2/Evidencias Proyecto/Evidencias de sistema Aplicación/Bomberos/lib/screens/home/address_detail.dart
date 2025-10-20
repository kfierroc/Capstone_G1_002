import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../widgets/home/emergency_alert_banner.dart';
import '../../widgets/search_card.dart';
import '../../widgets/critical_summary_card.dart';
import '../../widgets/address_info_card.dart';
import '../../widgets/contact_card.dart';
import '../../widgets/occupants_tab_view.dart';
import 'emergency_map.dart';

/// Pantalla de detalle de dirección con información de emergencia
class AddressDetailScreen extends StatefulWidget {
  final String addressId;

  const AddressDetailScreen({super.key, required this.addressId});

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAddress() {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un domicilio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // Búsqueda implementada - funcionalidad básica
  }

  void _clearSearch() {
    _searchController.clear();
  }

  void _navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyMapScreen(addressData: _getAddressData()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmergencyAlertBanner(),
              SearchCard(
                controller: _searchController,
                onSearch: _searchAddress,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 16),
              CriticalSummaryCard(
                peopleCount: _getPeopleData().length,
                petsCount: _getPetsData().length,
                specialConditionsCount: _countSpecialConditions(),
              ),
              const SizedBox(height: 16),
              AddressInfoCard(
                addressData: _getAddressData(),
                onViewMap: _navigateToMap,
              ),
              const SizedBox(height: 16),
              ContactCard(
                mainPhone: _getAddressData()['main_phone'] as String,
                altPhone: _getAddressData()['alt_phone'] as String,
              ),
              const SizedBox(height: 16),
              OccupantsTabView(
                people: _getPeopleData(),
                pets: _getPetsData(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red.shade700,
      foregroundColor: Colors.white,
      title: Text(
        'Sistema de Emergencias',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
      ),
    );
  }

  // Métodos de datos (mock data)
  // Datos de ejemplo - integrar con Supabase en futuras versiones

  Map<String, dynamic> _getAddressData() {
    return {
      'address': 'Av. Libertador 1234, Depto 5B, Las Condes, Santiago',
      'main_phone': '+56 9 1234 5678',
      'alt_phone': '+56 9 8765 4321',
      'housing_type': 'Departamento',
      'floor': '5',
      'construction_material': 'Hormigón/Concreto',
      'housing_condition': 'Bueno',
      'special_instructions':
          'Llave de emergencia con portero. Puerta blindada requiere herramientas especiales.',
      'last_update': '2024-01-15',
    };
  }

  List<Map<String, dynamic>> _getPeopleData() {
    return [
      {
        'name': 'Titular del domicilio',
        'age': 45,
        'rut': '12.345.678-9',
        'is_owner': true,
        'conditions': ['Diabetes', 'Problemas cardíacos'],
      },
      {
        'name': 'Persona 1',
        'age': 47,
        'conditions': ['Movilidad reducida'],
      },
      {
        'name': 'Persona 2',
        'age': 16,
        'conditions': ['Enfermedades respiratorias'],
      },
      {
        'name': 'Persona 3',
        'age': 72,
        'conditions': [
          'Adulto mayor (65+)',
          'Discapacidad sensorial',
          'Dispositivos médicos (oxígeno, etc.)',
          'Necesita ayuda para caminar',
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getPetsData() {
    return [
      {
        'name': 'Max',
        'type': 'Perro',
        'size': 'Grande',
        'breed': 'Golden Retriever',
        'weight': '35kg',
      },
      {
        'name': 'Mimi',
        'type': 'Gato',
        'size': 'Pequeño',
        'breed': 'Siamés',
        'weight': '4kg',
      },
    ];
  }

  int _countSpecialConditions() {
    int count = 0;
    for (var person in _getPeopleData()) {
      final conditions = person['conditions'] as List<String>? ?? [];
      if (conditions.isNotEmpty) {
        count++;
      }
    }
    return count;
  }
}