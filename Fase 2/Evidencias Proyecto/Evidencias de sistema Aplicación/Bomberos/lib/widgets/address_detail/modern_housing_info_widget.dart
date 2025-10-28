import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget modernizado y responsivo para mostrar información de la vivienda
/// Sin espacios excesivos y con diseño compacto
class ModernHousingInfoWidget extends StatelessWidget {
  final Map<String, dynamic> housingData;

  const ModernHousingInfoWidget({
    super.key,
    required this.housingData,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF8FAFC),
            const Color(0xFFF1F5F9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de la Vivienda',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildHousingGrid(isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildHousingGrid(bool isTablet, bool isMobile) {
    // En móviles, usar layout vertical para mejor usabilidad
    if (isMobile) {
      return Column(
        children: [
          _buildHousingInfoCard(
            'Tipo',
            housingData['tipo'] as String? ?? 'No especificado',
            Icons.category_rounded,
            const Color(0xFF3B82F6),
            isTablet,
          ),
          const SizedBox(height: 8),
          _buildHousingInfoCard(
            'Material',
            housingData['material'] as String? ?? 'No especificado',
            Icons.construction_rounded,
            const Color(0xFF10B981),
            isTablet,
          ),
          const SizedBox(height: 8),
          _buildHousingInfoCard(
            'Pisos',
            housingData['pisos']?.toString() ?? 'No especificado',
            Icons.stairs_rounded,
            const Color(0xFF8B5CF6),
            isTablet,
          ),
          const SizedBox(height: 8),
          _buildHousingInfoCard(
            'Estado',
            housingData['estado'] as String? ?? 'No especificado',
            Icons.check_circle_rounded,
            _getEstadoColor(housingData['estado'] as String?),
            isTablet,
          ),
        ],
      );
    }
    
    // En tablets y desktop, usar layout de grid adaptativo
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: crossAxisCount == 4 ? 3.5 : 2.5,
          crossAxisSpacing: isTablet ? 16 : 12,
          mainAxisSpacing: isTablet ? 16 : 12,
          children: [
        _buildHousingInfoCard(
          'Tipo',
          housingData['tipo'] as String? ?? 'No especificado',
          Icons.category_rounded,
          const Color(0xFF3B82F6),
          isTablet,
        ),
        _buildHousingInfoCard(
          'Material',
          housingData['material'] as String? ?? 'No especificado',
          Icons.construction_rounded,
          const Color(0xFF10B981),
          isTablet,
        ),
        _buildHousingInfoCard(
          'Pisos',
          housingData['pisos']?.toString() ?? 'No especificado',
          Icons.stairs_rounded,
          const Color(0xFF8B5CF6),
          isTablet,
        ),
        _buildHousingInfoCard(
          'Estado',
          housingData['estado'] as String? ?? 'No especificado',
          Icons.check_circle_rounded,
          _getEstadoColor(housingData['estado'] as String?),
          isTablet,
        ),
          ],
        );
      },
    );
  }

  Widget _buildHousingInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
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
    );
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFF64748B);
    
    switch (estado.toLowerCase()) {
      case 'excelente':
      case 'muy bueno':
        return const Color(0xFF10B981);
      case 'bueno':
        return const Color(0xFF3B82F6);
      case 'regular':
        return const Color(0xFFF59E0B);
      case 'malo':
      case 'muy malo':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }
}
