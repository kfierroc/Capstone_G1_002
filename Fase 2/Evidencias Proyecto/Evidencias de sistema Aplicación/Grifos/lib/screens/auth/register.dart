import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/white_card_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _rutController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _rutController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Paso 1: Registrar usuario en Supabase Auth
        final response = await SupabaseConfig.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          // Paso 2: Guardar información adicional en la tabla profiles
          try {
            await SupabaseConfig.client.from('profiles').insert({
              'id': response.user!.id,
              'full_name': _fullNameController.text.trim(),
              'rut': _rutController.text.trim(),
              'fire_company': _companyController.text.trim(),
              'email': _emailController.text.trim(),
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppConstants.msgRegistroSuccess),
                  backgroundColor: AppColors.success,
                  duration: AppConstants.snackbarDuration,
                ),
              );
              Navigator.pop(context);
            }
          } on PostgrestException catch (e) {
            // Error al insertar en la tabla profiles
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al guardar el perfil: ${e.message}'),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No se pudo crear el usuario'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } on AuthException catch (e) {
        // Errores de autenticación (email duplicado, contraseña débil, etc.)
        if (mounted) {
          String errorMessage = e.message;
          
          // Traducir mensajes comunes de error
          if (errorMessage.contains('User already registered')) {
            errorMessage = 'Este correo electrónico ya está registrado';
          } else if (errorMessage.contains('Password should be at least')) {
            errorMessage = 'La contraseña debe tener al menos 6 caracteres';
          } else if (errorMessage.contains('Invalid email')) {
            errorMessage = 'El correo electrónico no es válido';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        // Otros errores generales
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradientColors: [AppColors.secondaryLight, AppColors.secondaryDark],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuthHeader(
              icon: Icons.person_add_outlined,
              iconColor: AppColors.secondary,
              title: 'Crear cuenta nueva',
              subtitle: 'Regístrate para acceder al sistema de emergencias',
            ),
            const SizedBox(height: 40),
            WhiteCardContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Nombre Completo *',
                    hintText: 'Carlos Neira Valenzuela',
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _rutController,
                    labelText: 'RUT *',
                    hintText: '12.345.678-9',
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.rut,
                    onChanged: (value) {
                      Formatters.applyRutFormat(value, (formatted) {
                        _rutController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _companyController,
                    labelText: 'Compañía de Bomberos *',
                    hintText: 'Primera Compañía de Santiago',
                    prefixIcon: Icons.local_fire_department_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.minLength(
                      value,
                      3,
                      fieldName: 'Nombre de la compañía',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email *',
                    hintText: 'correo@ejemplo.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña *',
                    hintText: 'Mínimo 6 caracteres',
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmar Contraseña *',
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* Todos los campos son obligatorios',
                      style: AppStyles.caption,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Registrarse',
                    backgroundColor: AppColors.secondary,
                    onPressed: _register,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes cuenta? ',
                  style: TextStyle(color: AppColors.textLight),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Inicia Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
