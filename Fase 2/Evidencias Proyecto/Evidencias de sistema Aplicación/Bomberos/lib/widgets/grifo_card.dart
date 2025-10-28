import 'package:flutter/material.dart';
import '../models/grifo.dart';
import '../models/info_grifo.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';
import '../utils/responsive.dart';

class GrifoCard extends StatelessWidget {
  final Grifo grifo;
  final InfoGrifo? infoGrifo; // Información adicional del grifo
  final String nombreComuna; // Nombre de la comuna
  final Map<String, dynamic>? infoCompleta; // Información completa incluyendo bombero
  final Function(int, String) onCambiarEstado;

  const GrifoCard({
    super.key,
    required this.grifo,
    this.infoGrifo,
    required this.nombreComuna,
    this.infoCompleta,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Obtener color basado en el estado del grifo
    final estadoColor = _getEstadoColor();
    final estadoTexto = infoGrifo?.estado ?? 'Sin verificar';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: estadoColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: estadoColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetallesDialog(context),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernHeader(context, estadoColor, estadoTexto),
                SizedBox(height: isTablet ? 20 : 16),
                _buildModernInfo(context),
                SizedBox(height: isTablet ? 20 : 16),
                _buildModernActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, Color estadoColor, String estadoTexto) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // En móviles, usar layout vertical para evitar overflow
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      estadoColor.withValues(alpha: 0.1),
                      estadoColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: estadoColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: estadoColor,
                  size: isTablet ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Grifo ${grifo.idGrifo}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  grifo.cutCom.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: estadoColor, width: 1),
            ),
            child: Text(
              estadoTexto,
              style: TextStyle(
                color: estadoColor,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ),
        ],
      );
    }
    
    // En tablets y desktop, usar layout horizontal
    return Row(
      children: [
        // Icono del grifo con estado
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                estadoColor.withValues(alpha: 0.1),
                estadoColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: estadoColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.water_drop_rounded,
            color: estadoColor,
            size: isTablet ? 28 : 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grifo ${grifo.idGrifo}',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: estadoColor, width: 1),
                ),
                child: Text(
                  estadoTexto,
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            grifo.cutCom.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfo(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
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
          _buildInfoRow(
            context: context,
            icon: Icons.location_city_rounded,
            label: 'Comuna',
            value: nombreComuna,
            color: const Color(0xFF10B981),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildInfoRow(
            context: context,
            icon: Icons.my_location_rounded,
            label: 'Coordenadas',
            value: '${grifo.lat.toStringAsFixed(4)}, ${grifo.lon.toStringAsFixed(4)}',
            color: const Color(0xFF3B82F6),
          ),
          if (infoGrifo != null) ...[
            SizedBox(height: isTablet ? 16 : 12),
            _buildInfoRow(
              context: context,
              icon: Icons.update_rounded,
              label: 'Última inspección',
              value: _formatDateComplete(infoGrifo!.fechaRegistro),
              color: const Color(0xFF8B5CF6),
            ),
                  SizedBox(height: isTablet ? 16 : 12),
                  _buildReporterInfo(context),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
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
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateComplete(DateTime? date) {
    if (date == null) return 'No disponible';
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildReporterInfo(BuildContext context) {
    if (infoCompleta == null || infoCompleta!['bombero'] == null) {
      return _buildInfoRow(
        context: context,
        icon: Icons.person_rounded,
        label: 'Reportado por',
        value: 'Información no disponible',
        color: const Color(0xFF64748B),
      );
    }
    
    final bomberoData = infoCompleta!['bombero'] as Map<String, dynamic>;
    final nombreBombero = bomberoData['nomb_bombero'] as String? ?? 'No disponible';
    final apellidoBombero = bomberoData['ape_p_bombero'] as String? ?? 'No disponible';
    
    // Truncar nombres largos para evitar overflow
    final nombreTruncado = nombreBombero.length > 15 ? '${nombreBombero.substring(0, 15)}...' : nombreBombero;
    final apellidoTruncado = apellidoBombero.length > 15 ? '${apellidoBombero.substring(0, 15)}...' : apellidoBombero;
    
    return _buildInfoRow(
      context: context,
      icon: Icons.person_rounded,
      label: 'Reportado por',
      value: 'Voluntario $nombreTruncado $apellidoTruncado',
      color: const Color(0xFFF59E0B),
    );
  }

  Widget _buildModernActions(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // En móviles, usar layout vertical para mejor usabilidad
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: isTablet ? 52 : 48,
            child: ElevatedButton.icon(
              onPressed: () => _showEstadoDialog(context),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Cambiar Estado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 52 : 48,
            child: OutlinedButton.icon(
              onPressed: () => _showDetallesDialog(context),
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              label: const Text('Ver Detalles'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // En tablets y desktop, usar layout horizontal
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: isTablet ? 52 : 48,
            child: ElevatedButton.icon(
              onPressed: () => _showEstadoDialog(context),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Cambiar Estado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: SizedBox(
            height: isTablet ? 52 : 48,
            child: OutlinedButton.icon(
              onPressed: () => _showDetallesDialog(context),
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              label: const Text('Ver Detalles'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEstadoDialog(BuildContext context) {
    final estados = ['Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: estados.map((estado) => ListTile(
            title: Text(estado),
            onTap: () {
              Navigator.pop(context);
              onCambiarEstado(grifo.idGrifo, estado);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showDetallesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grifo ${grifo.idGrifo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID:', grifo.idGrifo.toString()),
            _buildDetailRow('Comuna:', nombreComuna),
            _buildDetailRow('Latitud:', grifo.lat.toStringAsFixed(6)),
            _buildDetailRow('Longitud:', grifo.lon.toStringAsFixed(6)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GrifoStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
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

  /// Obtener color basado en el estado del grifo
  Color _getEstadoColor() {
    if (infoGrifo == null) return GrifoColors.sinVerificar;
    
    return GrifoColors.getEstadoColor(infoGrifo!.estado);
  }
}
