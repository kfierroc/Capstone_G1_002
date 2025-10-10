import 'package:flutter/material.dart';
import '../../services/mock_auth_service.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../home/resident_home.dart';
import 'register.dart';
import 'password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Usar servicio de autenticación temporal
        final mockAuth = MockAuthService();
        final result = await mockAuth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Bienvenido ${result.user!.name}!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navegar al home después del login exitoso
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ResidentHomeScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Error de autenticación'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final isTablet = width >= 600 && width < 900;
    final isDesktop = width >= 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ResponsiveContainer(
              maxWidth: isDesktop ? 500 : null,
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: isTablet ? 70 : 60,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: isTablet ? 50 : 40),

                      Text(
                        'Iniciar Sesión - Residente',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 28,
                            tablet: 36,
                            desktop: 40,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isTablet ? 15 : 10),
                      Text(
                        'Accede a tu información familiar registrada',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: isTablet ? 50 : 40),

                      Container(
                        padding: EdgeInsets.all(isTablet ? 32 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            isTablet ? 24 : 20,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: isTablet ? 24 : 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 16 : 12,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 20 : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: isTablet ? 24 : 20),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validators.validatePassword,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: isTablet ? 24 : 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: isTablet ? 24 : 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 16 : 12,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 20 : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: isTablet ? 15 : 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 12,
                                          tablet: 14,
                                          desktop: 16,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isTablet ? 24 : 20),

                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 65 : 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: isTablet ? 24 : 20,
                                        width: isTablet ? 24 : 20,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(
                                                context,
                                                mobile: 16,
                                                tablet: 18,
                                                desktop: 20,
                                              ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 30 : 20),

                      // Botón de modo prueba
                      Container(
                        margin: EdgeInsets.only(bottom: isTablet ? 30 : 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _emailController.text = MockAuthService.testEmail;
                            _passwordController.text =
                                MockAuthService.testPassword;
                          },
                          icon: Icon(Icons.science, size: isTablet ? 22 : 18),
                          label: Text(
                            'Usar Credenciales de Prueba',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 20,
                              vertical: isTablet ? 16 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isTablet ? 30 : 25,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterWizardScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Regístrate',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 12,
                                      tablet: 14,
                                      desktop: 16,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
