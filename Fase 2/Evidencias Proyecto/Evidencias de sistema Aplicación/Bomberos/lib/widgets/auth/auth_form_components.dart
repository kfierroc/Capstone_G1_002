import 'package:flutter/material.dart';
import '../../utils/responsive_constants.dart';
import '../forms/reusable_buttons.dart';

class AuthTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onSuffixIconPressed;
  final IconData? suffixIcon;

  const AuthTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onSuffixIconPressed,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveConstants.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon != null
              ? CustomIconButton(
                  icon: suffixIcon!,
                  onPressed: onSuffixIconPressed,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 12, desktop: 16),
            ),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveConstants.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

class BomberoRegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController apellidoPaternoController;
  final TextEditingController rutController;
  final TextEditingController companyController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onPasswordToggle;
  final VoidCallback onConfirmPasswordToggle;
  final VoidCallback onRegister;
  final bool isLoading;

  const BomberoRegisterForm({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.apellidoPaternoController,
    required this.rutController,
    required this.companyController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onPasswordToggle,
    required this.onConfirmPasswordToggle,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AuthTextFormField(
            controller: nombreController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
            label: 'Nombre *',
            hint: 'Carlos',
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20, desktop: 24)),
          AuthTextFormField(
            controller: apellidoPaternoController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu apellido paterno';
              }
              return null;
            },
            label: 'Apellido Paterno *',
            hint: 'Neira',
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20, desktop: 24)),
          AuthTextFormField(
            controller: rutController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu RUT';
              }
              // Validación básica de RUT
              String cleanRut = value.replaceAll('.', '').replaceAll('-', '');
              if (cleanRut.length < 8) {
                return 'RUT inválido';
              }
              return null;
            },
            label: 'RUT *',
            hint: '12.345.678-9',
            prefixIcon: Icons.badge_outlined,
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20, desktop: 24)),
          AuthTextFormField(
            controller: companyController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la compañía de bomberos';
              }
              if (value.length < 3) {
                return 'Compañía debe tener al menos 3 caracteres';
              }
              return null;
            },
            label: 'Compañía de Bomberos *',
            hint: 'Primera Compañía de Santiago',
            prefixIcon: Icons.local_fire_department_outlined,
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20, desktop: 24)),
          AuthTextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Ingresa un email válido';
              }
              return null;
            },
            label: 'Email *',
            hint: 'correo@ejemplo.com',
            prefixIcon: Icons.email_outlined,
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20, desktop: 24)),
          AuthTextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
            label: 'Contraseña *',
            hint: 'Mínimo 6 caracteres',
            prefixIcon: Icons.lock_outline,
            suffixIcon: obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            onSuffixIconPressed: onPasswordToggle,
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20, desktop: 24)),
          AuthTextFormField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            label: 'Confirmar Contraseña *',
            prefixIcon: Icons.lock_outline,
            suffixIcon: obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            onSuffixIconPressed: onConfirmPasswordToggle,
          ),
        ],
      ),
    );
  }
}

class AuthNavigation extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onPressed;

  const AuthNavigation({
    super.key,
    required this.question,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            color: Colors.white70,
            fontSize: ResponsiveConstants.getFontSize(MediaQuery.of(context).size.width, mobile: 12, tablet: 14, desktop: 16),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionText,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveConstants.getFontSize(MediaQuery.of(context).size.width, mobile: 12, tablet: 14, desktop: 16),
            ),
          ),
        ),
      ],
    );
  }
}