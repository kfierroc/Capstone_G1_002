import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Scaffold con gradiente de fondo reutilizable
class GradientScaffold extends StatelessWidget {
  final List<Color> gradientColors;
  final Widget child;
  final double? maxWidth;

  const GradientScaffold({
    Key? key,
    required this.gradientColors,
    required this.child,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentMaxWidth =
        maxWidth ?? ResponsiveHelper.maxContentWidth(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.padding(
                context,
                mobile: const EdgeInsets.all(24.0),
                tablet: const EdgeInsets.all(32.0),
                desktop: const EdgeInsets.all(40.0),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

