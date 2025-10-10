import 'package:flutter/material.dart';

/// Helper para diseño responsivo optimizado
class ResponsiveHelper {
  // Breakpoints para diferentes dispositivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Obtiene el ancho de pantalla
  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Obtiene la altura de pantalla
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Verificar si es móvil
  static bool isMobile(BuildContext context) =>
      getWidth(context) < mobileBreakpoint;

  /// Verificar si es tablet
  static bool isTablet(BuildContext context) =>
      getWidth(context) >= mobileBreakpoint &&
      getWidth(context) < tabletBreakpoint;

  /// Verificar si es desktop
  static bool isDesktop(BuildContext context) =>
      getWidth(context) >= tabletBreakpoint;

  /// Obtener valor responsivo genérico
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Obtener tamaño de fuente responsivo
  static double fontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) =>
      responsive(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Obtener padding responsivo
  static EdgeInsets padding(
    BuildContext context, {
    required EdgeInsets mobile,
    required EdgeInsets tablet,
    required EdgeInsets desktop,
  }) =>
      responsive(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Obtener espaciado responsivo
  static double spacing(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) =>
      responsive(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Obtener tamaño de icono responsivo
  static double iconSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) =>
      responsive(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Obtener border radius responsivo
  static double borderRadius(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) =>
      responsive(context, mobile: mobile, tablet: tablet, desktop: desktop);

  /// Obtener columnas para grid responsivo
  static int gridColumns(BuildContext context) =>
      responsive(context, mobile: 1, tablet: 2, desktop: 3);

  /// Obtener ancho máximo del contenido
  static double maxContentWidth(BuildContext context) {
    final screenWidth = getWidth(context);
    if (isMobile(context)) return screenWidth;
    if (isTablet(context)) return 800;
    return 1200;
  }
}
