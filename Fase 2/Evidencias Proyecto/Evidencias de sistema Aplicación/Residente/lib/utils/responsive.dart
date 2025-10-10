import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class ResponsiveHelper {
  // Cachear MediaQueryData para evitar múltiples llamadas
  static MediaQueryData _getMediaQuery(BuildContext context) {
    return MediaQuery.of(context);
  }

  static bool isMobile(BuildContext context) {
    return _getMediaQuery(context).size.width < ResponsiveBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = _getMediaQuery(context).size.width;
    return width >= ResponsiveBreakpoints.mobile && width < ResponsiveBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return _getMediaQuery(context).size.width >= ResponsiveBreakpoints.tablet;
  }

  // Obtener el tipo de dispositivo (optimizado - una sola consulta)
  static DeviceType getDeviceType(BuildContext context) {
    final width = _getMediaQuery(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) return DeviceType.mobile;
    if (width < ResponsiveBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Obtener padding responsivo (optimizado)
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = _getMediaQuery(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) {
      return const EdgeInsets.all(16.0);
    } else if (width < ResponsiveBreakpoints.tablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Obtener tamaño de fuente responsivo (optimizado)
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = _getMediaQuery(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) return mobile;
    if (width < ResponsiveBreakpoints.tablet) return tablet;
    return desktop;
  }

  // Obtener ancho máximo para contenido (optimizado)
  static double getMaxContentWidth(BuildContext context) {
    final width = _getMediaQuery(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) return width;
    if (width < ResponsiveBreakpoints.tablet) return 800;
    return 1200;
  }
}

enum DeviceType { mobile, tablet, desktop }

// Widget para hacer contenido responsivo (optimizado)
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? (width < ResponsiveBreakpoints.mobile ? width : 
                     width < ResponsiveBreakpoints.tablet ? 800 : 1200),
        ),
        padding: padding ?? (width < ResponsiveBreakpoints.mobile ? const EdgeInsets.all(16.0) :
                   width < ResponsiveBreakpoints.tablet ? const EdgeInsets.all(24.0) : const EdgeInsets.all(32.0)),
        child: child,
      ),
    );
  }
}
