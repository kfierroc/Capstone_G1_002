import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sistema de tipografía unificado siguiendo Material Design
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // TAMAÑOS DE FUENTE
  // ============================================
  
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;
  static const double fontSizeHuge = 32.0;

  // ============================================
  // PESOS DE FUENTE
  // ============================================
  
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // ============================================
  // ESTILOS DE ENCABEZADOS
  // ============================================
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: fontSizeHuge,
    fontWeight: fontWeightLight,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: fontWeightLight,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24.0,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: fontSizeXl,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightMedium,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightMedium,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: fontWeightMedium,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: fontWeightMedium,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // ============================================
  // ESTILOS ESPECIALES
  // ============================================
  
  static const TextStyle button = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightMedium,
    letterSpacing: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: fontWeightNormal,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // ============================================
  // ESTILOS PERSONALIZADOS PARA LA APLICACIÓN
  // ============================================
  
  static const TextStyle appTitle = TextStyle(
    fontSize: fontSizeXxl,
    fontWeight: fontWeightBold,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightSemiBold,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.error,
  );

  static const TextStyle successText = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.success,
  );

  static const TextStyle warningText = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.warning,
  );

  static const TextStyle infoText = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightNormal,
    letterSpacing: 0.0,
    color: AppColors.info,
  );

  // ============================================
  // MÉTODOS UTILITARIOS
  // ============================================
  
  /// Obtiene un estilo de texto con el color del tema
  static TextStyle getThemeTextStyle(BuildContext context, TextStyle baseStyle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return baseStyle.copyWith(
      color: isDark ? AppColors.textSecondary : AppColors.textPrimary,
    );
  }

  /// Obtiene un estilo de texto responsivo
  static TextStyle getResponsiveTextStyle(BuildContext context, TextStyle baseStyle) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = 1.0;
    
    if (screenWidth < 600) {
      scaleFactor = 0.9; // Móvil
    } else if (screenWidth < 1200) {
      scaleFactor = 1.0; // Tablet
    } else {
      scaleFactor = 1.1; // Desktop
    }
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? fontSizeMd) * scaleFactor,
    );
  }

  /// Obtiene un estilo de texto con color personalizado
  static TextStyle withColor(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }

  /// Obtiene un estilo de texto con peso personalizado
  static TextStyle withWeight(TextStyle baseStyle, FontWeight weight) {
    return baseStyle.copyWith(fontWeight: weight);
  }

  /// Obtiene un estilo de texto con tamaño personalizado
  static TextStyle withSize(TextStyle baseStyle, double size) {
    return baseStyle.copyWith(fontSize: size);
  }
}
