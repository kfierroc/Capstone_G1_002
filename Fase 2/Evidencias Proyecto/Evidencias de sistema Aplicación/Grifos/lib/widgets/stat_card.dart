import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_styles.dart';

/// Tarjeta de estadística reutilizable
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppStyles.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(
            context,
            mobile: 8,
            tablet: 10,
            desktop: 12,
          ),
        ),
      ),
      child: Padding(
        padding: ResponsiveHelper.padding(
          context,
          mobile: const EdgeInsets.all(12),
          tablet: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.spacing(
                context,
                mobile: 4,
                tablet: 6,
                desktop: 8,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

