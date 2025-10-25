import 'package:flutter/material.dart';

/// Sistema de estilos centralizado para toda la aplicación
/// Uso: AppColors.primary, AppTextStyles.heading1, etc.

// ============================================
// COLORES
// ============================================
class AppColors {
  AppColors._(); // Constructor privado para evitar instanciación

  // Colores primarios
  static const Color primary = Color(0xFF43A047);
  static final Color primaryLight = Colors.green.shade600;
  static final Color primaryDark = Colors.green.shade800;
  
  // Colores secundarios
  static const Color secondary = Color(0xFFFF6F00);
  static final Color secondaryLight = Colors.orange.shade600;
  static final Color secondaryDark = Colors.orange.shade800;
  
  // Colores de UI
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static final Color surfaceVariant = Colors.grey.shade50;
  
  // Colores de texto
  static final Color textPrimary = Colors.grey.shade900;
  static final Color textSecondary = Colors.grey.shade700;
  static final Color textTertiary = Colors.grey.shade600;
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Color(0xB3FFFFFF);
  
  // Colores de estado
  static final Color success = Colors.green.shade600;
  static final Color error = Colors.red.shade600;
  static final Color warning = Colors.orange.shade700;
  static final Color info = Colors.blue.shade700;
  
  // Colores de secciones - Paleta moderna y distintiva
  // Familia - Verde moderno
  static const Color familyPrimary = Color(0xFF4CAF50);      // Verde vibrante
  static const Color familySecondary = Color(0xFF2E7D32);    // Verde oscuro
  static const Color familyAccent = Color(0xFF81C784);        // Verde claro
  
  // Mascotas - Naranja cálido
  static const Color petsPrimary = Color(0xFFFF9800);        // Naranja vibrante
  static const Color petsSecondary = Color(0xFFE65100);      // Naranja oscuro
  static const Color petsAccent = Color(0xFFFFB74D);         // Naranja claro
  
  // Domicilio - Azul profesional
  static const Color residencePrimary = Color(0xFF2196F3);   // Azul vibrante
  static const Color residenceSecondary = Color(0xFF1565C0); // Azul oscuro
  static const Color residenceAccent = Color(0xFF64B5F6);    // Azul claro
  
  // Configuración - Morado elegante
  static const Color settingsPrimary = Color(0xFF9C27B0);   // Morado vibrante
  static const Color settingsSecondary = Color(0xFF6A1B9A);  // Morado oscuro
  static const Color settingsAccent = Color(0xFFBA68C8);    // Morado claro
  
  // Colores de bordes y sombras
  static final Color border = Colors.grey.shade200;
  static final Color borderDark = Colors.grey.shade300;
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}

// ============================================
// ESTILOS DE TEXTO
// ============================================
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  // Body text
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textTertiary,
  );

  // Subtitles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 14,
    color: Color(0xB3FFFFFF),
  );

  static TextStyle subtitle2 = TextStyle(
    fontSize: 12,
    color: AppColors.textTertiary,
  );

  // Special
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle chipText = TextStyle(
    fontSize: 12,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

// ============================================
// ESPACIADO
// ============================================
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
}

// ============================================
// RADIOS DE BORDE
// ============================================
class AppRadius {
  AppRadius._();

  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double round = 100.0;
}

// ============================================
// SOMBRAS
// ============================================
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> small = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];
}

// ============================================
// DECORACIONES COMUNES
// ============================================
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.border),
    boxShadow: AppShadows.small,
  );

  static BoxDecoration cardElevated = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.border),
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration roundedContainer = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.border),
  );

  static BoxDecoration gradientHeader(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(AppRadius.xl),
    );
  }
}

// ============================================
// TAMAÑOS DE ICONOS
// ============================================
class AppIconSizes {
  AppIconSizes._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 60.0;
  static const double huge = 80.0;
}

// ============================================
// DURACIONES DE ANIMACIÓN
// ============================================
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// ============================================
// CONSTANTES DE LA APP
// ============================================
class AppConstants {
  AppConstants._();

  static const String appName = 'Sistema de Emergencias';
  static const int maxFamilyMembers = 50;
  static const int maxPets = 20;
  static const int maxConditionsLength = 10;
}

