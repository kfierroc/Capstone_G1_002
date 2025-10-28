import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';

class Step1CreateAccount extends StatefulWidget{
  final RegistrationData registrationData;
  final VoidCallback onNext;

  const Step1CreateAccount({
    super.key,
    required this.registrationData,
    required this.onNext,
  });

  @override
  State<Step1CreateAccount> createState() => _Step1CreateAccountState();
}

class _Step1CreateAccountState extends State<Step1CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.registrationData.email ?? '';
    _passwordController.text = widget.registrationData.password ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.registrationData.email = _emailController.text.trim();
      widget.registrationData.password = _passwordController.text;
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isTablet = ResponsiveHelper.isTablet(context) ||
                      ResponsiveHelper.isDesktop(context);
    
    return ResponsiveContainer(
      maxWidth: isTablet ? 800 : null,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: padding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 28,
                    tablet: 32,
                    desktop: 36,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Regístrate como titular del domicilio',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 18,
                  ),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: isTablet ? 40 : 32),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'ejemplo@correo.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Contraseña
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña *',
                hintText: 'Mínimo 6 caracteres',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Confirmar Contraseña
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 32),

            // Botón Continuar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Link para iniciar sesión
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes cuenta? ',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Inicia Sesión',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
