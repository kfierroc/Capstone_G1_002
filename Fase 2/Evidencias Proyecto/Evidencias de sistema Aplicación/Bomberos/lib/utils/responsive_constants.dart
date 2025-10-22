import 'package:flutter/material.dart';

/// Constantes responsivas para diferentes tamaños de pantalla
class ResponsiveConstants {
  ResponsiveConstants._();

  // Breakpoints para diferentes dispositivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Espaciado responsivo
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Tamaños de fuente responsivos
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;
  static const double fontSizeHuge = 32.0;

  // Tamaños de botones responsivos
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  // Tamaños de iconos responsivos
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 40.0;

  // Padding responsivo
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  // Border radius responsivo
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  // Elevación responsiva
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  /// Obtiene el tipo de dispositivo basado en el ancho de pantalla
  static DeviceType getDeviceType(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Obtiene el espaciado apropiado para el dispositivo
  static double getSpacing(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? spacingMd;
      case DeviceType.tablet:
        return tablet ?? spacingLg;
      case DeviceType.desktop:
        return desktop ?? spacingXl;
    }
  }

  /// Obtiene el tamaño de fuente apropiado para el dispositivo
  static double getFontSize(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? fontSizeMd;
      case DeviceType.tablet:
        return tablet ?? fontSizeLg;
      case DeviceType.desktop:
        return desktop ?? fontSizeXl;
    }
  }

  /// Obtiene el tamaño de botón apropiado para el dispositivo
  static double getButtonHeight(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? buttonHeightMd;
      case DeviceType.tablet:
        return tablet ?? buttonHeightLg;
      case DeviceType.desktop:
        return desktop ?? buttonHeightXl;
    }
  }

  /// Obtiene el tamaño de icono apropiado para el dispositivo
  static double getIconSize(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? iconSizeMd;
      case DeviceType.tablet:
        return tablet ?? iconSizeLg;
      case DeviceType.desktop:
        return desktop ?? iconSizeXl;
    }
  }

  /// Obtiene el padding apropiado para el dispositivo
  static double getPadding(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? paddingMd;
      case DeviceType.tablet:
        return tablet ?? paddingLg;
      case DeviceType.desktop:
        return desktop ?? paddingXl;
    }
  }

  /// Obtiene el border radius apropiado para el dispositivo
  static double getRadius(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? radiusMd;
      case DeviceType.tablet:
        return tablet ?? radiusLg;
      case DeviceType.desktop:
        return desktop ?? radiusXl;
    }
  }

  /// Obtiene la elevación apropiada para el dispositivo
  static double getElevation(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? elevationMd;
      case DeviceType.tablet:
        return tablet ?? elevationLg;
      case DeviceType.desktop:
        return desktop ?? elevationXl;
    }
  }


  /// Obtiene valor responsivo genérico
  static double getResponsiveValue(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 16.0;
      case DeviceType.tablet:
        return tablet ?? 20.0;
      case DeviceType.desktop:
        return desktop ?? 24.0;
    }
  }

  /// Obtiene tamaño de fuente responsivo (alias para getFontSize)
  static double getResponsiveFontSize(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return getFontSize(screenWidth, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Obtiene border radius responsivo
  static double getBorderRadius(double screenWidth, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(screenWidth);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? radiusSm;
      case DeviceType.tablet:
        return tablet ?? radiusMd;
      case DeviceType.desktop:
        return desktop ?? radiusLg;
    }
  }

  /// Obtiene padding responsivo con BuildContext
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(screenWidth);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? const EdgeInsets.all(paddingMd);
      case DeviceType.tablet:
        return tablet ?? const EdgeInsets.all(paddingLg);
      case DeviceType.desktop:
        return desktop ?? const EdgeInsets.all(paddingXl);
    }
  }

  /// Obtiene border radius responsivo con BuildContext
  static double getResponsiveBorderRadius(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getBorderRadius(screenWidth, mobile: mobile, tablet: tablet, desktop: desktop);
  }
}

/// Tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Clases de utilidad para tamaños responsivos
class ResponsiveIconSize {
  static double get small => ResponsiveConstants.iconSizeSm;
  static double get medium => ResponsiveConstants.iconSizeMd;
  static double get large => ResponsiveConstants.iconSizeLg;
  static double get extraLarge => ResponsiveConstants.iconSizeXl;
}

