import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_styles.dart';

/// Contenedor blanco con sombra reutilizable
class WhiteCardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const WhiteCardContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          ResponsiveHelper.padding(
            context,
            mobile: const EdgeInsets.all(20),
            tablet: const EdgeInsets.all(30),
            desktop: const EdgeInsets.all(40),
          ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(
            context,
            mobile: 20,
            tablet: 25,
            desktop: 30,
          ),
        ),
        boxShadow: AppStyles.shadowLight,
      ),
      child: child,
    );
  }
}

