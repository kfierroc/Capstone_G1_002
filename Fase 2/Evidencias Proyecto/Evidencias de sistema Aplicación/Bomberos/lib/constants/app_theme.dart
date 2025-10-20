import 'package:flutter/material.dart';

/// Tema unificado para la aplicación de bomberos
class AppTheme {
  // Colores principales
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryGreen = Color(0xFF4CAF50);

  // Colores de fondo
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhite70 = Color(0xB3FFFFFF);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Colores de emergencia
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color emergencyOrange = Color(0xFFFF5722);
  static const Color emergencyYellow = Color(0xFFFFC107);

  // Colores adicionales
  static const Color secondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);

  // Colores específicos para tarjetas
  static const Color ownerBackground = Color(0xFFE3F2FD);
  static const Color ownerBorder = Color(0xFF1976D2);
  static const Color medicalBackground = Color(0xFFE8F5E8);
  static const Color medicalBorder = Color(0xFF4CAF50);
  static const Color medicalText = Color(0xFF2E7D32);

  // Colores para mascotas
  static const Color dogColor = Color(0xFF8D6E63);
  static const Color catColor = Color(0xFF795548);

  // Alturas de botones
  static const double buttonHeightMobile = 48.0;
  static const double buttonHeightTablet = 56.0;

  // Gradientes
  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [emergencyRed, Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sombras
  static const List<BoxShadow> shadowLight = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Espaciado
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Padding
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
  static const double paddingXxl = 48.0;

  // Padding genérico
  static const EdgeInsets padding = EdgeInsets.all(paddingMd);

  // Radio de bordes
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Radio genérico
  static const double radius = radiusMd;

  // Tamaños de fuente
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;

  // Tamaños de iconos
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Fuentes
  static const String fontFamily = 'Roboto';
  static const String fontTitle = 'Roboto';
  static const String font = fontFamily;

  // Tamaños de fuente específicos
  static const double fontXs = fontSizeXs;
  static const double fontSm = fontSizeSm;
  static const double fontMd = fontSizeMd;
  static const double fontLg = fontSizeLg;
  static const double fontXl = fontSizeXl;
  static const double fontXxl = fontSizeXxl;
  static const double fontTitleSize = fontSizeXxl;

  // Espaciado genérico
  static const double space = spacingMd;
  static const double spaceXs = spacingXs;
  static const double spaceSm = spacingSm;
  static const double spaceMd = spacingMd;
  static const double spaceLg = spacingLg;
  static const double spaceXl = spacingXl;
  static const double spaceXxl = spacingXxl;

  // Padding específico
  static const double paddingXsSize = paddingXs;
  static const double paddingSmSize = paddingSm;
  static const double paddingMdSize = paddingMd;
  static const double paddingLgSize = paddingLg;
  static const double paddingXlSize = paddingXl;
  static const double paddingXxlSize = paddingXxl;

  // Radio específico
  static const double radiusSmSize = radiusSm;
  static const double radiusMdSize = radiusMd;
  static const double radiusLgSize = radiusLg;

  // Iconos específicos
  static const double iconXsSize = iconXs;
  static const double iconSmSize = iconSm;
  static const double iconLgSize = iconLg;
  static const double iconXxlSize = iconXxl;

  // Fuentes específicas
  static const double fontXsSize = fontXs;
  static const double fontSmSize = fontSm;
  static const double fontXlSize = fontXl;
  static const double fontTitleSizeValue = fontTitleSize;

  // Constantes adicionales para compatibilidad
  static const double spacingXSmall = spacingXs;
  static const double spacingSmall = spacingSm;
  static const double spacingMedium = spacingMd;
  static const double spacingLarge = spacingLg;
  static const double spacingXLarge = spacingXl;

  static const double radiusSmall = radiusSm;
  static const double radiusMedium = radiusMd;
  static const double radiusLarge = radiusLg;
  static const double radiusXLarge = radiusXl;

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryOrange,
        surface: surfaceLight,
        error: error,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onSurface: textPrimary,
        onError: textWhite,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryOrange,
        surface: surfaceDark,
        error: error,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onSurface: textWhite,
        onError: textWhite,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.5,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        labelStyle: const TextStyle(color: textWhite70, fontSize: 16),
        hintStyle: const TextStyle(color: textWhite70, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}

/// Estilos de texto unificados
class AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: AppTheme.fontSizeXxl,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  static const TextStyle subtitlePrimary = TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
  );

  static const TextStyle subtitleSecondary = TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );

  static const TextStyle whiteTitle = TextStyle(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: FontWeight.bold,
    color: AppTheme.textWhite,
  );

  static const TextStyle whiteSubtitle = TextStyle(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: FontWeight.w600,
    color: AppTheme.textWhite,
  );

  static const TextStyle emergency = TextStyle(
    fontSize: AppTheme.fontSizeXxl,
    fontWeight: FontWeight.bold,
    color: AppTheme.emergencyRed,
  );
}

/// Métodos de decoración para compatibilidad
extension AppThemeDecorations on AppTheme {
  static BoxDecoration card() {
    return BoxDecoration(
      color: AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      boxShadow: AppTheme.shadowLight,
    );
  }

  static BoxDecoration redGradient() {
    return BoxDecoration(
      gradient: AppTheme.emergencyGradient,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    );
  }

  static InputDecoration textField({
    IconData? prefixIcon,
    double? borderRadius,
  }) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusMedium,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    );
  }

  static ButtonStyle elevatedButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );
  }

  static ButtonStyle outlinedButton() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primaryBlue,
      side: BorderSide(color: AppTheme.primaryBlue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );
  }
}
