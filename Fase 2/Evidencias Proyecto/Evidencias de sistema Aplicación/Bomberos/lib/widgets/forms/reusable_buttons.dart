import 'package:flutter/material.dart';
import '../../utils/responsive_constants.dart';
import '../../constants/grifo_colors.dart';

/// Botón primario reutilizable
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 48, tablet: 56),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? GrifoColors.primary,
          foregroundColor: textColor ?? GrifoColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 12),
            ),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24),
                height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? GrifoColors.textOnPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 18, tablet: 20)),
                    SizedBox(width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 10)),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 16, tablet: 18, desktop: 20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón secundario reutilizable
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 48, tablet: 56),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? GrifoColors.surface,
          foregroundColor: textColor ?? GrifoColors.primary,
          side: BorderSide(
            color: textColor ?? GrifoColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 12),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24),
                height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? GrifoColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 18, tablet: 20)),
                    SizedBox(width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 10)),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 16, tablet: 18, desktop: 20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón de texto reutilizable
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final IconData? icon;
  final double? fontSize;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.icon,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 4, tablet: 6),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 18),
                  color: textColor ?? GrifoColors.primary,
                ),
                SizedBox(width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 4, tablet: 6)),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? ResponsiveConstants.getFontSize(MediaQuery.of(context).size.width, mobile: 14, tablet: 16),
                  color: textColor ?? GrifoColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de acción flotante reutilizable
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? GrifoColors.primary,
      foregroundColor: foregroundColor ?? GrifoColors.textOnPrimary,
      child: Icon(icon),
    );
  }
}

/// Botón de acción flotante extendido reutilizable
class CustomFloatingActionButtonExtended extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFloatingActionButtonExtended({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? GrifoColors.primary,
      foregroundColor: foregroundColor ?? GrifoColors.textOnPrimary,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

/// Botón de icono reutilizable
class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double? size;

  const CustomIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color ?? GrifoColors.textPrimary,
      iconSize: size ?? ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 24, tablet: 28),
    );
  }
}

/// Botón de toggle reutilizable
class ToggleButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ToggleButton({
    super.key,
    required this.isSelected,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: isSelected
          ? (selectedColor ?? GrifoColors.primary)
          : (unselectedColor ?? GrifoColors.textSecondary),
      iconSize: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 24, tablet: 28),
    );
  }
}