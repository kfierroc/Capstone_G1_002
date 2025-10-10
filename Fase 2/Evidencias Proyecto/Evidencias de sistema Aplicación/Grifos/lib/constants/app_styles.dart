import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos estandarizados de la aplicación
class AppStyles {
  AppStyles._();

  // Radios de borde estandarizados
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusCircle = 25.0;

  // Elevaciones
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Espaciados
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 40.0;

  // Tamaños de iconos
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 60.0;
  static const double iconXLarge = 80.0;

  // BorderRadius reutilizables
  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusCircle =>
      BorderRadius.circular(radiusCircle);

  // Sombras estándar
  static List<BoxShadow> shadowLight = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> shadowMedium = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ];

  // InputDecoration estándar
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: borderRadiusMedium,
      ),
      filled: true,
      fillColor: AppColors.surfaceVariant,
    );
  }

  // Estilos de texto estándar
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textTertiary,
    fontStyle: FontStyle.italic,
  );
}

