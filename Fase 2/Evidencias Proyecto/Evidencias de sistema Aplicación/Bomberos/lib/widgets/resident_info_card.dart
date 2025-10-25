import 'package:flutter/material.dart';

/// Widget para mostrar información detallada de un residente
class ResidentInfoCard extends StatelessWidget {
  final Map<String, dynamic> residentData;
  final VoidCallback? onClose;

  const ResidentInfoCard({
    super.key,
    required this.residentData,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final grupoFamiliar = residentData['grupo_familiar'] as Map<String, dynamic>? ?? {};
    final integrantes = residentData['integrantes'] as List<dynamic>? ?? [];
    final mascotas = residentData['mascotas'] as List<dynamic>? ?? [];
    final registroV = residentData['registro_v'] as Map<String, dynamic>? ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header moderno con gradiente
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Información del Residente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (onClose != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: onClose,
                    ),
                  ),
              ],
            ),
          ),
          // Contenido con padding moderno
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Información de contacto
                _buildModernSection(
                  'Contacto',
                  Icons.contact_phone_rounded,
                  const Color(0xFF3B82F6),
                  [
                    _buildModernInfoRow('Dirección', residentData['address'] ?? 'No especificada', Icons.location_on_rounded),
                    _buildModernInfoRow('Teléfono', grupoFamiliar['telefono_titular'] ?? 'No especificado', Icons.phone_rounded),
                    _buildModernInfoRow('RUT Titular', grupoFamiliar['rut_titular'] ?? 'No especificado', Icons.badge_rounded),
                    _buildModernInfoRow('Email', grupoFamiliar['email'] ?? 'No especificado', Icons.email_rounded),
                  ],
                ),

                const SizedBox(height: 24),

                // Información de la vivienda
                _buildModernSection(
                  'Vivienda',
                  Icons.home_rounded,
                  const Color(0xFF10B981),
                  [
                    _buildModernInfoRow('Tipo', registroV['tipo'] ?? 'No especificado', Icons.category_rounded),
                    _buildModernInfoRow('Material', registroV['material'] ?? 'No especificado', Icons.construction_rounded),
                    _buildModernInfoRow('Estado', registroV['estado'] ?? 'No especificado', Icons.check_circle_rounded),
                    _buildModernInfoRow('Pisos', registroV['pisos']?.toString() ?? 'No especificado', Icons.stairs_rounded),
                  ],
                ),

                const SizedBox(height: 24),

                // Integrantes del hogar
                if (integrantes.isNotEmpty) ...[
                  _buildModernSection(
                    'Integrantes del Hogar (${integrantes.length})',
                    Icons.people_rounded,
                    const Color(0xFF8B5CF6),
                    integrantes.map((integrante) => _buildModernIntegranteInfo(integrante)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Mascotas
                if (mascotas.isNotEmpty) ...[
                  _buildModernSection(
                    'Mascotas (${mascotas.length})',
                    Icons.pets_rounded,
                    const Color(0xFFF59E0B),
                    mascotas.map((mascota) => _buildModernMascotaInfo(mascota)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Información de actualización
                _buildModernSection(
                  'Información del Sistema',
                  Icons.info_rounded,
                  const Color(0xFF6B7280),
                  [
                    _buildModernInfoRow('Última actualización', _formatLastUpdated(residentData['last_updated']), Icons.update_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildModernIntegranteInfo(Map<String, dynamic> integrante) {
    final padecimientos = integrante['padecimientos'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Integrante #${integrante['id_integrante']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          if (integrante['edad'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Edad: ${integrante['edad']} años',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
          if (padecimientos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Condiciones médicas:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: padecimientos.map((padecimiento) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
                ),
                child: Text(
                  padecimiento.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDC2626),
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildModernMascotaInfo(Map<String, dynamic> mascota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pets_rounded,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mascota['nombre_m'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mascota['especie'] ?? 'Especie no especificada'} - ${mascota['tamanio'] ?? 'Tamaño no especificado'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
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
      return 'Hoy';
    }
    
    try {
      final dateTime = DateTime.parse(lastUpdated.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Hace menos de 1 minuto';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} minutos';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} horas';
      } else if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return 'Hace ${(difference.inDays / 7).floor()} semanas';
      }
    } catch (e) {
      return 'Hoy';
    }
  }
}
