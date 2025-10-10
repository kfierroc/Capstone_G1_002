import 'package:flutter/material.dart';
import '../constants/app_styles.dart';
import '../utils/responsive_helper.dart';

/// Botón principal personalizado y reutilizable
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final IconData? icon;
  final double? height;
  final bool fullWidth;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.icon,
    this.height,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ??
        ResponsiveHelper.spacing(
          context,
          mobile: 55,
          tablet: 65,
          desktop: 75,
        );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(
              context,
              mobile: 12,
              tablet: 15,
              desktop: 18,
            ),
          ),
        ),
        elevation: AppStyles.elevationMedium,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          vertical: ResponsiveHelper.spacing(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: ResponsiveHelper.iconSize(
                      context,
                      mobile: 18,
                      tablet: 22,
                      desktop: 26,
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingSmall),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: button,
          )
        : SizedBox(height: buttonHeight, child: button);
  }
}

/// Botón con borde (outline) personalizado
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? height;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 55,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? borderColor,
          side: BorderSide(color: borderColor ?? Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: AppStyles.borderRadiusMedium,
          ),
          padding: const EdgeInsets.symmetric(vertical: AppStyles.spacingMedium),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

