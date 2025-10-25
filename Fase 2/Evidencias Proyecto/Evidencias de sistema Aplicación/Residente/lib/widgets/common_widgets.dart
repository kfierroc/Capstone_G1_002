import 'package:flutter/material.dart';

// Widget optimizado para headers de secciones
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70, 
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget optimizado para botones de acción
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color backgroundColor;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: backgroundColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// Widget optimizado para tarjetas de información
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? backgroundColor;
  final Border? border;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15, 
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget optimizado para mostrar detalles en formato fila
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double? labelWidth;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth ?? 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14, 
                color: Color(0xFF616161),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14, 
                color: Color(0xFF212121),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget optimizado para tarjetas vacías
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: const Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget optimizado para contenedor con sombra
class ShadowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;

  const ShadowContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

