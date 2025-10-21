import 'package:flutter/material.dart';

/// Constantes de estilos para la pantalla de detalles de dirección
/// Aplicando principios de Clean Code y reutilización
class AddressDetailStyles {
  // Colores principales
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color darkRed = Color(0xFFB91C1C);
  static const Color lightRed = Color(0xFFFEE2E2);
  static const Color lightYellow = Color(0xFFFFF9E6);
  static const Color yellowBorder = Color(0xFFFBBF24);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);
  static const Color green = Color(0xFF10B981);
  static const Color darkGray = Color(0xFF1F2937);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFE5E7EB);
  static const Color white = Colors.white;

  // Espaciado
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;
  static const double paddingXXLarge = 24.0;

  // Bordes redondeados
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;

  // Tamaños de fuente
  static const double fontSizeSmall = 10.0;
  static const double fontSizeMedium = 12.0;
  static const double fontSizeLarge = 14.0;
  static const double fontSizeXLarge = 16.0;
  static const double fontSizeXXLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeNumber = 20.0;

  // Tamaños de íconos
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get redShadow => [
    BoxShadow(
      color: primaryRed.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: fontSizeXXLarge,
    fontWeight: FontWeight.bold,
    color: darkGray,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: fontSizeMedium,
    color: mediumGray,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: fontSizeLarge,
    color: darkGray,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle numberStyle = TextStyle(
    fontSize: fontSizeNumber,
    fontWeight: FontWeight.bold,
    color: darkGray,
  );

  // Estilos de botones
  static ButtonStyle get redButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryRed,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingXXLarge,
      vertical: paddingLarge,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
  );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: mediumGray,
    side: const BorderSide(color: lightGray),
    padding: const EdgeInsets.symmetric(
      horizontal: paddingXXLarge,
      vertical: paddingLarge,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
  );

  // Estilos de contenedores
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: cardShadow,
  );

  static BoxDecoration get redCardDecoration => BoxDecoration(
    color: primaryRed,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: redShadow,
  );

  static BoxDecoration get yellowCardDecoration => BoxDecoration(
    color: lightYellow,
    borderRadius: BorderRadius.circular(radiusSmall),
    border: Border.all(color: yellowBorder),
  );

  static BoxDecoration get lightRedCardDecoration => BoxDecoration(
    color: lightRed,
    borderRadius: BorderRadius.circular(radiusSmall),
  );

  // Estilos de chips
  static BoxDecoration get chipDecoration => BoxDecoration(
    color: white,
    border: Border.all(color: lightGray),
    borderRadius: BorderRadius.circular(radiusLarge),
  );

  // Estilos de gradientes
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkRed, primaryRed],
  );
}
