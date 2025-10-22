import 'package:flutter/material.dart';
import '../../utils/responsive_constants.dart';
import '../../utils/validation_system.dart';
import '../../utils/common_utilities.dart';
import '../../constants/grifo_colors.dart';

/// Campo de texto reutilizable
class ReusableTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onSuffixIconPressed;
  final int maxLines;
  final EdgeInsets? padding;

  const ReusableTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? ResponsiveConstants.getResponsivePadding(
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
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onSuffixIconPressed,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 12, desktop: 16),
            ),
          ),
          filled: true,
          fillColor: GrifoColors.surfaceVariant,
        ),
      ),
    );
  }
}

/// Campo de texto con validación de RUT
class RutTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const RutTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.text,
      validator: validator ?? ValidationSystem.validateRut,
      onChanged: (value) {
        // Formatear RUT automáticamente
        final formatted = CommonUtilities.formatRut(value);
        if (formatted != value) {
          controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
        onChanged?.call(formatted);
      },
    );
  }
}

/// Campo de texto con validación de email
class EmailTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.emailAddress,
      validator: validator ?? ValidationSystem.validateEmail,
      onChanged: onChanged,
    );
  }
}

/// Campo de texto con validación de contraseña
class PasswordTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      prefixIcon: widget.prefixIcon,
      obscureText: _obscureText,
      validator: widget.validator ?? ValidationSystem.validatePassword,
      onChanged: widget.onChanged,
      suffixIcon: _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      onSuffixIconPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}

/// Campo de texto con validación de confirmación de contraseña
class ConfirmPasswordTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ConfirmPasswordTextFormField({
    super.key,
    required this.controller,
    required this.passwordController,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<ConfirmPasswordTextFormField> createState() => _ConfirmPasswordTextFormFieldState();
}

class _ConfirmPasswordTextFormFieldState extends State<ConfirmPasswordTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      prefixIcon: widget.prefixIcon,
      obscureText: _obscureText,
      validator: widget.validator ?? (value) => ValidationSystem.validateConfirmPassword(value, widget.passwordController.text),
      onChanged: widget.onChanged,
      suffixIcon: _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      onSuffixIconPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}

/// Campo de texto con validación de nombre
class NameTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const NameTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: validator ?? ValidationSystem.validateName,
      onChanged: onChanged,
    );
  }
}

/// Campo de texto con validación de compañía
class CompanyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CompanyTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: validator ?? ValidationSystem.validateCompany,
      onChanged: onChanged,
    );
  }
}

/// Campo de texto con validación de dirección
class AddressTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AddressTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.words,
      validator: validator ?? ValidationSystem.validateAddress,
      onChanged: onChanged,
    );
  }
}

/// Campo de texto con validación de comuna
class ComunaTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ComunaTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: validator ?? ValidationSystem.validateComuna,
      onChanged: onChanged,
    );
  }
}

/// Campo de texto con validación de notas
class NotesTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  const NotesTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      validator: validator ?? ValidationSystem.validateNotes,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }
}