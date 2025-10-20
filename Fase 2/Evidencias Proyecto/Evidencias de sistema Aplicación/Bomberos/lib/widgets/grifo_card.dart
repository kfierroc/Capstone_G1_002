import 'package:flutter/material.dart';
import '../models/grifo.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';
import '../utils/responsive.dart';

class GrifoCard extends StatelessWidget {
  final Grifo grifo;
  final Function(String, String) onCambiarEstado;

  const GrifoCard({
    super.key,
    required this.grifo,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final estadoColor = GrifoColors.getEstadoColor(grifo.estado);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: GrifoStyles.borderRadiusMedium,
        boxShadow: GrifoStyles.shadowLight,
        border: Border.all(
          color: estadoColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(estadoColor),
            SizedBox(height: isTablet ? 16 : 12),
            _buildInfo(),
            SizedBox(height: isTablet ? 16 : 12),
            _buildNotas(),
            SizedBox(height: isTablet ? 16 : 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color estadoColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: estadoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: estadoColor, width: 1),
          ),
          child: Text(
            grifo.estado,
            style: TextStyle(
              color: estadoColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GrifoColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            grifo.tipo,
            style: TextStyle(
              color: GrifoColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          grifo.direccion,
          style: GrifoStyles.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          grifo.comuna,
          style: GrifoStyles.bodyMedium.copyWith(
            color: GrifoColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: GrifoColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Última inspección: ${_formatDate(grifo.ultimaInspeccion)}',
              style: GrifoStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrifoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notas:',
            style: GrifoStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            grifo.notas,
            style: GrifoStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Reportado por: ${grifo.reportadoPor}',
            style: GrifoStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showEstadoDialog(context),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Cambiar Estado'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GrifoColors.primary,
              side: BorderSide(color: GrifoColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDetallesDialog(context),
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('Ver Detalles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GrifoColors.secondary,
              side: BorderSide(color: GrifoColors.secondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
            leading: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: grifo.estado == estado ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: grifo.estado == estado ? Colors.blue : Colors.transparent,
              ),
              child: grifo.estado == estado
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            onTap: () {
              Navigator.pop(context);
              onCambiarEstado(grifo.id, estado);
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
        title: Text(grifo.direccion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Comuna:', grifo.comuna),
            _buildDetailRow('Tipo:', grifo.tipo),
            _buildDetailRow('Estado:', grifo.estado),
            _buildDetailRow('Última inspección:', _formatDate(grifo.ultimaInspeccion)),
            _buildDetailRow('Reportado por:', grifo.reportadoPor),
            _buildDetailRow('Fecha reporte:', _formatDate(grifo.fechaReporte)),
            _buildDetailRow('Coordenadas:', '${grifo.lat}, ${grifo.lng}'),
            const SizedBox(height: 12),
            const Text('Notas:', style: GrifoStyles.titleMedium),
            const SizedBox(height: 4),
            Text(grifo.notas, style: GrifoStyles.bodyMedium),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
