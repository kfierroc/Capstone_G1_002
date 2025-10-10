import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_styles.dart';

/// Header reutilizable para pantallas de autenticación
class AuthHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const AuthHeader({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icono circular
        Container(
          padding: EdgeInsets.all(
            ResponsiveHelper.spacing(
              context,
              mobile: 20,
              tablet: 30,
              desktop: 40,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppStyles.shadowLight,
          ),
          child: Icon(
            icon,
            size: ResponsiveHelper.iconSize(
              context,
              mobile: 60,
              tablet: 80,
              desktop: 100,
            ),
            color: iconColor,
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.spacing(
            context,
            mobile: 40,
            tablet: 50,
            desktop: 60,
          ),
        ),
        // Título
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(
              context,
              mobile: 32,
              tablet: 40,
              desktop: 48,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: ResponsiveHelper.spacing(
            context,
            mobile: 10,
            tablet: 15,
            desktop: 20,
          ),
        ),
        // Subtítulo
        Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

