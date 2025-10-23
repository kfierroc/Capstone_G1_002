import 'package:flutter/material.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';

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

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con botón de cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Información del Residente',
                  style: GrifoStyles.titleLarge.copyWith(
                    color: GrifoColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    color: GrifoColors.error,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Información de contacto
            _buildSection(
              'Contacto',
              Icons.contact_phone,
              [
                _buildInfoRow('Dirección', residentData['address'] ?? 'No especificada'),
                _buildInfoRow('Teléfono', grupoFamiliar['telefono_titular'] ?? 'No especificado'),
                _buildInfoRow('RUT Titular', grupoFamiliar['rut_titular'] ?? 'No especificado'),
                _buildInfoRow('Email', grupoFamiliar['email'] ?? 'No especificado'),
              ],
            ),

            const SizedBox(height: 16),

            // Información de la vivienda
            _buildSection(
              'Vivienda',
              Icons.home,
              [
                _buildInfoRow('Tipo', registroV['tipo'] ?? 'No especificado'),
                _buildInfoRow('Material', registroV['material'] ?? 'No especificado'),
                _buildInfoRow('Estado', registroV['estado'] ?? 'No especificado'),
                _buildInfoRow('Pisos', registroV['pisos']?.toString() ?? 'No especificado'),
                if (registroV['instrucciones_especiales'] != null)
                  _buildInfoRow('Instrucciones Especiales', _parseInstruccionesEspeciales(registroV['instrucciones_especiales'])),
              ],
            ),

            const SizedBox(height: 16),

            // Integrantes del hogar
            if (integrantes.isNotEmpty) ...[
              _buildSection(
                'Integrantes del Hogar (${integrantes.length})',
                Icons.people,
                integrantes.map((integrante) => _buildIntegranteInfo(integrante)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Mascotas
            if (mascotas.isNotEmpty) ...[
              _buildSection(
                'Mascotas (${mascotas.length})',
                Icons.pets,
                mascotas.map((mascota) => _buildMascotaInfo(mascota)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Información de actualización
            _buildSection(
              'Información del Sistema',
              Icons.info_outline,
              [
                _buildInfoRow('Última actualización', _formatLastUpdated(residentData['last_updated'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: GrifoColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GrifoStyles.titleMedium.copyWith(
                color: GrifoColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GrifoStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: GrifoColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GrifoStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegranteInfo(Map<String, dynamic> integrante) {
    final padecimientos = integrante['padecimientos'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrifoColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GrifoColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Integrante #${integrante['id_integrante']}',
            style: GrifoStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (integrante['edad'] != null)
            Text('Edad: ${integrante['edad']} años'),
          if (padecimientos.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Condiciones médicas:',
              style: GrifoStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: GrifoColors.error,
              ),
            ),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: padecimientos.map((padecimiento) => Chip(
                label: Text(
                  padecimiento.toString(),
                  style: GrifoStyles.bodySmall,
                ),
                backgroundColor: GrifoColors.error.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: GrifoColors.error,
                  fontSize: 10,
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMascotaInfo(Map<String, dynamic> mascota) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrifoColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GrifoColors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pets,
            size: 16,
            color: GrifoColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mascota['nombre_m'] ?? 'Sin nombre',
                  style: GrifoStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${mascota['especie'] ?? 'Especie no especificada'} - ${mascota['tamanio'] ?? 'Tamaño no especificado'}',
                  style: GrifoStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _parseInstruccionesEspeciales(dynamic instrucciones) {
    if (instrucciones == null) return 'No especificadas';
    
    try {
      // Si es un JSON string, extraer el valor
      if (instrucciones is String && instrucciones.startsWith('{')) {
        final jsonData = Map<String, dynamic>.from(
          Uri.splitQueryString(instrucciones.replaceAll('{', '').replaceAll('}', ''))
        );
        return jsonData['general'] ?? instrucciones;
      }
      return instrucciones.toString();
    } catch (e) {
      return instrucciones.toString();
    }
  }

  String _formatLastUpdated(dynamic lastUpdated) {
    if (lastUpdated == null) return 'No disponible';
    
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
      } else {
        return 'Hace ${difference.inDays} días';
      }
    } catch (e) {
      return 'Formato inválido';
    }
  }
}
