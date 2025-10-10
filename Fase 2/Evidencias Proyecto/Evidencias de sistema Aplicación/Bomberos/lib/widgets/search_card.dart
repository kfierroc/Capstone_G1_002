import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_styles.dart';
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
      padding: EdgeInsets.all(isTablet ? AppSizes.paddingXxl : AppSizes.paddingLg),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Búsqueda de Domicilio',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppSizes.fontLg,
                tablet: AppSizes.fontXxl,
                desktop: 24,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.spaceMd : AppSizes.spaceSm),
          Text(
            'Ingresa la dirección para obtener información crítica del domicilio',
            style: AppTextStyles.subtitleSecondary.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppSizes.fontSm,
                tablet: AppSizes.font,
                desktop: AppSizes.fontLg,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.spaceXxl : AppSizes.spaceXl),
          TextField(
            controller: controller,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: AppSizes.fontLg,
                tablet: AppSizes.fontXl,
                desktop: AppSizes.fontXxl,
              ),
            ),
            decoration: AppDecorations.textField(
              prefixIcon: Icons.location_on,
              borderRadius: isTablet ? AppSizes.radius : AppSizes.radiusMd,
            ).copyWith(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? AppSizes.paddingLg : AppSizes.padding,
                vertical: isTablet ? AppSizes.paddingLg : AppSizes.padding,
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          SizedBox(height: isTablet ? AppSizes.spaceXl : AppSizes.spaceLg),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: isTablet
                      ? AppSizes.buttonHeightTablet
                      : AppSizes.buttonHeightMobile,
                  child: ElevatedButton(
                    onPressed: onSearch,
                    style: AppDecorations.elevatedButton(
                      borderRadius: isTablet ? 14 : AppSizes.radiusSm,
                    ),
                    child: Text(
                      'Buscar',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textWhite,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: AppSizes.font,
                          tablet: AppSizes.fontLg,
                          desktop: AppSizes.fontXl,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? AppSizes.spaceXl : AppSizes.spaceLg),
              Expanded(
                child: SizedBox(
                  height: isTablet
                      ? AppSizes.buttonHeightTablet
                      : AppSizes.buttonHeightMobile,
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: AppDecorations.outlinedButton(
                      borderRadius: isTablet ? 14 : AppSizes.radiusSm,
                    ),
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: AppSizes.font,
                          tablet: AppSizes.fontLg,
                          desktop: AppSizes.fontXl,
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
