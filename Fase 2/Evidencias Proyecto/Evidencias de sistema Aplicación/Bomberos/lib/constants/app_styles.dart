import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

/// Estilos de texto estandarizados
class AppTextStyles {
  AppTextStyles._();

  // Títulos
  static const titleLarge = TextStyle(
    fontSize: AppSizes.fontXxl,
    fontWeight: FontWeight.bold,
  );

  static const titleMedium = TextStyle(
    fontSize: AppSizes.fontXl,
    fontWeight: FontWeight.bold,
  );

  static const titleSmall = TextStyle(
    fontSize: AppSizes.fontLg,
    fontWeight: FontWeight.bold,
  );

  // Subtítulos
  static TextStyle subtitlePrimary = TextStyle(
    fontSize: AppSizes.font,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
  );

  static TextStyle subtitleSecondary = TextStyle(
    fontSize: AppSizes.fontSm,
    color: AppColors.textTertiary,
  );

  // Texto de cuerpo
  static const bodyLarge = TextStyle(
    fontSize: AppSizes.fontLg,
    fontWeight: FontWeight.w600,
  );

  static const bodyMedium = TextStyle(
    fontSize: AppSizes.fontBase,
    height: 1.4,
  );

  static const bodySmall = TextStyle(
    fontSize: AppSizes.font,
  );

  // Texto pequeño
  static TextStyle caption = TextStyle(
    fontSize: AppSizes.fontMd,
    color: AppColors.textTertiary,
  );

  // Texto blanco
  static const whiteTitle = TextStyle(
    color: AppColors.textWhite,
    fontWeight: FontWeight.bold,
  );

  static const whiteBody = TextStyle(
    color: AppColors.textWhite,
    height: 1.4,
  );
}

/// Decoraciones estandarizadas
class AppDecorations {
  AppDecorations._();

  // Decoración de tarjeta básica
  static BoxDecoration card({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: AppSizes.elevation,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Decoración con gradiente rojo
  static BoxDecoration redGradient({double? borderRadius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryLight, AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: AppSizes.elevationLg,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Decoración de campo de texto
  static InputDecoration textField({
    String? hintText,
    IconData? prefixIcon,
    double? borderRadius,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusMd),
      ),
      filled: true,
      fillColor: AppColors.backgroundLight,
    );
  }

  // Decoración de botón elevado
  static ButtonStyle elevatedButton({
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.secondary,
      foregroundColor: foregroundColor ?? AppColors.textWhite,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppSizes.radiusSm),
      ),
    );
  }

  // Decoración de botón outlined
  static ButtonStyle outlinedButton({double? borderRadius}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      side: BorderSide(color: AppColors.borderDark),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppSizes.radiusSm),
      ),
    );
  }
}
