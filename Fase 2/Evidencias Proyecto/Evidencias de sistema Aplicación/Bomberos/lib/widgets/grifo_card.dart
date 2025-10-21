import 'package:flutter/material.dart';
import '../models/grifo.dart';
import '../constants/grifo_colors.dart';
import '../constants/grifo_styles.dart';
import '../utils/responsive.dart';

class GrifoCard extends StatelessWidget {
  final Grifo grifo;
  final Function(int, String) onCambiarEstado;

  const GrifoCard({
    super.key,
    required this.grifo,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    // Por ahora usamos un color por defecto ya que el estado está en info_grifo
    final estadoColor = Colors.blue;

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
            'Grifo ${grifo.idGrifo}',
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
            grifo.cutCom,
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
          'Grifo ${grifo.idGrifo}',
          style: GrifoStyles.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Comuna: ${grifo.cutCom}',
          style: GrifoStyles.bodyMedium.copyWith(
            color: GrifoColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: GrifoColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Coordenadas: ${grifo.lat.toStringAsFixed(4)}, ${grifo.lon.toStringAsFixed(4)}',
              style: GrifoStyles.caption,
            ),
          ],
        ),
      ],
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
            _buildDetailRow('Comuna:', grifo.cutCom),
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
}
