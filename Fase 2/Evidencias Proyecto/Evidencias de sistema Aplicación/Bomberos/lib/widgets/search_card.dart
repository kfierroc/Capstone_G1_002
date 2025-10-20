import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../utils/responsive.dart';

/// Tarjeta de búsqueda de domicilio
class SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const SearchCard({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: EdgeInsets.all(isTablet ? AppTheme.paddingXxl : AppTheme.paddingLg),
      decoration: AppThemeDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Búsqueda de Domicilio',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppTheme.fontLg,
                tablet: AppTheme.fontXxl,
                desktop: 24,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppTheme.spaceMd : AppTheme.spaceSm),
          Text(
            'Ingresa la dirección para obtener información crítica del domicilio',
            style: AppTextStyles.subtitleSecondary.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppTheme.fontSm,
                tablet: AppTheme.fontMd,
                desktop: AppTheme.fontLg,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppTheme.spaceXxl : AppTheme.spaceXl),
          TextField(
            controller: controller,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppTheme.fontLg,
                tablet: AppTheme.fontXl,
                desktop: AppTheme.fontXxl,
              ),
            ),
            decoration: AppThemeDecorations.textField(
              prefixIcon: Icons.location_on,
              borderRadius: isTablet ? AppTheme.radius : AppTheme.radiusMd,
            ).copyWith(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? AppTheme.paddingLg : AppTheme.paddingMd,
                vertical: isTablet ? AppTheme.paddingLg : AppTheme.paddingMd,
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          SizedBox(height: isTablet ? AppTheme.spaceXl : AppTheme.spaceLg),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: isTablet
                      ? AppTheme.buttonHeightTablet
                      : AppTheme.buttonHeightMobile,
                  child: ElevatedButton(
                    onPressed: onSearch,
                    style: AppThemeDecorations.elevatedButton(),
                    child: Text(
                      'Buscar',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: AppTheme.fontMd,
                          tablet: AppTheme.fontLg,
                          desktop: AppTheme.fontXl,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? AppTheme.spaceXl : AppTheme.spaceLg),
              Expanded(
                child: SizedBox(
                  height: isTablet
                      ? AppTheme.buttonHeightTablet
                      : AppTheme.buttonHeightMobile,
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: AppThemeDecorations.outlinedButton(),
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: AppTheme.fontMd,
                          tablet: AppTheme.fontLg,
                          desktop: AppTheme.fontXl,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
