import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';
import '../../utils/responsive.dart';

/// Widget modernizado y completamente responsivo para mostrar información de ocupantes
/// Sin errores de overflow y con diseño moderno
class ModernOccupantsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> integrantes;
  final List<Map<String, dynamic>> mascotas;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const ModernOccupantsWidget({
    super.key,
    required this.integrantes,
    required this.mascotas,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: EdgeInsets.all(isTablet ? 28 : 24),
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
          _buildModernHeader(isTablet),
          SizedBox(height: isTablet ? 24 : 20),
          _buildModernTabBar(isTablet, isMobile),
          SizedBox(height: isTablet ? 24 : 20),
          _buildContentArea(isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildModernHeader(bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_rounded,
            color: Colors.white,
            size: isTablet ? 28 : 24,
          ),
        ),
        SizedBox(width: isTablet ? 20 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ocupantes del Domicilio',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${integrantes.length} personas • ${mascotas.length} mascotas',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernTabBar(bool isTablet, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 8 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'Personas',
              Icons.person_rounded,
              const Color(0xFF3B82F6),
              0,
              isTablet,
            ),
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Expanded(
            child: _buildTabButton(
              'Mascotas',
              Icons.pets_rounded,
              const Color(0xFF10B981),
              1,
              isTablet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, Color color, int tabIndex, bool isTablet) {
    final isSelected = selectedTab == tabIndex;
    final count = tabIndex == 0 ? integrantes.length : mascotas.length;
    
    return GestureDetector(
      onTap: () => onTabChanged(tabIndex),
      child: Container(
        height: isTablet ? 48 : 44, // Altura fija para ambos botones
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE2E8F0) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
              size: isTablet ? 18 : 16,
            ),
            SizedBox(width: isTablet ? 6 : 4),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea(bool isTablet, bool isMobile) {
    return Container(
      constraints: BoxConstraints(
        minHeight: isTablet ? 300 : 250,
        maxHeight: isTablet ? 500 : 400,
      ),
      child: selectedTab == 0
          ? _buildModernPersonasList(isTablet, isMobile)
          : _buildModernMascotasList(isTablet, isMobile),
    );
  }

  Widget _buildModernPersonasList(bool isTablet, bool isMobile) {
    if (integrantes.isEmpty) {
      return _buildEmptyState(
        'No hay personas registradas',
        Icons.person_off_rounded,
        const Color(0xFF64748B),
        isTablet,
      );
    }

    // Debug: Imprimir datos de integrantes
    debugPrint('🔍 Datos de integrantes: $integrantes');

    // Usar datos reales de la base de datos
    List<Map<String, dynamic>> integrantesConDatos = integrantes;

    // Separar titular de integrantes
    final titular = integrantesConDatos.firstWhere(
      (i) => i['es_titular'] == true || 
             i['titular'] == true ||
             i['es_titular_domicilio'] == true,
      orElse: () => integrantesConDatos.first, // Si no hay titular marcado, usar el primero
    );
    
    final otrosIntegrantes = integrantesConDatos.where(
      (i) => i != titular,
    ).toList();

    // Debug: Imprimir información del titular
    debugPrint('🏠 Titular encontrado: $titular');
    debugPrint('👥 Otros integrantes: $otrosIntegrantes');

    return SingleChildScrollView(
      child: Column(
        children: [
          // Mostrar titular primero
          _buildModernPersonCard(titular, -1, _extractConditions(titular), isTablet, isMobile, isTitular: true),
          
          // Mostrar otros integrantes
          ...otrosIntegrantes.asMap().entries.map((entry) {
            final index = entry.key;
            final integrante = entry.value;
            final conditions = _extractConditions(integrante);
            
            return _buildModernPersonCard(integrante, index, conditions, isTablet, isMobile, isTitular: false);
          }),
        ],
      ),
    );
  }

  Widget _buildModernMascotasList(bool isTablet, bool isMobile) {
    if (mascotas.isEmpty) {
      return _buildEmptyState(
        'No hay mascotas registradas',
        Icons.pets_rounded,
        const Color(0xFF64748B),
        isTablet,
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: mascotas.asMap().entries.map((entry) {
          final index = entry.key;
          final mascota = entry.value;
          return _buildModernPetCard(mascota, index, isTablet, isMobile);
        }).toList(),
      ),
    );
  }

  Widget _buildModernPersonCard(
      Map<String, dynamic> integrante,
      int index,
      List<String> conditions,
      bool isTablet,
      bool isMobile, {
      required bool isTitular,
    }) {
      return Container(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isTitular 
              ? const Color(0xFFE0F2FE) // Azul cálido claro para titular
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTitular 
                ? const Color(0xFF0EA5E9) // Azul cálido para titular
                : const Color(0xFFE2E8F0),
            width: isTitular ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal
              Text(
                isTitular ? 'Titular del domicilio' : 'Persona ${index + 1}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              
              // RUT en línea separada (solo para titular)
              if (isTitular && integrante['rut'] != null) ...[
                Text(
                  'RUT: ${integrante['rut']}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              
              // Edad en línea separada
              Text(
                '${integrante['edad'] ?? 'No especificada'} años',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Condiciones médicas si existen
              if (conditions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🚨 ',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Condiciones Médicas/Especiales:',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: conditions.map((condition) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          condition,
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

  Widget _buildModernPetCard(
    Map<String, dynamic> mascota,
    int index,
    bool isTablet,
    bool isMobile,
  ) {
    // Extraer información de la mascota
    final nombre = mascota['nombre_m'] ?? 'Sin nombre';
    final especie = mascota['especie'] ?? 'No especificada';
    final tamano = mascota['tamanio'] ?? 'No especificado';
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBBF7D0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre de la mascota
            Text(
              nombre,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            
            // Detalles: Especie • Tamaño
            Text(
              '$especie • $tamano',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoChip(String label, String value, IconData icon, Color color, bool isTablet) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: isTablet ? 16 : 14,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 48 : 40,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            message,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalConditions(List<String> conditions, bool isTitular, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: const Color(0xFFEF4444),
              size: isTablet ? 18 : 16,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              'Condiciones médicas/especiales:',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 8 : 6),
        Wrap(
          spacing: isTablet ? 8 : 6,
          runSpacing: isTablet ? 8 : 6,
          children: conditions.map((condition) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 10,
                vertical: isTablet ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444), // Rojo sólido
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              child: Text(
                condition,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 12 : 11,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> _extractConditions(Map<String, dynamic> integrante) {
    List<String> conditions = [];
    
    // Debug: Imprimir datos del integrante
    debugPrint('🔍 Extrayendo condiciones de: $integrante');
    
    // Lista de campos posibles donde pueden estar las condiciones médicas
    final possibleFields = [
      'condiciones_medicas',
      'condiciones_especiales', 
      'enfermedades',
      'discapacidades',
      'padecimiento',
      'condiciones',
      'problemas_salud',
      'necesidades_especiales',
      'medicamentos',
      'alergias',
      'tratamientos',
      'limitaciones',
      'cuidados_especiales'
    ];
    
    for (String field in possibleFields) {
      if (integrante[field] != null) {
        debugPrint('📋 Campo encontrado: $field = ${integrante[field]}');
        if (integrante[field] is String) {
          final condStr = integrante[field] as String;
          if (condStr.isNotEmpty && condStr.toLowerCase() != 'null') {
            // Dividir por comas, puntos y comas, o saltos de línea
            final parts = condStr.split(RegExp(r'[,;]|\n')).map((e) => e.trim()).where((e) => e.isNotEmpty);
            conditions.addAll(parts);
          }
        } else if (integrante[field] is List) {
          final condList = integrante[field] as List;
          conditions.addAll(condList.map((e) => e.toString().trim()).where((e) => e.isNotEmpty && e.toLowerCase() != 'null'));
        }
      }
    }
    
    // Eliminar duplicados y limpiar
    conditions = conditions.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    
    debugPrint('🚨 Condiciones extraídas: $conditions');
    
    return conditions;
  }
}
