import 'package:flutter/material.dart';
import '../../services/supabase_auth_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/white_card_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'register.dart';
import 'password.dart';
import '../home/home.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Usar servicio de autenticación con Supabase
        final authService = SupabaseAuthService();
        final result = await authService.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Bienvenido ${result.user!.fullName}!'),
                backgroundColor: AppColors.success,
              ),
            );
            // Navegar al home después del login exitoso
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  onLogout: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(
                          onLogin: (email) {},
                        ),
                      ),
                    );
                  },
                  userEmail: result.user!.email,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Error de autenticación'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
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
      gradientColors: [AppColors.primaryLight, Colors.blue.shade700],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuthHeader(
              icon: Icons.lock_outline,
              iconColor: AppColors.primaryLight,
              title: 'Iniciar Sesión - Grifos',
              subtitle: 'Accede al sistema de gestión de grifos de agua',
            ),
            const SizedBox(height: 40),
            WhiteCardContainer(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Iniciar Sesión',
                    backgroundColor: AppColors.primaryLight,
                    onPressed: _login,
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
                  '¿No tienes cuenta? ',
                  style: TextStyle(color: AppColors.textLight),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Regístrate',
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