class ResponsiveFontSize {
  static double get extraSmall => ResponsiveConstants.fontSizeXs;
  static double get small => ResponsiveConstants.fontSizeSm;
  static double get medium => ResponsiveConstants.fontSizeMd;
  static double get large => ResponsiveConstants.fontSizeLg;
  static double get extraLarge => ResponsiveConstants.fontSizeXl;
  static double get xlarge => ResponsiveConstants.fontSizeXl; // Alias para extraLarge
  static double get extraExtraLarge => ResponsiveConstants.fontSizeXxl;
  static double get extraExtraExtraLarge => ResponsiveConstants.fontSizeXxxl;
  static double get huge => ResponsiveConstants.fontSizeHuge;
}

/// Clase de utilidad para espaciado responsivo
class ResponsiveSpacing {
  static double small(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getPadding(screenWidth, mobile: ResponsiveConstants.spacingSm, tablet: ResponsiveConstants.spacingMd, desktop: ResponsiveConstants.spacingLg);
  }

  static double medium(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getPadding(screenWidth, mobile: ResponsiveConstants.spacingMd, tablet: ResponsiveConstants.spacingLg, desktop: ResponsiveConstants.spacingXl);
  }

  static double large(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getPadding(screenWidth, mobile: ResponsiveConstants.spacingLg, tablet: ResponsiveConstants.spacingXl, desktop: ResponsiveConstants.spacingXxl);
  }
}

/// Clase de utilidad para altura de botones responsivos
class ResponsiveButtonHeight {
  static double small(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getResponsiveValue(screenWidth, mobile: ResponsiveConstants.buttonHeightSm, tablet: ResponsiveConstants.buttonHeightMd, desktop: ResponsiveConstants.buttonHeightLg);
  }

  static double medium(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getResponsiveValue(screenWidth, mobile: ResponsiveConstants.buttonHeightMd, tablet: ResponsiveConstants.buttonHeightLg, desktop: ResponsiveConstants.buttonHeightXl);
  }

  static double large(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getResponsiveValue(screenWidth, mobile: ResponsiveConstants.buttonHeightLg, tablet: ResponsiveConstants.buttonHeightXl, desktop: ResponsiveConstants.buttonHeightXl);
  }
}

/// Clase de utilidad para tamaños de iconos responsivos
class IconSize {
  static double small(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getIconSize(screenWidth, mobile: ResponsiveConstants.iconSizeSm, tablet: ResponsiveConstants.iconSizeMd, desktop: ResponsiveConstants.iconSizeLg);
  }

  static double medium(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getIconSize(screenWidth, mobile: ResponsiveConstants.iconSizeMd, tablet: ResponsiveConstants.iconSizeLg, desktop: ResponsiveConstants.iconSizeXl);
  }

  static double large(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getIconSize(screenWidth, mobile: ResponsiveConstants.iconSizeLg, tablet: ResponsiveConstants.iconSizeXl, desktop: ResponsiveConstants.iconSizeXl);
  }
}

/// Clase de utilidad para espaciado responsivo
class Spacing {
  static double small(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getSpacing(screenWidth, mobile: ResponsiveConstants.spacingSm, tablet: ResponsiveConstants.spacingMd, desktop: ResponsiveConstants.spacingLg);
  }

  static double medium(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getSpacing(screenWidth, mobile: ResponsiveConstants.spacingMd, tablet: ResponsiveConstants.spacingLg, desktop: ResponsiveConstants.spacingXl);
  }

  static double large(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getSpacing(screenWidth, mobile: ResponsiveConstants.spacingLg, tablet: ResponsiveConstants.spacingXl, desktop: ResponsiveConstants.spacingXxl);
  }
}

/// Clase de utilidad para tamaños de fuente responsivos
class FontSize {
  static double small(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getFontSize(screenWidth, mobile: ResponsiveConstants.fontSizeSm, tablet: ResponsiveConstants.fontSizeMd, desktop: ResponsiveConstants.fontSizeLg);
  }

  static double medium(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getFontSize(screenWidth, mobile: ResponsiveConstants.fontSizeMd, tablet: ResponsiveConstants.fontSizeLg, desktop: ResponsiveConstants.fontSizeXl);
  }

  static double large(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getFontSize(screenWidth, mobile: ResponsiveConstants.fontSizeLg, tablet: ResponsiveConstants.fontSizeXl, desktop: ResponsiveConstants.fontSizeXxl);
  }
}