import 'package:flutter/material.dart';
import '../../services/supabase_auth_service.dart';
import '../../utils/responsive_constants.dart';
import '../../utils/validation_system.dart';
import '../../widgets/auth/auth_form_components.dart';
import '../../widgets/forms/reusable_buttons.dart';
import '../home/home_main.dart';

/// Pantalla de registro refactorizada
/// Aplicando principios SOLID y Clean Code
class RegisterScreenRefactored extends StatefulWidget {
  const RegisterScreenRefactored({super.key});

  @override
  State<RegisterScreenRefactored> createState() => _RegisterScreenRefactoredState();
}

class _RegisterScreenRefactoredState extends State<RegisterScreenRefactored> {
  // Controladores de formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estado del formulario
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _rutController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Procesa el registro del bombero
  Future<void> _register() async {
    // Prevenir múltiples llamadas simultáneas
    if (_isLoading) return;
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Usar servicio de autenticación con Supabase
        final authService = SupabaseAuthService();
        final result = await authService.signUpBombero(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rutCompleto: _rutController.text.trim(),
          nombre: _nombreController.text.trim(),
          apellidoPaterno: _apellidoPaternoController.text.trim(),
          compania: _companyController.text.trim(),
        );

        if (mounted) {
          await _handleRegistrationResult(result);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error inesperado: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Maneja el resultado del registro
  Future<void> _handleRegistrationResult(dynamic result) async {
    if (result.isSuccess) {
      await _showSuccessMessage(result);
      _navigateToHome();
    } else {
      _showErrorMessage(result.error ?? 'Error al registrar');
    }
  }

  /// Muestra mensaje de éxito
  Future<void> _showSuccessMessage(dynamic result) async {
    final bombero = result.user?.bombero;
    final nombreCompleto = bombero != null 
        ? '${bombero.nombBombero} ${bombero.apePBombero}'
        : result.user!.email;
    final cargo = 'Voluntario';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Registro exitoso! Bienvenido, $cargo $nombreCompleto',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra mensaje de error
  void _showErrorMessage(String errorMessage) {
    if (errorMessage.contains('Ya existe un bombero registrado')) {
      _showDuplicateUserError(errorMessage);
    } else {
      _showErrorSnackBar(errorMessage);
    }
  }

  /// Muestra error específico para usuario duplicado
  void _showDuplicateUserError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            const SizedBox(height: 8),
            const Text(
              '💡 Sugerencias:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Verifica que el RUT sea correcto'),
            const Text('• Si ya tienes cuenta, ve a "Iniciar Sesión"'),
            const Text('• Si olvidaste tu contraseña, usa "Recuperar contraseña"'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Iniciar Sesión',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// Navega a la pantalla principal
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  /// Muestra mensaje de error genérico
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveConstants.getResponsivePadding(
                context,
                mobile: const EdgeInsets.all(24.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 40, tablet: 50)),
                  _buildForm(),
                  SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
                  AuthNavigation(
                    question: '¿Ya tienes cuenta? ',
                    actionText: 'Inicia Sesión',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_outlined,
            size: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 40, tablet: 50, desktop: 60),
            color: Colors.green,
          ),
        ),
        SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 40, tablet: 50)),
        Text(
          'Crear cuenta nueva',
          style: TextStyle(
            fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 24, tablet: 28, desktop: 32),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 10, tablet: 15)),
        Text(
          'Regístrate para acceder al sistema de emergencias',
          style: TextStyle(
            fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 16, tablet: 18, desktop: 20),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthTextFormField(
              controller: _nombreController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: (value) => ValidationSystem.validateRequired(value),
              label: 'Nombre *',
              hint: 'Carlos',
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            AuthTextFormField(
              controller: _apellidoPaternoController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: (value) => ValidationSystem.validateRequired(value),
              label: 'Apellido Paterno *',
              hint: 'Neira',
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            AuthTextFormField(
              controller: _rutController,
              keyboardType: TextInputType.text,
              validator: ValidationSystem.validateRut,
              label: 'RUT *',
              hint: '12.345.678-9',
              prefixIcon: Icons.badge_outlined,
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            AuthTextFormField(
              controller: _companyController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              validator: (value) => ValidationSystem.validateMinLength(value, 3),
              label: 'Compañía de Bomberos *',
              hint: 'Primera Compañía de Santiago',
              prefixIcon: Icons.local_fire_department_outlined,
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            AuthTextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationSystem.validateEmail,
              label: 'Email *',
              hint: 'correo@ejemplo.com',
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            AuthTextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: ValidationSystem.validatePassword,
              label: 'Contraseña *',
              hint: 'Mínimo 6 caracteres',
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              onSuffixIconPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            AuthTextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: (value) => ValidationSystem.validateConfirmPassword(value, _passwordController.text),
              label: 'Confirmar Contraseña *',
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              onSuffixIconPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 10)),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '* Todos los campos son obligatorios',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
            PrimaryButton(
              text: 'Registrarse',
              onPressed: _register,
              isLoading: _isLoading,
              icon: Icons.person_add_alt_1,
            ),
          ],
        ),
      ),
    );
  }
}
