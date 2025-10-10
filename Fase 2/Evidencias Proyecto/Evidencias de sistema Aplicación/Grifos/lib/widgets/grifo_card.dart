import 'package:flutter/material.dart';
import '../models/grifo.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/formatters.dart';

/// Tarjeta que muestra información de un grifo
class GrifoCard extends StatelessWidget {
  final Grifo grifo;
  final Function(String, String) onCambiarEstado;

  const GrifoCard({
    Key? key,
    required this.grifo,
    required this.onCambiarEstado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: ResponsiveHelper.padding(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      elevation: AppStyles.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(
            context,
            mobile: 8,
            tablet: 10,
            desktop: 12,
          ),
        ),
      ),
      child: Padding(
        padding: ResponsiveHelper.padding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(
              height: ResponsiveHelper.spacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            _buildInfo(context),
            SizedBox(
              height: ResponsiveHelper.spacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${grifo.direccion}, ${grifo.comuna}',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildEstadoBadge(context),
      ],
    );
  }

  Widget _buildEstadoBadge(BuildContext context) {
    final color = AppColors.getEstadoColor(grifo.estado);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.spacing(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        vertical: ResponsiveHelper.spacing(
          context,
          mobile: 6,
          tablet: 8,
          desktop: 10,
        ),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(
            context,
            mobile: 12,
            tablet: 15,
            desktop: 18,
          ),
        ),
        border: Border.all(color: color),
      ),
      child: Text(
        grifo.estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.fontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: ResponsiveHelper.fontSize(
        context,
        mobile: 14,
        tablet: 16,
        desktop: 18,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo: ${grifo.tipo}', style: textStyle),
        Text(
          'Última inspección: ${Formatters.formatDate(grifo.ultimaInspeccion)}',
          style: textStyle,
        ),
        const SizedBox(height: AppStyles.spacingSmall),
        Text(
          'Notas: ${grifo.notas}',
          style: textStyle.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppStyles.spacingSmall),
        Text(
          'Reportado por ${grifo.reportadoPor} el ${Formatters.formatDate(grifo.fechaReporte)}',
          style: textStyle.copyWith(
            fontSize: ResponsiveHelper.fontSize(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return _buildMobileButtons(context);
    }
    return _buildDesktopButtons(context);
  }

  Widget _buildMobileButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatusButton(
                context,
                'Operativo',
                AppColors.operativo,
              ),
            ),
            const SizedBox(width: AppStyles.spacingSmall),
            Expanded(
              child: _buildStatusButton(
                context,
                'Dañado',
                AppColors.danado,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppStyles.spacingSmall),
        _buildStatusButton(
          context,
          'Mantenimiento',
          AppColors.mantenimiento,
        ),
      ],
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusButton(context, 'Operativo', AppColors.operativo),
        ),
        const SizedBox(width: AppStyles.spacingSmall),
        Expanded(
          child: _buildStatusButton(context, 'Dañado', AppColors.danado),
        ),
        const SizedBox(width: AppStyles.spacingSmall),
        Expanded(
          child: _buildStatusButton(
            context,
            'Mantenimiento',
            AppColors.mantenimiento,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String estado,
    Color color,
  ) {
    return OutlinedButton(
      onPressed: () => onCambiarEstado(grifo.id, estado),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.spacing(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
    );
  }
}

