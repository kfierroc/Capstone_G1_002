import 'package:flutter/material.dart';
import '../../services/supabase_auth_service.dart';
import '../home/home_main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Ingresa tu nombre y apellido';
    }
    return null;
  }

  String? _validateRut(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu RUT';
    }

    String cleanRut = value
        .replaceAll('.', '')
        .replaceAll('-', '')
        .toUpperCase();

    if (cleanRut.length < 8) {
      return 'RUT inválido';
    }

    String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
    String verifier = cleanRut.substring(cleanRut.length - 1);

    if (int.tryParse(rutNumber) == null) {
      return 'RUT inválido';
    }

    int sum = 0;
    int multiplier = 2;

    for (int i = rutNumber.length - 1; i >= 0; i--) {
      sum += int.parse(rutNumber[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }

    int mod = 11 - (sum % 11);
    String calculatedVerifier = mod == 11
        ? '0'
        : mod == 10
        ? 'K'
        : mod.toString();

    if (verifier != calculatedVerifier) {
      return 'RUT inválido';
    }

    return null;
  }

  void _formatRut(String value) {
    String cleanRut = value.replaceAll('.', '').replaceAll('-', '');

    if (cleanRut.isNotEmpty && cleanRut.length > 1) {
      String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
      String verifier = cleanRut.substring(cleanRut.length - 1);

      String formattedNumber = '';
      int counter = 0;
      for (int i = rutNumber.length - 1; i >= 0; i--) {
        if (counter == 3) {
          formattedNumber = '.$formattedNumber';
          counter = 0;
        }
        formattedNumber = rutNumber[i] + formattedNumber;
        counter++;
      }

      String formattedRut = '$formattedNumber-$verifier';

      if (formattedRut != value) {
        _rutController.value = TextEditingValue(
          text: formattedRut,
          selection: TextSelection.collapsed(offset: formattedRut.length),
        );
      }
    }
  }

  String? _validateCompany(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu compañía de bomberos';
    }
    if (value.length < 3) {
      return 'Nombre completo de la compañía';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

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
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Registro exitoso! Bienvenido ${result.user!.email}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            // Navegar al home después del registro exitoso
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // Mostrar error específico con más detalles
            String errorMessage = result.error ?? 'Error al registrar';
            
            // Si es un error de duplicado, mostrar sugerencias
            if (errorMessage.contains('Ya existe un bombero registrado')) {
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 60,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      'Crear cuenta nueva',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Regístrate para acceder al sistema de emergencias',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: _validateFullName,
                            decoration: InputDecoration(
                              labelText: 'Nombre Completo *',
                              hintText: 'Carlos Neira Valenzuela',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _rutController,
                            keyboardType: TextInputType.text,
                            validator: _validateRut,
                            onChanged: _formatRut,
                            decoration: InputDecoration(
                              labelText: 'RUT *',
                              hintText: '12.345.678-9',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _companyController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            validator: _validateCompany,
                            decoration: InputDecoration(
                              labelText: 'Compañía de Bomberos *',
                              hintText: 'Primera Compañía de Santiago',
                              prefixIcon: const Icon(
                                Icons.local_fire_department_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              hintText: 'correo@ejemplo.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
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
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            validator: _validateConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
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
                          const SizedBox(height: 8),

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
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
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
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
            ),
          ),
        ),
      ),
    );
  }
}
