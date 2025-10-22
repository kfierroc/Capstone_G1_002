import 'package:flutter/material.dart';

/// Sistema de colores unificado para toda la aplicación
/// Sigue principios de Design System y accesibilidad
class AppColors {
  AppColors._();

  // ============================================
  // COLORES PRIMARIOS
  // ============================================
  
  /// Color primario principal
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  
  /// Color secundario
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFE65100);

  // ============================================
  // COLORES SEMÁNTICOS
  // ============================================
  
  /// Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF2E7D32);
  
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFE65100);
  
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1565C0);

  // ============================================
  // COLORES DE EMERGENCIA
  // ============================================
  
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyLight = Color(0xFFEF5350);
  static const Color emergencyDark = Color(0xFFB71C1C);

  // ============================================
  // COLORES DE SUPERFICIE
  // ============================================
  
  /// Colores de fondo y superficie
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFE8E8E8);
  static const Color surfaceContainerHigh = Color(0xFFD1D1D1);
  static const Color surfaceContainerHighest = Color(0xFFB8B8B8);
  
  /// Colores de fondo alternativos
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFF0F0F0);

  // ============================================
  // COLORES DE TEXTO
  // ============================================
  
  /// Colores de texto principales
  static const Color onSurface = Color(0xFF1C1C1C);
  static const Color onSurfaceVariant = Color(0xFF4A4A4A);
  static const Color onBackground = Color(0xFF1C1C1C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  
  /// Colores de texto secundarios
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFB8B8B8);

  // ============================================
  // COLORES DE BORDE Y DIVISOR
  // ============================================
  
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFE0E0E0);

  // ============================================
  // COLORES DE ESTADO INTERACTIVO
  // ============================================
  
  /// Estados de interacción
  static const Color hover = Color(0xFFF5F5F5);
  static const Color pressed = Color(0xFFE0E0E0);
  static const Color focused = Color(0xFF1976D2);
  static const Color selected = Color(0xFFE3F2FD);
  static const Color disabled = Color(0xFFB8B8B8);

  // ============================================
  // COLORES ESPECÍFICOS PARA BOMBEROS
  // ============================================
  
  /// Colores específicos para la aplicación de bomberos
  static const Color fireRed = Color(0xFFD32F2F);
  static const Color fireOrange = Color(0xFFFF5722);
  static const Color fireYellow = Color(0xFFFFC107);
  static const Color waterBlue = Color(0xFF2196F3);
  static const Color rescueGreen = Color(0xFF4CAF50);
  static const Color emergencyPurple = Color(0xFF9C27B0);

  // ============================================
  // MÉTODOS UTILITARIOS
  // ============================================
  
  /// Obtiene el color apropiado según el tema (claro/oscuro)
  static Color getAdaptiveColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkColor 
        : lightColor;
  }
  
  /// Obtiene el color de texto apropiado según el tema
  static Color getAdaptiveTextColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkColor 
        : lightColor;
  }
  
  /// Obtiene el color de superficie apropiado según el tema
  static Color getAdaptiveSurfaceColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkColor 
        : lightColor;
  }
  
  /// Obtiene el color de fondo apropiado según el tema
  static Color getAdaptiveBackgroundColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkColor 
        : lightColor;
  }
  
  /// Obtiene el color de borde apropiado según el tema
  static Color getAdaptiveBorderColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkColor 
        : lightColor;
  }

  // ============================================
  // COLORES DE GRADIENTE
  // ============================================
  
  /// Gradientes predefinidos
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient emergencyGradient = LinearGradient(
    colors: [emergency, emergencyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient fireGradient = LinearGradient(
    colors: [fireRed, fireOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient waterGradient = LinearGradient(
    colors: [waterBlue, infoLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient rescueGradient = LinearGradient(
    colors: [rescueGreen, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
