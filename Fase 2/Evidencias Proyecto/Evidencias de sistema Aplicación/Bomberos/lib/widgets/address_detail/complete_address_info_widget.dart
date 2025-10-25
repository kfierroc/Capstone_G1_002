import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget que muestra toda la información del domicilio en una sola tarjeta
/// Siguiendo el diseño exacto de la imagen proporcionada
class CompleteAddressInfoWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onViewMap;

  const CompleteAddressInfoWidget({
    super.key,
    required this.data,
    this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final registroV = data['registro_v'] as Map<String, dynamic>? ?? {};
    
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con icono de mapa
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFF3B82F6),
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Información del Domicilio',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Dirección
          _buildSection(
            'Dirección',
            data['address'] as String? ?? 'No especificada',
            isTablet,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          
          // Detalles de la Vivienda
          _buildSection(
            'Detalles de la Vivienda',
            null,
            isTablet,
            children: [
              _buildHousingDetail(
                'Tipo de vivienda',
                registroV['tipo'] as String? ?? 'No especificado',
                isTablet,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              _buildHousingDetail(
                'Material de construcción',
                registroV['material'] as String? ?? 'No especificado',
                isTablet,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              _buildHousingDetail(
                'Piso del departamento',
                registroV['pisos']?.toString() ?? 'No especificado',
                isTablet,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              _buildHousingDetail(
                'Estado de la vivienda',
                registroV['estado'] as String? ?? 'No especificado',
                isTablet,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          
          // Instrucciones Especiales (si existen)
          if (data['instrucciones_especiales'] != null && 
              (data['instrucciones_especiales'] as String).isNotEmpty) ...[
            _buildSection(
              'Instrucciones Especiales',
              data['instrucciones_especiales'] as String,
              isTablet,
            ),
            SizedBox(height: isTablet ? 16 : 12),
          ],
          
          // Footer con fecha y botón
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Última actualización
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: const Color(0xFF64748B),
                    size: isTablet ? 16 : 14,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    'Última actualización: ${_formatLastUpdated(data['last_update'])}',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Botón Ver en Mapa
              ElevatedButton.icon(
                onPressed: onViewMap,
                icon: Icon(
                  Icons.location_on_rounded,
                  size: isTablet ? 16 : 14,
                ),
                label: Text(
                  'Ver en Mapa',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 10,
                    vertical: isTablet ? 8 : 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? content, bool isTablet, {List<Widget>? children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        if (content != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            content,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
        if (children != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          ...children,
        ],
      ],
    );
  }

  Widget _buildHousingDetail(String label, String value, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isTablet ? 140 : 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated(dynamic lastUpdated) {
    if (lastUpdated == null || lastUpdated.toString().toLowerCase() == 'null') {
      return 'No registrada';
    }
    
    try {
      DateTime dateTime;
      
      if (lastUpdated is String) {
        // Intentar parsear diferentes formatos de fecha
        if (lastUpdated.contains('T')) {
          dateTime = DateTime.parse(lastUpdated);
        } else if (lastUpdated.contains('-')) {
          dateTime = DateTime.parse(lastUpdated);
        } else {
          return 'No registrada';
        }
      } else if (lastUpdated is DateTime) {
        dateTime = lastUpdated;
      } else {
        return 'No registrada';
      }
      
      // Formato: año-mes-día (como en la imagen)
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      
      return '$year-$month-$day';
    } catch (e) {
      return 'No registrada';
    }
  }
}
